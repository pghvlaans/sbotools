package SBO::Lib::Build;

use 5.016;
use strict;
use warnings;

our $VERSION = '3.2.1';

use SBO::Lib::Util qw/ :const prompt script_error get_sbo_from_loc get_arch check_multilib on_blacklist open_fh uniq save_options wrapsay %config in /;
use SBO::Lib::Tree qw/ get_sbo_location /;
use SBO::Lib::Info qw/ get_sbo_version check_x32 get_requires /;
use SBO::Lib::Download qw/ get_sbo_downloads get_dl_fns get_filename_from_link check_distfiles /;

use Exporter 'import';
use Fcntl qw(F_SETFD F_GETFD);
use File::Copy; # copy() and move()
use File::Path qw/ make_path remove_tree /;
use File::Temp qw/ tempdir tempfile /;
use Tie::File;
use Cwd;

use sigtrap qw/ handler _build_terminated ABRT INT QUIT TERM /;

our @EXPORT_OK = qw{
  do_convertpkg
  do_slackbuild
  do_upgradepkg
  get_build_queue
  get_dc_regex
  get_full_queue
  get_pkg_name
  get_src_dir
  get_tmp_extfn
  make_clean
  make_distclean
  merge_queues
  perform_sbo
  process_sbos
  revert_slackbuild
  rewrite_slackbuild
  run_tee

  $tempdir
  $tmpd
  $env_tmp
};

our %EXPORT_TAGS = (
  all => \@EXPORT_OK,
);

=pod

=encoding UTF-8

=head1 NAME

SBO::Lib::Build - Routines for building Slackware packages from SlackBuilds.org.

=head1 SYNOPSIS

  use SBO::Lib::Build qw/ perform_sbo /;

  my ($foo, $bar, $exit) = perform_sbo(LOCATION => $location, ARCH => 'x86_64');

=head1 VARIABLES

=head2 $env_tmp

This reflects C<$TMP> from the environment, being C<undef> if it is not
set.

=head2 $tmpd

This is the same as C<$TMP> if it is set. Otherwise, it is C</tmp/SBo>.

=head2 $tempdir

This is a temporary directory created for sbotools' use. It should be
removed when sbotools exits.

=cut

# get $TMP from the env, if defined - we use two variables here because there
# are times when we need to know if the environment variable is set, and other
# times where it doesn't matter.
our $env_tmp = $ENV{TMP};
our $tmpd = $env_tmp ? $env_tmp : '/tmp/SBo';
make_path($tmpd) unless -d $tmpd;

our $tempdir = tempdir(CLEANUP => 1, DIR => $tmpd);

=head1 SUBROUTINES

=cut

=head2 do_convertpkg

  my ($name32, $exit) = do_convertpkg($name64);

C<do_convertpkg()> runs C<convertpkg> on the package in C<$name64>.

On success, it returns the name of the converted package and an exit status. On
failure, it returns an error message instead of the package name.

=cut

# run convertpkg on a package to turn it into a -compat32 thing
sub do_convertpkg {
  script_error('do_convertpkg requires an argument.') unless @_ == 1;
  my $pkg = shift;
  my $c32tmpd = $env_tmp // '/tmp';

  my ($out, $ret) = run_tee("/bin/bash -c '/usr/sbin/convertpkg-compat32 -i $pkg -d $c32tmpd'");

  if ($ret != 0) {
    return "convertpkg-compt32 returned non-zero exit status\n",
      _ERR_CONVERTPKG;
  }
  unlink $pkg;
  return get_pkg_name($out);
}

=head2 do_slackbuild

  my ($ver, $pkg, $src, $exit) = do_slackbuild(LOCATION => $location);

C<do_slackbuild()> makes checks and sets up the C<perform_sbo()> call,
running C<do_convertpkg()> if needed.

A list of four values is returned if successful: version number, package name,
an array with source directories and an exit code. In case of failure, the first
value is an error message; the second and third values are empty.

=cut

