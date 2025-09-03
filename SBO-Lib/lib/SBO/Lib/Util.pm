package SBO::Lib::Util;

# vim: ts=2:et

# The lines below are used to inform the sbotest wrapper script
# that sbotools is compatible with "sbotest config",
# "sbotest hints" and "sbotest find". Do not alter or remove.

#% SBOTEST CONFIG HINTS %
#% SBOTEST FIND %

#% SBOTEST V1 COMPAT %
#% SBOTEST V1.0.1 COMPAT %
#% SBOTEST V1.1.1 COMPAT %

use 5.016;
use strict;
use warnings;

our $VERSION = '3.8.1';

use Exporter 'import';
use File::Copy;
use File::Basename;
use SBO::ThirdParty::Sort::Versions;
use Term::ANSIColor qw/ color colorvalid /;
use Text::Wrap qw/ wrap $columns /;

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
  _ERR_INST_SIGNAL   => 12,  # sboinstall or sboupgrade was interrupted
  _ERR_CIRCULAR      => 13,  # attempted to calculate circular dependencies
  _ERR_USR_GRP       => 14,  # a required user or group is missing
  _ERR_GPG           => 15,  # GPG verification failed
  _ERR_STDIN         => 16,  # reading keyboard input failed
};

my @EXPORT_CONSTS = keys %$consts;
my @EXPORT_CONFIG = qw{
  read_config

  @auto_reverse
  $arch
  $conf_dir
  $conf_file
  $color_file
  $hint_file
  %config
  @listings
  @on_blacklist
  $obs_file
  @obsolete
  %optional
  $pkg_db
  $sbotest_compatible
  $script_db
  $is_sbotest
  $userland_32
};

my @EXPORT_TIME = qw{
  display_times
  reconcile_time

  $download_time
  $resume_time
  $stop_time
  $total_build_time
  $total_install_time
  $paused_time
};

my @EXPORT_COLORS = qw{
  print_color
  wrapsay_color
  warn_color

  $color_default
  $color_lesser
  $color_notice
  $color_warn
};

our @EXPORT_OK = (
  qw{
    auto_reverse
    build_cmp
    check_multilib
    dangerous_directory
    error_code
    get_colors
    get_kernel_version
    get_optional
    get_sbo_from_loc
    get_slack_branch
    get_slack_version
    get_slack_version_url
    idx
    in
    in_regexp
    indent
    is_obsolete
    lint_sbo_config
    obsolete_array
    on_blacklist
    open_fh
    open_read
    print_color
    print_failures
    prompt
    read_hints
    save_options
    script_error
    show_version
    slurp
    time_format
    uniq
    usage_error
    version_cmp
    wrapsay
  },
  @EXPORT_COLORS,
  @EXPORT_CONSTS,
  @EXPORT_CONFIG,
  @EXPORT_TIME,
);

our %EXPORT_TAGS = (
  all => \@EXPORT_OK,
  colors => \@EXPORT_COLORS,
  const => \@EXPORT_CONSTS,
  config => \@EXPORT_CONFIG,
  times => \@EXPORT_TIME,
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

=head2 $arch

The kernel architecture, accounting for C<i?86> userlands reporting a C<x86_64> kernel.

=head2 ($color_default, $color_lesser, $color_notice, $color_warn)

These variables are ANSI colors. C<$color_notice> is C<cyan> for selected
C<sbotools> informative messages. C<$color_lesser> is C<bold> for warnings
of lesser concern. C<$color_warn>, C<red bold>, is for errors and warnings of greater concern.
C<sbotools> color display can be enabled by setting C<COLOR> to C<TRUE>. C<$color_default>
is currently C<reset> and is not configurable.

C<get_colors()> reads C</etc/sbotools/sbotools.colors> for custom values.

=head2 $conf_dir

C<$conf_dir> is C</etc/sbotools> by default, or else the contents of an
environment variable C<SBOTOOLS_CONF_DIR>.

=head2 $conf_file

C<$conf_file> is C</etc/sbotools/sbotools.conf> by default.

=head2 %config

All values default to C<"FALSE">, but when C<read_config()> is run,
they change according to the configuration. C<SBO_HOME> is changed to
C</usr/sbo> if still C<"FALSE">.

The supported keys are: C<NOCLEAN>, C<DISTCLEAN>, C<JOBS>, C<PKG_DIR>,
C<SBO_HOME>, C<LOCAL_OVERRIDES>, C<SLACKWARE_VERSION>, C<REPO>, C<BUILD_IGNORE>,
C<GPG_VERIFY>, C<RSYNC_DEFAULT>, C<STRICT_UPGRADES>, C<GIT_BRANCH>, C<CLASSIC>,
C<CPAN_IGNORE>, C<ETC_PROFILE>, C<LOG_DIR>, C<NOWRAP>, C<COLOR>, C<SO_CHECK> and
C<DIALOGRC>.

=head2 $download_time

The time spent downloading source files. Unless C<CLASSIC> is C<"TRUE">, it is
displayed when all builds are complete.

=head2 $hint_file

A file, C</etc/sbotools/sbotools.hints> by default, containing blacklisted scripts,
optional script dependencies and automatic revese dependency rebuild requests.

=head2 $is_sbotest

This shared variable indicates a run from C<sbotest>.

=head2 $sbotest_compatible

This shared variable indicates compatibility with the C<sbotest> companion package.

=head2 $total_build_time

A running total of the time it took to build and package each script in the queue.
Unless C<CLASSIC> is C<"TRUE">, it is displayed when all builds are complete.

=head2 $total_install_time

A running total of the time it took to install each script in the queue. Unless
C<CLASSIC> is C<"TRUE">, it is displayed when all builds are complete.

=head2 ($paused_time, $resume_time, $stop_time)

These variables are used to track any time spent stopped by keyboard interrupt.
Times are adjusted in the C<reconcile_time()> subroutine before reporting.

=head2 @listings

An array with blacklisted scripts and requests for optional dependencies and
automatic reverse dependency rebuilds read in from C</etc/sbotools/sbotools.hints>.

=head2 (@on_blacklist, @auto_reverse, %optional)

These exported variables are populated by C<read_hints()> and used to determine hint
status.

=cut

=head2 $obs_file

This file contains a list of scripts that have been renamed and added to Slackware
-current, or are known to be obsolete build dependencies. It is located at
C</etc/sbotools/obsolete> by default.

=cut

=head2 @obsolete

This array is based on the contents of C<$obs_file>. Only C<obsolete_array()> should
interact with C<@obsolete> directly; in other situations, make a copy.

=cut

=head2 $userland_32

C<get_arch()> defines this variable when running in a 32-bit userland on a 64-bit
kernel.

=cut

our $arch = get_arch();

our $pkg_db = '/var/log/packages';
our $script_db = '/var/log/scripts';

# global config variables
my $req_dir = $ENV{SBOTOOLS_CONF_DIR};
our $conf_dir = defined $req_dir ? $req_dir : '/etc/sbotools';
our $is_sbotest = $ENV{SBOTEST_MODE};
my $dir_check_var = "\$SBOTOOLS_CONF_DIR";
$dir_check_var .= " and \$SBOTEST_CONF_DIR" if defined $is_sbotest;
usage_error("$conf_dir is not an absolute path.\nCheck the value of $dir_check_var. Exiting.") unless $conf_dir =~ m/^\//;
my $filebase = defined $is_sbotest ? "sbotest" : "sbotools";
our $conf_file = "$conf_dir/$filebase.conf";
our $hint_file = "$conf_dir/$filebase.hints";
our $obs_file = "$conf_dir/obsolete";
our $color_file = "$conf_dir/$filebase.colors";
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
  STRICT_UPGRADES => 'FALSE',
  CPAN_IGNORE => 'FALSE',
  OBSOLETE_CHECK => 'FALSE',
  ETC_PROFILE => 'FALSE',
  LOG_DIR => 'FALSE',
  COLOR => 'FALSE',
  NOWRAP => 'FALSE',
  SO_CHECK => 'FALSE',
  DIALOGRC => 'FALSE',
);

