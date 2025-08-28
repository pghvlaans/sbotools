package SBO::Lib::Info;

# vim: ts=2:et

use 5.016;
use strict;
use warnings;

our $VERSION = '3.8.1';

use SBO::Lib::Util qw/ :config :const in get_sbo_from_loc get_optional open_read script_error slurp usage_error error_code uniq wrapsay /;
use SBO::Lib::Tree qw/ get_orig_location get_sbo_location is_local /;

use Exporter 'import';
use File::Basename;

use sigtrap qw/ handler _caught_signal ABRT INT QUIT TERM /;

our @EXPORT_OK = qw{
  check_x32
  check_x64
  fix_info
  get_download_info
  get_from_info
  get_orig_build_number
  get_orig_version
  get_requires
  get_reverse_reqs
  get_sbo_build_number
  get_sbo_version
  ineligible_compat
  parse_info
};

our %EXPORT_TAGS = (
  all => \@EXPORT_OK,
);

# values from info files are stored here
my %store;

=pod

=encoding UTF-8

=head1 NAME

SBO::Lib::Info - Utilities to get data from SBo info files.

=head1 SYNOPSIS

  use SBO::Lib::Info qw/ get_reqs /;

  my @reqs = @{ get_requires($sbo) };

=head1 SUBROUTINES

=cut

=head2 check_x32

  my $bool = check_x32($location);

C<check_x32()> returns a true value if the SlackBuild in C<$location> considers
64-bit builds C<UNTESTED> or C<UNSUPPORTED> and false otherwise.

=cut

# determine whether or not a given sbo is 32-bit only
sub check_x32 {
  script_error('check_x32 requires an argument.') unless @_ == 1;
  my $location = shift;
  my $dl = get_from_info(LOCATION => $location, GET => 'DOWNLOAD_x86_64');
  return $$dl[0] =~ /UN(SUPPOR|TES)TED/ ? 1 : 0;
}

=head2 check_x64

  my $bool = check_x64($location);

C<check_x64()> returns a true value if the SlackBuild in C<$location> considers
32-bit builds C<UNTESTED> or C<UNSUPPORTED> and false otherwise.

=cut

# determine whether or not a given sbo is 64-bit only
sub check_x64 {
  script_error('check_x64 requires an argument.') unless @_ == 1;
  my $location = shift;
  my $dl = get_from_info(LOCATION => $location, GET => 'DOWNLOAD');
  return $$dl[0] =~ /UN(SUPPOR|TES)TED/ ? 1 : 0;
}

=head2 fix_info

  my $fixed_string = fix_info($info_string);

C<fix_info()> sanitizes the contents of info files, and should be run once when a
C<parse_info()> call fails. It attempts to repair trailing whitespace, blank lines,
garbage lines and missing quotation marks and backslashes.

=cut

