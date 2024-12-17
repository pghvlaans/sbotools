package SBO::Lib::Util;

use 5.016;
use strict;
use warnings;

our $VERSION = '3.1';

use Exporter 'import';
use File::Copy;
use Sort::Versions;

my $consts;
use constant $consts = {
  _ERR_USAGE         => 1,   # usage errors
  _ERR_SCRIPT        => 2,   # errors with the scripts themselves
  _ERR_BUILD         => 3,   # errors during the slackbuild process
  _ERR_MD5SUM        => 4,   # md5sum verification
  _ERR_DOWNLOAD      => 5,   # errors with downloading things
  _ERR_OPENFH        => 6,   # opening file handles
  _ERR_NOINFO        => 7,   # missing information
  _ERR_F_SETFD       => 8,   # unsetting exec-on-close bit
  _ERR_NOMULTILIB    => 9,   # lacking multilib where required
  _ERR_CONVERTPKG    => 10,  # errors while running convertpkg-compat32
  _ERR_NOCONVERTPKG  => 11,  # lacking convertpkg-compat32 where required
};

my @EXPORT_CONSTS = keys %$consts;
my @EXPORT_CONFIG = qw{
  read_config

  $conf_dir
  $conf_file
  %config
};

our @EXPORT_OK = (
  qw{
    build_cmp
    check_multilib
    get_arch
    get_kernel_version
    get_optional
    get_sbo_from_loc
    get_slack_branch
    get_slack_version
    get_slack_version_url
    idx
    in
    indent
    on_blacklist
    open_fh
    open_read
    print_failures
    prompt
    save_options
    script_error
    show_version
    slurp
    uniq
    usage_error
    version_cmp
  },
  @EXPORT_CONSTS,
  @EXPORT_CONFIG,
);

our %EXPORT_TAGS = (
  all => \@EXPORT_OK,
  const => \@EXPORT_CONSTS,
  config => \@EXPORT_CONFIG,
);

=pod

=encoding UTF-8

=head1 NAME

SBO::Lib::Util - Utility functions for SBO::Lib and the sbotools

=head1 SYNOPSIS

  use SBO::Lib::Util qw/uniq/;

  # ('duplicate');
  my @uniq = uniq('duplicate', 'duplicate');

=head1 VARIABLES

=head2 $conf_dir

By default, C<$conf_dir> will be C</etc/sbotools>.

=head2 $conf_file

By default, C<$conf_file> will be C</etc/sbotools/sbotools.conf>.

=head2 %config

By default, all values are set to C<"FALSE">, but when C<read_config()> is run,
the values will change according to the configuration, and C<SBO_HOME> will by
default get changed to C</usr/sbo>.

The supported keys are: C<NOCLEAN>, C<DISTCLEAN>, C<JOBS>, C<PKG_DIR>,
C<SBO_HOME>, C<LOCAL_OVERRIDES>, C<SLACKWARE_VERSION>, C<REPO>, C<BUILD_IGNORE>
and C<RSYNC_DEFAULT>.

=cut

# global config variables
our $conf_dir = '/etc/sbotools';
our $conf_file = "$conf_dir/sbotools.conf";
our %config = (
  CLASSIC => 'FALSE',
  NOCLEAN => 'FALSE',
  DISTCLEAN => 'FALSE',
  JOBS => 'FALSE',
  PKG_DIR => 'FALSE',
  SBO_HOME => 'FALSE',
  LOCAL_OVERRIDES => 'FALSE',
  SLACKWARE_VERSION => 'FALSE',
  REPO => 'FALSE',
  BUILD_IGNORE => 'FALSE',
  GIT_BRANCH => 'FALSE',
  RSYNC_DEFAULT => 'FALSE',
  GPG_VERIFY => 'FALSE',
);

read_config();

# The hints file should be read in once and only once.
our @listings = read_hints();

=head1 SUBROUTINES

=cut

=head2 check_multilib

  my $ml = check_multilib();

C<check_multilib()> checks if the file C</etc/profile.d/32dev.sh> exists,
because without it, there's no way to build 32bit things on an x64 arch.

Returns a true value if it exists, and a false value otherwise.

