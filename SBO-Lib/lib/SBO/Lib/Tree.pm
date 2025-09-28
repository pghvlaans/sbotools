package SBO::Lib::Tree;

# vim: ts=2:et

use 5.016;
use strict;
use warnings;

our $VERSION = '4.0_RC';

use SBO::Lib::Util qw/ error_code script_error open_read uniq in %config /;
use SBO::Lib::Repo qw/ $repo_path $slackbuilds_txt /;

use Exporter 'import';
use File::Basename;

use sigtrap qw/ handler _caught_signal ABRT INT QUIT TERM /;

our @EXPORT_OK = qw{
  get_all_available
  get_orig_location
  get_sbo_description
  get_sbo_location
  get_sbo_locations
  is_local
  renew_sbo_locations

  $descriptions_generated
};

our %EXPORT_TAGS = (
  all => \@EXPORT_OK,
);

=pod

=encoding UTF-8

=head1 NAME

SBO::Lib::Tree - Routines for interacting with a SlackBuilds.org tree.

=head1 SYNOPSIS

  use SBO::Lib::tree qw/ is_local /;

  my $bool = is_local($sbo);

=head1 SUBROUTINES

=cut

# private variables needed by most subroutines
my (%store, %local, %orig, %descriptions, @available);
my $ran_locations = 0;
# indicates whether SLACKBUILDS.TXT has description lines
our $descriptions_generated = 0;

=head2 get_all_available

  my @available = get_all_available();

C<get_all_available()> returns an array of available scripts based on C<SLACKBUILDS.TXT>
and the contents of the C<LOCAL_OVERRIDES> directory. This subroutine may be called
in lieu of C<get_sbo_locations()> near the start of the script.

=cut

sub get_all_available {
  unless (-s $slackbuilds_txt) {
    $ran_locations = 1;
    return 0;
  }
  get_sbo_locations() unless $ran_locations;
  return @available;
}

=head2 get_orig_location

  my $loc = get_orig_location($sbo);

C<get_orig_location()> returns the location in the SlackBuilds.org tree for the
given C<$sbo>. Ensure that either C<get_sbo_locations()> or C<get_all_available()>
is run before attempting C<get_orig_location()>.

=cut

sub get_orig_location {
  script_error('get_orig_location requires an argument.') unless @_ == 1;
  script_error('get_sbo_locations or get_all_available must be run before get_orig_location.') unless $ran_locations;
  my $sbo = shift;
  $sbo =~ s/-compat32//;
  return $orig{$sbo};
}

=head2 get_sbo_description

  my $description = get_sbo_description($sbo);

C<get_sbo_description()> returns the short description for C<$sbo>. Ensure that either
C<get_sbo_locations()> or C<get_all_available()> is run before attempting
C<get_sbo_description()>.

=cut

sub get_sbo_description {
  script_error('get_sbo_description requires an argument.') unless @_ == 1;
  script_error('get_sbo_locations or get_all_available must be run before get_sbo_description.') unless $ran_locations;
  my $sbo = shift;
  $sbo =~ s/-compat32$//;
  return $descriptions{$sbo} if exists $descriptions{$sbo};
  return undef;
}

=head2 get_sbo_location

  my $loc = get_sbo_location($sbo);

C<get_sbo_location()> returns the location in C<LOCAL_OVERRIDES> or the
SlackBuilds.org tree for C<$sbo>. Ensure that either C<get_sbo_locations()>
or C<get_all_available()> is run before attempting C<get_sbo_location()>.

=cut

sub get_sbo_location {
  my $sbo = shift;
  $sbo =~ s/-compat32//;
  script_error('get_sbo_location requires an argument.') unless $sbo;
  script_error('get_sbo_locations or get_all_available must be run before get_sbo_location.') unless $ran_locations;

  return $store{$sbo} if exists $store{$sbo};
  return undef;
}

=head2 get_sbo_locations

  my %locations = get_sbo_locations();

C<get_sbo_locations> finds all SlackBuilds in C<@sbos> and returns a hash matching each
package name to its location. After C<get_sbo_locations()> has been run for the first time,
it simply returns the hash again in subsequent calls.

The descriptions hash is populated as well on the first run.

=cut

sub get_sbo_locations {
  return %store if $ran_locations;
  $ran_locations = 1;
  my ($fh, $exit) = open_read($slackbuilds_txt);
  error_code("Failed to open $slackbuilds_txt; exiting.", $exit) if $exit;

  while (my $line = <$fh>) {
    if (my ($loc, $sbo) = $line =~ m!LOCATION:\s+\.(/[^/]+/([^/\n]+))$!) {
      $store{$sbo} = $repo_path . $loc;
      $orig{$sbo} = $store{$sbo};
      push @available, $sbo;
    } elsif (my ($pkg, $description) = $line =~ m/DESCRIPTION:\s+([\S]+)\s+\(([^\n]+)\)$/) {
      $descriptions_generated = 1;
      $descriptions{$pkg} = $description;
    }
  }
  close $fh;

  my $local = $config{LOCAL_OVERRIDES};
  unless ( $local eq 'FALSE' or not -d $local ) {
    for my $loc (glob "$local/*") {
      my $sbo = basename $loc;
      next unless -f "$loc/$sbo.info";
      $store{$sbo} = $loc;
      $local{$sbo} = $local;
      push @available, $sbo unless in $sbo, @available;
      my ($sd_fh, $sd_exit) = open_read("$loc/slack-desc");
      next if $sd_exit;
      while (<$sd_fh>) {
        next unless my ($description) = $_ =~ m/$sbo:\s$sbo\s\(([^\n]+)\)$/;
        $descriptions{$sbo} = $description;
        last;
      }
      close $sd_fh;
    }
  }

  return %store;
}

=head2 is_local

  my $bool = is_local($sbo);

C<is_local()> checks whether the given C<$sbo> (or, for C<compat32>, the base script)
is in the C<LOCAL_OVERRIDES> directory. The return value is true if it is, and false
if it is not.

=cut

sub is_local {
  script_error('is_local requires an argument.') unless @_ == 1;
  my $sbo = shift;
  $sbo =~ s/-compat32$//;
  # Make sure we have checked for the slackbuild in question:
  get_sbo_location($sbo);
  return !!$local{$sbo};
}

=head2 renew_sbo_locations

  my %locations = renew_sbo_locations();

C<renew_sbo_locations()> clears all location- and description-related hashes
and the available script array. It then runs C<get_sbo_locations()> and returns
the new locations hash.

=cut

sub renew_sbo_locations {
  %store = ();
  %local = ();
  %orig = ();
  %descriptions = ();
  splice @available if @available;
  $ran_locations = 0;
  $descriptions_generated = 0;

  get_sbo_locations();
  return %store;
}

=head1 EXIT CODES

Tree.pm subroutines can return the following exit code:

  _ERR_SCRIPT        2   script or module bug
  _ERR_OPENFH        6   failure to open file handles

=head1 SEE ALSO

SBO::Lib(3), SBO::Lib::Build(3), SBO::Lib::Download(3), SBO::Lib::Info(3), SBO::Lib::Pkgs(3), SBO::Lib::Readme(3), SBO::Lib::Repo(3), SBO::Lib::Util(3)

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
