# sbotools.conf

[NAME](#name)\
[DESCRIPTION](#description)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[MAINTAINER](#maintainer)

------------------------------------------------------------------------

## NAME

**sbotools.conf** - configuration file for **sbotools** commands

## DESCRIPTION

*/etc/sbotools/sbotools.conf* contains *KEY=VALUE* configuration
parameters, and is read by all **sbotools** commands.

If an invalid configuration is detected (or requested with
[sboconfig(1)](sboconfig.1.md)), the script exits with a diagnostic message.

To quickly restore all default settings, run

    sboconfig --reset

To use a configuration directory other than */etc/sbotools*, export an
environment variable **SBOTOOLS_CONF_DIR** with an absolute path.

*/root*, */home*, */* and possible top-level directories under */home*
are not permitted as directory settings.

The current configuration keys are as follows:

**CLASSIC=(FALSE\|TRUE)**

If **TRUE**, automatically enable **RSYNC_DEFAULT**and **BUILD_IGNORE**,
and disable **COLOR** (overriding the contents of this file). Build
increment and out-of-tree SlackBuild checks by [sbocheck(1)](sbocheck.1.md) are
disabled, and previously-used build options are not displayed. This
provides a more traditional **sbotools** look and feel for those who
want it.

**CPAN_IGNORE=(FALSE\|TRUE)**

If **TRUE**, install scripts even if they are already installed from the
CPAN.

**DISTCLEAN=(FALSE\|TRUE)**

If **TRUE**, remove the package and source archives after building.
Source archives are otherwise retained in md5sum-designated directories
under */usr/sbo/distfiles* (with *SBO_HOME=/usr/sbo*) by default. If
**PKG_DIR** is set, package archives are saved there regardless of
**DISTCLEAN**.

**GPG_VERIFY=(FALSE\|TRUE)**

If **TRUE**, use **gpg(1)** to verify the contents of the local
repository (and, if applicable, */etc/sbotools/obsolete*) when running
[sbocheck(1)](sbocheck.1.md), [sboinstall(1)](sboinstall.1.md) and [sboupgrade(1)](sboupgrade.1.md). Missing public
keys are detected, and a download from
[keyserver.ubuntu.com](keyserver.ubuntu.com) on port 80 is offered if
available. Only rsync repositories can be verified on Slackware 14.0 and
Slackware 14.1.

**JOBS=(FALSE\|#)**

If **numerical**, pass to the **-j** argument when a SlackBuild invoking
**make** is run.

**NOCLEAN=(FALSE\|TRUE)**

If **TRUE**, do not clean working directories after building. These are
the build and *package-(sbo)* directories under */tmp/SBo* (or *\$TMP*).

**COLOR=(FALSE\|TRUE)**

If **TRUE**, enable **sbotools** color output. To customize color
output, edit the */etc/sbotools/sbotools.colors* file directly. See
[sbotools.colors(5)](sbotools.colors.5.md) for more details.

**GIT_BRANCH=(FALSE\|branch_name)**

If **FALSE**, use the default git branch for the Slackware version, if
any. If **branch_name**, attempt to change branches to **branch_name**
when using [sbocheck(1)](sbocheck.1.md) with an upstream git repository.

**BUILD_IGNORE=(FALSE\|TRUE)**

If **TRUE**, do not perform upgrades unless the version number differs.
By default, upgrades also occur when the build number differs.

**ETC_PROFILE=(FALSE\|TRUE)**

**If TRUE**, source any executable scripts in */etc/profile.d* named
*\*.sh* before running each SlackBuild in the build queue.

**LOG_DIR=(FALSE\|/path)**

If set to an **absolute path**, save build logs here. Logs are saved
with the name of the script and a timestamp. Please note that because
**STDERR** must be redirected for a complete log, colors and formatting
may differ when running some SlackBuilds unless **LOG_DIR** is
**FALSE**.

**OBSOLETE_CHECK=(FALSE\|TRUE)**

If **TRUE**, download an updated copy of the obsolete script list to
*/etc/sbotools/obsolete* from the **sbotools** home page at
<https://pghvlaans.github.io/sbotools> when running [sbocheck(1)](sbocheck.1.md) in
Slackware -current.

**PKG_DIR=(FALSE\|/path)**

If set to a **path**, packages are stored there after installation. This
overrides the **DISTCLEAN** setting for saved packages.

**SBO_HOME=(/usr/sbo\|/path)**

If set to a **path**, this is where the **SlackBuilds.org** tree is
stored. The default setting is */usr/sbo*. The tree must be
re-downloaded with [sbocheck(1)](sbocheck.1.md) if the **SBO_HOME** setting changes.

**LOCAL_OVERRIDES=(FALSE\|/path)**

If set to a **path**, any directory name in the top level under that
path matching a SlackBuild name is used in preference to the in-tree
version. This works even if the SlackBuild is out-of-tree. Scripts
installing packages not marked with the *\_SBo* tag are neither
upgradeable with [sboupgrade(1)](sboupgrade.1.md) nor removable with [sboremove(1)](sboremove.1.md).
*README*, *slack-desc*, an *info* file and a SlackBuild must all be
present.

**SLACKWARE_VERSION=(FALSE\|#.#)**

If set to a **version number**, use the **SlackBuilds.org** repository
for that version of Slackware rather than the one specified in
*/etc/slackware-version*.

**SO_CHECK=(FALSE\|TRUE)**

If set to **TRUE**, check for missing first-order shared object (solib)
dependencies among *\_SBo* packages when running [sbocheck(1)](sbocheck.1.md) and
[sboupgrade(1)](sboupgrade.1.md).

**REPO=(FALSE\|url\|/path)**

If set to a git or rsync **URL**, use that repository instead of the
**sbotools** default for your **SLACKWARE_VERSION**. The default
repositories are under rsync://slackbuilds.org/slackbuilds if
**RSYNC_DEFAULT** is **TRUE** and for Slackware versions prior to 14.2,
and <https://gitlab.com/SlackBuilds.org> otherwise. The repository must
be laid out in the same manner as one found at
<https://git.slackbuilds.org/slackbuilds> such that SlackBuild
directories are under the category directories.

**RSYNC_DEFAULT=(FALSE\|TRUE)**

If set to **TRUE**, use rsync default mirrors except for Slackware
-current.

**STRICT_UPGRADES=(FALSE\|TRUE)**

If set to **TRUE**, upgrades are only attempted if the incoming version
or build number is greater. This has no effect on scripts in the local
overrides directory.

**NOWRAP=(FALSE\|TRUE)**

If set to **TRUE**, do not wrap **sbotools** output.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboclean(1)](sboclean.1.md), [sboconfig(1)](sboconfig.1.md), [sbofind(1)](sbofind.1.md), [sbohints(1)](sbohints.1.md),
[sboinstall(1)](sboinstall.1.md), [sboremove(1)](sboremove.1.md), [sboupgrade(1)](sboupgrade.1.md), [sbotools.colors(5)](sbotools.colors.5.md),
[sbotools.hints(5)](sbotools.hints.5.md), gpg(1)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
