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

**sbocheck** - update a local **SlackBuilds.org** tree and check for
updates

## SYNOPSIS

    sbocheck [-h|-v]

    sbocheck [-Ogn]

## DESCRIPTION

**sbocheck** updates or fetches a copy of the **SlackBuilds.org** tree,
checks for available upgrades, and reports what it finds. If
**OBSOLETE_CHECK** is **TRUE**, an updated copy of the script list at
**/etc/sbotools/obsolete** is downloaded from
<https://pghvlaans.github.io/sbotools> when running Slackware -current
(see [sboconfig(1)](sboconfig.1.md) or [sbotools.conf(5)](sbotools.conf.5.md)).

SlackBuilds with differing build numbers are reported separately, as are
any SlackBuilds marked *\_SBo* that are not found in the repository or
local overrides (see [sboconfig(1)](sboconfig.1.md) or [sbotools.conf(5)](sbotools.conf.5.md)). Except
in **CLASSIC** mode, scripts in the report that would not be upgraded by
[sboupgrade(1)](sboupgrade.1.md) are marked with **=** (equals sign).

The three output categories are logged separately to
*/var/log/sbocheck.log*, */var/log/sbocheck-bumps.log* and
*/var/log/sbocheck-out-of-tree.log*. The out-of-tree and build number
increment checks are disabled when **CLASSIC** is **TRUE**; if
**STRICT_UPGRADES** is **TRUE**, apparent downgrades are reported with
"differs", but are not acted on by [sboupgrade(1)](sboupgrade.1.md) (see
[sboconfig(1)](sboconfig.1.md) or [sbotools.conf(5)](sbotools.conf.5.md)).

To check for updated SlackBuilds without updating the SlackBuilds tree,
pass the **\--nopull** option. **sbocheck** performs **gpg**
verification upon pulling the tree if **GPG_VERIFY** is **TRUE** (see
[sboconfig(1)](sboconfig.1.md) or [sbotools.conf(5)](sbotools.conf.5.md)). The **\--gpg-verify** option
has the same effect. Passing both **\--gpg-verify** and **\--nopull**
verifies the repo in-place without fetching. Only rsync repositories can
be verified on Slackware 14.0 and Slackware 14.1.

Please note that **sbosnap**, which was removed as an independent script
in **sbotools-3.3**, is a compatibility symlink to **sbocheck**.

Non-root users can only call **sbocheck** with the **\--nopull**,
**\--help** and **\--version** flags. **sbocheck** issues a warning if
the directory specified with **LOCAL_OVERRIDES** does not exist (see
[sboconfig(1)](sboconfig.1.md) or [sbotools.conf(5)](sbotools.conf.5.md)). If an invalid configuration
is detected in */etc/sbotools/sbotools.conf*, the script exits with a
diagnostic message.

## OPTIONS

**-g\|\--gpg-verify**

Use **gpg** to verify the fetched repository, even if **GPG_VERIFY** is
**FALSE**. When called with **\--nopull**, verify the repo without
fetching. Only rsync repositories can be verified on Slackware 14.0 and
Slackware 14.1.

**-O\|\--obsolete-check**

If running Slackware -current, download a copy of the obsolete script
list from <https://pghvlaans.github.io/sbotools> and verify with gpg if
**GPG_VERIFY** is **TRUE** or **\--gpg-verify** is passed. Incompatible
with **\--nopull**.

**-n\|\--nopull**

Check for updated SlackBuilds without updating the SlackBuilds tree. The
**\--nopull** flag can be used without root privileges, but no log is
kept.

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

## EXIT CODES

**sbocheck** can exit with the following codes:

0: all operations were successful.\
1: a usage error occurred.\
2: a script or module error occurred.\
5: failed to download the tree.\
6: failed to open a required file handle.\
12: interrupt signal received.\
15: GPG verification failed.

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
