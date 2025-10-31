# sboconfig

[NAME](#name)\
[SYNOPSIS](#synopsis)\
[DESCRIPTION](#description)\
[OPTIONS](#options)\
[SBOTEST](#sbotest)\
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

    sboconfig [-l|-n]

    sboconfig [--reset]

    sboconfig [-CKOPRSXcbdegw TRUE|FALSE] [-j #|FALSE] [-DLpo
/path\|FALSE] \
              [-s /path|/usr/sbo] [-B branch_name|FALSE] [-V #.#|FALSE] \
              [-r url|FALSE]

## DESCRIPTION

**sboconfig** is a front-end for managing **sbotools** configuration
options. Using **sboconfig** without any flags enters the **Settings**
menu within **sbotool**, provided that **dialog(1)** is installed. If
running as root, settings changes can be done from here.

The [sbotools.conf(5)](sbotools.conf.5.md) file can also be manually edited; any fields
not relevant to **sbotools** configuration are ignored. To use a
configuration directory other than */etc/sbotools*, export an
environment variable **SBOTOOLS_CONF_DIR** with an absolute path.

*/root*, */home*, */* and possible top-level directories under */home*
are not permitted as directory settings.

Non-root users can only call **sboconfig** with the **\--list**,
**\--non-default**, **\--help** and **\--version** flags.

## OPTIONS

**-l\|\--list**

List the current configuration options, including unmodified defaults.
**\--list** also shows the **sboconfig** flag used to set each option
for reference. The **\--list** flag can be used without root privileges.

**-n\|\--non-default**

List current non-default configuration options. **\--non-default** also
shows the **sboconfig** flag used to set each option for reference. The
**\--non-default** flag can be used without root privileges.

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
**BUILD_IGNORE**, and disable **COLOR** (overriding the contents of
[sbotools.conf(5)](sbotools.conf.5.md)). Build increment and out-of-tree SlackBuild checks
by [sbocheck(1)](sbocheck.1.md) are disabled, and previously-used build options are
not displayed. This provides a more traditional **sbotools** look and
feel for those who want it.

**-c\|\--noclean (FALSE\|TRUE)**

**NOCLEAN**: If **TRUE**, do not clean working directories after
building. These are the build and *package-(sbo)* directories under
*/tmp/SBo* (or *\$TMP*).

**-D\|\--dialogrc (FALSE\|/path)**

DIALOGRC: If set to an **absolute path**, use that file as *dialogrc*
when running [sbotool(1)](sbotool.1.md).

**-d\|\--distclean (FALSE\|TRUE)**

**DISTCLEAN**: If **TRUE**, remove the package and source archives after
building. Source archives are otherwise retained in md5sum-designated
directories under */usr/sbo/distfiles* (with default **SBO_HOME**). If
**PKG_DIR** is set, package archives are saved there regardless of
**DISTCLEAN**.

**-e\|\--etc-profile (FALSE\|TRUE)**

**ETC_PROFILE**: If **TRUE**, source any executable scripts in
*/etc/profile.d* named *\*.sh* before running each SlackBuild in the
build queue.

**-g\|\--gpg-verify (FALSE\|TRUE)**

**GPG_VERIFY**: If **TRUE**, use **gpg(1)** to verify the contents of
the local repository (and, if applicable, */etc/sbotools/obsolete*) when
running [sbocheck(1)](sbocheck.1.md), [sboinstall(1)](sboinstall.1.md) and [sboupgrade(1)](sboupgrade.1.md).
Missing public keys are detected, and a download from
[keyserver.ubuntu.com](keyserver.ubuntu.com) on port 80 is offered if
available.

**-j\|\--jobs (FALSE\|#)**

**JOBS**: If **numerical**, pass to the **-j** argument when a
SlackBuild invoking **make** is run.

**-K\|\--color (FALSE\|TRUE)**

**COLOR**: If **TRUE**, enable **sbotools** color output. To customize
color output, edit the */etc/sbotools/sbotools.colors* file directly.
See [sbotools.colors(5)](sbotools.colors.5.md) for details.

**-L\|\--log-dir (FALSE\|/path)**

**LOG_DIR**: If set to an **absolute path**, save build logs here. Logs
are saved with the name of the script and a timestamp. Please note that
because **STDERR** must be redirected for a complete log, colors and
formatting may differ when running some SlackBuilds unless **LOG_DIR**
is **FALSE**.

**-O\|\--obsolete-check (FALSE\|TRUE)**

**OBSOLETE_CHECK**: If **TRUE**, download updated copies of the obsolete
script list and the perl version history file to
*/etc/sbotools/obsolete* and */etc/sbotools/perl_vers*, respectively,
from the **sbotools** home page at
<https://pghvlaans.github.io/sbotools> when running [sbocheck(1)](sbocheck.1.md) in
Slackware -current.

**-P\|\--cpan-ignore (FALSE\|TRUE)**

**CPAN_IGNORE**: If **TRUE**, install scripts even if they are already
installed from the CPAN.

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
[sboremove(1)](sboremove.1.md). *slack-desc*, an *info* file and a SlackBuild must all
be present.

**-V\|\--slackware-version (FALSE\|#.#)**

**SLACKWARE_VERSION**: If set to a **version number**, use the
**SlackBuilds.org** repository for that version of Slackware rather than
the one specified in */etc/slackware-version*.

**-r\|\--repo (FALSE\|url)**

**REPO**: If set to a git or rsync **URL**, use that repository instead
of the **sbotools** default for your **SLACKWARE_VERSION**. The default
repositories are under rsync://slackbuilds.org/slackbuilds if
**RSYNC_DEFAULT** is **TRUE**, and <https://gitlab.com/SlackBuilds.org>
otherwise. The repository must be laid out in the same manner as one
found at <https://git.slackbuilds.org/slackbuilds> such that SlackBuild
directories are under the category directories.

**-R\|\--rsync (FALSE\|TRUE)**

**RSYNC_DEFAULT**: If set to **TRUE**, use rsync default mirrors except
for Slackware -current.

**-S\|\--strict-upgrades (FALSE\|TRUE)**

**STRICT_UPGRADES**: If set to **TRUE**, upgrades are only attempted if
the incoming version or build number is greater. This has no effect on
scripts in the local overrides directory.

**-w\|\--nowrap (FALSE\|TRUE)**

**NOWRAP**: If set to **TRUE**, do not wrap **sbotools** output.

**-X\|\--so-check (FALSE\|TRUE)**

**SO_CHECK**: If set to **TRUE**, check for missing first-order shared
object (solib) dependencies among *\_SBo* packages when running
[sbocheck(1)](sbocheck.1.md) and [sboupgrade(1)](sboupgrade.1.md). Additionally, [sbocheck(1)](sbocheck.1.md)
searches for incompatible **perl**, **python** and **ruby** *\_SBo*
packages.

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

## SBOTEST

**sboconfig** is called when running **sbotest config**; the following
default values change in this situation:

**-A\|\--sbo-archive**

Defaults to */usr/sbotest/archive*. This setting is specific to
**sbotest**.

**-e\|\--etc-profile**

Defaults to **TRUE**.

**-L\|\--log-dir**

Defaults to */usr/sbotest/logs*.

**-P\|\--cpan-ignore**

Defaults to **TRUE**.

**-p\|\--pkg-dir**

Defaults to */usr/sbotest/tests*.

**-s\|\--sbo-home**

Defaults to */usr/sbotest*.

Running **sbotest config** without options is ineffective.

## EXIT CODES

**sboconfig** can exit with the following codes:

0: all operations were successful.\
1: a usage error occurred (e.g. passing invalid option specifications)\
2: a script or module error occurred.\
6: a required file handle could not be obtained.\
16: reading keyboard input failed.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools/> are always welcome.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboclean(1)](sboclean.1.md), [sbofind(1)](sbofind.1.md), [sbohints(1)](sbohints.1.md), [sboinstall(1)](sboinstall.1.md),
[sboremove(1)](sboremove.1.md), [sbotool(1)](sbotool.1.md), [sboupgrade(1)](sboupgrade.1.md), [sbotool(1)](sbotool.1.md), [sbotools.colors(5)](sbotools.colors.5.md),
[sbotools.conf(5)](sbotools.conf.5.md), [sbotools.hints(5)](sbotools.hints.5.md), dialog(1), gpg(1)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