if (defined $is_sbotest) {
  $config{CPAN_IGNORE} = 'TRUE';
  $config{ETC_PROFILE} = 'TRUE';
  $config{SBO_ARCHIVE} = 'FALSE';
}

read_config();

# The hints file should be read in at the start, and
# only if editing the hints file thereafter.
our (@on_blacklist, @auto_reverse, %optional);
our @listings = read_hints();

# A list of obsolete scripts for Slackware-current.
our @obsolete = obsolete_array();

# A running build/packaging time total.
our $total_build_time;

# A running installation time total.
our $total_install_time;

# Total time paused
our $paused_time;

# Time TSTP signal received
our $stop_time;

# Time CONT signal received
our $resume_time;

# Time spent downloading.
our $download_time;

# This version of sbotools is compatible with sbotest.
our $sbotest_compatible = 1;

# A 32-bit userland is running on a 64-bit kernel.
our $userland_32;

# Set colors here
our $color_default = "reset";
our $color_lesser = "bold";
our $color_notice = "cyan";
our $color_warn = "red bold";
get_colors();

usage_error("Forbidden value of \$TMP: $ENV{TMP}\n") if defined $ENV{TMP} and dangerous_directory($ENV{TMP});

=head1 SUBROUTINES

=cut

=head2 auto_reverse

  my $result = auto_reverse($sbo)

C<auto_reverse()> checks whether automatic reverse dependency rebuilding for C<$sbo> has
been requested. Results will be the same for the C<compat32> version of the script.

=cut

sub auto_reverse {
  script_error("auto_reverse requires an argument.") unless @_ == 1;
  my $sbo = shift;
  return 1 if in($sbo, @auto_reverse);
  return 0;
}

=head2 build_cmp

  my $cmp = build_cmp($build1, $build2, $ver1, $ver2);

C<build_cmp()> compares C<$build1> with C<$build2> while checking that C<$ver1>
and C<$ver2> are different. If the build numbers are not the same and the version
numbers are, upgrading for a script bump may be in order.

=cut

sub build_cmp {
  my ($b1, $b2, $v1, $v2) = @_;
  if (versioncmp($v1, $v2)) { return 0; }
  if ($b1 > $b2) { return 1; }
  if ($b1 < $b2) { return -1; }

  return 0;
}

=head2 check_multilib

  my $ml = check_multilib();

C<check_multilib()> verifies C</etc/profile.d/32dev.sh> existence.
The sbotools use this file to build 32-bit packages on x64 architecture.

Returns 1 if the file exists, and 0 otherwise.

=cut

# can't do 32-bit on x86_64 without this file, so we'll use it as the test to
# to determine whether or not an x86_64 system is setup for multilib
sub check_multilib {
  return 1 if -f '/etc/profile.d/32dev.sh';
  return();
}

=head2 dangerous_directory

  my $dangerous = dangerous_directory($dirname);

C<dangerous_directory()> takes a string and returns true if it is equal to C</>,
C</root>, C</home> or a possible top-level directory under C</home>.

=cut

sub dangerous_directory {
  script_error("dangerous_directory requires an argument.") unless @_ == 1;
  my $dirname = shift;
  my $dangerous = 0;
  if ($dirname =~ m/^\/+$/ or
      $dirname =~ m/^\/+home\/+[^\/]+(|\/+)$/ or
      $dirname =~ m/^\/+(home|root)(|\/+)$/) {
    $dangerous = 1;
  }
  return $dangerous;
}

