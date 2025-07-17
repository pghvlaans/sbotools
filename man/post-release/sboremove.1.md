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

    sboremove [-ap] sbo_name (sbo_name)

    sboremove [--color|--nocolor] \...

## DESCRIPTION

**sboremove** removes packages installed from SlackBuilds, along with
any unneeded dependencies. Dependency information is pulled recursively
from *info* files and honors the contents of [sbotools.hints(5)](sbotools.hints.5.md); any
dependencies required by no other installed SlackBuilds are eligible for
removal as well. **sboremove** does not handle blacklisted scripts.

If **sboremove** is called with the **\--alwaysask** flag, all
dependencies receive removal prompts, even if they are required by other
installed SlackBuilds. The per-script prompts list installed reverse
dependencies, if any.

To remove *compat32* packages, call **sboremove** with the
**\--compat32** flag.

In all cases, this script prompts the user package-by-package before
performing any removal operations. No option exists to enable
**sboremove** to uninstall packages without confirmation prompts, and
there are no plans to add that functionality in the future.

Root privileges are required to run **sboremove**. If an invalid
configuration is detected in */etc/sbotools/sbotools.conf*, or if
invalid options are specified, the script exits with a diagnostic
message.

## OPTIONS

**-a\|\--alwaysask**

Always ask to remove dependencies, even if they are required by other
packages installed to the system.

**-p\|\--compat32**

Remove the *compat32* version of the script or scripts, along with
*compat32* dependencies.

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

**\--color**

Turn on **sbotools** color output. See also [sbotools.colors(5)](sbotools.colors.5.md).

**\--nocolor**

Turn off **sbotools** color output.

## EXIT CODES

**sboremove** can exit with the following codes:

0: all operations completed successfully.\
1: a usage error occurred, such as running **sboremove** with nothing to
remove.\
2: a script or module error occurred.\
13: circular dependencies detected.\
16: reading keyboard input failed.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools/> are always welcome.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboclean(1)](sboclean.1.md), [sboconfig(1)](sboconfig.1.md), [sbofind(1)](sbofind.1.md), [sbohints(1)](sbohints.1.md),
[sboinstall(1)](sboinstall.1.md), [sboupgrade(1)](sboupgrade.1.md), [sbotools.colors(5)](sbotools.colors.5.md), [sbotools.conf(5)](sbotools.conf.5.md),
[sbotools.hints(5)](sbotools.hints.5.md)

## AUTHORS

Luke Williams \<xocel (at) iquidus (dot) org\>

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