# "public interface", sort of thing.
sub do_slackbuild {
  my %args = (
    OPTS      => 0,
    JOBS      => 0,
    LOCATION  => '',
    COMPAT32  => 0,
    @_
  );
  $args{LOCATION} or script_error('do_slackbuild requires LOCATION.');
  my $location = $args{LOCATION};
  my $sbo = get_sbo_from_loc($location);
  my $arch = get_arch();
  my $multilib = check_multilib();
  my $version = get_sbo_version($location);
  my $x32;
  # ensure x32 stuff is set correctly, or that we're setup for it
  if ($args{COMPAT32}) {
    unless ($multilib) {
      return "compat32 packages can only be built on multilib systems.\n", (undef) x 2,
        _ERR_NOMULTILIB;
    }
    unless (-f '/usr/sbin/convertpkg-compat32') {
      return "compat32 requires /usr/sbin/convertpkg-compat32.\n",
        (undef) x 2, _ERR_NOCONVERTPKG;
    }
  } else {
    if ($arch eq 'x86_64') {
      $x32 = check_x32 $args{LOCATION};
      if ($x32 && ! $multilib) {
        my $warn =
          "$sbo is 32-bit, which requires multilib on x86_64.\n";
        return $warn, (undef) x 2, _ERR_NOMULTILIB;
      }
    }
  }
  # setup and run the .SlackBuild itself
  my ($pkg, $src, $exit) = perform_sbo(
    OPTS => $args{OPTS},
    JOBS => $args{JOBS},
    LOCATION => $location,
    ARCH => $arch,
    C32 => $args{COMPAT32},
    X32 => $x32,
  );
  return $pkg, (undef) x 2, $exit if $exit;
  if ($args{COMPAT32}) {
    ($pkg, $exit) = do_convertpkg($pkg);
    return $pkg, (undef) x 2, $exit if $exit;
  }
  return $version, $pkg, $src;
}

=head2 do_upgradepkg

  do_upgradepkg($pkg);

C<do_upgradepkg()> runs C<upgradepkg --reinstall --install-new> on C<$pkg>.

There is no useful return value.

=cut

# run upgradepkg for a created package
sub do_upgradepkg {
  script_error('do_upgradepkg requires an argument.') unless @_ == 1;
  system('/sbin/upgradepkg', '--reinstall', '--install-new', shift);
  return 1;
}

=head2 get_build_queue

  my @queue = @{ get_build_queue($sbo, my $warnings) };

C<get_build_queue()> gets the prerequisites for C<$sbo>, updating the
C<$warnings> hash reference with any C<%README%> encountered. It returns the
prerequisites and C<$sbo> in the correct build order.

=cut

sub get_build_queue {
  script_error('get_build_queue requires two arguments.') unless @_ == 2;
  return [ _build_queue(@_) ];
}

=head2 get_dc_regex

  my ($rx, $initial) = get_dc_regex($line);

C<get_dc_regex()> creates a regular expression that should match the filename
given a line with e.g. an untar command. This is returned together with the C<$initial>
character, which starts the filename match.

=cut

# given a line that looks like it's decompressing something, try to return a
# valid filename regex
sub get_dc_regex {
  my $line = shift;
  # get rid of initial 'tar x'whatever stuff
  $line =~ s/^.*(?<![a-z])(tar|p7zip|unzip|ar|rpm2cpio|sh)\s+[^\s]+\s+//;
  # need to know preceeding character - should be safe to assume it's either
  # a slash or a space
  my $initial = $line =~ qr|/| ? '/' : ' ';
  # get rid of initial path info
  $line =~ s|^\$[^/]+/||;
  # convert any instances of command substitution to [^-]+
  $line =~ s/\$\([^)]+\)/[^-]+/g;
  # convert any bash variables to [^-]+
  $line =~ s/\$(\{|)[A-Za-z0-9_]+(}|)/[^-]+/g;
  # get rid of anything excess at the end
  $line =~ s/\s+.*$//;
  # fix .?z* at the end
  $line =~ s/\.\?z\*/\.[a-z]z.*/;
  # return what's left as a regex
  my $regex = qr/$initial$line/;
  return $regex, $initial;
}

=head2 get_pkg_name

  my $name = get_pkg_name($str);

C<get_pkg_name()> searches C<$str> for text matching the package name output
from C<makepkg>. The package name is returned.

=cut

