package SBO::Lib::Pkgs;

use 5.016;
use strict;
use warnings;

our $VERSION = '3.4';

use SBO::Lib::Util qw/ %config build_cmp script_error open_read version_cmp /;
use SBO::Lib::Tree qw/ get_sbo_location get_sbo_locations is_local /;
use SBO::Lib::Info qw/ get_orig_build_number get_orig_version get_sbo_build_number get_sbo_version /;

use Exporter 'import';

our @EXPORT_OK = qw{
  get_available_updates
  get_inst_names
  get_installed_cpans
  get_installed_packages
  get_local_outdated_versions
  get_removed_builds
};

our %EXPORT_TAGS = (
  all => \@EXPORT_OK,
);

=pod

=encoding UTF-8

=head1 NAME

SBO::Lib::Pkgs - Routines for interacting with the Slackware package database.

=head1 SYNOPSIS

  use SBO::Lib::Pkgs qw/ get_installed_packages /;

  my @installed_sbos = get_installed_packages('SBO');

=head1 SUBROUTINES

=cut

my $pkg_db = '/var/log/packages';

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

  my @cpans = @{ get_installed_cpans() };

C<get_installed_cpans()> returns an array reference to a list of Perl
modules installed from the CPAN. This is used in C<sboinstall(1)> to
prevent conflicting installations from the CPAN and SlackBuilds.

=cut

# return a list of perl modules installed via the CPAN
sub get_installed_cpans {
  my @contents;
  for my $file (grep { -f $_ } map { "$_/perllocal.pod" } @INC) {
    my ($fh, $exit) = open_read($file);
    next if $exit;
    push @contents, grep {/Module/} <$fh>;
    close $fh;
  }
  my $mod_regex = qr/C<Module>\s+L<([^\|]+)/;
  my (@mods, @vers);
  for my $line (@contents) {
    push @mods, ($line =~ $mod_regex)[0];
  }
  return \@mods;
}

=head2 get_installed_packages

  my @packages = @{ get_installed_packages($type) };

C<get_installed_packages()> returns an array reference to a list of installed packages
matching the specified C<$type>. The available types are C<STD> for non-SBo packages,
C<SBO> for in-tree _SBo packages, C<DIRTY> for out-of-tree _SBo packages and C<ALL> for all.

The returned array reference holds a list of hash references representing
the names, versions and full installed package names of the returned packages.

=cut

# pull an array of hashes, each hash containing the name and version of a
# package currently installed. Gets filtered using STD, SBO, DIRTY or ALL.
sub get_installed_packages {
  script_error('get_installed_packages requires an argument.') unless @_ == 1;
  my $filter = shift;

  # Valid types: STD, SBO
  my (@pkgs, %types);
  foreach my $pkg (glob("$pkg_db/*")) {
    $pkg =~ s!^\Q$pkg_db/\E!!;
    my ($name, $version, $build) = $pkg =~ m#^([^/]+)-([^-]+)-[^-]+-([^-]+)$#
      or next;
    my $numbuild = $build;
    $numbuild =~ s/_SBo(|compat32)$//g ;
    push @pkgs, { name => $name, version => $version, build => $build, numbuild => $numbuild, pkg => $pkg };
    $types{$name} = 'STD';
  }

  # If we want all packages, let's just return them all
  return [ map { +{ name => $_->{name}, version => $_->{version}, build=> $_->{build}, numbuild => $_->{numbuild}, pkg => $_->{pkg} } } @pkgs ]
    if $filter eq 'ALL';

  # Otherwise, SlackBuilds with locations can be marked with SBO, and packages with
  # the _SBo tag but no location can be marked with DIRTY
  my @sbos = map { $_->{name} } grep { $_->{build} =~ m/_SBo(|compat32)$/ }
    @pkgs;
  if (@sbos) {
    my %locations = get_sbo_locations(map { s/-compat32//gr } @sbos);
    foreach my $sbo (@sbos) {
      $types{$sbo} = 'DIRTY';
      if ($locations{ $sbo =~ s/-compat32//gr }) {
         $types{$sbo} = 'SBO';
      }
    }
  }
  return [ map { +{ name => $_->{name}, version => $_->{version}, build => $_->{build}, numbuild => $_->{numbuild}, pkg => $_->{pkg} } }
    grep { $types{$_->{name}} eq $filter } @pkgs ];
}

=head2 get_local_outdated_versions

  my @outdated = get_local_outdated_versions($filter);

C<get_local_outdated_versions()> checks installed SBo packages from C<LOCAL_OVERRIDES>.
It returns an array with information about those that have version or build numbers
differing from the local repository or the SlackBuild in C<LOCAL_OVERRIDES>.

Build number differences with the SBo repository are returned, but are currently unused.
This subroutine is used only by C<sbocheck(1)>.

=cut

sub get_local_outdated_versions {
  script_error('get_local_outdated_versions requires an argument.') unless @_ == 1;
  my $filter = shift;
  my @outdated;

  my $local = $config{LOCAL_OVERRIDES};
  unless ( $local eq 'FALSE' ) {
    my $pkglist = get_installed_packages('SBO');
    my @local = grep { is_local($_->{name}) } @$pkglist;

    foreach my $sbo (@local) {
      my $local_location = get_sbo_location($sbo->{name});
      next if not defined $local_location;
      my $orig = get_orig_version($sbo->{name});
      next if not defined $orig;
      my $orig_build_number = get_orig_build_number($sbo->{name});
      my $local_build_number = get_sbo_build_number($local_location);

      if ($filter eq 'VERS') {
        next if not version_cmp($orig, $sbo->{version});
      } elsif ($filter eq 'BUILD' and defined $local_build_number) {
        if (not build_cmp($local_build_number, $sbo->{numbuild}, $orig, $sbo->{version})) {
	  next;
        }
      } elsif ($filter eq 'BOTH' and defined $local_build_number) {
	if (not build_cmp($local_build_number, $sbo->{numbuild}, $orig, $sbo->{version}) && not version_cmp($orig, $sbo->{version})) {
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

=head1 AUTHORS

SBO::Lib was originally written by Jacob Pipkin <j@dawnrazor.net> with
contributions from Luke Williams <xocel@iquidus.org> and Andreas
Guldstrand <andreas.guldstrand@gmail.com>.

SBO::Lib is maintained by K. Eugene Carlson <kvngncrlsn@gmail.com>.

=head1 LICENSE

The sbotools are licensed under the MIT License.

Copyright (C) 2012-2017, Jacob Pipkin, Luke Williams, Andreas Guldstrand.

Copyright (C) 2024-2025, K. Eugene Carlson.

=cut

1;
