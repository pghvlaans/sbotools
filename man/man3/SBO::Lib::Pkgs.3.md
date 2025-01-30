# SBO::Lib::Pkgs

[NAME](#name)\
[SYNOPSIS](#synopsis)\
[SUBROUTINES](#subroutines)\
[get_available_updates](#get_available_updates)\
[get_inst_names](#get_inst_names)\
[get_installed_cpans](#get_installed_cpans)\
[get_installed_packages](#get_installed_packages)\
[get_local_outdated_versions](#get_local_outdated_versions)\
[get_removed_builds](#get_removed_builds)\
[EXIT CODES](#exit-codes)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[LICENSE](#LICENSE)\

------------------------------------------------------------------------

## NAME

SBO::Lib::Pkgs − Routines for interacting with the Slackware package
database.

## SYNOPSIS

use SBO::Lib::Pkgs qw/ get_installed_packages /;\
my \@installed_sbos = get_installed_packages(\'SBO\');

## SUBROUTINES

### get_available_updates

my \@updates = \@{ get_available_updates() };

get_available_updates() compares version and build number information
for packages installed with the \_SBo tag with the local repository. It
returns an array reference to an array of hash references specifying
package names, installed versions and available versions.

### get_inst_names

my \@names = get_inst_names(get_available_updates());

get_inst_names() returns a list of package names from an array
reference, such as one returned by get_available_updates().

### get_installed_cpans

my \@cpans = \@{ get_installed_cpans() };

get_installed_cpans() returns an array reference to a list of Perl
modules installed from the CPAN. This is used in [sboinstall(1)](sboinstall.1.md) to
prevent conflicting installations from the CPAN and SlackBuilds.

### get_installed_packages

my \@packages = \@{ get_installed_packages(\$type) };

get_installed_packages() returns an array reference to a list of
installed packages matching the specified \$type. The available types
are \"STD\" for non-SBo packages, \"SBO\" for in-tree \_SBo packages,
\"DIRTY\" for out-of-tree \_SBo packages and \"ALL\" for all.

The returned array reference holds a list of hash references
representing the names, versions and full installed package names of the
returned packages.

### get_local_outdated_versions

my \@outdated = get_local_outdated_versions(\$filter);

get_local_outdated_versions() checks installed SBo packages from
\"LOCAL_OVERRIDES\". It returns an array with information about those
that have version or build numbers differing from the local repository
or the SlackBuild in \"LOCAL_OVERRIDES\".

Build number differences with the SBo repository are returned, but are
currently unused. This subroutine is used only by [sbocheck(1)](sbocheck.1.md).

### get_removed_builds

my \@removed = get_removed_builds();

get_removed_builds() returns an array of SlackBuild names and versions
of all out-of-tree installed packages marked \"\_SBo\".

## EXIT CODES

Pkgs.pm subroutines can return the following exit code:

\_ERR_SCRIPT 2 script or module bug

## SEE ALSO

[SBO::Lib(3)](SBO::Lib.3.md), [SBO::Lib::Build(3)](SBO::Lib::Build.3.md), [SBO::Lib::Download(3)](SBO::Lib::Download.3.md),
[SBO::Lib::Info(3)](SBO::Lib::Info.3.md), [SBO::Lib::Pkgs(3)](SBO::Lib::Pkgs.3.md), [SBO::Lib::Readme(3)](SBO::Lib::Readme.3.md),
[SBO::Lib::Repo(3)](SBO::Lib::Repo.3.md), [SBO::Lib::Tree(3)](SBO::Lib::Tree.3.md), [SBO::Lib::Util(3)](SBO::Lib::Util.3.md)

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
