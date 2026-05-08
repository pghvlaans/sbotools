# sbocutleaves

[NAME](#name)\
[SYNOPSIS](#synopsis)\
[DESCRIPTION](#description)\
[OPTIONS](#options)\
[BUGS](#bugs)\
[EXIT CODES](#exit-codes)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[MAINTAINER](#maintainer)

------------------------------------------------------------------------

## NAME

**sbocutleaves** - list or remove SBo leaf packages

## SYNOPSIS

    sbocutleaves [-h|-v]

    sbocutleaves [-l] [--no-display]

    sbocutleaves [--color|--nocolor] [--wrap|--nowrap] \...

    sbocutleaves [--raw]

## DESCRIPTION

**sbocutleaves** finds leaf packages (those which no other packages
require) installed from *slackbuilds.org*, offers to remove or keep
them. Once any removals have been done, it prompts the user to repeat
this process until no leaf packages are marked for deletion. Blacklisted
scripts and optional dependency requests are respected; see
[sbohints(1)](sbohints.1.md) or [sbotools.hints(5)](sbotools.hints.5.md) for details.

Use the **\--list** or **\--raw** flags to generate a list of leaf
packages without taking any other action.

Root privileges are required to run **sbocutleaves** unless passing
**\--list** or **\--raw**. If an invalid configuration is detected in
*/etc/sbotools/sbotools.conf*, the script exits with a diagnostic
message.

## OPTIONS

**-l\|\--list**

Print a newline-delineated list of leaf packages with descriptions and
take no other action. The **\--list** flag can be used without root
privileges.

**\--no-descriptions**

Do not show descriptions in list or interactive output. This flag is
unnecessary when calling **sbocutleaves** with **\--raw**.

**\--raw**

Print a space-delineated list of leaf packages with no descriptions or
other formatting. The **\--raw** flag can be used without root
privileges.

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

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools/> are always welcome.

## EXIT CODES

**sbocutleaves** can exit with the following codes:

0: all operations completed successfully.\
1: a usage error occurred, such as passing incorrect options to
**sbocutleaves**.\
2: a script or module error occurred.\
13: attempted to calculate a circular dependency.\
16: reading keyboard input failed.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboconfig(1)](sboconfig.1.md), [sbocutleaves(1)](sbocutleaves.1.md), [sbofind(1)](sbofind.1.md), [sbohints(1)](sbohints.1.md),
[sboinstall(1)](sboinstall.1.md), [sboremove(1)](sboremove.1.md), [sbotool(1)](sbotool.1.md), [sboupgrade(1)](sboupgrade.1.md),
[sbotools.colors(5)](sbotools.colors.5.md), [sbotools.conf(5)](sbotools.conf.5.md), [sbotools.hints(5)](sbotools.hints.5.md), removepkg(8)

## AUTHORS

Jacob Pipkin \<jacob.pipkin (at) icloud (dot) com\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
