# sbohints

[NAME](#name)\
[SYNOPSIS](#synopsis)\
[DESCRIPTION](#description)\
[OPTIONS](#options)\
[SBOTEST](#sbotest)\
[EXIT CODES](#exit-codes)\
[BUGS](#bugs)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[MAINTAINER](#maintainer)

------------------------------------------------------------------------

## NAME

**sbohints** - interact with sbotools.hints

## SYNOPSIS

    sbohints [-h|-v]

    sbohints [-l|--reset]

    sbohints [-c] [-Obor] sbo_name (sbo_name)

    sbohints [-q] sbo_name (sbo_name)

    sbohints [--color|--nocolor] [--wrap|--nowrap] \...

## DESCRIPTION

**sbohints** is a script for querying and editing script-specific hints
in [sbotools.hints(5)](sbotools.hints.5.md). Three kinds of hints are recognized:

• blacklist

• optional dependencies

• automatic reverse dependency rebuild

The modification flags are **\--blacklist**, **\--optional**,
**\--replace-optional** and **\--reverse**. These can be used in
conjunction with **\--clear**, but not with each other.

Please note that all hints apply equally to the *compat32* version of
the target script or scripts; specific requests for *compat32* scripts
are unsupported.

Non-root users can only call **sbohints** with the **\--list**,
**\--query**, **\--help** and **\--version** flags. If an invalid
configuration is detected in */etc/sbotools/sbotools.conf*, the script
exits with a diagnostic message. To use a configuration directory other
than */etc/sbotools*, export an environment variable
**SBOTOOLS_CONF_DIR** with an absolute path.

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
for such packages is not advised unless the **ETC_PROFILE** setting is
**TRUE**. See [sboconfig(1)](sboconfig.1.md) or [sbotools.conf(5)](sbotools.conf.5.md) for details.

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

**\--color**

Turn on **sbotools** color output. See also [sbotools.colors(5)](sbotools.colors.5.md).

**\--nocolor**

Turn off **sbotools** color output.

**\--wrap**

Turn on **sbotools** word wrapping (default).

**\--nowrap**

Turn off **sbotools** word wrapping.

## SBOTEST

**sbohints** is called when running **sbotest hints**; flags are
unchanged.

## EXIT CODES

**sbohints** can exit with the following codes:

0: all operations were successful.\
1: a usage error occurred.\
2: a script or module error occurred.\
6: a required file handle could not be obtained.\
16: reading keyboard input failed.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools/> are always welcome.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboclean(1)](sboclean.1.md), [sboconfig(1)](sboconfig.1.md), [sbofind(1)](sbofind.1.md), [sboinstall(1)](sboinstall.1.md),
[sboremove(1)](sboremove.1.md), [sbotool(1)](sbotool.1.md), [sboupgrade(1)](sboupgrade.1.md), [sbotools.colors(5)](sbotools.colors.5.md),
[sbotools.conf(5)](sbotools.conf.5.md), [sbotools.hints(5)](sbotools.hints.5.md)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
