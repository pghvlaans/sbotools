# sboconfig

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

**sboconfig** - set **sbotools** configuration options

## SYNOPSIS

    sboconfig [-h|-v]

    sboconfig [-l]

    sboconfig [--reset]

    sboconfig [-C TRUE|FALSE] [-c TRUE|FALSE] [-d TRUE|FALSE] \
              [-g TRUE|FALSE ] [-j #|FALSE] [-p /path|FALSE] \
              [-s /path|/usr/sbo] [-B branch_name|FALSE] [-b TRUE|FALSE] \
              [-o /path|FALSE] [-V #.#|FALSE] [-r url|FALSE] \
              [-R TRUE|FALSE] [-S TRUE|FALSE]

## DESCRIPTION

**sboconfig** is a front-end for managing **sbotools** configuration
options. Using **sboconfig** without any flags starts an interactive
menu to specify settings; all options are accompanied by an explanatory
message, and no changes are applied without user confirmation.

The [sbotools.conf(5)](sbotools.conf.5.md) file can also be manually edited; any fields
not relevant to **sbotools** configuration are ignored.

## OPTIONS

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

**-l\|\--list**

List the current configuration options, including unmodified defaults.
**\--list** also shows the **sboconfig** flag used to set each option
for reference.

**\--reset**

Restore the default configuration to */etc/sbotools/sbotools.conf*.

**-B\|\--branch (FALSE\|branch_name)**

**GIT_BRANCH**: If **FALSE**, use the default git branch for the
Slackware version, if any. If **branch_name**, attempt to change
branches to **branch_name** when using [sbocheck(1)](sbocheck.1.md) with an upstream
git repository.

**-b\|\--build-ignore (FALSE\|TRUE)**

**BUILD_IGNORE**: If **TRUE**, do not perform upgrades unless the
version number differs. By default, upgrades also occur when the build
number differs.

**-C\|\--classic (FALSE\|TRUE)**

**CLASSIC**: If **TRUE**, automatically enable **RSYNC_DEFAULT** and
**BUILD_IGNORE** (overriding the contents of [sbotools.conf(5)](sbotools.conf.5.md)).
Build increment and out-of-tree SlackBuild checks by [sbocheck(1)](sbocheck.1.md) are
disabled, and previously-used build options are not displayed. This
provides a more traditional **sbotools** look and feel for those who
want it.

**-c\|\--noclean (FALSE\|TRUE)**

**NOCLEAN**: If **TRUE**, do not clean working directories after
building. These are the build and *package-(sbo)* directories under
*/tmp/SBo* (or *\$TMP*).

**-d\|\--distclean (FALSE\|TRUE)**

**DISTCLEAN**: If **TRUE**, then remove the package and source archives
after building. Source archives are otherwise retained in
*/usr/sbo/distfiles* (with default **SBO_HOME**). If **PKG_DIR** is set,
package archives are saved there regardless of **DISTCLEAN**.

**-g\|\--gpg-verify (FALSE\|TRUE)**

**GPG_VERIFY**: If **TRUE**, use **gpg** to verify the contents of the
local repository when running [sbocheck(1)](sbocheck.1.md), [sboinstall(1)](sboinstall.1.md) and
[sboupgrade(1)](sboupgrade.1.md). Missing public keys are detected, and a download from
[keyserver.ubuntu.com](keyserver.ubuntu.com) on port 80 is offered if
available. Only rsync repositories can be verified on Slackware 14.0 and
Slackware 14.1.

**-j\|\--jobs (FALSE\|#)**

**JOBS**: If **numerical**, pass to the **-j** argument when a
SlackBuild invoking **make** is run.

**-p\|\--pkg-dir (FALSE\|/path)**

**PKG_DIR**: If set to a **path**, packages are stored there after
installation. This overrides the **DISTCLEAN** setting for saved
packages.

**-s\|\--sbo-home (/usr/sbo\|/path)**

**SBO_HOME**: If set to a **path**, this is where the
**SlackBuilds.org** tree is stored. The default setting is */usr/sbo*.
The tree must be re-downloaded if the **SBO_HOME** setting changes.

**-o\|\--local-overrides (FALSE\|/path)**

**LOCAL_OVERRIDES**: If set to a **path**, any directory name in the top
level under that path matching a SlackBuild name is used in preference
to the in-tree version. This works even if the SlackBuild is
out-of-tree. Scripts installing packages not marked with the *\_SBo* tag
are neither upgradeable with [sboupgrade(1)](sboupgrade.1.md) nor removable with
[sboremove(1)](sboremove.1.md). *README*, *slack-desc*, an *info* file and a
SlackBuild must all be present.

**-V\|\--slackware-version (FALSE\|#.#)**

**SLACKWARE_VERSION**: If set to a **version number**, use the
**SlackBuilds.org** repository for that version of Slackware rather than
the one specified in */etc/slackware-version*.

**-r\|\--repo (FALSE\|url)**

**REPO**: If set to a git or rsync **URL**, use that repository instead
of the **sbotools** default for your **SLACKWARE_VERSION**. The default
repositories are under rsync://slackbuilds.org/slackbuilds if
**RSYNC_DEFAULT** is **TRUE** and for Slackware versions prior to 14.2,
and <https://gitlab.com/SlackBuilds.org> otherwise. The repository must
be laid out in the same manner as one found at
<https://git.slackbuilds.org/slackbuilds> such that SlackBuild
directories are under the category directories.

**-R\|\--rsync (FALSE\|TRUE)**

**RSYNC_DEFAULT**: If set to **TRUE**, use rsync default mirrors except
for Slackware -current.

**-S\|\--strict-upgrades (FALSE\|TRUE)**

**STRICT_UPGRADES**: If set to **TRUE**, upgrades are only attempted if
the incoming version or build number is greater. This has no effect on
scripts in the local overrides directory.

## EXIT CODES

**sboconfig** can exit with the following codes:

0: all operations were successful.\
1: a usage error occurred (e.g. passing invalid option specifications)\
6: **sboconfig** was unable to obtain a required file handle.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools/> are always welcome.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboclean(1)](sboclean.1.md), [sbofind(1)](sbofind.1.md), [sbohints(1)](sbohints.1.md), [sboinstall(1)](sboinstall.1.md),
[sboremove(1)](sboremove.1.md), [sboupgrade(1)](sboupgrade.1.md), [sbotools.conf(5)](sbotools.conf.5.md), [sbotools.hints(5)](sbotools.hints.5.md)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
