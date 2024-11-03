# sbotools.conf

[NAME](#name)\
[DESCRIPTION](#description)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[MAINTAINER](#maintainer)\

------------------------------------------------------------------------

## NAME

**sbotools.conf** - configuration file for **sbotools3** commands

## DESCRIPTION

*/etc/sbotools/sbotools.conf* contains *KEY=VALUE* configuration
parameters, and is read by all **sbotools3** commands.

The current configuration keys are as follows:

**DISTCLEAN=(FALSE\|TRUE)**

If **TRUE**, then remove the source archives after building. They are
retained in */usr/sbo/distfiles* (with **SBO_HOME**= */usr/sbo*) by
default.

**JOBS=(FALSE\|#)**

If **numerical**, pass to the **-j** argument when a SlackBuild invoking
**make** is run.

**NOCLEAN=(FALSE\|TRUE)**

If **TRUE**, do not clean working directories after building. These are
the build and *package-(sbo)* directories under */tmp/SBo* (or *$TMP*).

**GIT_BRANCH=(FALSE\|branch_name)**

If **FALSE**, use the default git branch for the Slackware version, if
any. If **branch_name**, attempt to change branches to **branch_name**
when using [sbosnap(1)](sbosnap.1.md) or [sbocheck(1)](sbocheck.1.md) with an upstream git
repository.

**BUILD_IGNORE=(FALSE\|TRUE)**

If **TRUE**, do not perform upgrades unless the version number differs.
By default, upgrades also occur when the build number differs.

**PKG_DIR=(FALSE\|/path)**

If set to a **path**, packages will be stored there after installation.
This overrides the **DISTCLEAN** setting for saved packages.

**SBO_HOME=(/usr/sbo\|/path)**

If set to a **path**, this is where the **slackbuilds.org** tree will be
stored. The default setting is */usr/sbo*. The tree must be
re-downloaded with **sbosnap fetch** if the **SBO_HOME** setting
changes.

**LOCAL_OVERRIDES=(FALSE\|/path)**

If set to a **path**, any directory name under that path matching a
SlackBuild name will be used in preference to the in-tree version. This
will work even if the SlackBuild is out-of-tree. *README*, *slack-desc*,
an *info* file and a SlackBuild must all be present.

**SLACKWARE_VERSION=(FALSE\|#.#)**

If set to a **version number**, use the **slackbuilds.org** repository
for that version of Slackware rather than the one specified in
*/etc/slackware-version*.

**REPO=(FALSE\|url)**

If set to a git or rsync **URL**, use that repository instead of the
**sbotools3** default for your **SLACKWARE_VERSION**. The default
repositories are under rsync://slackbuilds.org/slackbuilds if
**RSYNC_DEFAULT** is **TRUE** and <https://gitlab.com/SlackBuilds.org>
otherwise. The repository must be laid out in the same manner as one
found at <https://git.slackbuilds.org/slackbuilds> , such that
SlackBuild directories are under the category directories.

**RSYNC_DEFAULT(FALSE\|TRUE)**

If set to **TRUE**, use rsync default mirrors except for Slackware
-current.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboclean(1)](sboclean.1.md), [sboconfig(1)](sboconfig.1.md), [sbofind(1)](sbofind.1.md), [sboinstall(1)](sboinstall.1.md),
[sboremove(1)](sboremove.1.md), [sbosnap(1)](sbosnap.1.md), [sboupgrade(1)](sboupgrade.1.md)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
