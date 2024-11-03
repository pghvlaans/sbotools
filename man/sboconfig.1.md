# sboconfig

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

**sboconfig** - set **sbotools3** configuration options.

## SYNOPSIS

    sboconfig [-h|-v]

    sboconfig [-l]

    sboconfig [-c TRUE|FALSE] [-d TRUE|FALSE] [-j #\|FALSE] \
              [-p /path|FALSE] [-s /path|/usr/sbo] [-B branch_name|FALSE] \
              [-b TRUE|FALSE] [-o /path|FALSE] [-V #.#|FALSE] \
              [-r url|FALSE] [-R TRUE|FALSE]

## DESCRIPTION

**sboconfig** is a front-end for managing **sbotools3** configuration
options. The [sbotools.conf(5)](sbotools.conf.5.md) file can also be manually edited; any
fields not relevant to **sbotools3** configuration will be ignored.

## OPTIONS

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

**-l\|\--list**

List the current configuration options, including unmodified defaults.
**\--list** also shows the **sboconfig** flag used to set each option
for reference.

**-B\|\--branch (FALSE\|branch_name)**

**GIT_BRANCH**: If **FALSE**, use the default git branch for the
Slackware version, if any. If **branch_name**, attempt to change
branches to **branch_name** when using [sbosnap(1)](sbosnap.1.md) or [sbocheck(1)](sbocheck.1.md)
with an upstream git repository.

**-b\|\--build-ignore (FALSE\|TRUE)**

**BUILD_IGNORE**: If **TRUE**, do not perform upgrades unless the
version number differs. By default, upgrades also occur when the build
number differs.

**-c\|\--noclean (FALSE\|TRUE)**

**NOCLEAN**:If **TRUE**, do not clean working directories after
building. These are the build and *package-(sbo)* directories under
*/tmp/SBo* (or *$TMP*).

**-d\|\--distclean (FALSE\|TRUE)**

**DISTCLEAN**: If **TRUE**, then remove the source archives after
building. They are retained in */usr/sbo/distfiles* (with default
**SBO_HOME**).

**-j\|\--jobs (FALSE\|#)**

**JOBS**: If **numerical**, pass to the **-j** argument when a
SlackBuild invoking **make** is run.

**-p\|\--pkg-dir (FALSE\|/path)**

**PKG_DIR**: If set to a **path**, packages will be stored there after
installation. This overrides the **DISTCLEAN** setting for saved
packages.

**-s\|\--sbo-home (/usr/sbo\|/path)**

**SBO_HOME**: If set to a **path**, this is where the
**slackbuilds.org** tree will be stored. The default setting is
*/usr/sbo*. The tree must be re-downloaded with **sbosnap fetch** if the
**SBO_HOME** setting changes.

**-o\|\--local-overrides (FALSE\|/path)**

**LOCAL_OVERRIDES**: If set to a **path**, any directory name under that
path matching a SlackBuild name will be used in preference to the
in-tree version. This will work even if the SlackBuild is out-of-tree.
*README*, *slack-desc*, an *info* file and a SlackBuild must all be
present.

**-V\|\--slackware-version (FALSE\|#.#)**

**SLACKWARE_VERSION**: If set to a **version number**, use the
**slackbuilds.org** repository for that version of Slackware rather than
the one specified in */etc/slackware-version*.

**-r\|\--repo (FALSE\|url)**

**REPO**: If set to a git or rsync **URL**, use that repository instead
of the **sbotools3** default for your **SLACKWARE_VERSION**. The default
repositories are under rsync://slackbuilds.org/slackbuilds if
**RSYNC_DEFAULT** is **TRUE** and <https://gitlab.com/SlackBuilds.org>
otherwise. The repository must be laid out in the same manner as one
found at <https://git.slackbuilds.org/slackbuilds> such that SlackBuild
directories are under the category directories.

**-R\|\--rsync (FALSE\|TRUE)**

**RSYNC_DEFAULT**: If set to **TRUE**, use rsync default mirrors except
for Slackware -current.

## EXIT CODES

**sboconfig** can exit with the following codes:

0: all operations were successful.\
1: a usage error occurred (e.g. passing invalid option specifications)\
6: **sboconfig** was unable to obtain a required file handle.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools3/> are always welcome.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboclean(1)](sboclean.1.md), [sbofind(1)](sbofind.1.md), [sboinstall(1)](sboinstall.1.md), [sboremove(1)](sboremove.1.md),
[sbosnap(1)](sbosnap.1.md), [sboupgrade(1)](sboupgrade.1.md), [sbotools.conf(5)](sbotools.conf.5.md)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
