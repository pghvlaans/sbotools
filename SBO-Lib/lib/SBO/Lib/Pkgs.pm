package SBO::Lib::Pkgs;

# vim: ts=2:et

use 5.016;
use strict;
use warnings;

our $VERSION = '4.1.2';

use SBO::Lib::Util qw/ :config :const build_cmp in script_error error_code open_read version_cmp /;
use SBO::Lib::Tree qw/ get_sbo_location is_local /;
use SBO::Lib::Info qw/ get_orig_build_number get_orig_version get_sbo_build_number get_sbo_version /;

use Exporter 'import';
use POSIX 'strftime';

use sigtrap qw/ handler _caught_signal ABRT INT QUIT TERM /;

our @EXPORT_OK = qw{
  get_available_updates
  get_inst_names
  get_installed_cpans
  get_installed_packages
  get_local_outdated_versions
  get_removed_builds
  $perl_pkg
  $ruby_pkg
};

our %EXPORT_TAGS = (
  all => \@EXPORT_OK,
);

my ($all_pkgs, $std_pkgs, $sbo_pkgs, $dirty_pkgs);
our ($perl_pkg, $ruby_pkg);

=pod

=encoding UTF-8

=head1 NAME

SBO::Lib::Pkgs - Routines for interacting with the Slackware package database.

=head1 SYNOPSIS

  use SBO::Lib::Pkgs qw/ get_installed_packages /;

  my @installed_sbos = get_installed_packages('SBO');

=cut

=head1 VARIABLES

=cut

=head2 $perl_pkg

The file name of the installed C<perl> package.

=cut

=head2 $ruby_pkg

The file name of the installed C<ruby> package.

=cut

=head1 SUBROUTINES

=cut

=head2 get_available_updates

  my @updates = @{ get_available_updates() };

C<get_available_updates()> compares version and build number information for
packages installed with the _SBo tag with the local repository. It returns
an array reference to an array of hash references specifying package names,
installed versions and available versions.

=cut

# for each installed sbo, find out whether or not the version or build number in
# the tree is newer, and compile an array of hashes containing those which are.
# Takes BUILD for build number only, VERS for version only and BOTH for both
sub get_available_updates {
    script_error('get_available_updates requires an argument.') unless @_ == 1;

    my $filter = shift;
    my @updates;
    my $pkg_list = get_installed_packages('SBO');

    for my $pkg (@$pkg_list) {
        my $location = get_sbo_location($pkg->{name});
        next unless $location;

        my $version = get_sbo_version($location);
        next unless $version;
        my $bump = get_sbo_build_number($location);
        next unless $bump;
        my $version_needed;
        my $build_needed;
        if ($config{STRICT_UPGRADES} eq 'TRUE' and not is_local($pkg->{name})) {
            $version_needed = version_cmp($version, $pkg->{version}) > 0;
            $build_needed = build_cmp($bump, $pkg->{numbuild}, $version, $pkg->{version}) > 0;
        } else {
            $version_needed = version_cmp($version, $pkg->{version}) != 0;
            $build_needed = build_cmp($bump, $pkg->{numbuild}, $version, $pkg->{version}) != 0;
        }
        if ($filter eq 'VERS') {
            if ($version_needed) {
                push @updates, { name => $pkg->{name}, installed => $pkg->{version}, build => $pkg->{numbuild}, update => $version };
            }
        } elsif ($filter eq 'BUILD') {
          if ($build_needed) {
                push @updates, { name => $pkg->{name}, installed => $pkg->{version}, build => $pkg->{numbuild}, update => $version, bump => $bump };
            }
        } else {
            if ($version_needed or $build_needed) {
                push @updates, { name => $pkg->{name}, installed => $pkg->{version}, build => $pkg->{numbuild}, update => $version, bump => $bump };
            }
        }
    }
    return \@updates;
}

=head2 get_inst_names

  my @names = get_inst_names(get_available_updates());

C<get_inst_names()> returns a list of package names from an array reference, such
as one returned by C<get_available_updates()>.

=cut

# for a ref to an array of hashes of installed packages, return an array ref
# consisting of just their names
sub get_inst_names {
    script_error('get_inst_names requires an argument.') unless @_ == 1;
    my $inst = shift;
    my @installed;
    push @installed, $$_{name} for @$inst;
    return \@installed;
}

=head2 get_installed_cpans

  my (@mods, @defective) = @{ get_installed_cpans() };

C<get_installed_cpans()> returns an array reference to a list of Perl
modules installed from the CPAN and a second array with installed modules
that have missing files. Modules are only fully recognized as installed if all
files in C<.packlist> exist. This is used in C<sboinstall(1)> and
C<sboupgrade(1)> to prevent conflicting installations from the CPAN and
SlackBuilds.

