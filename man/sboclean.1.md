# sboclean {#sboclean align="center"}

[NAME](#NAME)\
[SYNOPSIS](#SYNOPSIS)\
[DESCRIPTION](#DESCRIPTION)\
[OPTIONS](#OPTIONS)\
[EXIT CODES](#EXIT%20CODES)\
[BUGS](#BUGS)\
[SEE ALSO](#SEE%20ALSO)\
[AUTHOR](#AUTHOR)\
[MAINTAINER](#MAINTAINER)\

------------------------------------------------------------------------

## NAME []{#NAME}

**sboclean** - clean files left by **sbotools3.**

## SYNOPSIS []{#SYNOPSIS}

sboclean \[-h\|-v\] \[-dwi\] \[-o ALL\|package\]

## DESCRIPTION []{#DESCRIPTION}

**sboclean** is used to clean files left by **sbotools3**, such as saved
options (in `/var/log/sbotools`), downloaded source files ("distfiles"),
or working directories under `/tmp/SBo` (or `$TMP`) and, for compat32
installs, under `/tmp` (or `$TMP`). Note that if not run with the
**\--interactive** flag, **sboclean** will remove anything in the
distfiles and/or `/tmp/SBo` (or `$TMP`) directories and any
`/tmp/package-*-compat32` (or `$TMP/package-*-compat32`) directories
with extreme prejudice. One of **\--dist**, **\--work** or **\--option**
must be specified for this script to do anything.

## OPTIONS []{#OPTIONS}

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

**-d\|\--dist**

Clean distfiles, located at `/usr/sbo/distfiles` by default.

**-w\|\--work**

Clean working directories, located by default under `/tmp/SBo` and, for
compat32 installs, `/tmp`.

**-o\|\--options (ALL\|sbo_name)**

With **ALL**, clean all saved options from `/var/log/sbotools`. With the
name of a SlackBuild, clean the saved options for that SlackBuild only.

**-i\|\--interactive**

Be interactive; **sboclean** will use confirmation prompts for each item
that could be removed.

## EXIT CODES []{#EXIT CODES}

**sboclean** can exit with the following codes:

0: all operations completed successfully.\
1: a usage error occurred, such as running **sboclean** with nothing to
clean.

## BUGS []{#BUGS}

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools3/> are always welcome.

## SEE ALSO []{#SEE ALSO}

sbocheck(1), sboconfig(1), sbofind(1), sboinstall(1), sboremove(1),
sbosnap(1), sboupgrade(1), sbotools.conf(5)

## AUTHOR []{#AUTHOR}

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER []{#MAINTAINER}

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
