package SBO::Lib::Download;

# vim: ts=2:et

use 5.016;
use strict;
use warnings;

our $VERSION = '3.6';

use SBO::Lib::Util qw/ :const :times script_error get_sbo_from_loc open_read get_arch /;
use SBO::Lib::Repo qw/ $distfiles /;
use SBO::Lib::Info qw/ get_download_info /;

use Cwd;
use Digest::MD5;
use Exporter 'import';
use File::Basename;
use Time::HiRes qw/ time /;
use URI::Escape qw/ uri_unescape /;

our @EXPORT_OK = qw{
  check_distfiles
  compute_md5sum
  create_symlinks
  get_distfile
  get_dl_fns
  get_filename_from_link
  get_sbo_downloads
  get_symlink_from_filename
  verify_distfile
};

our %EXPORT_TAGS = (
  all => \@EXPORT_OK,
);

=pod

=encoding UTF-8

=head1 NAME

SBO::Lib::Download - Routines for downloading SlackBuild sources.

=head1 SYNOPSIS

  use SBO::Lib::Download qw/ check_distfiles /;

  my ($ret, $exit) = check_distfiles(LOCATION => $loc);

=head1 SUBROUTINES

=cut

=head2 check_distfiles

  my ($ret, $exit) = check_distfiles(LOCATION => $loc);

C<check_distfiles()> gets the list of downloads from C<$loc>. Any previously-downloaded
files have their checksums verified. Missing and unverifiable files are downloaded to
md5sum-designated directories and verified. Finally, C<create_symlinks()> is run on each
download.

In case of success, an array of symlinks from C<create_symlinks()> is returned. In case of
failure, an error message and an exit code are returned.

=cut

# for the given location, pull list of downloads and check to see if any exist;
# if so, verify they md5 correctly and if not, download them and check the new
# download's md5sum, then create required symlinks for them.
sub check_distfiles {
  my %args = (
    LOCATION  => '',
    COMPAT32  => 0,
    @_
  );
  $args{LOCATION} or script_error('check_distfiles requires LOCATION.');

  my $location = $args{LOCATION};
  my $sbo = get_sbo_from_loc($location);
  my $downloads = get_sbo_downloads(
    LOCATION => $location,
    32 => $args{COMPAT32}
  );
  # return an error if we're unable to get download info
  unless (keys %$downloads > 0) {
    return "Unable to get download informtion from $location/$sbo.info\n",
      _ERR_NOINFO;
  }
  for my $link (keys %$downloads) {
    my $md5 = $downloads->{$link};
    unless (verify_distfile($link, $md5)) {
      my ($fail, $exit) = get_distfile($link, $md5);
      return $fail, $exit if $exit;
    }
  }
  my $symlinks = create_symlinks($args{LOCATION}, $downloads);
  return $symlinks;
}

=head2 compute_md5sum

  my $md5sum = compute_md5sum($file);

C<compute_md5sum()> computes and returns the md5sum of the file in C<$file>.

=cut

# for a given file, compute its md5sum
sub compute_md5sum {
  script_error('compute_md5sum requires a file argument.') unless -f $_[0];
  my ($fh, $exit) = open_read(shift);
  my $md5 = Digest::MD5->new;
  $md5->addfile($fh);
  my $md5sum = $md5->hexdigest;
  close $fh;
  return $md5sum;
}

=head2 create_symlinks

  my @symlinks = @{ create_symlinks($location, {%downloads}) };

C<create_symlinks()> creates symlinks for the an array C<%downloads> in
C<$location>, returning an array reference of the symlinks created.

=cut

# given a location and a list of download links, assemble a list of symlinks,
# and create them.
sub create_symlinks {
  script_error('create_symlinks requires two arguments.') unless @_ == 2;
  my ($location, $downloads) = @_;
  my @symlinks;
  for my $link (keys %$downloads) {
    my $md5 = $downloads->{$link};
    my $filename = get_filename_from_link($link, $md5);
    my $symlink = get_symlink_from_filename($filename, $location);
    unlink $symlink if -l $symlink;
    push @symlinks, $symlink;
    symlink $filename, $symlink;
  }
  return \@symlinks;
}

=head2 get_distfile

  my ($msg, $err) = get_distfile($link, $md5);

C<get_distfile()> downloads from the URL C<$link> with C<wget(1)> and compares
the md5sum to C<$md5>. The file is saved in an md5sum-designated directory.
The subroutine returns a message and an error code upon failure, and 1 upon success.

=cut