# pull the created package name from the temp file we tee'd to
sub get_pkg_name {
  my $str = shift;

  my ($out) = $str =~ m/^Slackware\s+package\s+([^\s]+)\s+created\.$/m;

  return $out;
}

=head2 get_src_dir

  my @dirs = @{ get_src_dir(@orig_dirs) };

C<get_src_dir()> returns a list of those directories under C</tmp/SBo> or C<$TMP>
that are not in C<@orig_dirs>. That is, the source directories for the script.

=cut

sub get_src_dir {
  my @ls = @_;
  my @src_dirs;
  # scripts use either $TMP or /tmp/SBo
  if (opendir(my $tsbo_dh, $tmpd)) {
    FIRST: while (my $ls = readdir $tsbo_dh) {
      next FIRST if in($ls => qw/ . .. /, qr/^package-/, @ls);
      next FIRST unless -d "$tmpd/$ls";

      push @src_dirs, $ls;
    }
    close $tsbo_dh;
  }
  return \@src_dirs;
}

=head2 get_tmp_extfn

  my ($ret, $exit) = get_tmp_extfn($fh);

C<get_tmp_extfn()> gets the C</dev/fd/X> filename for the file handle C<$fh> passed
in, setting flats to make it usable from other processes.

It returns the filename if successful, and C<undef> otherwise.

=cut

# return a filename from a temp fh for use externally
sub get_tmp_extfn {
  script_error('get_tmp_extfn requires an argument.') unless @_ == 1;
  my $fh = shift;
  unless (fcntl($fh, F_SETFD, 0)) { return undef; }
  return '/dev/fd/'. fileno $fh;
}

=head2 make_clean

  make_clean(SBO => $sbo, SRC => $src, VERSION => $ver);

C<make_clean()> removes source, package and compat32 directories left after running
a SlackBuild.

It has no useful return value.

=cut

# remove work directories (source and packaging dirs under /tmp/SBo or $TMP and /tmp or $OUTPUT)
sub make_clean {
  my %args = (
    SBO      => '',
    SRC      => '',
    VERSION  => '',
    @_
  );
  unless ($args{SBO} && $args{SRC} && $args{VERSION}) {
    script_error('make_clean requires three arguments.');
  }
  my $src = $args{SRC};
  wrapsay "Cleaning for $args{SBO}-$args{VERSION}...";
  for my $dir (@$src) {
    remove_tree("$tmpd/$dir") if -d "$tmpd/$dir";
  }

  my $output = $ENV{OUTPUT} // '/tmp';
  remove_tree("$output/package-$args{SBO}") if
    -d "$output/package-$args{SBO}";

  if ($args{SBO} =~ /^(.+)-compat32$/) {
    my $pkg_name = $1;
    remove_tree("/tmp/package-$args{SBO}") if
      not defined $env_tmp and
      -d "/tmp/package-$args{SBO}";
    remove_tree("$tmpd/package-$pkg_name") if
      -d "$tmpd/package-$pkg_name";
  }
  return 1;
}

=head2 make_distclean

  make_distclean(SRC => $src, VERSION => $ver, LOCATION => $loc);

C<make_distclean()> removes the same directories as C<make_clean()> does,
as well as distribution files, such as the downloaded source tarballs.

It has no useful return value.

=cut

# remove distfiles
sub make_distclean {
  my %args = (
    SRC       => '',
    VERSION   => '',
    LOCATION  => '',
    @_
  );
  unless ($args{SRC} && $args{VERSION} && $args{LOCATION}) {
    script_error('make_distclean requires four arguments.');
  }
  my $sbo = get_sbo_from_loc($args{LOCATION});
  make_clean(SBO => $sbo, SRC => $args{SRC}, VERSION => $args{VERSION});
  wrapsay "Distcleaning for $sbo-$args{VERSION}...";
  # remove any distfiles for this particular SBo.
  my $downloads = get_sbo_downloads(LOCATION => $args{LOCATION});
  for my $key (keys %$downloads) {
    my $filename = get_filename_from_link($key);
    unlink $filename if -f $filename;
  }
  return 1;
}

=head2 merge_queues

  my @merged = @{ merge_queues([@queue1], [@queue2]) };

