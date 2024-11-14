# sbocheck

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

**sbocheck** - update a local **slackbuilds.org** tree and check for
updates

## SYNOPSIS

    sbocheck [-h|-v]

    sbocheck [-n]

## DESCRIPTION

**sbocheck** first updates a previously-fetched copy of the
**slackbuilds.org** tree (see [sbosnap(1)](sbosnap.1.md)), checks for available
upgrades, and reports what it finds. SlackBuilds with differing build
numbers are reported separately, as are any SlackBuilds marked *\_SBo*
that are not found in the repository.

The three output categories are logged separately to
*/etc/sbocheck.log*, */etc/sbocheck-bumps.log* and
*/etc/sbocheck-out-of-tree.log*. The out-of-tree and build number
increment checks are disabled when **CLASSIC** is **TRUE** (see
[sboconfig(1)](sboconfig.1.md) or [sbotools.conf(5)](sbotools.conf.5.md)).

To check for updated SlackBuilds without updating the SlackBuilds tree,
pass the **\--nopull** option.

## OPTIONS

**-n\|\--nopull**

Check for updated SlackBuilds without updating the SlackBuilds tree.

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools/> are always welcome.

## SEE ALSO

[sboclean(1)](sboclean.1.md), [sboconfig(1)](sboconfig.1.md), [sbofind(1)](sbofind.1.md), [sboinstall(1)](sboinstall.1.md), [sboremove(1)](sboremove.1.md),
[sbosnap(1)](sbosnap.1.md), [sboupgrade(1)](sboupgrade.1.md), [sbotools.conf(5)](sbotools.conf.5.md)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
