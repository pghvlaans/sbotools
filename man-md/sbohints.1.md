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

    sbohints [-c] [-b | -o | -O | -r] sbo_name (sbo_name)

    sbohints [-q] sbo_name (sbo_name)

## DESCRIPTION

**sbohints** is a script for querying and editing script-specific hints
in [sbotools.hints(5)](sbotools.hints.5.md). Three kinds of hints are recognized:

• blacklist

• optional dependencies

• automatic reverse dependency rebuild

Please note that all hints apply equally to the *compat32* version of
the target script or scripts; specific requests for *compat32* scripts
are unsupported. The modification flags are **\--blacklist**,
**\--optional**, **\--replace-optional** and **\--reverse**. These can
be used in conjunction with **\--clear**, but not with each other.

Non-root users can only call **sbohints** with the **\--list**,
**\--query**, **\--help** and **\--version** flags. If an invalid
configuration is detected in */etc/sbotools/sbotools.conf*, the script
exits with a diagnostic message.

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

**-r\|\--reverse**

Add (or, with **\--clear**, clear) automatic reverse dependency rebuild
requests for one or more scripts. Please note that building against some
packages, such as **google-go-lang**, fails unless a version-specific
profile script has been sourced. Requesting reverse dependency rebuilds
for such packages is not advised.

**-c\|\--clear**

This flag is used together with one (and only one) of **\--blacklist**,
**\--optional**, **\--replace-optional** or **\--reverse**. For
**\--blacklist**, **\--optional** and **\--reverse**, clear entries
instead of adding them. For **\--replace-optional**, clear all existing
optional dependency requests.

**-l\|\--list**

List all active hints. If a blacklisted script has optional dependency
requests or is requested as an optional depenedency, the user is
notified. The **\--list** flag can be used without root privileges.

**-q\|\--query**

Return the hint status for one or more scripts. There is no output
unless the queried script is involved with one or more hints. The
**\--query** flag can be used without root privileges.

**\--reset**

Clear all hints upon confirmation.

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

## EXIT CODES

**sbohints** can exit with the following codes:

0: all operations were successful.\
1: a usage error occurred.\
2: a script or module error occurred.\
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
