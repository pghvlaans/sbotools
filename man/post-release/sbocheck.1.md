# sbocheck

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

**sbocheck** - update a local **slackbuilds.org** tree and check for
updates

## SYNOPSIS

    sbocheck [-h|-v]

    sbocheck [-g|-n]

## DESCRIPTION

**sbocheck** first updates or fetches a copy of the **slackbuilds.org**
tree, checks for available upgrades, and reports what it finds.
SlackBuilds with differing build numbers are reported separately, as are
any SlackBuilds marked *\_SBo* that are not found in the repository or
local overrides (see [sboconfig(1)](sboconfig.1.md) or [sbotools.conf(5)](sbotools.conf.5.md)).

The three output categories are logged separately to
*/var/log/sbocheck.log*, */var/log/sbocheck-bumps.log* and
*/var/log/sbocheck-out-of-tree.log*. The out-of-tree and build number
increment checks are disabled when **CLASSIC** is **TRUE**&; if
**STRICT_UPGRADES** is **TRUE**, apparent downgrades are reported with
"differs", but will not be acted on by [sboupgrade(1)](sboupgrade.1.md) (see
[sboconfig(1)](sboconfig.1.md) or [sbotools.conf(5)](sbotools.conf.5.md)).

To check for updated SlackBuilds without updating the SlackBuilds tree,
pass the **\--nopull** option. **sbocheck** will perform **gpg**
verification upon pulling the tree if **GPG_VERIFY** is **TRUE** (see
[sboconfig(1)](sboconfig.1.md) or [sbotools.conf(5)](sbotools.conf.5.md)). The **\--gpg-verify** option
has the same effect. Passing both **\--gpg-verify** and **\--nopull**
verifies the repo in-place without fetching. Only rsync repositories can
be verified on Slackware 14.0 and Slackware 14.1.

Please note that **sbosnap**, which was removed as an independent script
in **sbotools-3.4**, is a compatibility symlink to **sbocheck**.

If an invalid configuration is detected in
*/etc/sbotools/sbotools.conf*, the script will exit with a diagnostic
message.

## OPTIONS

**-g\|\--gpg-verify**

Use **gpg** to verify the fetched repository, even if **GPG_VERIFY** is
**FALSE**. When called with **\--nopull**, verify the repo without
fetching. Only rsync repositories can be verified on Slackware 14.0 and
Slackware 14.1.

**-n\|\--nopull**

Check for updated SlackBuilds without updating the SlackBuilds tree.

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

## EXIT CODES

**sbocheck** can exit with the following codes:

0: all operations were successful.\
5: failed to download the tree.\
6: failed to open a required file handle.\
12: interrupt signal received.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools/> are always welcome.

## SEE ALSO

[sboclean(1)](sboclean.1.md), [sboconfig(1)](sboconfig.1.md), [sbofind(1)](sbofind.1.md), [sbohints(1)](sbohints.1.md), [sboinstall(1)](sboinstall.1.md),
[sboremove(1)](sboremove.1.md), [sboupgrade(1)](sboupgrade.1.md), [sbotools.conf(5)](sbotools.conf.5.md), [sbotools.hints(5)](sbotools.hints.5.md)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
