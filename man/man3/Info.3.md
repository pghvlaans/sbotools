# Info

[NAME](#name)\
[SYNOPSIS](#synopsis)\
[SUBROUTINES](#subroutines)\
[check_x32](#check_x32)\
[get_download_info](#get_download_info)\
[get_from_info](#get_from_info)\
[get_orig_build_number](#get_orig_build_number)\
[get_orig_version](#get_orig_version)\
[get_requires](#get_requires)\
[get_reverse_reqs](#get_reverse_reqs)\
[get_sbo_build_number](#get_sbo_build_number)\
[get_sbo_version](#get_sbo_version)\
[parse_info](#parse_info)\
[EXIT CODES](#exit-codes)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[LICENSE](#license)\

------------------------------------------------------------------------

## NAME

SBO::Lib::Info − Utilities to get data from SBo info files.

## SYNOPSIS

use SBO::Lib::Info qw/ get_reqs /;\
my \@reqs = \@{ get_requires(\$sbo) };

## SUBROUTINES

### check_x32

my \$bool = check_x32(\$location);

check_x32() returns a true value if the SlackBuild in \$location
considers 64−bit builds \"UNTESTED\" or \"UNSUPPORTED\". Otherwise, it
returns a false value.

### get_download_info

my \$downloads = get_download_info(LOCATION =\> \$location, X64 =\>
\$x64);\
my \$downloads = get_download_info(LOCATION =\> \$location);

get_download_info() reads in an info file from \$location. The flag
\$x64 determines whether the 64−bit download files should be used or
not. \$x64 defaults to a true value if unspecified.

This subroutine returns a hashref where each key is a download link; the
corresponding value is the expected md5sum.

### get_from_info

my \$data = get_from_info(LOCATION =\> \$location, GET =\> \$key);

get_from_info() retrieves the information under \$key from the info file
in \$location.

### get_orig_build_number

my \$build = get_orig_build_number(\$sbo);

get_orig_build_number() returns the build number in the SlackBuilds.org
tree for the given \$sbo, calling get_sbo_build_number().

### get_orig_version

my \$ver = get_orig_version(\$sbo);

get_orig_version() returns the version in the SlackBuilds.org tree for
the given \$sbo, calling get_sbo_version().

### get_requires

my \$reqs = get_requires(\$sbo);

get_requires() returns the requirements for a given \$sbo.

### get_reverse_reqs

my %required_by = get_reverse_reqs(\$slackbuilds);

get_reverse_reqs() takes a list of SlackBuilds and returns a hashref
with reverse dependencies among them. \$slackbuilds should ordinarily be
a list of all installed scripts.

### get_sbo_build_number

my \$build = get_sbo_build_number(\$location);

get_sbo_build_number() returns the build number found in the SlackBuild
in \$location.

### get_sbo_version

my \$ver = get_sbo_version(\$location);

get_sbo_version() returns the version found in the info file in
\$location.

### parse_info

my %parse = parse_info(\$str);

parse_info() parses the contents of an info file from \$str and returns
a key-value list of all values present. It attempts to repair trailing
whitespace, blank lines, garbage lines and missing quotation marks and
backslashes.

## EXIT CODES

Info.pm subroutines can return the following exit codes:

\_ERR_USAGE 1 usage errors\
\_ERR_SCRIPT 2 script or module bug

## SEE ALSO

[SBO::Lib(3)](Lib.3.md), [SBO::Lib::Build(3)](Build.3.md), [SBO::Lib::Download(3)](Download.3.md),
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
