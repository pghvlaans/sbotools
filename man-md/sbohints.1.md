# sbohints

[NAME](#name)\
[SYNOPSIS](#synopsis)\
[DESCRIPTION](#description)\
[OPTIONS](#options)\
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

    sbohints [-r] [-b | -o | -O] sbo \...

    sbohints [-q] sbo \...

## DESCRIPTION

**sbohints** is a script for querying and editing the blacklist and
optional dependency requests made in [sbotools.hints(5)](sbotools.hints.5.md). The
modification flags are **\--blacklist**, **\--optional** and
**\--replace-optional**. These may be used in conjunction with
**\--remove**, but not with each other.

If an invalid configuration is detected in
*/etc/sbotools/sbotools.conf*, the script will exit with a diagnostic
message.

## OPTIONS

**-b\|\--blacklist**

Add (or remove with **\--remove**) one or more scripts to the blacklist.

**-o\|\--optional**

Add (or remove with **\--remove**) optional dependency requests for one
or more scripts. The current optional dependencies will be displayed
together with a prompt for adding or removing.

**-O\|\--replace-optional**

Replace all existing optional dependency requests for one or more
scripts. The current optional dependencies will be displayed together
with a prompt for the new request list. If used with **\--remove**, a
confirmation prompt for clearing the optional dependencies will appear.

**-r\|\--remove**

This flag is used together with one (and only one) of **\--blacklist**,
**\--optional** or **\--replace-optional**. For **\--blacklist** and
\--optional, remove entries instead of adding them. For
**\--replace-optional**, clear all existing optional dependency
requests.

**-l\|\--list**

List the current blacklist and all optional dependency requests. If a
blacklisted script has optional dependency requests, the user is
notified.

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
