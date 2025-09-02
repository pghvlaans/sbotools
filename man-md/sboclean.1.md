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

    sboclean [--color|--nocolor] [--wrap|--nowrap] \...

## DESCRIPTION

**sboclean** is used to clean files left by **sbotools**, including:

• saved build options in */var/log/sbotools*

• downloaded source files

• working directories under */tmp/SBo* (or *\$TMP*)

• for **compat32** packages, working directories under */tmp*

Note that if run without the **\--interactive** flag, **sboclean**
removes anything in the distfiles and/or */tmp/SBo* (or *\$TMP*)
directories and any */tmp/package-\*-compat32* (or
*\$TMP/package-\*-compat32*) directories with extreme prejudice. One of
**\--dist**, **\--work** or **\--option** must be specified for this
script to do anything.

Root privileges are required to run **sboclean**. If an invalid
configuration is detected in */etc/sbotools/sbotools.conf*, or if
invalid options are specified, the script exits with a diagnostic
message.

## OPTIONS

**-d\|\--dist**

Clean distfiles, located at */usr/sbo/distfiles* by default.

**-w\|\--work**

Clean working directories, located by default under */tmp/SBo* and, for
compat32 installs, */tmp*.

**-o\|\--options (ALL\|sbo_name)**

With **ALL**, clean all saved options from */var/log/sbotools*. With the
name of a SlackBuild, clean the saved options for that SlackBuild only.

**-i\|\--interactive**

Be interactive; **sboclean** uses confirmation prompts for each item
that could be removed.

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

**\--color**

Turn on **sbotools** color output. See also [sbotools.colors(5)](sbotools.colors.5.md).

**\--nocolor**

Turn off **sbotools** color output.

**\--wrap**

Turn on **sbotools** word wrapping (default).

**\--nowrap**

Turn off **sbotools** word wrapping.

## EXIT CODES

**sboclean** can exit with the following codes:

0: all operations completed successfully.\
1: a usage error occurred, such as passing incorrect options to
**sboclean**.\
2: a script or module error occurred.\
16: reading keyboard input failed.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools/> are always welcome.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboconfig(1)](sboconfig.1.md), [sbofind(1)](sbofind.1.md), [sbohints(1)](sbohints.1.md), [sboinstall(1)](sboinstall.1.md),
[sboremove(1)](sboremove.1.md), [sboupgrade(1)](sboupgrade.1.md), [sbotools.colors(5)](sbotools.colors.5.md), [sbotools.conf(5)](sbotools.conf.5.md),
[sbotools.hints(5)](sbotools.hints.5.md)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