C<merge_queues()> takes two array references and merges them such that C<@queue1>
is in front, followed by any non-redundant items in C<@queue2>. This is returned
as an array reference.

=cut

sub merge_queues {
  # Usage: merge_queues(\@queue_a, \@queue_b);
  # Results in queue_b being merged into queue_a (without duplicates)
  script_error('merge_queues requires two arguments.') unless @_ == 2;

  return [ uniq @{$_[0]}, @{$_[1]} ];
}

=head2 get_full_queue

  my @revdep_queue = ($installed, @sbos);

C<get_full_queue()> takes a list of installed SlackBuilds and an array
of SlackBuilds to check. It returns a list of reverse dependencies.

=cut

sub get_full_queue {
  my ($installed, @sbos) = @_;

  my $revdep_queue = [];
  my %warnings;
  for my $sbo (@sbos) {
    my $queue = get_build_queue([$sbo], \%warnings);
    @$queue = reverse @$queue;
    $revdep_queue = merge_queues($revdep_queue, $queue);
  }

  return map {; +{
      name => $_,
      pkg => $installed->{$_},
      defined $warnings{$_} ? (warning => $warnings{$_}) : ()
    } }
    grep { exists $installed->{$_} }
    @$revdep_queue;
}

=head2 perform_sbo

  my ($pkg, $src, $exit) = perform_sbo(LOCATION => $location, ARCH => $arch);

C<perform_sbo()> prepares and runs a SlackBuild. It returns the package name,
an array with source directories and an exit code if successful. If unsuccessful,
the first value is instead an error message.

=cut

# prep and run .SlackBuild
sub perform_sbo {
  my %args = (
    OPTS      => 0,
    JOBS      => 0,
    LOCATION  => '',
    ARCH      => '',
    C32       => 0,
    X32       => 0,
    @_
  );
  unless ($args{LOCATION} && $args{ARCH}) {
    script_error('perform_sbo requires LOCATION and ARCH.');
  }

  my $location = $args{LOCATION};
  my $sbo = get_sbo_from_loc($location);

  # we need to get a listing of /tmp/SBo, or $TMP, if we can, before we run
  # the SlackBuild so that we can compare to a listing taken afterward.
  my @src_ls;
  if (opendir(my $tsbo_dh, $tmpd)) {
    @src_ls = grep { ! in( $_ => qw/ . .. /) } readdir $tsbo_dh;
  }

  my ($cmd, %changes);
  # set any changes we need to make to the .SlackBuild, setup the command

  $cmd = '';

  if ($args{ARCH} eq 'x86_64' and ($args{C32} || $args{X32})) {
    if ($args{C32}) {
      $changes{libdirsuffix} = '';
    } elsif ($args{X32}) {
      if (`grep -q "ARCH=i686" $location/$sbo.SlackBuild` == 0) { $changes{arch_out} = 'i686'; }
      elsif (`grep -q "ARCH=i586" $location/$sbo.SlackBuild` == 0) { $changes{arch_out} = 'i586'; }
      elsif (`grep -q "ARCH=i486" $location/$sbo.SlackBuild` == 0) { $changes{arch_out} = 'i486'; }
      elsif (`grep -q "ARCH=x86" $location/$sbo.SlackBuild` == 0) { $changes{arch_out} = 'x86'; }
    }
    $cmd .= '. /etc/profile.d/32dev.sh &&';
  }
  if ($args{JOBS} and $args{JOBS} ne 'FALSE') {
    $changes{jobs} = 1;
  }
  if ($args{OPTS}) {
    save_options($sbo, $args{OPTS});
    $cmd .= " $args{OPTS}";
  }
  $cmd .= " MAKEOPTS=\"-j$args{JOBS}\"" if $changes{jobs};

  # set TMP/OUTPUT if set in the environment
  $cmd .= " TMP=$env_tmp" if $env_tmp;
  $cmd .= " OUTPUT=$ENV{OUTPUT}" if defined $ENV{OUTPUT};
  $cmd .= " /bin/bash $location/$sbo.SlackBuild";

  # attempt to rewrite the slackbuild, or exit if we can't
  my ($fail, $exit) = rewrite_slackbuild(
    SBO => $sbo,
    SLACKBUILD => "$location/$sbo.SlackBuild",
    CHANGES => \%changes,
    C32 => $args{C32},
  );
  return $fail, undef, $exit if $exit;

  # run the slackbuild, grab its exit status, revert our changes
  my $cwd = getcwd();
  chdir $location;
  my ($out, $ret) = run_tee($cmd);
  chdir $cwd;

  revert_slackbuild("$location/$sbo.SlackBuild");
  # return error now if the slackbuild didn't exit 0
  return "$sbo.SlackBuild return non-zero\n", undef, _ERR_BUILD if $ret != 0;
  my $pkg = get_pkg_name($out);
  return "$sbo.SlackBuild didn't create a package\n", undef, _ERR_BUILD if not defined $pkg;
  my $src = get_src_dir(@src_ls);
  return $pkg, $src;
}

