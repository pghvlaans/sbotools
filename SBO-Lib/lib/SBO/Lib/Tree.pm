package SBO::Lib::Tree;

# vim: ts=2:et

use 5.016;
use strict;
use warnings;

our $VERSION = '3.5';

use SBO::Lib::Util qw/ script_error open_read uniq idx %config /;
use SBO::Lib::Repo qw/ $repo_path $slackbuilds_txt /;

use Exporter 'import';
use File::Basename;

our @EXPORT_OK = qw{
  get_all_available
  get_orig_location
  get_sbo_location
  get_sbo_locations
  is_local
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
my $store;
my %local;
my %orig;

=head2 get_all_available

  my $available = get_all_available();

C<get_all_available()> returns a hash of available scripts based on C<SLACKBUILDS.TXT>
and the contents of the C<LOCAL_OVERRIDES> directory. Keys include C<name> and C<series>.
C<series> is C<local> if the script can be found in C<LOCAL_OVERRIDES>.

=cut

sub get_all_available {
  return 0 unless -s $slackbuilds_txt;
  my @result;
  my ($fh, $exit) = open_read($slackbuilds_txt);
  if ($exit) {
    warn $fh;
    exit $exit;
  }
  FIRST: for my $line (<$fh>) {
    next FIRST unless $line =~ /LOCATION/;
    my @line = split(" ", $line);
    my $candidate = pop @line;
    my $location = $candidate;
    $location =~ s/\./$config{SBO_HOME}\/repo/g;
    my $script = basename($candidate);
    my $series = basename(dirname($candidate));
    push @result, { name => $script, series => $series, location => $location } unless $config{LOCAL_OVERRIDES} ne "FALSE" and -s "$config{LOCAL_OVERRIDES}/$script/$script.info";
  }
  close $fh;
  if ($config{LOCAL_OVERRIDES} ne "FALSE" and -d $config{LOCAL_OVERRIDES}) {
    opendir(my $dh, $config{LOCAL_OVERRIDES});
    while (my $dir = readdir($dh)) {
      next unless -d "$config{LOCAL_OVERRIDES}/$dir";
      push @result, { name => $dir, series => "local", location => "$config{LOCAL_OVERRIDES}/$dir" } if -f "$config{LOCAL_OVERRIDES}/$dir/$dir.info";
    }
    closedir $dh;
  }
  return [ map { +{ name => $_->{name}, series => $_->{series}, location => $_->{location} } } @result ];
}

=head2 get_orig_location

  my $loc = get_orig_location($sbo);

C<get_orig_location()> returns the location in the SlackBuilds.org tree for the
given C<$sbo>.

=cut

sub get_orig_location {
  script_error('get_orig_location requires an argument.') unless @_ == 1;
  my $sbo = shift;
  # Make sure we have checked for the slackbuild in question:
  get_sbo_location($sbo);
  return $orig{$sbo};
}

=head2 get_sbo_location

  my $loc = get_sbo_location($sbo, ...);
  my $loc = get_sbo_location([$sbo, ...]);

C<get_sbo_location()> returns the location in C<LOCAL_OVERRIDES> or the
SlackBuilds.org tree for the first C<$sbo> given.

Specifying more than one C<$sbo> is useful only for accessing the
filesystem once when searching or populating the internal cache. No
code does this currently. If the subroutine is to be called sequentially
on any substantial number of C<$sbo>, calling C<get_sbo_locations()> on
them collectively first is advisable for performance reasons.

=cut

sub get_sbo_location {
  my @sbos = map { s/-compat32$//r } defined $_[0] && ref $_[0] eq 'ARRAY' ? @{ $_[0] } : @_;
  script_error('get_sbo_location requires an argument.') unless @sbos;

  # if we already have the location, return it now.
  return $$store{$sbos[0]} if exists $$store{$sbos[0]};
  my %locations = get_sbo_locations(@sbos);
  return $locations{$sbos[0]};
}

=head2 get_sbo_locations

  my %locations = get_sbo_locations(@sbos);

C<get_sbo_locations> finds all SlackBuilds in C<@sbos> and returns a hash matching each
package name to its location.

=cut

sub get_sbo_locations {
  my @sbos = map { s/-compat32$//r } defined $_[0] && ref $_[0] eq 'ARRAY' ? @{ $_[0] } : @_;
  script_error('get_sbo_locations requires an argument.') unless @_;

  my %locations;

  # if an sbo is already in the $store, set the %location for it and filter it out
  @sbos = grep { exists $$store{$_} ? ($locations{$_} = $$store{$_}, 0) : 1 } @sbos;
  return %locations unless @sbos;

  my ($fh, $exit) = open_read($slackbuilds_txt);
  if ($exit) {
    warn $fh;
    exit $exit;
  }

  while (my $line = <$fh>) {
    my ($loc, $sbo) = $line =~ m!LOCATION:\s+\.(/[^/]+/([^/\n]+))$!
      or next;
    my $found = idx($sbo, @sbos);
    next unless defined $found;

    $$store{$sbo} = $repo_path . $loc;
    $locations{$sbo} = $$store{$sbo};

    splice @sbos, $found, 1;
    last unless @sbos;
  }
  close $fh;

  # after we've checked the regular sbo locations, we'll see if it needs to
  # be overridden by a local change
  my $local = $config{LOCAL_OVERRIDES};
  unless ( $local eq 'FALSE' or not -d $local ) {
    for my $sbo (@sbos, keys %locations) {
      my $loc = "$local/$sbo";
      next unless -d $loc;
      $$store{$sbo} = $loc;
      $orig{$sbo} //= $locations{$sbo};
      $locations{$sbo} = $loc;
      $local{$sbo} = $local;
    }
  }

  return %locations;
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

=head1 EXIT CODES

Tree.pm subroutines can return the following exit code:

  _ERR_SCRIPT        2   script or module bug

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

1;