# for a given distfile, attempt to retrieve it and, if successful, check its
# md5sum against that in the sbo's .info file
sub get_distfile {
  script_error('get_distfile requires two arguments.') unless @_ == 2;
  my ($link, $info_md5) = @_;
  my $cwd = getcwd();
  my $filename = get_filename_from_link($link, $info_md5);
  mkdir $distfiles unless -d $distfiles;
  mkdir "$distfiles/$info_md5" unless -d "$distfiles/$info_md5";
  chdir "$distfiles/$info_md5";
  unlink $filename if -f $filename;
  my $fail = {};

  my $download_start = time();
  #  if wget $link && verify, return
  #  else wget sbosrcarch && verify
  if (system('wget', '--tries=5', $link) != 0) {
    $fail->{msg} = "Unable to wget $link.\n";
    $fail->{err} = _ERR_DOWNLOAD;
  }
  if (not %$fail and verify_distfile(@_)) {
    chdir $cwd;
    my $download_finish = time();
    my $download_took = $download_finish - $download_start;
    $download_took = reconcile_time($download_took);
    $download_time += $download_took if $download_took;
    return 1;
  }
  if (not %$fail) {
    $fail->{msg} = "The md5sum could not be verified for $filename.\n";
    $fail->{err} = _ERR_MD5SUM;
  }

  # since the download from the original link either didn't download or
  # didn't verify, try to get it from sbosrcarch instead
  unlink $filename if -f $filename;
  my $sbosrcarch = sprintf(
    "ftp://slackware.uk/sbosrcarch/by-md5/%s/%s/%s",
    substr($info_md5, 0, 1), substr($info_md5, 1, 1), _get_fname($link, $info_md5));

  if (system('wget', '--tries=5', $sbosrcarch) == 0 and
    verify_distfile(@_)) {
    chdir $cwd;
    my $download_finish = time();
    my $download_took = $download_finish - $download_start;
    $download_took = reconcile_time($download_took);
    $download_time += $download_took if $download_took;
    return 1;
  }

  my $download_finish = time();
  my $download_took = $download_finish - $download_start;
  $download_took = reconcile_time($download_took);
  $download_time += $download_took if $download_took;
  chdir $cwd;
  return $fail->{msg}, $fail->{err};
}

=head2 get_dl_fns

  my @filenames = @{ get_dl_fns([@links]) };

C<get_dl_fns()> returns the filenames of the items in C<@links> in an
array reference.

=cut

# given a list of downloads, return just the filenames
sub get_dl_fns {
  my $fns = shift;
  my $return;
  push @$return, basename $_ for @$fns;
  return $return;
}

=head2 get_filename_from_link

  my $path = get_filename_from_link($link, $md5);

C<get_filename_from_link()> returns the full path to the file downloaded from
C<$link>, given its required md5sum, C<$md5>.

=cut

sub get_filename_from_link {
  script_error('get_filename_from_link requires two arguments.') unless @_ == 2;
  my $filename = _get_fname(@_);
  return undef unless defined $filename;
  return "$distfiles/$filename";
}

=head2 get_sbo_downloads

  my %downloads = %{ get_sbo_downloads(LOCATION => $loc) };

C<get_sbo_downloads()> gets the download links and md5sums for the SlackBuild
in location C<$loc>, returning them in a hash reference.

=cut

# TODO: should probably combine this with get_download_info
sub get_sbo_downloads {
  my %args = (
    LOCATION  => '',
    32        => 0,
    @_
  );
  $args{LOCATION} or script_error('get_sbo_downloads requires LOCATION.');
  my $location = $args{LOCATION};
  -d $location or script_error('get_sbo_downloads was given a non-directory.');
  my $arch = get_arch();
  my $dl_info;
  if ($arch eq 'x86_64') {
    $dl_info = get_download_info(LOCATION => $location) unless $args{32};
  }
  unless (keys %$dl_info > 0) {
    $dl_info = get_download_info(LOCATION => $location, X64 => 0);
  }
  return $dl_info;
}

=head2 get_symlink_from_filename

  my $symlink = get_symlink_from_filename($path, $loc);

C<get_symlink_from_filename()>, given a source file at C<$path> and a location C<$loc>,
returns the path of the generated symlink.

=cut

# for a given distfile, figure out what the full path to its symlink will be
sub get_symlink_from_filename {
  script_error('get_symlink_from_filename requires two arguments.') unless @_ == 2;
  script_error('get_symlink_from_filename first argument is not a file.') unless -f $_[0];
  my ($filename, $location) = @_;
  return "$location/". basename $filename;
}

=head2 verify_distfile

  my $bool = verify_distfile($link, $md5);

C<verify_distfile()> verifies that the file downloaded from C<$link> has an
md5sum equal to C<$md5>.

=cut

# for a given distfile, see whether or not it exists, and if so, if its md5sum
# matches the sbo's .info file
sub verify_distfile {
  script_error('verify_distfile requires two arguments.') unless @_ == 2;
  my ($link, $info_md5) = @_;
  my $filename = get_filename_from_link($link, $info_md5);
  return() unless -f $filename;
  my $md5sum = compute_md5sum($filename);
  return $info_md5 eq $md5sum ? 1 : 0;
}

=head1 EXIT CODES

Download.pm subroutines can return the following exit codes:

  _ERR_SCRIPT        2   script or module bug
  _ERR_MD5SUM        4   download verification failure
  _ERR_DOWNLOAD      5   download failure
  _ERR_NOINFO        7   missing download information

=head1 SEE ALSO

SBO::Lib(3), SBO::Lib::Build(3), SBO::Lib::Info(3), SBO::Lib::Pkgs(3), SBO::Lib::Readme(3), SBO::Lib::Repo(3), SBO::Lib::Tree(3), SBO::Lib::Util(3)

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

# given a link, grab the filename from it and prepend $distfiles
sub _get_fname {
  my ($fn, $md5) = @_;
  my $filename = uri_unescape $fn;
  $filename = basename $filename;
  return "$md5/$filename";
}

1;