=head2 process_sbos

  my (@failures, $exit) = process_sbos(TODO => [@queue]);

C<process_sbos()> processes a C<@queue> of SlackBuilds and returns an array reference
with failed builds and the exit status.

In case of a mass rebuild, C<process_sbos> updates the resume file C<resume.temp>
when a build fails.

=cut

# do the things with the provided sbos - whether upgrades or new installs.
sub process_sbos {
  my %args = (
    TODO       => '',
    CMDS       => '',
    OPTS       => '',
    JOBS       => 'FALSE',
    LOCATIONS  => '',
    NOINSTALL  => 0,
    NOCLEAN    => 'FALSE',
    DISTCLEAN  => 'FALSE',
    NON_INT    => 0,
    MASS       => 0,
    @_
  );
  my $todo = $args{TODO};
  my $cmds = $args{CMDS};
  my $opts = $args{OPTS};
  my $locs = $args{LOCATIONS};
  my $jobs = $args{JOBS} =~ /^\d+$/ ? $args{JOBS} : 0;
  my $mass = $args{MASS};
  @$todo >= 1 or script_error('process_sbos requires TODO.');
  my $mtemp_in = "$config{SBO_HOME}/mass_rebuild.temp";
  my $mtemp_resume = "$config{SBO_HOME}/resume.temp";
  my (@failures, @symlinks, $err);
  FIRST: for my $sbo (@$todo) {
    my $compat32 = $sbo =~ /-compat32$/ ? 1 : 0;
    my ($temp_syms, $exit) = check_distfiles(
      LOCATION => $$locs{$sbo}, COMPAT32 => $compat32
    );
    # if $exit is defined, prompt to proceed or return with last $exit
    if ($exit) {
      $err = $exit;
      my $fail = $temp_syms;
      push @failures, {$sbo => $fail};
      # return now if we're not interactive
      return \@failures, $exit if $args{NON_INT};
      wrapsay "Unable to download/verify source file(s) for $sbo:";
      say "  $fail";
      if (prompt('Do you want to proceed?' , default => 'no')) {
        next FIRST;
      } else {
        unlink for @symlinks;
        return \@failures, $exit;
      }
    } else {
      push @symlinks, @$temp_syms;
    }
  }
  my $count = 0;
  FIRST: for my $sbo (@$todo) {
    $count++;
    my $options = $$opts{$sbo} // 0;
    my $cmds = $$cmds{$sbo} // [];
    for my $cmd (@$cmds) {
      system($cmd) == 0 or warn "\"$cmd\" exited non-zero.\n";
    }
    # switch compat32 on if upgrading/installing a -compat32
    # else make sure compat32 is off
    my $compat32 = $sbo =~ /-compat32$/ ? 1 : 0;
    my ($version, $pkg, $src, $exit) = do_slackbuild(
      OPTS      => $options,
      JOBS      => $jobs,
      LOCATION  => $$locs{$sbo},
      COMPAT32  => $compat32,
    );
    if ($exit) {
      my $fail = $version;
      push @failures, {$sbo => $fail};
      if ($mass and -f $mtemp_in) {
        my ($in_fh, $exit_in) = open_fh($mtemp_in, '<');
        do { warn $in_fh; exit $exit_in } if $exit_in;
        unlink $mtemp_resume if -f $mtemp_resume;
        my ($out_fh, $exit_out) = open_fh($mtemp_resume, '>');
        do { warn $out_fh; exit $exit_out } if $exit_out;
        while(readline($in_fh)) {
          if ($. < 3 or $. > $count + 2) {
            print {$out_fh} $_;
          }
        }
        close $in_fh;
        close $out_fh;
      }
      # return now if we're not interactive
      return \@failures, $exit if $args{NON_INT};
      # or if this is the last $sbo
      return \@failures, $exit if $count == @$todo;
      wrapsay "A failure occurred while building $sbo:";
      say "  $fail";
      if (prompt('Do you want to proceed?', default => 'no')) {
        next FIRST;
      } else {
        unlink for @symlinks;
        return \@failures, $exit;
      }
    }

    do_upgradepkg($pkg) unless $args{NOINSTALL};

    unless ($args{DISTCLEAN}) {
      make_clean(SBO => $sbo, SRC => $src, VERSION => $version)
        unless $args{NOCLEAN};
    } else {
      make_distclean(
        SBO       => $sbo,
        SRC       => $src,
        VERSION   => $version,
        LOCATION  => $$locs{$sbo},
      );
    }
    # move package to $config{PKG_DIR} if defined
    unless ($config{PKG_DIR} eq 'FALSE') {
      my $dir = $config{PKG_DIR};
      unless (-d $dir) {
        mkdir($dir) or warn "Unable to create $dir.\n";
      }
      if (-d $dir) {
        move($pkg, $dir), wrapsay "$pkg stored in $dir.";
      } else {
        warn "$pkg left in $tmpd.\n";
      }
    } elsif ($args{DISTCLEAN}) {
      unlink $pkg;
    }
  }
  unlink $mtemp_resume if $mass and -f $mtemp_resume;
  unlink for @symlinks;
  return \@failures, $err;
}

