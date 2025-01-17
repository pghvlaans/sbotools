# sbohints

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

**sbohints** - interact with sbotools.hints

## SYNOPSIS

    sbohints [-h | -v]

    sbohints [-l | --reset]

    sbohints [-c] [-b | -o | -O] sbo_name (sbo_name)

    sbohints [-q] sbo_name (sbo_name)

## DESCRIPTION

**sbohints** is a script for querying and editing the blacklist and
optional dependency requests made in [sbotools.hints(5)](sbotools.hints.5.md). The
modification flags are **\--blacklist**, **\--optional** and
**\--replace-optional**. These may be used in conjunction with
**\--clear**, but not with each other.

If an invalid configuration is detected in
*/etc/sbotools/sbotools.conf*, the script exits with a diagnostic
message.

## OPTIONS

**-b\|\--blacklist**

Modify the blacklist by adding (or, with **\--clear**, clearing) one or
more scripts.

**-o\|\--optional**

Add (or clear with **\--clear**) optional dependency requests for one or
more scripts. The current optional dependencies are displayed together
with a prompt for adding or clearing.

**-O\|\--replace-optional**

Replace all existing optional dependency requests for one or more
scripts. The current optional dependencies are displayed together with a
prompt for the new request list. If used with **\--clear**, a
confirmation prompt for clearing the optional dependencies appears.

**-c\|\--clear**

This flag is used together with one (and only one) of **\--blacklist**,
**\--optional** or **\--replace-optional**. For **\--blacklist** and
**\--optional**, clear entries instead of adding them. For
**\--replace-optional**, clear all existing optional dependency
requests.

**-l\|\--list**

List the current blacklist and all optional dependency requests. If a
blacklisted script has optional dependency requests or is requested as
an optional depenedency, the user is notified.

**-q\|\--query**

Return the current blacklist and optional dependency request status for
one or more scripts.

**\--reset**

Clear the blacklist and all optional dependency requests upon
confirmation.

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

## EXIT CODES

**sbohints** can exit with the following codes:

0: all operations were successful.\
1: a usage error occurred.\
6: **sbohints** was unable to obtain a required file handle.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools/> are always welcome.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboclean(1)](sboclean.1.md), [sboconfig(1)](sboconfig.1.md), [sbofind(1)](sbofind.1.md), [sboinstall(1)](sboinstall.1.md),
[sboremove(1)](sboremove.1.md), [sboupgrade(1)](sboupgrade.1.md), [sbotools.conf(5)](sbotools.conf.5.md), [sbotools.hints(5)](sbotools.hints.5.md)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
