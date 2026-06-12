package SBO::Lib::Download;

# vim: ts=2:et

use 5.016;
use strict;
use warnings;

our $VERSION = '4.2';

use SBO::Lib::Util qw/ :colors :config :const :times script_error error_code get_sbo_from_loc check_distfiles_dir open_read wrapsay_color /;
use SBO::Lib::Info qw/ get_download_info /;

use Cwd;
use Digest::MD5;
use Exporter 'import';
use File::Basename;
use File::Copy qw/ move /;
use File::Find;
use SBO::ThirdParty::File::Copy::Recursive qw/ dircopy /;
use File::Path qw/ make_path remove_tree /;
use File::Temp qw/ tempdir /;
use Time::HiRes qw/ time /;
use URI::Escape qw/ uri_unescape /;

our @EXPORT_OK = qw{
  check_distfiles
  check_manual
  compute_md5sum
  get_distfile
  get_filename_from_link
  get_sbo_downloads
  get_hardlink_from_filename
  prepare_staging
  stage
  unstage
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

  my ($ret, $exit) = check_distfiles(LOCATION => $loc, NO_DL => $no_dl);

=head1 SUBROUTINES

=cut

=head2 check_distfiles

  my ($ret, $exit) = check_distfiles(LOCATION => $loc, NO_DL => $no_dl);

C<check_distfiles()> gets the list of downloads from C<$loc>. Any previously-downloaded
files have their checksums verified. Unless there is a C<NO_DL> argument, missing and
unverifiable files are downloaded to md5sum-designated directories and verified.
Finally, C<prepare_staging()> is run on the downloads.

In case of success, a hash of source files and destinations from C<prepare_staging()> is
returned. The subroutine returns empty if the SlackBuild did not contain any downloads.
In case of failure, an error message and an exit code are returned.

If there is an argument C<NO_DL>, 1 is returned if all sources are verified and 0
otherwise.

=cut

# for the given location, pull list of downloads and check to see if any exist;
# if so, verify they md5 correctly and if not, download them and check the new
# download's md5sum, then create a hash with required file moves.
sub check_distfiles {
  my %args = (
    LOCATION  => '',
    COMPAT32  => 0,
    NO_DL     => 0,
    @_
  );
  $args{LOCATION} or script_error('check_distfiles requires LOCATION.');

  my $location = $args{LOCATION};
  my $no_dl = $args{NO_DL};
  my $sbo = get_sbo_from_loc($location);
  my $downloads = get_sbo_downloads(
    LOCATION => $location,
    32 => $args{COMPAT32}
  );
  # return empty if no files are specified (1 in the no-download case)
  if ($no_dl) {
    return 1 unless keys %$downloads > 0;
  } else {
    return unless keys %$downloads > 0;
  }
  for my $link (keys %$downloads) {
    my $md5 = $downloads->{$link};
    unless (verify_distfile($link, $md5)) {
      if ($no_dl) {
        return 0;
      } else {
        my ($fail, $exit) = get_distfile($link, $md5);
        return $fail, $exit if $exit;
      }
    }
  }
  if ($no_dl) {
    return 1;
  } else {
    my $moves = prepare_staging($downloads);
    return $moves;
  }
}

=head2 check_manual

  my $manual_file = check_manual($filename, $info_md5);

C<check_manual()> checks for a file C<$filename> with md5sum C<$info_md5> in
C<SBO_HOME/distfiles/manual>. It returns the path to this file if it exists
and 0 otherwise.

=cut

# check whether a file with a given md5sum exists in SBO_HOME/distfiles/manual
sub check_manual {
  script_error('check_manual requires two arguments.') unless @_ == 2;
  my ($filename, $info_md5) = @_;
  $filename = "$manual_dir/" . basename $filename;
  if (-f $filename) {
    my $md5sum = compute_md5sum($filename);
    return $md5sum eq $info_md5 ? $filename : 0;
  }
  return 0;
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
  check_distfiles_dir();
  mkdir "$distfiles_dir/$info_md5" unless -d "$distfiles_dir/$info_md5";
  chdir "$distfiles_dir/$info_md5";
  unlink $filename if -f $filename;
  my $info_filename = _get_fname($link, $info_md5);
  my $file_check = basename $info_filename;
  my $use_content_disposition = $file_check =~ /[?;]/ ? 1 : 0;
  my $fail = {};

  my $download_start = time();
  #  if wget $link && verify, return
  #  else wget sbosrcarch && verify
  my $wget_res;
  if ($use_content_disposition) {
    $wget_res = system('wget', '--tries=5', '--content-disposition', $link) == 0;
  } else {
    $wget_res = system('wget', '--tries=5', $link) == 0;
  }
  unless ($wget_res) {
    $fail->{msg} = "Unable to wget $link.";
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
    $fail->{msg} = "The md5sum could not be verified for $filename.";
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

=head2 get_filename_from_link

  my $path = get_filename_from_link($link, $md5);

C<get_filename_from_link()> returns the full path to the file downloaded from
C<$link>, given its required md5sum, C<$md5>.

=cut

sub get_filename_from_link {
  script_error('get_filename_from_link requires two arguments.') unless @_ == 2;
  my $filename = _get_fname(@_);
  return undef unless defined $filename;
  if ($filename =~ /[?;]f(|n)=/) {
    my $md5sum = dirname $filename;
    my @filename = split /[?;]/, $filename;
    for (@filename) {
      if ($_ =~ /^f(|n)=/) {
        $_ =~ s/^f(|n)=//;
        $filename = "$md5sum/$_";
        last;
      }
    }
  }
  return "$distfiles_dir/$filename";
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
  my $dl_info;
  if ($arch eq 'x86_64') {
    $dl_info = get_download_info(LOCATION => $location) unless $args{32};
  }
  unless (keys %$dl_info > 0) {
    $dl_info = get_download_info(LOCATION => $location, X64 => 0);
  }
  return $dl_info;
}

=head2 get_hardlink_from_filename

  my $destination = get_hardlink_from_filename($path, $staging);

C<get_hardlink_from_filename()>, given a source file at C<$path> and a location C<$staging>,
returns the destination path for linking the file.

=cut

# for a given distfile, figure out what the full path to its temporary location will be
sub get_hardlink_from_filename {
  script_error('get_hardlink_from_filename requires two arguments.') unless @_ == 2;
  script_error('get_hardlink_from_filename first argument is not a file.') unless -f $_[0];
  my ($filename, $staging) = @_;
  return "$staging/". basename $filename;
}

=head2 prepare_staging

  my $destinations = prepare_staging({%downloads});

C<prepare_staging()> prepares a hash of files and their proper names based on
C<%downloads> for use during the build in a staging directory.

=cut

# given a location and a list of download links, prepare a hash of files to be moved
sub prepare_staging {
  script_error('prepare_staging requires one argument.') unless @_ == 1;
  my ($downloads) = @_;
  my $sources;
  for my $link (keys %$downloads) {
    my $md5 = $downloads->{$link};
    my $filename = get_filename_from_link($link, $md5);
    my $manual_filename = check_manual($filename, $md5);
    $filename = $manual_filename if $manual_filename;
    $sources->{$link} = $filename;
  }
  return $sources;
}

=head2 stage

  stage($location, $distfiles);

C<stage()> takes a location and a hash of distfiles to create the staging directory for
a build; the SlackBuild directory is copied over and hardlinks to the required source
files are created. It returns the location of the staging directory if it can be created
and 0 otherwise.

The script exits if the C<distfiles> directory is malformed or the source file or directory
is a symlink.

=cut

sub stage {
  script_error('stage requires two arguments.') unless @_ == 2;
  script_error('stage must be run by root.') unless $< == 0;
  check_distfiles_dir();
  my ($location, $distfiles) = @_;
  my @sources;
  push @sources, dirname $distfiles->{$_} for keys %$distfiles;
  find { wanted => sub { error_code("Symlink found at $File::Find::name. Please remove it and try again.", _ERR_SBO_HOME) if -l; },
         no_chdir => 1,
         follow => 0 }, @sources if @sources;
  $stage_dir = tempdir(DIR => $distfiles_dir, TEMPLATE => "XXXXXX");
  my $staging = "$stage_dir/" . basename $location;
  dircopy $location, $staging or return 0;
  for my $link (keys %$distfiles) {
    my $source = $distfiles->{$link};
    my $file = "$staging/" . basename $source;
    unlink $file;
    link $source, $file;
  }
  return $staging;
}

=head2 unstage

  my $res = unstage();

C<unstage()> is a shorthand subroutine for the removal of the staging directory when building
is complete or upon signal. It has no useful return value.

=cut

sub unstage {
  remove_tree $stage_dir if -d $stage_dir;
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
  if (check_manual($filename, $info_md5)) {
    my $msg_filename = basename $filename;
    wrapsay_color $color_notice, "Using $msg_filename from the manual downloads directory.", 1;
    return 1;
  }
  return() unless -f $filename;
  my $md5sum = compute_md5sum($filename);
  return $info_md5 eq $md5sum ? 1 : 0;
}

=head1 EXIT CODES

Download.pm subroutines can return the following exit codes:

  _ERR_SCRIPT        2   script or module bug
  _ERR_MD5SUM        4   download verification failure
  _ERR_DOWNLOAD      5   download failure
  _ERR_OPENFH        6   failure to open file handles
  _ERR_NOINFO        7   missing download information
  _ERR_SBO_HOME      17  could not give SBO_HOME valid contents

=head1 SEE ALSO

SBO::Lib(3), SBO::Lib::Build(3), SBO::Lib::Info(3), SBO::Lib::Pkgs(3), SBO::Lib::Readme(3), SBO::Lib::Repo(3), SBO::Lib::Solibs(3), SBO::Lib::Tree(3), SBO::Lib::Util(3), wget(1)

=head1 AUTHORS

SBO::Lib was originally written by Jacob Pipkin <jacob.pipkin@icloud.com> with
contributions from Luke Williams <xocel@iquidus.org> and Andreas
Guldstrand <andreas.guldstrand@gmail.com>.

=head1 MAINTAINER

SBO::Lib is maintained by K. Eugene Carlson <kvngncrlsn@gmail.com>.

=head1 LICENSE

The sbotools are licensed under the MIT License.

Copyright (C) 2012-2017, Jacob Pipkin, Luke Williams, Andreas Guldstrand.

Copyright (C) 2024-2026, K. Eugene Carlson.

Copyright (C) 2026, K. Eugene Carlson, Jacob Pipkin.

=cut

# given a link, grab the filename from it and prepend $distfiles
sub _get_fname {
  my ($fn, $md5) = @_;
  my $filename = uri_unescape $fn;
  $filename = basename $filename;
  return "$md5/$filename";
}

1;
