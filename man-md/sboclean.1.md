# sboclean

[NAME](#name)\
[SYNOPSIS](#synopsis)\
[DESCRIPTION](#description)\
[OPTIONS](#options)\
[EXIT CODES](#exit-codes)\
[BUGS](#bugs)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[MAINTAINER](#maintainer)

------------------------------------------------------------------------

## NAME

**sboclean** - clean files left by **sbotools**

## SYNOPSIS

    sboclean [-h|-v]

    sboclean [-dwi] [-o ALL|package]

## DESCRIPTION

**sboclean** is used to clean files left by **sbotools**, such as saved
options (in */var/log/sbotools*), downloaded source files ("distfiles"),
or working directories under */tmp/SBo* (or *\$TMP*) and, for compat32
installs, under */tmp* (or *\$TMP*). Note that if not run with the
**\--interactive** flag, **sboclean** will remove anything in the
distfiles and/or */tmp/SBo* (or *\$TMP*) directories and any
*/tmp/package-\*-compat32* (or *\$TMP/package-\*-compat32*) directories
with extreme prejudice. One of **\--dist**, **\--work** or **\--option**
must be specified for this script to do anything.

## OPTIONS

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

**-d\|\--dist**

Clean distfiles, located at */usr/sbo/distfiles* by default.

**-w\|\--work**

Clean working directories, located by default under */tmp/SBo* and, for
compat32 installs, */tmp*.

**-o\|\--options (ALL\|sbo_name)**

With **ALL**, clean all saved options from */var/log/sbotools*. With the
name of a SlackBuild, clean the saved options for that SlackBuild only.

**-i\|\--interactive**

Be interactive; **sboclean** will use confirmation prompts for each item
that could be removed.

## EXIT CODES

**sboclean** can exit with the following codes:

0: all operations completed successfully.\
1: a usage error occurred, such as running **sboclean** with nothing to
clean.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools/> are always welcome.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboconfig(1)](sboconfig.1.md), [sbofind(1)](sbofind.1.md), [sboinstall(1)](sboinstall.1.md), [sboremove(1)](sboremove.1.md),
[sbosnap(1)](sbosnap.1.md), [sboupgrade(1)](sboupgrade.1.md), [sbotools.conf(5)](sbotools.conf.5.md)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
