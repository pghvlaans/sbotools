# SBO::Lib::Tree

[NAME](#name)\
[SYNOPSIS](#synopsis)\
[SUBROUTINES](#subroutines)\
[get_orig_location](#get_orig_location)\
[get_sbo_location](#get_sbo_location)\
[get_sbo_locations](#get_sbo_locations)\
[is_local](#is_local)\
[EXIT CODES](#exit-codes)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[LICENSE](#LICENSE)\

------------------------------------------------------------------------

## NAME

SBO::Lib::Tree − Routines for interacting with a SlackBuilds.org tree.

## SYNOPSIS

use SBO::Lib::tree qw/ is_local /;\
my \$bool = is_local(\$sbo);

## SUBROUTINES

### get_orig_location

my \$loc = get_orig_location(\$sbo);

get_orig_location() returns the location in the SlackBuilds.org tree for
the given \$sbo.

### get_sbo_location

my \$loc = get_sbo_location(\$sbo, \...);\
my \$loc = get_sbo_location([\$sbo, \...]);

get_sbo_location() returns the location in \"LOCAL_OVERRIDES\" or the
SlackBuilds.org tree for the first \$sbo given.

Specifying more than one \$sbo is useful only for accessing the
filesystem once when searching or populating the internal cache. No code
does this currently.

### get_sbo_locations

my %locations = get_sbo_locations(@sbos);

\"get_sbo_locations\" finds all SlackBuilds in \@sbos and returns a hash
matching each package name to its location.

### is_local

my \$bool = is_local(\$sbo);

is_local() checks whether the given \$sbo is in the \"LOCAL_OVERRIDES\"
directory. The return value is true if it is, and false if it is not.

## EXIT CODES

Tree.pm subroutines can return the following exit code:

\_ERR_SCRIPT 2 script or module bug

## SEE ALSO

[SBO::Lib(3)](SBO::Lib.3.md), [SBO::Lib::Build(3)](SBO::Lib::Build.3.md), [SBO::Lib::Download(3)](SBO::Lib::Download.3.md),
[SBO::Lib::Info(3)](SBO::Lib::Info.3.md), [SBO::Lib::Pkgs(3)](SBO::Lib::Pkgs.3.md), [SBO::Lib::Pkgs(3)](SBO::Lib::Pkgs.3.md),
[SBO::Lib::Readme(3)](SBO::Lib::Readme.3.md), [SBO::Lib::Repo(3)](SBO::Lib::Repo.3.md), [SBO::Lib::Util(3)](SBO::Lib::Util.3.md)

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