=head2 revert_slackbuild

  revert_slackbuild($path);

C<revert_slackbuild()> restores a SlackBuild rewritten by
C<rewrite_slackbuild()>.

There is no useful return value.

=cut

# move a backed-up .SlackBuild file back into place
sub revert_slackbuild {
  script_error('revert_slackbuild requires an argument.') unless @_ == 1;
  my $slackbuild = shift;
  if (-f "$slackbuild.orig") {
    unlink $slackbuild if -f $slackbuild;
    rename "$slackbuild.orig", $slackbuild;
  }
  return 1;
}

=head2 rewrite_slackbuild

  my ($ret, $exit) = rewrite_slackbuild(%args);

C<rewrite_slackbuild()>, when given an argument hash, copies the SlackBuild
at C<$path> and rewrites it with the needed changes. The required arguments include
C<SBO> (the name of the script), C<SLACKBUILD> (the location of the unaltered
SlackBuild), C<CHANGES> (the required changes) and C<C32> (0 if the build is not
compat32, and 1 if it is).

On failure, an error message and the exit status are returned. On success, 1 and an exit
status of 0 are returned.

=cut

# make a backup of the existent SlackBuild, and rewrite the original as needed
sub rewrite_slackbuild {
  my %args = (
    SBO         => '',
    SLACKBUILD  => '',
    CHANGES     => {},
    C32         => 0,
    @_
  );
  $args{SLACKBUILD} or script_error('rewrite_slackbuild requires SLACKBUILD.');
  my $slackbuild = $args{SLACKBUILD};
  my $changes = $args{CHANGES};

  # $status will be undefined if either the rename or the copy fails, otherwise it will be 1
  my $status = eval {
    rename($slackbuild, "$slackbuild.orig") or die "not ok";
    copy("$slackbuild.orig", $slackbuild) or die "not ok";
    1;
  };
  if (not $status) {
    rename "$slackbuild.orig", $slackbuild if not -f $slackbuild;
    return "Unable to backup $slackbuild to $slackbuild.orig\n",
      _ERR_OPENFH;
  }

  my $libdir_regex = qr/^\s*LIBDIRSUFFIX="64"\s*$/;
  my $arch_regex = qr/\$VERSION-\$ARCH-\$BUILD/;
  my $dc_regex = qr/(?<![a-z])(tar|p7zip|unzip|ar|rpm2cpio|sh)\s+/;
  my $make_regex = qr/^\s*make\s*$/;
  # tie the slackbuild, because this is the easiest way to handle this.
  tie my @sb_file, 'Tie::File', $slackbuild;
  # if we're dealing with a compat32, we need to change the tar line(s) so
  # that the 32-bit source is untarred
  if ($args{C32}) {
    my $location = get_sbo_location($args{SBO});
    my $downloads = get_sbo_downloads(
      LOCATION => $location,
      32 => 1,
    );
    my $fns = get_dl_fns([keys %$downloads]);
    for my $line (@sb_file) {
      if ($line =~ $dc_regex) {
        my ($regex, $initial) = get_dc_regex($line);
        for my $fn (@$fns) {
          $fn = "$initial$fn";
          $line =~ s/$regex/$fn/ if $fn =~ $regex;
        }
      }
    }
  }
  for my $line (@sb_file) {
    # then check for and apply any other %$changes
    if (exists $$changes{libdirsuffix}) {
      $line =~ s/64/$$changes{libdirsuffix}/ if $line =~ $libdir_regex;
    }
    if (exists $$changes{arch_out}) {
      $line =~ s/\$ARCH/$$changes{arch_out}/ if $line =~ $arch_regex;
    }
    if (exists $changes->{jobs}) {
      $line =~ s/make/make \$MAKEOPTS/ if $line =~ $make_regex;
    }
  }
  untie @sb_file;
  return 1;
}