=head2 display_times

  display_times();

C<display_times()> shows the time spent downloading, packaging and installing
the scripts in the build queue. It takes no arguments and has no useful return
value.

=cut

sub display_times {
  my ($build_time_string, $download_time_string, $install_time_string);
  $build_time_string = time_format($total_build_time) if $total_build_time;
  $download_time_string = time_format($download_time) if $download_time;
  $install_time_string = time_format($total_install_time) if $total_install_time;
  print_color($color_notice);
  say "" if $build_time_string or $download_time_string or $install_time_string;
  say "Download: $download_time_string" if $download_time_string;
  say "Package:  $build_time_string" if $build_time_string;
  say "Install:  $install_time_string" if $install_time_string;
  print_color($color_default);
  return;
}

=head2 error_code

  error_code($message, $code);

C<error_code()> takes a message and an error code. The message is displayed
wrapped at 72 characters and the script exits with the specified error code.
There is no useful return value.

For _ERR_USAGE and _ERR_SCRIPT, use C<usage_error()> and C<script_error()>,
respectively.

=cut

sub error_code {
  script_error("error_code requires two arguments.") unless @_ == 2;
  my $msg = shift;
  unless ($config{NOWRAP} eq 'TRUE') {
    $columns = 73;
    if ($config{COLOR} eq 'TRUE') {
      warn color($color_warn). wrap('', '', $msg). "\n";
    } else {
      warn wrap('', '', $msg). "\n";
    }
  } else {
    if ($config{COLOR} eq 'TRUE') {
      warn color($color_warn). "$msg\n";
    } else {
      warn "$msg\n";
    }
  }
  print color($color_default);
  exit shift;
}

=head2 get_arch

  my $arch = get_arch();

C<get_arch()> returns the machine architechture as reported by C<uname
-m>. For the C<x86_64> architecture, additionally check whether C</bin/bash>
is 64- or 32-bit to account for 32-bit userlands running on a 64-bit kernel.

C<get_arch> is not exported; use the exported variable C<$arch> if it is necessary
to check for architecture.

=cut

sub get_arch {
  chomp(my $arch = `uname -m`);
  if ($arch eq "x86_64") {
    if (`file /bin/bash` =~ m/32-bit/) {
      $arch = "i686";
      $userland_32 = 1;
    }
  }
  return $arch;
}

=head2 get_colors

  my ($color_notice, $color_lesser, $color_warn) = get_colors();

C<get_colors()> reads the contents of C</etc/sbotools/sbotools.colors> to
set custom values for C<$color_notice>, C<$color_lesser> and C<$color_warn>.
No color can be set to an invalid ANSI specification; in such cases, the default
value is used instead. See C<Term::ANSIColor(3)> for details.

=cut