=cut

# return a list of perl modules installed via the CPAN
sub get_installed_cpans {
  my $libdirsuffix = $arch =~ m/64(-|$)/ ? "64" : "";
  my $auto_location = "/usr/local/lib$libdirsuffix/perl5/auto";
  my @contents;
  for my $file (grep { -f $_ } map { "$_/perllocal.pod" } @INC) {
    my ($fh, $exit) = open_read($file);
    next if $exit;
    push @contents, grep {/Module/} <$fh>;
    close $fh;
  }
  my $mod_regex = qr/C<Module>\s+L<([^\|]+)/;
  my (@mods, @defective);
  FIRST: for my $line (@contents) {
    my ($missing, $present);
    my $modname = ($line =~ $mod_regex)[0];
    my $dirname = $modname;
    $dirname =~ s/::/\//g;
    my $packlist = "$auto_location/$dirname/.packlist";
    if (-f $packlist) {
      my ($pfh, $pfexit) = open_read($packlist);
      next FIRST if $pfexit;
      for my $pfline (<$pfh>) {
        $pfline =~ s/\n//;
        unless (-f $pfline or -l $pfline) {
          $missing = 1;
        } else {
          $present = 1;
        }
      }
      unless ($missing) {
        push @mods, $modname;
      } elsif ($present) {
        push @defective, $modname;
      }
      close $pfh;
    }
  }
  return (\@mods, \@defective);
}

=head2 get_installed_packages

  my @packages = @{ get_installed_packages($type, $clear) };

C<get_installed_packages()> returns an array reference to a list of installed packages
matching the specified C<$type>. The available types are C<STD> for non-SBo packages,
C<SBO> for in-tree _SBo and _SBocompat32 packages, C<DIRTY> for out-of-tree _SBo packages
and C<ALL> for all.

The returned array reference holds a list of hash references representing the names,
versions, full installed package names and creation times of the returned packages.

The default behavior is to retain the package lists for future calls; add a true value
to the arguments to clear them instead. This is irrelevant when running C<sbotest>.

The C<perl> and C<ruby> package file names are found at this time.

=cut