=head2 run_tee

  my ($output, $exit) = run_tee($cmd);

C<run_tee()> runs C<$cmd> under C<tee(1)> to display STDOUT and return it as
a string. The second return value is the exit status.

If the bash interpreter cannot be run, the first return value is C<undef> and
the exit status holds a non-zero value.

=cut

sub run_tee {
  my $cmd = shift;

  my $out_fh = tempfile(DIR => $tempdir);
  my $out_fn = get_tmp_extfn($out_fh);
  return undef, _ERR_F_SETFD if not defined $out_fn;

  my $exit_fh = tempfile(DIR => $tempdir);
  my $exit_fn = get_tmp_extfn($exit_fh);
  return undef, _ERR_F_SETFD if not defined $exit_fn;

  $cmd = sprintf '( %s; echo $? > %s ) | tee %s', $cmd, $exit_fn, $out_fn;

  my $ret = system('/bin/bash', '-c', $cmd);

  return undef, $ret if $ret;

  seek $exit_fh, 0, 0;
  chomp($ret = readline $exit_fh);

  seek $out_fh, 0, 0;
  my $out = do { local $/; readline $out_fh; };

  return $out, $ret;
}

=head1 AUTHORS

SBO::Lib was originally written by Jacob Pipkin <j@dawnrazor.net> with
contributions from Luke Williams <xocel@iquidus.org> and Andreas
Guldstrand <andreas.guldstrand@gmail.com>.

SBO::Lib is maintained by K. Eugene Carlson <kvngncrlsn@gmail.com>.

=head1 LICENSE

The sbotools are licensed under the MIT License.

Copyright (C) 2012-2017, Jacob Pipkin, Luke Williams, Andreas Guldstrand.

Copyright (C) 2024, K. Eugene Carlson.

=cut

sub _build_terminated {
  remove_tree("$tempdir");
  exit _ERR_INST_SIGNAL;
}  

sub _build_queue {
  my ($sbos, $warnings) = @_;
  my @queue;
  for my $cand (@$sbos) { push @queue, $cand if not on_blacklist($cand); }
  my @result;

  while (my $sbo = shift @queue) {
    next if $sbo eq "%README%";
    my $reqs = get_requires($sbo);
    if (defined $reqs) {
      push @result, _build_queue($reqs, $warnings);
      foreach my $req (@$reqs) {
        $warnings->{$sbo}="%README%" if $req eq "%README%";
      }
    }
    else {
      $warnings->{$sbo} = "nonexistent";
    }
    push @result, $sbo;
  }

  return uniq @result;
}

1;
