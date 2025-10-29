# sbotools

[NAME](#name)\
[DESCRIPTION](#description)\
[STARTUP](#startup)\
[BUGS](#bugs)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[MAINTAINER](#maintainer)

------------------------------------------------------------------------

## NAME

**sbotools** - Perl scripts providing a ports-like interface to
**SlackBuilds.org**

## DESCRIPTION

**sbotools** is a set of Perl scripts that collectively provide a
ports-like interface to **SlackBuilds.org**. Each tool is documented in
its own man page.

[sbocheck(1)](sbocheck.1.md)

Fetch the latest version of the upstream SlackBuilds repository. Check
for version updates, build number changes and out-of-tree installed
SlackBuilds with the *\_SBo* tag. Perform shared object dependency
checks.

[sboclean(1)](sboclean.1.md)

Remove cruft by cleaning source archives, build directories and saved
build options.

[sboconfig(1)](sboconfig.1.md)

A command line interface for changing */etc/sbotools/sbotools.conf*.

[sbofind(1)](sbofind.1.md)

Search the local copy of the repository for SlackBuilds. Optionally,
display build queues, *README* and *info* files and installed reverse
dependencies.

[sbohints(1)](sbohints.1.md)

Query and modify script specific hints: blacklist, optional dependencies
and reverse dependency rebuilds.

[sboinstall(1)](sboinstall.1.md)

Install SlackBuilds with their dependencies. Handle compat32 packages
and create or build from templates.

[sboremove(1)](sboremove.1.md)

Interactively remove installed SlackBuilds along with any unused
dependencies.

[sbotool(1)](sbotool.1.md)

Perform most **sbotools** operations from this TUI with dynamic
**dialog(1)** menus. Calling the commands individually provides superior
efficiency and option control.

[sboupgrade(1)](sboupgrade.1.md)

Upgrade previously-installed SlackBuilds.

By default, [sboinstall(1)](sboinstall.1.md) and [sboupgrade(1)](sboupgrade.1.md) give prompts before
adding items to the build queue. These scripts have a **\--batch** flag
available for non-interactive building with dependency resolution.
Because **\--batch** can install new dependencies without prompting,
using it in a production environment without a well-maintained
*/etc/sbotools.hints* file, or with unfamiliar scripts, can potentially
lead to unwanted results. Consider passing **\--dry-run** first, which
prints the build queue with other information and exits.

For details about all configuration options in *sbotools.conf*, see
[sbotools.conf(5)](sbotools.conf.5.md). [sbotools.hints(5)](sbotools.hints.5.md) documents the
*/etc/sbotools/sbotools.hints* file, which passes hints to
[sboinstall(1)](sboinstall.1.md) and [sboupgrade(1)](sboupgrade.1.md): blacklist, optional
dependencies and automatic reverse dependency rebuilds.

Those who wish to use **sbotools** for testing scripts and reverse
dependencies in a clean build environment may be interested in the
**sbotest** companion package.

**sbotools** currently supports Slackware 15.0 and beyond. For Slackware
14.0, 14.1 and 14.2, install **sbotools-4.0.1** at the latest.

## STARTUP

When using **sbotools** for the first time, a copy of the SlackBuilds
repository must be fetched with [sbocheck(1)](sbocheck.1.md):

    sbocheck

The local repository is saved to */usr/sbo/repo*. To use an alternative
location, give an absolute file path to the **SBO_HOME** setting with
[sboconfig(1)](sboconfig.1.md) or by editing */etc/sbotools/sbotools.conf*. The
repositiory can also be fetched using **sbotool** if running as root.

The default mirror depends on the running version of Slackware. Stable
releases use the appropriate branch on
<https://gitlab.com/SlackBuilds.org/slackbuilds/> and -current uses
<https://github.com/Ponce/slackbuilds/> with the **current** branch.

To use an rsync mirror with \<rsync://slackbuilds.org/slackbuilds/\*/\>
as the default, set **RSYNC_DEFAULT** to **TRUE**. The **REPO** setting
overrides the default mirror with a git or rsync URL, and **GIT_BRANCH**
sets a custom git branch.

To update the local repository, run [sbocheck(1)](sbocheck.1.md). This generates a
report with potential version upgrades, SlackBuilds with incremented
build numbers and out-of-tree SlackBuilds installed with the *\_SBo*
tag.

The simplest way to upgrade all eligible SlackBuilds is to run

    sboupgrade --all

Build number increments are ignored if **BUILD_IGNORE** is set to
**TRUE**.

Using [sboconfig(1)](sboconfig.1.md) without flags enters the [sbotool(1)](sbotool.1.md) settings
menu, which shows all available options with explanations. Settings
changes can be done from here if running as root. Using flags is faster,
but some users may find this a helpful resource.

**sbotools** can be set up to print some messages and prompts in color.
All scripts except for **sboconfig** have **\--color** and
**\--nocolor** options to turn colors on and off. To turn all colors on
by default, set **COLOR** to **TRUE**. Output colors can be customized
by editing the */etc/sbotools/sbotools.colors* file. See the comments
there or [sbotools.colors(5)](sbotools.colors.5.md) for details.

Upgrading Slackware or other packages occasionally causes breakage
related to missing shared object dependencies (solibs). To check
first-order dependencies for all installed *SBo* packages, use
**sbocheck** with the **-X** option. Use **-c** instead to check a list
of installed packages, or **-C** to check all installed packages. **-C**
and **-c** can be used without a local copy of the repository. Checks of
*\_SBo* packages only are performed automatically after running
**sbocheck** and [sboupgrade(1)](sboupgrade.1.md) when the **SO_CHECK** setting is
**TRUE**.

Use **sbocheck** with the **\--perl**, **\--python** and **\--ruby**
options to check for incompatible *SBo* packages. This is done
automatically when running **sbocheck** if the **SO_CHECK** setting is
**TRUE**.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools/> are always welcome.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboclean(1)](sboclean.1.md), [sboconfig(1)](sboconfig.1.md), [sbofind(1)](sbofind.1.md), [sbohints(1)](sbohints.1.md),
[sboinstall(1)](sboinstall.1.md), [sboremove(1)](sboremove.1.md), [sbotool(1)](sbotool.1.md), [sboupgrade(1)](sboupgrade.1.md),
[sbotools.colors(5)](sbotools.colors.5.md), [sbotools.conf(5)](sbotools.conf.5.md), [sbotools.hints(5)](sbotools.hints.5.md), dialog(1)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
