# Download

[NAME](#name)\
[SYNOPSIS](#synopsis)\
[SUBROUTINES](#subroutines)\
[check_distfiles](#check_distfiles)\
[compute_md5sum](#compute_md5sum)\
[create_symlinks](#create_symlinks)\
[get_distfile](#get_distfile)\
[get_dl_fns](#get_dl_fns)\
[get_filename_from_link](#get_filename_from_link)\
[get_sbo_downloads](#get_sbo_downloads)\
[get_symlink_from_filename](#get_symlink_from_filename)\
[verify_distfile](#verify_distfile)\
[EXIT CODES](#exit-codes)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[LICENSE](#license)

------------------------------------------------------------------------

## NAME

SBO::Lib::Download − Routines for downloading SlackBuild sources.

## SYNOPSIS

    use SBO::Lib::Download qw/ check_distfiles /;\
    my ($ret, $exit) = check_distfiles(LOCATION =\> $loc);

## SUBROUTINES

### check_distfiles

    my ($ret, $exit) = check_distfiles(LOCATION =\> $loc);

check_distfiles() gets the list of downloads from \$loc. Any
previously-downloaded files have their checksums verified. Missing and
unverifiable files are downloaded to md5sum−designated directories and
verified. Finally, create_symlinks() is run on each download.

In case of success, an array of symlinks from create_symlinks() is
returned. In case of failure, an error message and an exit code are
returned.

### compute_md5sum

    my $md5sum = compute_md5sum($file);

compute_md5sum() computes and returns the md5sum of the file in \$file.

### create_symlinks

    my \@symlinks = \@{ create_symlinks($location, {\%downloads}) };

create_symlinks() creates symlinks for the an array %downloads in
\$location, returning an array reference of the symlinks created.

### get_distfile

    my ($msg, $err) = get_distfile($link, $md5);

get_distfile() downloads from the URL \$link with wget(1) and compares
the md5sum to \$md5. The file is saved in an md5sum−designated
directory. The subroutine returns a message and an error code upon
failure, and 1 upon success.

### get_dl_fns

    my \@filenames = \@{ get_dl_fns([@links]) };

get_dl_fns() returns the filenames of the items in \@links in an array
reference.

### get_filename_from_link

    my $path = get_filename_from_link($link, $md5);

get_filename_from_link() returns the full path to the file downloaded
from \$link, given its required md5sum, \$md5.

### get_sbo_downloads

    my %downloads = %{ get_sbo_downloads(LOCATION =\> $loc) };

get_sbo_downloads() gets the download links and md5sums for the
SlackBuild in location \$loc, returning them in a hash reference.

### get_symlink_from_filename

    my $symlink = get_symlink_from_filename($path, $loc);

get_symlink_from_filename(), given a source file at \$path and a
location \$loc, returns the path of the generated symlink.

### verify_distfile

    my $bool = verify_distfile($link, $md5);

verify_distfile() verifies that the file downloaded from \$link has an
md5sum equal to \$md5.

## EXIT CODES

Download.pm subroutines can return the following exit codes:

    \_ERR_SCRIPT 2 script or module bug\
    \_ERR_MD5SUM 4 download verification failure\
    \_ERR_DOWNLOAD 5 download failure\
    \_ERR_NOINFO 7 missing download information

## SEE ALSO

[SBO::Lib(3)](Lib.3.md), [SBO::Lib::Build(3)](Build.3.md), [SBO::Lib::Info(3)](Info.3.md),
[SBO::Lib::Pkgs(3)](Pkgs.3.md), [SBO::Lib::Pkgs(3)](Pkgs.3.md), [SBO::Lib::Readme(3)](Readme.3.md),
[SBO::Lib::Repo(3)](Repo.3.md), [SBO::Lib::Tree(3)](Tree.3.md), [SBO::Lib::Util(3)](Util.3.md)

## AUTHORS

SBO::Lib was originally written by Jacob Pipkin \<j (at) dawnrazor (dot)
net\> with contributions from Luke Williams \<xocel (at) iquidus (dot)
org\> and Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot)
com\>.

SBO::Lib is maintained by K. Eugene Carlson \<kvngncrlsn (at) gmail
(dot) com\>.

## LICENSE

The sbotools are licensed under the MIT License.

Copyright (C) 2012−2017, Jacob Pipkin, Luke Williams, Andreas
Guldstrand.

Copyright (C) 2024−2025, K. Eugene Carlson.

------------------------------------------------------------------------
