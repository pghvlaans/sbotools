# sboremove {#sboremove align="center"}

[NAME](#NAME)\
[SYNOPSIS](#SYNOPSIS)\
[DESCRIPTION](#DESCRIPTION)\
[OPTIONS](#OPTIONS)\
[EXIT CODES](#EXIT%20CODES)\
[BUGS](#BUGS)\
[SEE ALSO](#SEE%20ALSO)\
[AUTHORS](#AUTHORS)\
[MAINTAINER](#MAINTAINER)\

------------------------------------------------------------------------

## NAME []{#NAME}

**sboremove** - remove packages installed from SlackBuilds

## SYNOPSIS []{#SYNOPSIS}

sboremove \[-h\|-v\]

sboremove \[-a\] sbo_name (sbo_name)

## DESCRIPTION []{#DESCRIPTION}

**sboremove** removes packages installed from SlackBuilds, along with
any unneeded dependencies. Dependency information is pulled recursively
from `info` files; any dependencies that are required by no other
SlackBuilds will be eligible for removal as well. If **sboremove** is
called with the **\--alwaysask** flag, the dependency requirements of
other installed SlackBuilds will not be checked.

In all cases, this script prompts the user package-by-package before
performing any removal operations. No option exists to enable
**sboremove** to uninstall packages without confirmation prompts, and
there are no plans to add that functionality in the future.

## OPTIONS []{#OPTIONS}

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

**-a\|\--alwaysask**

Always ask to remove dependencies, even if they are required by other
packages installed to the system.

## EXIT CODES []{#EXIT CODES}

**sboremove** can exit with the following codes:

0: all operations completed successfully.\
1: a usage error occurred, such as running **sboremove** with nothing to
remove.

## BUGS []{#BUGS}

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools3/> are always welcome.

## SEE ALSO []{#SEE ALSO}

sbocheck(1), sboclean(1), sboconfig(1), sbofind(1), sboinstall(1),
sbosnap(1), sboupgrade(1), sbotools.conf(5)

## AUTHORS []{#AUTHORS}

Luke Williams \<xocel (at) iquidus (dot) org\>

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER []{#MAINTAINER}

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