# pull an array of hashes, each hash containing the name and version of a
# package currently installed. Gets filtered using STD, SBO, DIRTY or ALL.
sub get_installed_packages {
  script_error('get_installed_packages requires at least one argument.') unless @_ ge 1;
  my ($filter, $clear) = @_;
  if ($clear) { $all_pkgs = ""; $std_pkgs = ""; $sbo_pkgs = ""; $dirty_pkgs = ""; }
  unless ($is_sbotest) {
    return $all_pkgs if ($filter eq "ALL" and $all_pkgs);
    return $std_pkgs if ($filter eq "STD" and $std_pkgs);
    return $sbo_pkgs if ($filter eq "SBO" and $sbo_pkgs);
    return $dirty_pkgs if ($filter eq "DIRTY" and $dirty_pkgs);
  }

  # Valid types: STD, SBO, DIRTY
  my (@pkgs, %types);
  foreach my $pkg (glob("$pkg_db/*")) {
    $pkg =~ s!^\Q$pkg_db/\E!!;
    my ($name, $version, $build) = $pkg =~ m#^([^/]+)-([^-]+)-[^-]+-([^-]+)$#
      or next;
    $perl_pkg = $pkg if $name eq "perl";
    $ruby_pkg = $pkg if $name eq "ruby";
    my $numbuild = $build;
    $numbuild =~ s/_SBo(|compat32)$//g ;
    my $created = strftime "%F, %H:%M:%S", localtime((stat "$pkg_db/$pkg")[10]);
    push @pkgs, { name => $name, version => $version, build => $build, numbuild => $numbuild, pkg => $pkg, created => $created };
    $types{$name} = 'STD';
  }

  $all_pkgs = [ map { +{ name => $_->{name}, version => $_->{version}, build=> $_->{build}, numbuild => $_->{numbuild}, pkg => $_->{pkg}, created => $_->{created} } } @pkgs ];

  # SlackBuilds with locations can be marked with SBO, and packages with
  # the _SBo tag but no location can be marked with DIRTY
  my @sbos = map { $_->{name} } grep { $_->{build} =~ m/_SBo(|compat32)$/ }
    @pkgs;
  if (@sbos) {
    foreach my $sbo (@sbos) {
      $types{$sbo} = 'DIRTY';
      if (defined get_sbo_location($sbo =~ s/-compat32//gr)) {
         $types{$sbo} = 'SBO';
      }
    }
  }

  $std_pkgs = [ map { +{ name => $_->{name}, version => $_->{version}, build => $_->{build}, numbuild => $_->{numbuild}, pkg => $_->{pkg}, created => $_->{created} } }
    grep { $types{$_->{name}} eq "STD" } @pkgs ];

  $sbo_pkgs = [ map { +{ name => $_->{name}, version => $_->{version}, build => $_->{build}, numbuild => $_->{numbuild}, pkg => $_->{pkg}, created => $_->{created} } }
    grep { $types{$_->{name}} eq "SBO" } @pkgs ];

  $dirty_pkgs = [ map { +{ name => $_->{name}, version => $_->{version}, build => $_->{build}, numbuild => $_->{numbuild}, pkg => $_->{pkg}, created => $_->{created} } }
    grep { $types{$_->{name}} eq "DIRTY" } @pkgs ];

return $all_pkgs if $filter eq "ALL";
return $std_pkgs if $filter eq "STD";
return $sbo_pkgs if $filter eq "SBO";
return $dirty_pkgs if $filter eq "DIRTY";
}

=head2 get_local_outdated_versions

  my @outdated = get_local_outdated_versions($filter);

C<get_local_outdated_versions()> checks installed SBo packages from C<LOCAL_OVERRIDES>.
It returns an array with information about those that have version or build numbers
differing from the local repository or the SlackBuild in C<LOCAL_OVERRIDES>.

This subroutine is used only by C<sbocheck(1)>.

=cut

sub get_local_outdated_versions {
  script_error('get_local_outdated_versions requires an argument.') unless @_ == 1;
  my $filter = shift;
  my @outdated;

  my $local = $config{LOCAL_OVERRIDES};
  unless ( $local eq 'FALSE' or not -d $local ) {
    my $pkglist = get_installed_packages('SBO');
    my @local = grep { is_local($_->{name}) } @$pkglist;

    foreach my $sbo (@local) {
      my $local_location = get_sbo_location($sbo->{name});
      next unless defined $local_location;
      my $orig = get_orig_version($sbo->{name});
      next unless defined $orig;
      my $orig_build_number = get_orig_build_number($sbo->{name});
      my $local_build_number = get_sbo_build_number($local_location);

      if ($filter eq 'VERS') {
        next unless version_cmp($orig, $sbo->{version});
      } elsif ($filter eq 'BUILD' and defined $local_build_number) {
        unless (build_cmp($local_build_number, $sbo->{numbuild}, $orig, $sbo->{version})) {
          next;
        }
      } elsif ($filter eq 'BOTH' and defined $local_build_number) {
        unless (build_cmp($local_build_number, $sbo->{numbuild}, $orig, $sbo->{version}) && not version_cmp($orig, $sbo->{version})) {
          next;
        }
      } else { next; }

      if (defined $orig_build_number and defined $local_build_number) {
        push @outdated, { %$sbo, orig => $orig, intree => $orig_build_number, bump => $local_build_number };
      } else {
        push @outdated, { %$sbo, orig => $orig };
      }
    }
  }

  return @outdated;
}

=head2 get_removed_builds

  my @removed = get_removed_builds();

C<get_removed_builds()> returns an array of SlackBuild names and versions of all out-of-tree
installed packages marked C<_SBo>.

This subroutine is used only by C<sbocheck(1)>.

=cut

# For each installed SlackBuild, find out whether it still exists in the tree
sub get_removed_builds {
    my @removed;
    my $pkg_list = get_installed_packages('DIRTY');

    for my $pkg (@$pkg_list) {
        push @removed, { name => $pkg->{name}, installed => $pkg->{version} };
    }

    return \@removed;
}

=head1 EXIT CODES

Pkgs.pm subroutines can return the following exit codes:

  _ERR_SCRIPT        2   script or module bug
  _ERR_OPENFH        6   failure to open file handles

=head1 SEE ALSO

SBO::Lib(3), SBO::Lib::Build(3), SBO::Lib::Download(3), SBO::Lib::Info(3), SBO::Lib::Readme(3), SBO::Lib::Repo(3), SBO::Lib::Solibs(3), SBO::Lib::Tree(3), SBO::Lib::Util(3)

=head1 AUTHORS

SBO::Lib was originally written by Jacob Pipkin <j@dawnrazor.net> with
contributions from Luke Williams <xocel@iquidus.org> and Andreas
Guldstrand <andreas.guldstrand@gmail.com>.

=head1 MAINTAINER

SBO::Lib is maintained by K. Eugene Carlson <kvngncrlsn@gmail.com>.

=head1 LICENSE

The sbotools are licensed under the MIT License.

Copyright (C) 2012-2017, Jacob Pipkin, Luke Williams, Andreas Guldstrand.

Copyright (C) 2024-2025, K. Eugene Carlson.

=cut

sub _caught_signal {
  exit 0;
}

1;