=cut

# can't do 32-bit on x86_64 without this file, so we'll use it as the test to
# to determine whether or not an x86_64 system is setup for multilib
sub check_multilib {
  return 1 if -f '/etc/profile.d/32dev.sh';
  return();
}

=head2 get_arch

  my $arch = get_arch();

C<get_arch()> returns the current machine architechture as reported by C<uname
-m>.

=cut

sub get_arch {
  chomp(my $arch = `uname -m`);
  return $arch;
}

=head2 get_kernel_version

  my $kv = get_kernel_version();

C<get_kernel_version()> will check what the version of the currently running
kernel is and return it in a format suitable for appending to a slackware
package version.

=cut

sub get_kernel_version {
  state $kv;
  return $kv if defined $kv;

  chomp($kv = `uname -r`);
  $kv =~ s/-/_/g;
  return $kv;
}

=head2 get_sbo_from_loc

  my $sbo = get_sbo_from_loc($location);

C<get_sbo_from_loc()> gets the package name from the C<$location> passed in
and returns it.

=cut

# pull the sbo name from a $location: $repo_path/system/wine, etc.
sub get_sbo_from_loc {
  script_error('get_sbo_from_loc requires an argument.') unless @_ == 1;
  return (shift =~ qr#/([^/]+)$#)[0];
}

=head2 get_slack_version

  my $version = get_slack_version();

C<get_slack_version()> checks which version of the SBo repository to use and if
successful, returns it.

If there is an error in getting the slackware version, or if it's not a
supported version, an error message will be shown on STDERR, and the program
will exit.

=cut

# %supported maps what's in /etc/slackware-version to an https URL, or to an
# rsync URL if RSYNC_DEFAULT is true. Git commit verification is unavailable
# prior to Slackware 14.2, so prior versions have rsync as well.
my %supported = (
  '14.0' => 'rsync://slackbuilds.org/slackbuilds/14.0/',
  '14.1' => 'rsync://slackbuilds.org/slackbuilds/14.1/',
  '14.2' => 'https://gitlab.com/SlackBuilds.org/slackbuilds.git',
  '15.0' => 'https://gitlab.com/SlackBuilds.org/slackbuilds.git',
  '15.0+' => 'https://github.com/Ponce/slackbuilds.git',
  '15.1' => 'https://gitlab.com/SlackBuilds.org/slackbuilds.git',
  '15.1+' => 'https://github.com/Ponce/slackbuilds.git',
  current => 'https://github.com/Ponce/slackbuilds.git',
);

if ($config{RSYNC_DEFAULT} eq 'TRUE') {
  %supported = (
    '14.0' => 'rsync://slackbuilds.org/slackbuilds/14.0/',
    '14.1' => 'rsync://slackbuilds.org/slackbuilds/14.1/',
    '14.2' => 'rsync://slackbuilds.org/slackbuilds/14.2/',
    '15.0' => 'rsync://slackbuilds.org/slackbuilds/15.0/',
    '15.0+' => 'https://github.com/Ponce/slackbuilds.git',
    '15.1' => 'rsync://slackbuilds.org/slackbuilds/15.1/',
    '15.1+' => 'https://github.com/Ponce/slackbuilds.git',
    current => 'https://github.com/Ponce/slackbuilds.git',
  );
}

my %branch = (
  '14.0' => '14.0',
  '14.1' => '14.1',
  '14.2' => '14.2',
  '15.0' => '15.0',
  '15.1' => '15.1',
);

sub get_slack_version {
  my $version;
  $version = $config{SLACKWARE_VERSION} unless $config{SLACKWARE_VERSION} eq 'FALSE';
  if (not $version) {
    my ($fh, $exit) = open_read('/etc/slackware-version');
    if ($exit) {
      warn $fh;
      exit $exit;
    }
    chomp(my $line = <$fh>);
    close $fh;
    $version = ($line =~ /\s+(\d+[^\s]+)$/)[0];
  }
  usage_error("\nThe running or configured Slackware version is unsupported: $version\n" .
    "Consider running \"sboconfig -r $supported{current}\" to\n" .
    "use a repository for -current.\n")
    unless $supported{$version};
  return $version;
}

=head2 get_slack_version_url

  my $url = get_slack_version_url();

C<get_slack_version_url()> returns the default URL for the given slackware
version.

If there is an error in getting the URL, or if it's not a supported version,
an error message will be shown on STDERR, and the program will exit.

=cut

sub get_slack_version_url {
  my $version = get_slack_version();
  return $supported{$version} unless $version eq "15.1";
  my $exists = system(qw! git ls-remote --exit-code https://gitlab.com/SlackBuilds.org/slackbuilds.git --heads origin 15.1 !) == 0;
  return $supported{$version} if $exists;
  return $supported{current};
}

=head2 get_slack_branch

  my $url = get_slack_branch();

C<get_slack_branch()> returns the default git branch for the given slackware
version, if any. If the pulled repository does not have this branch, an onscreen
message will appear.

=cut

sub get_slack_branch {
  return $branch{get_slack_version()};
}

=head2 idx

  my $idx = idx($needle, @haystack);

C<idx()> looks for C<$needle> in C<@haystack>, and returns the index of where
it was found, or C<undef> if it wasn't found.

=cut

sub idx {
  for my $idx (1 .. $#_) {
    $_[0] eq $_[$idx] and return $idx - 1;
  }
  return undef;
}

=head2 in

  my $found = in($needle, @haystack);

C<in()> looks for C<$needle> in C<@haystack>, and returns a true value if it
was found, and a false value otherwise.

=cut

# Checks if the first argument equals any of the subsequent ones
sub in {
  my ($first, @rest) = @_;
  foreach my $arg (@rest) {
    return 1 if ref $arg eq 'Regexp' and $first =~ $arg;
    return 1 if $first eq $arg;
  }
  return 0;
}

=head2 indent

  my $str = indent($indent, $text);

C<indent()> indents every non-empty line in C<$text> C<$indent> spaces and
returns the resulting string.

=cut

sub indent {
  my ($indent, $text) = @_;
  return $text unless $indent;

  my @lines = split /\n/, $text;
  foreach my $line (@lines) {
    next unless length($line);
    $line = (" " x $indent) . $line;
  }
  return join "\n", @lines;
}

=head2 open_fh

  my ($ret, $exit) = open_fh($fn, $op);

C<open_fh()> will open C<$fn> for reading and/or writing depending on what
C<$op> is.

It returns a list of two values. The second value is the exit status, and if it
is true, the first value will be an error message. Otherwise it will be the
opened filehandle.

=cut

# sub for opening files, second arg is like '<','>', etc
sub open_fh {
  script_error('open_fh requires two arguments') unless @_ == 2;
  unless ($_[1] eq '>') {
      -f $_[0] or script_error("open_fh, $_[0] is not a file");
  }
  my ($file, $op) = @_;
  my $fh;
  _race::cond('$file could be deleted between -f test and open');
  unless (open $fh, $op, $file) {
    my $warn = "Unable to open $file.\n";
    my $exit = _ERR_OPENFH;
    return ($warn, $exit);
  }
  return $fh;
}

=head2 open_read

  my ($ret, $exit) = open_read($fn);

C<open_read()> will open C<$fn> for reading.

It returns a list of two values. The second value is the exit status, and if it
is true, the first value will be an error message. Otherwise it will be the
opened filehandle.

=cut

sub open_read {
  return open_fh(shift, '<');
}

=head2 print_failures

  print_failures($failures);

C<print_failures()> prints all the failures in the C<$failures> array reference
to STDERR if any.

There is no useful return value.

=cut

# subroutine to print out failures
sub print_failures {
  my $failures = shift;
  if (@$failures > 0) {
    warn "Failures:\n";
    for my $failure (@$failures) {
      warn "  $_: $$failure{$_}" for keys %$failure;
    }
  }
}

=head2 prompt

  exit unless prompt "Should we continue?", default => "yes";

C<prompt()> prompts the user for an answer, optionally specifying a default of
C<yes> or C<no>. If the default has been specified it returns a true value in
case 'yes' was selected, and a false value if 'no' was selected. Otherwise it
returns whatever the user answered.

=cut

sub prompt {
  my ($q, %opts) = @_;
  my $def = $opts{default};
  $q = sprintf '%s [%s] ', $q, $def eq 'yes' ? 'y' : 'n' if defined $def;

  print $q;

  my $res = readline STDIN;

  if (defined $def) {
    return 1 if $res =~ /^y/i;
    return 0 if $res =~ /^n/i;
    return $def eq 'yes' if $res =~ /^\n/;

    # if none of the above matched, we ask again
    goto &prompt;
  }
  return $res;
}

=head2 read_config

  read_config();

C<read_config()> reads in the configuration settings from
C</etc/sbotools/sbotools.conf> and updates the C<%config> hash with them.
Additionally, tun on BUILD_IGNORE and RSYNC_DEFAULT if CLASSIC is TRUE.

There is no useful return value.

=cut

# subroutine to suck in config in order to facilitate unit testing
sub read_config {
  my $text = slurp($conf_file);
  if (defined $text) {
    my %conf_values = $text =~ /^(\w+)=(.*)$/mg;
    for my $key (keys %config) {
      $config{$key} = $conf_values{$key} if exists $conf_values{$key};
    }
    $config{JOBS} = 'FALSE' unless $config{JOBS} =~ /^\d+$/;
  } else {
    warn "Unable to open $conf_file.\n" if -f $conf_file;
  }
  if ($config{CLASSIC} eq "TRUE") {
    $config{BUILD_IGNORE} = "TRUE";
    $config{RSYNC_DEFAULT} = "TRUE";
  }
  $config{SBO_HOME} = '/usr/sbo' if $config{SBO_HOME} eq 'FALSE';
}

=head2 save_options

  save_options($sbo, $opts)

save_options() will save build options to /var/log/sbotools/sbo.

=cut

sub save_options {
  my $sbo = shift;
  my $args = shift;
  my $argdir = "/var/log/sbotools";
  my $logfile = "$argdir/$sbo";

  if(! -d $argdir) { mkdir $argdir; }
  if(-f $logfile) { move($logfile, "$logfile.bk"); }
  my ($args_fh, $exit) = open_fh($logfile, '>');
  if ($exit) {
    warn $args_fh;
    move("$logfile.bk", $logfile);
    return 0;
  } else {
    print $args_fh $args;
    close $args_fh;
    if (-f "$logfile.bk") { unlink("$logfile.bk"); }
    if ($config{CLASSIC} ne "TRUE") {
      say "\nA copy of the build options has been saved to $logfile.";
    }
  }
  return 1;
}

=head2 script_error

  script_error();
  script_error($msg);

script_error() will warn and exit, saying on STDERR

  A fatal script error has occurred. Exiting.

If there was a $msg supplied, it will instead say

  A fatal script error has occurred:
  $msg.
  Exiting.

There is no useful return value.

=cut

# subroutine for throwing internal script errors
sub script_error {
  if (@_) {
    warn "A fatal script error has occurred:\n$_[0]\nExiting.\n";
  } else {
    warn "A fatal script error has occurred. Exiting.\n";
  }
  exit _ERR_SCRIPT;
}

=head2 show_version

  show_version();

C<show_version()> will print out the sbotools version and licensing information
to STDOUT.

There is no useful return value.

=cut

sub show_version {
  say "sbotools version $SBO::Lib::VERSION";
  say 'licensed under the MIT License';
}

=head2 slurp

  my $data = slurp($fn);

C<slurp()> takes a filename in C<$fn>, opens it, and reads in the entire file,
the contents of which is then returned. On error, it returns C<undef>.

=cut

sub slurp {
  my $fn = shift;
  return undef unless -f $fn;
  my ($fh, $exit) = open_read($fn);
  return undef if $exit;
  local $/;
  return scalar readline($fh);
}

=head2 uniq

  my @uniq = uniq(@duplicates);

C<uniq()> removes the duplicates from C<@duplicates> but otherwise returns the
list in the same order.

=cut

sub uniq {
  my %seen;
  return grep { !$seen{$_}++ } @_;
}

=head2 usage_error

  usage_error($msg);

usage_error will warn and exit, saying on STDERR

  $msg

There is no useful return value.

=cut

# subroutine for usage errors
sub usage_error {
  warn shift ."\n";
  exit _ERR_USAGE;
}

=head2 version_cmp

  my $cmp = version_cmp($ver1, $ver2);

C<version_cmp()> will compare C<$ver1> with C<$ver2> to try to determine which
is bigger than the other, and returns 1 if C<$ver1> is bigger, -1 if C<$ver2>
is bigger, and 0 if they are just as big. Before making the comparison, it will
strip off the version of your running kernel as well as any locale information
if it happens to be appended to the version string being compared.

=cut

# wrapper around versioncmp for checking if versions have kernel version
# or locale info appended to them
sub version_cmp {
  my ($v1, $v2) = @_;
  my $kv = get_kernel_version();

  # strip off kernel version
  if ($v1 =~ /(.+)_\Q$kv\E$/) { $v1 = $1 }
  if ($v2 =~ /(.+)_\Q$kv\E$/) { $v2 = $1 }

  # if $v2 doesn't end in the same thing, strip off locale info from $v1
  if ($v1 =~ /(.*)_([a-z]{2})_([A-Z]{2})$/) {
      my $v = $1;
      if ($v2 !~ /_$2_$3$/) { $v1 = $v; }
  }
  # and vice versa...
  if ($v2 =~ /(.*)_([a-z]{2})_([A-Z]{2})$/) {
      my $v = $1;
      if ($v1 !~ /_$2_$3$/) { $v2 = $v; }
  }

  versioncmp($v1, $v2);
}

=head2 read_hints

  our @listings = read_hints()

C<read_hints()> reads the contents of /etc/sbotools/sbotools.hints, returning an array
of optional dependency requests and blacklisted scripts. C<read_hints()> is used to
populate global array C<@listings>, and should only be called once.

=cut

sub read_hints{
  if(-f "/etc/sbotools/sbotools.hints") {
    my $contents = slurp("/etc/sbotools/sbotools.hints");
    usage_error("read_hints: could not read existing /etc/sbotools/sbotools.hints") unless
      defined $contents;
    my @contents = split("\n", $contents);
    for my $entry (@contents) {
      push @listings, $entry unless grep { /^#|^\s/ } $entry;
    }
  }
  push @listings, "NULL" unless @listings;
  return @listings;
}

=head2 get_optional

  my $optional = get_optional($sbo)

C<get_optional()> checks for user-requested optional dependencies for C<$sbo>. Note that
global array C<@listings> is copied.

=cut

sub get_optional {
  script_error("get_optional requires an argument.") unless @_ == 1;
  my $sbo = shift;
  my @optional;
  my @loclistings = @listings;
  for my $entry (@loclistings) {
    next if grep { /^#|^!/ } $entry;
    next if not grep { /\s$sbo$/ } $entry;
    $entry =~ s/\s$sbo$//;
    push @optional, split(" ", $entry);
  }
  push @optional, "NULL" unless @optional;

  return @optional;
}

=head2 on_blacklist

  my $result = on_blacklist($sbo);

C<on_blacklist()> checks whether C<$sbo> has been blacklisted. Note that
global array C<@listings> is copied.

=cut

sub on_blacklist {
  script_error("on_blacklist requires an argument.") unless @_ == 1;
  my $sbo = shift;
  my @loclistings = @listings;
  for my $entry (@loclistings) {
    next if grep { /\s/ } $entry;
    return 1 if $entry eq "!$sbo"; }
  return 0;
}

=head2 build_cmp

  my $cmp = build_cmp($build1, $build2, $ver1, $ver2);

C<build_cmp()> will compare C<$build1> with C<$build2> while checking that C<$ver1>
and C<$ver2> are different. If the build numbers are not the same and the version
numbers are, upgrading for a script bump may be in order.

=cut

sub build_cmp {
  my ($b1, $b2, $v1, $v2) = @_;
  if (versioncmp($v1, $v2)) { return 0; }
  if ($b1 != $b2) { return 1; }

  return 0;
}

# _race::cond will allow both documenting and testing race conditions
# by overriding its implementation for tests
sub _race::cond { return }

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

1;
