# sboremove

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

**sboremove** - remove packages installed from SlackBuilds

## SYNOPSIS

    sboremove [-h|-v]

    sboremove [-apq] [--no-descriptions] sbo_name (sbo_name)

    sboremove [--color|--nocolor] [--wrap|--nowrap] \...

## DESCRIPTION

**sboremove** interactively removes SlackBuilds and any unneeded
dependencies. Dependency information is pulled recursively from *info*
files and honors the contents of [sbotools.hints(5)](sbotools.hints.5.md). **sboremove**
handles neither blacklisted scripts nor scripts installed from non-SBo
sources.

If **sboremove** is called with the **\--alwaysask** flag, all
dependencies receive removal prompts, even if they are required by other
installed SlackBuilds. The per-script prompts list installed reverse
dependencies, if any.

*compat32* and normal packages can be requested together at the command
line. Call **sboremove** with the **\--compat32** flag to specify all
command line scripts as *compat32* automatically.

In all cases, this script prompts the user package-by-package in reverse
build order before performing any removal operations. No option exists
to enable **sboremove** to uninstall packages without confirmation
prompts, and there are no plans to add that functionality in the future.

Root privileges are required to run **sboremove** unless passing
**\--query**. If an invalid configuration is detected in
*/etc/sbotools/sbotools.conf*, or if invalid options are specified, the
script exits with a diagnostic message.

## OPTIONS

**-a\|\--alwaysask**

Always ask to remove dependencies, even if they are required by other
packages installed to the system.

**\--no-descriptions**

Do not show descriptions in query or interactive output.

**-p\|\--compat32**

Interpret all scripts passed to **sboremove** at the command line as
*compat32*.

**-q\|\--query**

Show the prospective removal prompt order and exit.

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

**sboremove** can exit with the following codes:

0: all operations completed successfully.\
1: a usage error occurred, such as running **sboremove** without a list
of packages.\
2: a script or module error occurred.\
13: circular dependencies detected.\
16: reading keyboard input failed.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools/> are always welcome.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboclean(1)](sboclean.1.md), [sboconfig(1)](sboconfig.1.md), [sbocutleaves(1)](sbocutleaves.1.md), [sbofind(1)](sbofind.1.md),
[sbohints(1)](sbohints.1.md), [sboinstall(1)](sboinstall.1.md), [sbotool(1)](sbotool.1.md), [sboupgrade(1)](sboupgrade.1.md),
[sbotools.colors(5)](sbotools.colors.5.md), [sbotools.conf(5)](sbotools.conf.5.md), [sbotools.hints(5)](sbotools.hints.5.md)

## AUTHORS

Luke Williams \<xocel (at) iquidus (dot) org\>

Jacob Pipkin \<jacob.pipkin (at) icloud (dot) com\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