sub fix_info {
  script_error('fix_info requires an argument.') unless @_ == 1;
  my $info_str = shift;
  # Fix blank lines
  $info_str =~ s/\n\n/\n/g;
  # Fix trailing whitespace
  $info_str =~ s/\s\n/\n/g;
  # Fix EOF quotation marks
  $info_str =~ s/(?<=[^\"])\n+$/\"\n/g;
  # Fix missing backslashes
  $info_str =~ s/(?<=[^\\\"])\n(?=\s)/\\\n/g;
  # Fix missing terminal quotation marks
  $info_str =~ s/(?<=[^\\\"])\n(?=[A-Z])/\"\n/g;
  # Fix missing initial quotation marks
  my @fields = qw{
        PRGNAM
        VERSION
        HOMEPAGE
        DOWNLOAD
        MD5SUM
        DOWNLOAD_x86_64
        MD5SUM_x86_64
        REQUIRES
        MAINTAINER
        EMAIL
  };
  for my $field (@fields) { $info_str =~ s/(?<=$field)=(?=[^\"])/=\"/g; }
  # Anything that follows a terminal quote and doesn't start KEY="VALUE" is unwanted
  $info_str =~ s/\"\n[^=\"]+(\\|\")\n/\"\n/g;
  # And the start of the file
  $info_str =~ s/^[^=\"]+(\\|\")\n//g;
  return $info_str;
}

=head2 get_download_info

  my $downloads = get_download_info(LOCATION => $location, X64 => $x64);
  my $downloads = get_download_info(LOCATION => $location);

C<get_download_info()> reads in an info file from C<$location>. The flag
C<$x64> determines whether the 64-bit download files should be used or not.
C<$x64> defaults to a true value if unspecified.

This subroutine returns a hashref where each key is a download link; the
corresponding value is the expected md5sum.

=cut

# get downloads and md5sums from an sbo's .info file, first
# checking for x86_64-specific info if we are told to
sub get_download_info {
  my %args = (
    LOCATION  => 0,
    X64       => 1,
    @_
  );
  $args{LOCATION} or script_error('get_download_info requires LOCATION.');
  my ($get, $downs, $exit, $md5s, %return);
  $get = ($args{X64} ? 'DOWNLOAD_x86_64' : 'DOWNLOAD');
  $downs = get_from_info(LOCATION => $args{LOCATION}, GET => $get);
  # did we get nothing back, or UNSUPPORTED/UNTESTED?
  if ($args{X64}) {
    if (! $$downs[0] || $$downs[0] =~ qr/^UN(SUPPOR|TES)TED$/) {
      $args{X64} = 0;
      $downs = get_from_info(LOCATION => $args{LOCATION},
        GET => 'DOWNLOAD');
    }
  }
  # if we still don't have any links, something is really wrong.
  return() unless $$downs[0];
  # grab the md5s and build a hash
  $get = $args{X64} ? 'MD5SUM_x86_64' : 'MD5SUM';
  $md5s = get_from_info(LOCATION => $args{LOCATION}, GET => $get);
  return() unless $$md5s[0];
  $return{$$downs[$_]} = $$md5s[$_] for (keys @$downs);
  return \%return;
}

=head2 get_from_info

  my $data = get_from_info(LOCATION => $location, GET => $key);

C<get_from_info()> retrieves the information under C<$key> from the info file
in C<$location>. If the wanted information has already been found, it is returned
immediately.

=cut

# pull piece(s) of data, GET, from the $sbo.info file under LOCATION.
sub get_from_info {
  my %args = (
    LOCATION  => '',
    GET       => '',
    @_
  );
  unless ($args{LOCATION} && $args{GET}) {
    script_error('get_from_info requires LOCATION and GET.');
  }
  return $store{$args{LOCATION}}->{$args{GET}} if exists $store{$args{LOCATION}}->{$args{GET}};
  # if we're here, we haven't read in the .info file yet.
  my $sbo = get_sbo_from_loc($args{LOCATION});
  my $contents = slurp("$args{LOCATION}/$sbo.info");
  unless ($contents) {
    unless (-s "$args{LOCATION}/$sbo.info") {
      usage_error("$sbo.info is empty or does not exist. Run sbocheck.") unless is_local($sbo);
      usage_error("$sbo.info is empty or does not exist. Check the local overrides directory.");
    }
    usage_error("$sbo.info is non-empty, but could not be read.");
  }

  my %parse = parse_info($contents);
  unless (%parse) {
    my $new_contents = fix_info($contents);
    %parse = parse_info($new_contents);
    script_error("Error when parsing file $sbo.info.") unless %parse;
  }

  foreach my $k (keys %parse) { $store{$args{LOCATION}}->{$k} = $parse{$k}; }

  # allow local overrides to get away with not having quite all the fields
  if (is_local($sbo)) {
    for my $key (qw/DOWNLOAD_x86_64 MD5SUM_x86_64 REQUIRES/) {
      $store{$args{LOCATION}}->{$key} //= ['']; # if they don't exist, treat them as empty
    }
  }
  my @optional = get_optional($sbo);
  if (@optional) {
    for my $requested (@optional) {
      if ($store{$args{LOCATION}}->{REQUIRES}[0] eq '') {
        $store{$args{LOCATION}}->{REQUIRES}[0] = $requested;
      } else {
        push @{ $store{$args{LOCATION}}->{REQUIRES} }, $requested;
      }
    }
  }
  if ($store{$args{LOCATION}}->{REQUIRES}[0]) {
    my @compat = @{ $store{$args{LOCATION}}->{REQUIRES} };
    my $first = shift @compat;
    $store{$args{LOCATION}}->{REQUIRES_C32}[0] = "$first-compat32";
    $store{$args{LOCATION}}->{REQUIRES_X32}[0] = "$first-compat32";
    for (@compat) {
      push @{ $store{$args{LOCATION}}->{REQUIRES_C32} }, "$_-compat32";
      push @{ $store{$args{LOCATION}}->{REQUIRES_X32} }, "$_-compat32";
    }
    push @{ $store{$args{LOCATION}}->{REQUIRES_C32} }, $sbo;
  } else {
    $store{$args{LOCATION}}->{REQUIRES_C32}[0] = $sbo;
    $store{$args{LOCATION}}->{REQUIRES_X32}[0] = '';
  }

  return $store{$args{LOCATION}}->{$args{GET}};
}

=head2 get_orig_build_number

  my $build = get_orig_build_number($sbo);

C<get_orig_build_number()> returns the build number in the SlackBuilds.org tree for the
given C<$sbo>, calling C<get_sbo_build_number()>.

=cut

sub get_orig_build_number {
  script_error('get_orig_build_number requires an argument.') unless @_ == 1;
  my $sbo = shift;

  my $location = get_orig_location($sbo);

  return undef unless defined $location;

  return get_sbo_build_number($location);
}

=head2 get_orig_version

  my $ver = get_orig_version($sbo);

C<get_orig_version()> returns the version in the SlackBuilds.org tree for the
given C<$sbo>, calling C<get_sbo_version()>.

This subroutine is used only by C<sbocheck(1)>.

=cut

sub get_orig_version {
  script_error('get_orig_version requires an argument.') unless @_ == 1;
  my $sbo = shift;

  my $location = get_orig_location($sbo);

  return undef unless defined $location;

  return get_sbo_version($location);
}

=head2 get_requires

  my $reqs = get_requires($sbo);

C<get_requires()> returns the requirements for a given C<$sbo>.

=cut

# wrapper to pull the list of requirements for a given sbo
sub get_requires {
  my $sbo = shift;
  my $location = get_sbo_location($sbo);
  return undef unless $location;
  my $targ = "REQUIRES";
  if ($arch eq "x86_64") {
    $targ = $sbo =~ m/-compat32$/ ? "REQUIRES_C32" :
    (check_x32($location) ? "REQUIRES_X32" : $targ);
  }
  my $info = get_from_info(LOCATION => $location, GET => $targ);
  return $info;
}

=head2 get_reverse_reqs

  my %required_by = get_reverse_reqs($slackbuilds);

C<get_reverse_reqs()> takes a list of SlackBuilds and returns a hashref with
reverse dependencies among them. C<$slackbuilds> should ordinarily
be a list of all installed scripts.

=cut

sub get_reverse_reqs {
  my $slackbuilds = shift;
  my %required_by;

  my @packs = keys %$slackbuilds;
  for my $sbo (keys %$slackbuilds) {
    for my $req (@{ get_requires($sbo) }) {
      $required_by{$req}{$sbo} = 1 if exists $slackbuilds->{$req};
    }
  }

  return \%required_by;
}

=head2 get_sbo_build_number

  my $build = get_sbo_build_number($location);

C<get_sbo_build_number()> returns the build number found in the SlackBuild in
C<$location>.

=cut

# find the build number in the tree for a given sbo (provided a location)
sub get_sbo_build_number {
  script_error('get_sbo_build_number requires an argument.') unless @_ == 1;

  my $location = shift;
  my $sbo = get_sbo_from_loc($location);
  my $build;

  my ($fh, $exit) = open_read("$location/$sbo.SlackBuild");
  error_code("get_sbo_build_number: could not read $location/$sbo.SlackBuild.", $exit) if $exit;

  while (my $line = <$fh>) {
    $build = $line if $line =~ m/^BUILD=/;
    last if $build;
  }
  close $fh;

  $build =~ s/\D//g;

  return $build;
}

=head2 get_sbo_version

  my $ver = get_sbo_version($location);

C<get_sbo_version()> returns the version found in the info file in
C<$location>.

=cut

# find the version in the tree for a given sbo (provided a location)
sub get_sbo_version {
  script_error('get_sbo_version requires an argument.') unless @_ == 1;
  my $version = get_from_info(LOCATION => shift, GET => 'VERSION');
  return $version->[0];
}

=head2 ineligible_compat

  my $msg = ineligible_compat($location);

C<ineligible_compat()> takes a script's location and returns a diagnostic message if
it is ineligible for a C<compat32> package. C<noarch>, Perl-based and one-architecture
scripts are all ineligible.

=cut

sub ineligible_compat {
  script_error("ineligible_compat requires an argument.") unless @_ == 1;
  my $sbo_location = shift;
  my $sbo = get_sbo_from_loc($sbo_location);
  my ($perl_ineligible, $arch_ineligible, $only_64, $only_32);
  my $orig_location = get_orig_location($sbo);
  my $check_location = $orig_location ? $orig_location : $sbo_location;
  $perl_ineligible = 1 if $sbo =~ /^perl-/ or basename(dirname($check_location)) eq "perl";
  $only_64 = check_x64 $check_location;
  $only_32 = check_x32 $check_location;
  unless ($perl_ineligible or $only_64 or $only_32) {
    my ($fh, $exit) = open_read("$sbo_location/$sbo.SlackBuild");
    unless ($exit) {
      for my $line (<$fh>) {
        $perl_ineligible = 1 if $line =~ /perl (Makefile|Build).PL/;
        $arch_ineligible = 1 if $line =~ /ARCH=noarch/;
      }
      close $fh;
    }
  }
  return unless $perl_ineligible or $arch_ineligible or $only_64 or $only_32;
  return "$sbo is 64-bit only; skipping compat32." if $only_64;
  return "$sbo is 32-bit only; skipping compat32." if $only_32;
  return "$sbo is Perl-based; skipping compat32." if $perl_ineligible;
  return "$sbo is a noarch script; skipping compat32." if $arch_ineligible;
}

=head2 parse_info

  my %parse = parse_info($str);

C<parse_info()> parses the contents of an info file from C<$str> and returns
a key-value list of all values present.

In case of failure, use C<fix_info()> on the offending file and try again.

=cut

sub parse_info {
    script_error('parse_info requires an argument.') unless @_ == 1;
    my $info_str = shift;

    my $pos = 0;
    my %ret;

    while ($info_str =~ /\G([A-Za-z0-9_]+)="([^"]*)"\s*(?:\n|\z)/g) {
        my ($key, $val) = ($1, $2);
        $val =~ s/\\[ \t]*$/ /mg;
        my @val = split " ", $val;
        @val = '' unless @val;
        $ret{$key} = \@val;
        $pos = pos($info_str);
    }

    return if $pos != length($info_str);

    return %ret;

}

=head1 EXIT CODES

Info.pm subroutines can return the following exit codes:

  _ERR_USAGE         1   usage errors
  _ERR_SCRIPT        2   script or module bug
  _ERR_OPENFH        6   failure to open file handles

=head1 SEE ALSO

SBO::Lib(3), SBO::Lib::Build(3), SBO::Lib::Download(3), SBO::Lib::Pkgs(3), SBO::Lib::Readme(3), SBO::Lib::Repo(3), SBO::Lib::Solibs(3), SBO::Lib::Tree(3), SBO::Lib::Util(3)

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