sub get_colors {
  return unless -s $color_file;
  my ($fh, $exit) = open_read($color_file);
  return if $exit;
  for my $line (<$fh>) {
    next if $line =~ m/^(\s|#)/;
    next unless $line =~ m/^(\s+|)color_(notice|lesser|warn)(\s+|)=/;
    $line =~ s/("|')//g;
    my @items = split "=", $line;
    next unless colorvalid($items[1]);
    $items[0] =~ s/\s//g;
    $color_notice = $items[1] if $items[0] eq "color_notice";
    $color_lesser = $items[1] if $items[0] eq "color_lesser";
    $color_warn = $items[1] if $items[0] eq "color_warn";
  }
}

=head2 get_kernel_version

  my $kv = get_kernel_version();

C<get_kernel_version()> checks the version of the running kernel and returns
it in a format suitable for appending to a Slackware package version.

=cut

sub get_kernel_version {
  state $kv;
  return $kv if defined $kv;

  chomp($kv = `uname -r`);
  $kv =~ s/-/_/g;
  return $kv;
}

=head2 get_optional

  my $optional = get_optional($sbo)

C<get_optional()> checks for user-requested optional dependencies for C<$sbo>.
In all cases, results for C<compat32> scripts have the corresponding C<compat32>
scripts to the results for the base script.

=cut

sub get_optional {
  script_error("get_optional requires an argument.") unless @_ == 1;
  my $sbo = shift;
  my @optional;
  if (exists $optional{$sbo}) {
    push @optional, @{ $optional{$sbo} };
  }
  return @optional if @optional;
  return;
}

=head2 get_sbo_from_loc

  my $sbo = get_sbo_from_loc($location);

C<get_sbo_from_loc()> returns the package name from the C<$location> passed in.

=cut

# pull the sbo name from a $location: $repo_path/system/wine, etc.
sub get_sbo_from_loc {
  script_error('get_sbo_from_loc requires an argument.') unless @_ == 1;
  return (shift =~ qr#/([^/]+)$#)[0];
}

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

=head2 get_slack_branch

  my $url = get_slack_branch();

C<get_slack_branch()> returns the default git branch for the given Slackware
version, if any. If the upstream repository does not have this branch, an onscreen
message appears.

=cut

sub get_slack_branch {
  return $branch{get_slack_version()};
}

=head2 get_slack_version

  my $version = get_slack_version();

C<get_slack_version()> returns the appropriate version of the SBo reposiotry.

The program exits if the version is unsupported or if an error occurs.

=cut

sub get_slack_version {
  my $version;
  $version = $config{SLACKWARE_VERSION} unless $config{SLACKWARE_VERSION} eq 'FALSE';
  unless ($version) {
    my ($fh, $exit) = open_read('/etc/slackware-version');
    error_code("Could not open /etc/slackware-version; exiting.", $exit) if $exit;
    chomp(my $line = <$fh>);
    close $fh;
    $version = ($line =~ /\s+(\d+[^\s]+)$/)[0];
  }
  usage_error("\nThe running or configured Slackware version is unsupported: $version\n" .
    "Consider running \"sboconfig -r $supported{current}\" to use a repository for -current.")
    unless $supported{$version};
  return $version;
}

=head2 get_slack_version_url

  my $url = get_slack_version_url();

C<get_slack_version_url()> returns the default URL for the given Slackware
version.

The program exits if the version is unsupported or if an error occurs.

=cut

sub get_slack_version_url {
  my $version = get_slack_version();
  return $supported{$version} unless $version eq "15.1";
  my $exists = system(qw! git --no-pager ls-remote --exit-code https://gitlab.com/SlackBuilds.org/slackbuilds.git --heads origin 15.1 !) == 0;
  return $supported{$version} if $exists;
  return $supported{current};
}

=head2 idx

  my $idx = idx($needle, @haystack);

C<idx()> looks for C<$needle> in C<@haystack>, and returns the index of where
it was found, or C<undef> if it was not found.

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

C<in()> formerly matched C<Regexp>, but this was changed for performance reasons.
Use C<in_regexp()> for the old functionality.

=cut

# Checks if the first argument equals any of the subsequent ones
sub in {
  my $first = shift;
  for (@_) { return 1 if $first eq $_; }
  return 0;
}

sub in_regexp {
  my ($first, @rest) = @_;
  foreach my $arg (@rest) {
    return 1 if ref $arg eq 'Regexp' and $first =~ $arg;
    return 1 if $first eq $arg;
  }
  return 0;
}
=head2 indent

  my $str = indent($indent, $text);

C<indent()> indents every non-empty line in C<$text> by C<$indent> spaces and
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

=head2 is_obsolete

  my $is_obsolete = check_obsolete($sbo);

C<is_obsolete()> takes the name of a SlackBuild and searches for it in
the C<@obsolete> array. It returns 1 if the SlackBuild is found and the
Slackware version is -current equivalent.

=cut

sub is_obsolete {
  script_error('is_obsolete requires an argument.') unless @_ == 1;
  my $sbo = shift;
  my $sw_version = get_slack_version();
  return 0 unless $sw_version =~ /\+$|current/ or $sw_version eq "15.1";
  my @local_obsolete = @obsolete;
  for my $entry (@local_obsolete) { return 1 if $sbo eq $entry; }
  return 0;
}

=head2 lint_sbo_config

  lint_sbo_config($running_script, %configs);

C<lint_sbo_config()> takes the name of an sbotools script and a hash with configuration
parameters. It checks the validity of all parameters except for REPO,
exiting with an error message in case of invalid options.

C<sboconfig(1)> runs this subroutine to lint any requested parameter changes;
all other scripts lint the full configuration at startup.

=cut

sub lint_sbo_config {
  script_error("lint_sbo_config requires two arguments.") unless @_ > 2;
  my ($running, %configs) = @_;
  my @invalid;
  my @dangerous;
  my $warn;
  if ($running eq 'sboconfig') {
    $warn = 'Invalid parameter for';
  } else {
    $warn = $is_sbotest ? 'sbotest config' : 'sboconfig';
  }

  if (exists $configs{BUILD_IGNORE}) {
    unless ($configs{BUILD_IGNORE} =~ /^(TRUE|FALSE)$/) {
      push @invalid, "BUILD_IGNORE:" if $running ne 'sboconfig';
      push @invalid, "$warn -b (TRUE or FALSE)";
    }
  }
  if (exists $configs{CLASSIC}) {
    unless ($configs{CLASSIC} =~ /^(TRUE|FALSE)$/) {
      push @invalid, "CLASSIC:" if $running ne 'sboconfig';
      push @invalid, "$warn -C (TRUE or FALSE)";
    }
  }
  if (exists $configs{CPAN_IGNORE}) {
    unless ($configs{CPAN_IGNORE} =~ /^(TRUE|FALSE)$/) {
      push @invalid, "CPAN_IGNORE" if $running ne 'sboconfig';
      push @invalid, "$warn -P (TRUE or FALSE)";
    }
  }
  if (exists $configs{DISTCLEAN}) {
    unless ($configs{DISTCLEAN} =~ /^(TRUE|FALSE)$/) {
      push @invalid, "DISTCLEAN:" if $running ne 'sboconfig';
      push @invalid, "$warn -d (TRUE or FALSE)";
    }
  }
  if (exists $configs{ETC_PROFILE}) {
    unless ($configs{ETC_PROFILE} =~ /^(TRUE|FALSE)$/) {
      push @invalid, "ETC_PROFILE" if $running ne 'sboconfig';
      push @invalid, "$warn -e (TRUE or FALSE)";
    }
  }
  if (exists $configs{GPG_VERIFY}) {
    unless ($configs{GPG_VERIFY} =~ /^(TRUE|FALSE)$/) {
      push @invalid, "GPG_VERIFY:" if $running ne 'sboconfig';
      push @invalid, "$warn -g (TRUE or FALSE)";
    }
  }
  if (exists $configs{JOBS}) {
    unless ($configs{JOBS} =~ /^(\d+|FALSE)$/) {
      push @invalid, "JOBS:" if $running ne 'sboconfig';
      push @invalid, "$warn -j (numeric or FALSE)";
    }
  }
  if (exists $configs{LOCAL_OVERRIDES}) {
    unless ($configs{LOCAL_OVERRIDES} =~ qr#^(/|FALSE$)#) {
      push @invalid, "LOCAL_OVERRIDES:" if $running ne 'sboconfig';
      push @invalid, "$warn -o (absolute path or FALSE)";
    } elsif ($configs{LOCAL_OVERRIDES} =~ qr#^/#) {
      push @dangerous, "LOCAL_OVERRIDES: $configs{LOCAL_OVERRIDES}" if dangerous_directory($configs{LOCAL_OVERRIDES});
    }
  }
  if (exists $configs{LOG_DIR}) {
    unless ($configs{LOG_DIR} =~ qr#^(/|FALSE$)#) {
      push @invalid, "LOG_DIR:" if $running ne 'sboconfig';
      push @invalid, "$warn -L (absolute path or FALSE)";
    } elsif ($configs{LOG_DIR} =~ qr#^/#) {
      push @dangerous, "LOG_DIR: $configs{LOG_DIR}" if dangerous_directory($configs{LOG_DIR});
    }
  }
  if (exists $configs{NOCLEAN}) {
    unless ($configs{NOCLEAN} =~ /^(TRUE|FALSE)$/) {
      push @invalid, "NOCLEAN:" if $running ne 'sboconfig';
      push @invalid, "$warn -c (TRUE or FALSE)";
    }
  }
  if (exists $configs{COLOR}) {
    unless ($configs{COLOR} =~ /^(TRUE|FALSE)$/) {
      push @invalid, "COLOR" if $running ne 'sboconfig';
      push @invalid, "$warn -K (TRUE or FALSE)";
    }
  }
  if (exists $configs{NOWRAP}) {
    unless ($configs{NOWRAP} =~ /^(TRUE|FALSE)$/) {
      push @invalid, "NOWRAP" if $running ne 'sboconfig';
      push @invalid, "$warn -w (TRUE or FALSE)";
    }
  }
  if (exists $configs{OBSOLETE_CHECK}) {
    unless ($configs{OBSOLETE_CHECK} =~ /^(TRUE|FALSE)$/) {
      push @invalid, "OBSOLETE_CHECK" if $running ne 'sboconfig';
      push @invalid, "$warn -O (TRUE or FALSE)";
    }
  }
  if (exists $configs{PKG_DIR}) {
    unless ($configs{PKG_DIR} =~ qr#^(/|FALSE$)#) {
      push @invalid, "PKG_DIR:" if $running ne 'sboconfig';
      push @invalid, "$warn -p (absolute path or FALSE)";
    } elsif ($configs{PKG_DIR} =~ qr#^/#) {
      push @dangerous, "PKG_DIR: $configs{PKG_DIR}" if dangerous_directory($configs{PKG_DIR});
    }
  }
  if (exists $configs{RSYNC_DEFAULT}) {
    unless ($configs{RSYNC_DEFAULT} =~ /^(TRUE|FALSE)$/) {
      push @invalid, "RSYNC_DEFAULT:" if $running ne 'sboconfig';
      push @invalid, "$warn -R (TRUE or FALSE)";
    }
  }
  if (exists $configs{REPO}) {
    if ($configs{REPO} =~ qr#^/#) {
      push @dangerous, "REPO: $configs{REPO}" if dangerous_directory($configs{REPO});
    }
  }
  if (exists $configs{SBO_ARCHIVE}) {
    unless ($configs{SBO_ARCHIVE} =~ qr#^(/|FALSE$)#) {
      push @invalid, "SBO_ARCHIVE" if $running ne 'sboconfig';
      push @invalid, "$warn -A (absolute path or FALSE)";
    } elsif ($configs{SBO_ARCHIVE} =~ qr#^/#) {
      push @dangerous, "SBO_ARCHIVE: $configs{SBO_ARCHIVE}" if dangerous_directory($configs{SBO_ARCHIVE});
    }
  }
  if (exists $configs{SBO_HOME}) {
    unless ($configs{SBO_HOME} =~ qr#^(/|FALSE$)#) {
      push @invalid, "SBO_HOME:" if $running ne 'sboconfig';
      push @invalid, "$warn -s (absolute path or FALSE)";
    } elsif ($configs{SBO_HOME} =~ qr#^/#) {
      push @dangerous, "SBO_HOME: $configs{SBO_HOME}" if dangerous_directory($configs{SBO_HOME});
    }
  }
  if (exists $configs{SO_CHECK}) {
    unless ($configs{SO_CHECK} =~ /^(TRUE|FALSE)$/) {
      push @invalid, "SO_CHECK" if $running ne 'sboconfig';
      push @invalid, "$warn -X (TRUE or FALSE)";
    }
  }
  if (exists $configs{STRICT_UPGRADES}) {
    unless ($configs{STRICT_UPGRADES} =~ /^(TRUE|FALSE)$/) {
      push @invalid, "STRICT_UPGRADES:" if $running ne 'sboconfig';
      push @invalid, "$warn -S (TRUE or FALSE)";
    }
  }
  if (exists $configs{SLACKWARE_VERSION}) {
    unless ($configs{SLACKWARE_VERSION} =~ m/^(\d+\.\d+(|\+)|FALSE|current)$/) {
      push @invalid, "SLACKWARE_VERSION:" if $running ne 'sboconfig';
      push @invalid, "$warn -V (version number #.#(+), current or FALSE)";
    }
  }

  my $invalid_string = join("\n", @invalid);
  if ($invalid_string) {
    wrapsay("The configuration in $conf_file contains one or more invalid parameters.", 1) if $running ne 'sboconfig';
    usage_error("$invalid_string");
  }
  my $dangerous_string = join("\n", @dangerous);
  if ($dangerous_string) {
    wrapsay("The configuration in $conf_file contains one or more forbidden parameters.", 1) if $running ne 'sboconfig';
    wrapsay("The requested configuration contains one or more forbidden parameters.", 1) if $running eq 'sboconfig';
    usage_error("$dangerous_string");
  }
}

=head2 obsolete_array

  our @obsolete = obsolete_array();

C<obsolete_array()> populates the shared C<@obsolete> array based on the
C</etc/sbotools/obsolete> file.

=cut

sub obsolete_array {
  my @result;
  return 0 unless -f $obs_file;
  my ($fh, $exit) = open_fh($obs_file, "<");
  if ($exit) {
    warn_color($color_lesser, "Could not open $obs_file.");
    return 0;
  }
  FIRST: for my $line (<$fh>) {
    next FIRST if $line =~ /^#/;
    $line =~ s/\n//;
    push @result, $line;
  }
  close($fh);
  return @result;
}

=head2 on_blacklist

  my $result = on_blacklist($sbo);

C<on_blacklist()> checks whether C<$sbo> has been blacklisted. Results will
be the same for the C<compat32> version of the script.

=cut

sub on_blacklist {
  script_error("on_blacklist requires an argument.") unless @_ == 1;
  my $sbo = shift;
  return 1 if in($sbo, @on_blacklist);
  return 0;
}

=head2 open_fh

  my ($ret, $exit) = open_fh($fn, $op);

C<open_fh()> opens C<$fn> for reading and/or writing depending on
C<$op> (e.g., ">" or "<").

It returns two values: the file handle and the exit status. If the exit status
is non-zero, it returns an error message rather than a file handle.

=cut

# sub for opening files, second arg is like '<','>', etc
sub open_fh {
  script_error('open_fh requires two arguments') unless @_ == 2;
  my ($file, $op) = @_;
  my $fh;
  unless (open $fh, $op, $file) {
    my $warn = $< == 0 ? "Unable to open $file." : "Unable to open $file or the running user lacks permissions.\n\nTry running as root.";
    my $exit = _ERR_OPENFH;
    return ($warn, $exit);
  }
  return $fh;
}

=head2 open_read

  my ($ret, $exit) = open_read($fn);

C<open_read()> opens C<$fn> for reading.

It returns two values: the file handle and the exit status. If the exit status
is non-zero, it returns an error message rather than a file handle.

=cut

sub open_read {
  return open_fh(shift, '<');
}

=head2 print_color

  print_color "red bold";

C<print_color()> takes one or more ANSI colors and prints, provided that the
C<COLOR> setting is C<TRUE>. See the C<Function Interface> section in
C<Term::ANSIColor(3)> for a list of available colors.

Using colors C<black> through C<bright_white>, C<bold> and C<reset> only is
advisable to ensure terminal compatibility. When calling C<print_color()> before
exiting, ensure that a new line follows to avoid an improper cursor on some
terminals.

There is no useful return value.

=cut

sub print_color {
  return if $config{COLOR} ne 'TRUE';
  script_error("print_color requires at least one argument; exiting.") unless @_;
  my $color = shift;
  print color($color) if colorvalid($color);
  return;
}

=head2 print_failures

  print_failures($failures);

C<print_failures()> prints all failures in the C<$failures> array reference
to STDERR, if any.

There is no useful return value.

=cut

# subroutine to print out failures
sub print_failures {
  my $failures = shift;
  if (@$failures > 0) {
    warn_color($color_warn, "\nFailures:");
    for my $failure (@$failures) {
      warn "  $_: $$failure{$_}\n" for keys %$failure;
    }
  print color("reset");
  }
}

=head2 prompt

  exit unless prompt $color_notice, "Should we continue?", default => "yes";

C<prompt()> prompts the user for an answer, optionally specifying a default of
C<yes> or C<no>.

If the default has been specified, it returns a true value for 'yes' and a false
one for 'no'. Otherwise, it returns the content of the user's answer.

Output is wrapped at 72 characters.

=cut

sub prompt {
  my ($color, $q, %opts) = @_;
  my $def = $opts{default};
  my $extra_line;
  if ($q =~ m/^\n/) {
    $q =~ s/^\n//;
    $extra_line = 1;
  }
  $q = sprintf '%s [%s] ', $q, $def eq 'yes' ? 'y' : 'n' if defined $def;
  say "" if defined $extra_line;
  my $printcolor = colorvalid($color) ? $color : $color_default;
  unless ($config{NOWRAP} eq 'TRUE') {
    $columns = 73;
    if ($config{COLOR} eq 'TRUE') {
      print color($printcolor). wrap('', '', $q). color($color_default);
    } else {
      print wrap('', '', $q);
    }
  } else {
    if ($config{COLOR} eq 'TRUE') {
      print color($printcolor). $q. color($color_default);
    } else {
      print $q;
    }
  }

  my $res = readline STDIN;
  error_code("\nCould not read input; exiting.", _ERR_STDIN) unless defined $res;

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
C</etc/sbotools/sbotools.conf>, updating the C<%config> hash. If
C<SBO_HOME> is C<FALSE>, it changes to C</usr/sbo>.
Additionally, C<BUILD_IGNORE> and C<RSYNC_DEFAULT> are turned on
if C<CLASSIC> is C<TRUE>; C<COLOR> is turned off.

When C<sbotest> is running, the default value of C<SBO_HOME>
is C</usr/sbotest>, and C<ETC_PROFILE> and C<CPAN_IGNORE> default
to C<TRUE>. Supplementary setting C<SBO_ARCHIVE> defaults to
C</usr/sbotest/archive>. C<PKG_DIR> and C<LOG_DIR> default to
C</usr/sbotest/tests> and C</usr/sbotest/logs>, respectively, but
C<sbotest> uses timestamped directories under the configured paths.

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
    warn_color($color_warn, "Unable to open $conf_file.") if -f $conf_file;
  }
  if ($config{CLASSIC} eq "TRUE") {
    $config{BUILD_IGNORE} = "TRUE";
    $config{RSYNC_DEFAULT} = "TRUE";
    $config{COLOR} = "FALSE";
  }
  unless (defined $is_sbotest) {
    $config{SBO_HOME} = '/usr/sbo' if $config{SBO_HOME} eq 'FALSE';
  } else {
    $config{SBO_HOME} = '/usr/sbotest' if $config{SBO_HOME} eq 'FALSE';
    $config{SBO_ARCHIVE} = "$config{SBO_HOME}/archive" if $config{SBO_ARCHIVE} eq 'FALSE';
    $config{PKG_DIR} = "$config{SBO_HOME}/tests" if $config{PKG_DIR} eq 'FALSE';
    $config{LOG_DIR} = "$config{SBO_HOME}/logs" if $config{LOG_DIR} eq 'FALSE';
  }
}

=head2 read_hints

  our @listings = read_hints();

C<read_hints()> reads the contents of /etc/sbotools/sbotools.hints, returning an array
of optional dependency requests and blacklisted scripts. C<read_hints()> is used to
populate global array C<@listings>, and should only be called at the start and again
when editing the hints file.

C<@on_blacklist>, C<@auto_reverse> and C<%optional> are populated here and used by
C<on_blacklist()>, C<auto_reverse()> and C<get_optional()> later.

=cut

sub read_hints{
  @listings = () if @listings;
  splice @on_blacklist;
  splice @auto_reverse;
  %optional = ();
  if(-f "$hint_file") {
    my $contents = slurp("$hint_file");
    usage_error("read_hints: could not read existing $hint_file.") unless
      defined $contents;
    my @contents = split("\n", $contents);
    for my $entry (@contents) {
      push @listings, $entry unless $entry =~ m/^(#|\s)/ or $entry =~ m/\s$/;
    }
  }
  for (@listings) {
    my $item = $_;
    if ($item =~ m/^!/) {
      next if $item =~ m/\s/;
      $item =~ s/!//;
      push @on_blacklist, $item;
      push @on_blacklist, "$item-compat32";
    } elsif ($item =~ m/^~/) {
      next if $item =~ m/\s/;
      $item =~ s/~//;
      push @auto_reverse, $item;
      push @auto_reverse, "$item-compat32";
    } else {
      my @cand = split " ", $item;
      if (@cand gt 1) {
        my $has_optional = pop @cand;
        for (@cand) {
          push @{ $optional{$has_optional} }, $_ unless in($_, @{ $optional{$has_optional} });
          push @{ $optional{"$has_optional-compat32"} }, "$_-compat32" unless in("$_-compat32", @{ $optional{"$has_optional-compat32"} });
        }
      }
    }
  }

  push @listings, "NULL" unless @listings;
  return @listings;
}

=head2 reconcile_time

  my $corrected_seconds = reconcile_time($seconds);

C<reconcile_time()> takes a duration in seconds (integer or otherwise) and subtracts
any time spent stopped from keyboard signal. It returns the corrected number of seconds.

=cut
sub reconcile_time {
  script_error("reconcile_time requires an argument.") unless @_ == 1;
  my $duration = shift;
  return $duration unless $paused_time;
  my $corrected_duration = $duration - $paused_time;
  $paused_time = 0;
  return $corrected_duration if $corrected_duration gt 0;
  return $duration;
}

=head2 save_options

  save_options($sbo, $opts)

C<save_options()> saves build options to C</var/log/sbotools/sbo>. For C<compat32>
packages, the file for the base script is used. If the file already exists and the
user supplies no build options, the existing file is retained.

=cut

sub save_options {
  my $sbo = shift;
  $sbo =~ s/-compat32$//;
  my $args = shift;
  my $argdir = "/var/log/sbotools";
  my $logfile = "$argdir/$sbo";

  if(! -d $argdir) { mkdir $argdir; }
  if(-f $logfile) { move($logfile, "$logfile.bk"); }
  my ($args_fh, $exit) = open_fh($logfile, '>');
  if ($exit) {
    warn_color($color_lesser, $args_fh);
    move("$logfile.bk", $logfile);
    return 0;
  } else {
    print $args_fh $args;
    close $args_fh;
    if (-f "$logfile.bk") { unlink("$logfile.bk"); }
    if ($config{CLASSIC} ne "TRUE") {
      wrapsay("A copy of the build options has been saved to $logfile.", 1);
    }
  }
  return 1;
}

=head2 script_error

  script_error();
  script_error($msg);

script_error() warns and exits with code _ERR_SCRIPT, printing the following to STDERR:

  A fatal script error has occurred. Exiting.

If a $msg was supplied, it instead prints:

  A fatal script error has occurred:
  $msg.
  Exiting.

There is no useful return value. For _ERR_USAGE, use C<usage_error()>. For other error
codes, use C<error_code()>.

=cut

# subroutine for throwing internal script errors
sub script_error {
  if (@_) {
    if ($config{COLOR} eq 'TRUE') {
      warn color($color_warn). "A fatal script error has occurred:\n$_[0]\nExiting.\n";
    } else {
      warn "A fatal script error has occurred:\n$_[0]\nExiting.\n";
    }
  } else {
    if ($config{COLOR} eq 'TRUE') {
      warn color($color_warn). "A fatal script error has occurred. Exiting.\n";
    } else {
      warn "A fatal script error has occurred. Exiting.\n";
    }
  }
  print color("reset");
  exit _ERR_SCRIPT;
}

=head2 show_version

  show_version();

C<show_version()> prints the sbotools version and licensing information
to STDOUT.

There is no useful return value.

=cut

sub show_version {
  say "sbotools version $SBO::Lib::VERSION";
  say 'licensed under the MIT License';
}

=head2 slurp

  my $data = slurp($fn);

C<slurp()> takes a filename in C<$fn>, opens it, and reads in the entire file.
The contents are then returned. On error, it returns C<undef>.

=cut

sub slurp {
  my $fn = shift;
  my ($fh, $exit) = open_read($fn);
  return undef if $exit;
  local $/;
  return scalar readline($fh);
}

=head2 time_format

  my $time_string = time_format($time);

C<time_format()> takes a number of seconds (integer or otherwise) and returns
a string H:MM:SS.

=cut

sub time_format {
  script_error("time_format requres an argument.") unless @_;
  my $input = shift;
  my ($hours, $minutes, $seconds);
  $hours = int($input / 3600);
  $minutes = sprintf("%02d", int($input / 60) % 60);
  $seconds = sprintf("%02d", $input % 60);
  return "$hours:$minutes:$seconds";
}

=head2 uniq

  my @uniq = uniq(@duplicates);

C<uniq()> removes any duplicates from C<@duplicates>, otherwise returning the
list in the same order.

=cut

sub uniq {
  my %seen;
  return grep { !$seen{$_}++ } @_;
}

=head2 usage_error

  usage_error($msg);

C<usage_error()> warns and exits with code _ERR_USAGE, printing C<$msg> to STDERR.
Error messages wrap at 72 characters.

There is no useful return value. For _ERR_SCRIPT, use C<script_error()>; for other
error codes, use C<error_code()>.

=cut

# subroutine for usage errors
sub usage_error {
  my $msg = shift;
  unless ($config{NOWRAP} eq 'TRUE') {
    $columns = 73;
    if ($config{COLOR} eq 'TRUE') {
      warn color($color_warn). wrap('', '', $msg). "\n";
    } else {
      warn wrap('', '', $msg). "\n";
    }
  } else {
    if ($config{COLOR} eq 'TRUE') {
      warn color($color_warn). $msg. "\n";
    } else {
      warn "$msg\n";
    }
  }
  print color($color_default);
  exit _ERR_USAGE;
}

=head2 version_cmp

  my $cmp = version_cmp($ver1, $ver2);

C<version_cmp()> compares C<$ver1> with C<$ver2>. It returns 1 if C<$ver1> is higher,
-1 if C<$ver2> is higher and 0 if they are equal. It strips the running kernel version,
as well as any locale information that may have been appended to the version strings.

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

=head2 warn_color

  warn_color($color, $msg);

C<warn_color()> emits a warning in the chosen color and resets the color
afterwards. No colors are used unless C<COLOR> is C<TRUE>. A newline is added
automatically after the message. There is no useful return value.

=cut

sub warn_color {
  script_error("warn_color requires two arguments; exiting.") unless @_ == 2;
  my ($color, $message) = @_;
  my $warn_color = colorvalid($color) ? $color : $color_default;
  if ($config{COLOR} eq 'TRUE') {
    warn color($warn_color). $message. color($color_default). "\n";
    print color($color_default);
  } else {
    warn "$message\n";
  }
  return;
}

=head2 wrapsay

  wrapsay($msg, $trail);

C<wrapsay()> outputs a message with the lines wrapped at 72 characters and
a trailing newline. There is no useful return value. Optional C<$trail>
outputs an extra newline if present.

Use this subroutine whenever it is either obvious that the output exceeds
80 characters or the output includes a variable. C<say> can be used in
other cases. C<wrapsay()> should not be used on output that can be piped
for use in scripts (e.g., queue reports from C<sbofind(1)>).

=cut

sub wrapsay {
  script_error("wrapsay requires an argument.") unless @_ >= 1;
  my ($msg, $trail) = @_;
  unless ($config{NOWRAP} eq 'TRUE') {
    $columns = 73;
    print wrap('', '', "$msg\n");
  } else {
    say $msg;
  }
  print "\n" if $trail;
  return 1;
}

=head2 wrapsay_color

  wrapsay_color($color, $msg, $trail);

C<wrapsay_color()> takes a color, a message and any true value if a trailing line
is required. It applies a color, runs the message through C<wrapsay()> and
resets the color afterwards. No colors are used unless C<COLOR> is C<TRUE>. There
is no useful return value.

=cut

sub wrapsay_color {
  my $color = shift;
  return () unless colorvalid($color);
  script_error("wrapsay_color requires a message; exiting.") unless @_;
  my ($msg, $trail) = @_;
  my $extra_line;
  if ($msg =~ m/^\n/) {
    $msg =~ s/^\n//;
    $extra_line = 1;
  }
  say "" if defined $extra_line;
  print color($color) if $config{COLOR} eq 'TRUE';
  wrapsay($msg, $trail);
  print color($color_default) if $config{COLOR} eq 'TRUE';
  return;
}

=head1 EXIT CODES

The sbotools share the following exit codes:

  _ERR_USAGE         1   usage errors
  _ERR_SCRIPT        2   script or module bug
  _ERR_BUILD         3   errors when executing a SlackBuild
  _ERR_MD5SUM        4   download verification failure
  _ERR_DOWNLOAD      5   download failure
  _ERR_OPENFH        6   failure to open file handles
  _ERR_NOINFO        7   missing download information
  _ERR_F_SETD        8   fd-related temporary file failure
  _ERR_NOMULTILIB    9   lacking multilib capabilities when needed
  _ERR_CONVERTPKG    10  convertpkg-compat32 failure
  _ERR_NOCONVERTPKG  11  lacking convertpkg-compat32 when needed
  _ERR_INST_SIGNAL   12  the script was interrupted while building
  _ERR_CIRCULAR      13  attempted to calculate a circular dependency
  _ERR_USR_GRP       14  a required user or group is missing
  _ERR_GPG           15  GPG verification failed
  _ERR_STDIN         16  reading keyboard input failed

=head1 SEE ALSO

SBO::Lib(3), SBO::Lib::Build(3), SBO::Lib::Download(3), SBO::Lib::Info(3), SBO::Lib::Pkgs(3), SBO::Lib::Readme(3), SBO::Lib::Repo(3), SBO::Lib::Tree(3), Term::ANSIColor(3)

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

1;
