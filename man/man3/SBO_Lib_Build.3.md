# SBO::Lib::Build

[NAME](#name)\
[SYNOPSIS](#synopsis)\
[VARIABLES](#variables)\
[\@concluded](#@concluded)\
[\$env_tmp](#$env_tmp)\
[\@reverse_concluded](#@reverse_concluded)\
[\$tempdir](#$tempdir)\
[\$tmpd](#$tmpd)\
[\@upcoming](#@upcoming)\
[SUBROUTINES](#subroutines)\
[do_convertpkg](#do_convertpkg)\
[do_slackbuild](#do_slackbuild)\
[do_upgradepkg](#do_upgradepkg)\
[get_build_queue](#get_build_queue)\
[get_dc_regex](#get_dc_regex)\
[get_full_queue](#get_full_queue)\
[get_full_reverse](#get_full_reverse)\
[get_pkg_name](#get_pkg_name)\
[get_src_dir](#get_src_dir)\
[get_tmp_extfn](#get_tmp_extfn)\
[make_clean](#make_clean)\
[make_distclean](#make_distclean)\
[merge_queues](#merge_queues)\
[perform_sbo](#perform_sbo)\
[process_sbos](#process_sbos)\
[revert_slackbuild](#revert_slackbuild)\
[rewrite_slackbuild](#rewrite_slackbuild)\
[run_tee](#run_tee)\
[EXIT CODES](#exit-codes)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[LICENSE](#license)\

------------------------------------------------------------------------

## NAME

SBO::Lib::Build − Routines for building Slackware packages from
SlackBuilds.org.

## SYNOPSIS

use SBO::Lib::Build qw/ perform_sbo /;\
my (\$foo, \$bar, \$exit) = perform_sbo(LOCATION =\> \$location, ARCH
=\> \'x86_64\');

## VARIABLES

### \@concluded

This is a shared, non-exportable array that tracks scripts with verified
completable build queues; it is used by get_build_queue() to check for
circular dependencies.

### \$env_tmp

This reflects \$TMP from the environment, being \"undef\" if it is not
set.

### \@reverse_concluded

This is a shared, non-exportable array that tracks scripts with verified
reverse dependency chains; it is used by get_full_reverse() to check for
circular reverse dependencies.

### \$tempdir

This is a temporary directory created for sbotools' use. It should be
removed when sbotools exits.

### \$tmpd

This is the same as \$TMP if it is set. Otherwise, it is \"/tmp/SBo\".

### \@upcoming

This is a shared, non-exportable array that contains hashes with the
source files needed by each script in the queue. Each hash drops out of
the array when its corresponding script has been built.

## SUBROUTINES

### do_convertpkg

my (\$name32, \$exit) = do_convertpkg(\$name64);

do_convertpkg() runs \"convertpkg\" on the package in \$name64.

On success, it returns the name of the converted package and an exit
status. On failure, it returns an error message instead of the package
name.

### do_slackbuild

my (\$ver, \$pkg, \$src, \$exit) = do_slackbuild(LOCATION =\>
\$location);

do_slackbuild() makes checks and sets up the perform_sbo() call, running
do_convertpkg() if needed.

A list of four values is returned if successful: version number, package
name, an array with source directories and an exit code. In case of
failure, the first value is an error message; the second and third
values are empty.

### do_upgradepkg

do_upgradepkg(\$pkg);

do_upgradepkg() runs \"upgradepkg −−reinstall −−install−new\" on \$pkg.

There is no useful return value.

### get_build_queue

my \@queue = \@{ get_build_queue(\$sbo, my \$warnings, my \@checked) };

get_build_queue() gets the prerequisites for \$sbo, updating the
\$warnings hash reference with any \"%README%\" encountered. It returns
the prerequisites and \$sbo in the correct build order.

\@checked and \"our \@concluded\" are used to check for circular
dependencies; the script exits with \"\_ERR_CIRCULAR\" if any are
present.

### get_dc_regex

my (\$rx, \$initial) = get_dc_regex(\$line);

get_dc_regex() creates a regular expression that should match the
filename given a line with e.g. an untar command. This is returned
together with the \$initial character, which starts the filename match.

### get_full_queue

my \@revdep_queue = (\$installed, \@sbos);

get_full_queue() takes a list of installed SlackBuilds and an array of
SlackBuilds to check. It returns a list of the checked SlackBuilds and
their dependencies in reverse build order.

### get_full_reverse

my \@get_full_reverse = get_full_reverse(\$sbo, %installed, %fulldeps,
my \@checked, my \@list)

get_full_reverse() takes a SlackBuild, a hash of installed packages, a
hash of reverse dependency relationships (from \"get_reverse_reqs\") and
two arrays. These arrays should not be included when called from outside
of the subroutine. get_full_reverse() returns an array with installed
reverse dependencies.

If any circular reverse dependencies are found, the script exits with
\"\_ERR_CIRCULAR\".

### get_pkg_name

my \$name = get_pkg_name(\$str);

get_pkg_name() searches \$str for text matching the package name output
from \"makepkg\". The package name is returned.

### get_src_dir

my \@dirs = \@{ get_src_dir(@orig_dirs) };

get_src_dir() returns a list of those directories under \"/tmp/SBo\" or
\$TMP that are not in \@orig_dirs. That is, the source directories for
the script.

### get_tmp_extfn

my (\$ret, \$exit) = get_tmp_extfn(\$fh);

get_tmp_extfn() gets the \"/dev/fd/X\" filename for the file handle \$fh
passed in, setting flats to make it usable from other processes.

It returns the filename if successful, and \"undef\" otherwise.

### make_clean

make_clean(SBO =\> \$sbo, SRC =\> \$src, VERSION =\> \$ver);

make_clean() removes source, package and compat32 directories left after
running a SlackBuild.

It has no useful return value.

### make_distclean

make_distclean(SRC =\> \$src, VERSION =\> \$ver, LOCATION =\> \$loc);

make_distclean() removes any downloaded source tarballs and the
completed package archive. These files are not removed if they are
needed by a script later in the queue; this is mostly relevant for
compat32 and some Rust-based scripts.

It has no useful return value.

### merge_queues

my \@merged = \@{ merge_queues([@queue1], [@queue2]) };

merge_queues() takes two array references and merges them such that
\@queue1 is in front, followed by any non-redundant items in \@queue2.
This is returned as an array reference.

### perform_sbo

my (\$pkg, \$src, \$exit) = perform_sbo(LOCATION =\> \$location, ARCH
=\> \$arch);

perform_sbo() prepares and runs a SlackBuild. It returns the package
name, an array with source directories and an exit code if successful.
If unsuccessful, the first value is instead an error message.

### process_sbos

my (@failures, \$exit) = process_sbos(TODO =\> [@queue]);

process_sbos() processes a \@queue of SlackBuilds and returns an array
reference with failed builds and the exit status.

In case of a mass rebuild, \"process_sbos\" updates the resume file
\"resume.temp\" when a build fails.

### revert_slackbuild

revert_slackbuild(\$path);

revert_slackbuild() restores a SlackBuild rewritten by
rewrite_slackbuild().

There is no useful return value.

### rewrite_slackbuild

my (\$ret, \$exit) = rewrite_slackbuild(%args);

rewrite_slackbuild(), when given an argument hash, copies the SlackBuild
at \$path and rewrites it with the needed changes. The required
arguments include \"SBO\" (the name of the script), \"SLACKBUILD\" (the
location of the unaltered SlackBuild), \"CHANGES\" (the required
changes) and \"C32\" (0 if the build is not compat32, and 1 if it is).

On failure, an error message and the exit status are returned. On
success, 1 and an exit status of 0 are returned.

### run_tee

my (\$output, \$exit) = run_tee(\$cmd);

run_tee() runs \$cmd under tee(1) to display STDOUT and return it as a
string. The second return value is the exit status.

If the bash interpreter cannot be run, the first return value is
\"undef\" and the exit status holds a non-zero value.

## EXIT CODES

Build.pm subroutines can return the following exit codes:

\_ERR_SCRIPT 2 script or module bug\
\_ERR_BUILD 3 errors when executing a SlackBuild\
\_ERR_OPENFH 6 failure to open file handles\
\_ERR_NOMULTILIB 9 lacking multilib capabilities when needed\
\_ERR_CONVERTPKG 10 convertpkg−compat32 failure\
\_ERR_NOCONVERTPKG 11 lacking convertpkg−compat32 when needed\
\_ERR_INST_SIGNAL 12 the script was interrupted while building\
\_ERR_CIRCULAR 13 attempted to calculate a circular dependency

## SEE ALSO

[SBO::Lib(3)](SBO_Lib.3.md), [SBO::Lib::Download(3)](SBO_Lib_Download.3.md), [SBO::Lib::Info(3)](SBO_Lib_Info.3.md),
[SBO::Lib::Pkgs(3)](SBO_Lib_Pkgs.3.md), [SBO::Lib::Pkgs(3)](SBO_Lib_Pkgs.3.md), [SBO::Lib::Readme(3)](SBO_Lib_Readme.3.md),
[SBO::Lib::Repo(3)](SBO_Lib_Repo.3.md), [SBO::Lib::Tree(3)](SBO_Lib_Tree.3.md), [SBO::Lib::Util(3)](SBO_Lib_Util.3.md)

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
