# sbotool

[NAME](#name)\
[SYNOPSIS](#synopsis)\
[DESCRIPTION](#description)\
[STARTUP](#startup)\
[OPTIONS](#options)\
[BUGS](#bugs)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[MAINTAINER](#maintainer)

------------------------------------------------------------------------

## NAME

**sbotool** - text user interface to sbotools

## SYNOPSIS

    sbotool [-h|-v]

    sbotool [-d FILE]

## DESCRIPTION

**sbotool** is a meta-tool providing a TUI to all of the **sbotools**
based on **dialog(1)**. It can be run by root and non-root users.
**sbotool** must be run as root (preferably in a login shell reached
from e.g. **su -**) to perform package installations, upgrades and
removals, and to fetch the repository.

The contents of all menus are dynamic and reflect available and
efficacious options. Use the **Help** buttons for more information about
individual menu screens.

The basic workflow is straightforward: Navigate to a SlackBuild with
**Browse Repository** or **Package Search** and choose from the list of
options in the **Operations** menu. Installed, upgradable and override
scripts can be reached from **Installed**, **Upgradable** and
**Overrides**, respectively. A number of actions beyond basic package
management are available from **Operations**; see **Help** for details.

For system-wide actions, see **Main Menu**. Use **Fetch Repository** to
get or update a copy of the **SlackBuilds.org** repo, or **Settings** to
view and edit **sbotools** settings. Large-scale upgrades, rebuilds and
shared object checks can also be done here. To act on the **Install**,
**Upgrade**, **Remove** or **Template** lists, use the **List
Operations** menu screen.

**sbotools** calculates dependencies automatically, and individual
scripts can be added to the blacklist or have optional dependencies
specified using the script's **Edit Hints** interface. Installations and
upgrades can be performed either interactively or non-interactively. If
the non-interactive *batch mode* can be offered, **sbotool** displays a
dry run on the confirmation screen. To specify build options for a
particular script, install interactively or use **Build Options** from
the **Operations** menu ahead of time as root.

If package operations are performed or **sbotools** settings are changed
from outside of the running **sbotool** instance, use the **Refresh**
option in **Main Menu** to ensure that the output reflects these
changes.

Although most **sbotools** operations can be accomplished in
**sbotool**, calling the scripts individually from the command line
provides superior efficiency and fine-tuned option control to
experienced users. See the **Man Pages** menu to read further user
documentation.

## STARTUP

Ensure that the terminal window is at least 80x25 characters to run
**sbotool**. The **lines** and **cols** terminal capabilities are
required; **tput(1)** can be used to check. This should not be a problem
for any remotely modern terminal.

A copy of the **SlackBuilds.org** repository must be fetched when using
**sbotools** for the first time, or when the **sbotools** directory has
been changed. Run **sbotool** as root and select the **Fetch
Repository** option. The local repository is saved to */usr/sbo/repo* by
default; the default upstream is the **SlackBuilds.org GitLab** mirror,
or the **Ponce repository** for Slackware -current.

**sbotools** has a number of potentially useful configuration settings,
including the upstream repository, git branch and location. To make
changes, run **sbotool** as root and enter the **Settings** menu. Select
a setting from the list to see an explanation and enter a new value. All
configuration values are documented in [sbotools.conf(5)](sbotools.conf.5.md).

**sbotool** uses **dialog(1)** for output. The color scheme and
appearance can be changed using a *dialogrc* file. Set the **DIALOGRC**
setting to an **absolute file path** to use an alternative *dialogrc*.
See */etc/dialogrc* or */usr/share/sbotools* for an example, or run

    dialog --create-rc FILE

to generate a default *dialogrc* to modify. The **\--dialogrc** option
can also specify a file at runtime.

## OPTIONS

**-d\|\--dialogrc (FILE)**

Use this dialogrc file for the current run of **sbotool**. Overrides the
**DIALOGRC** setting.

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools/> are always welcome.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboclean(1)](sboclean.1.md), [sboconfig(1)](sboconfig.1.md), [sbofind(1)](sbofind.1.md), [sbohints(1)](sbohints.1.md),
[sboinstall(1)](sboinstall.1.md), [sboremove(1)](sboremove.1.md), [sboupgrade(1)](sboupgrade.1.md), sbotools(1),
[sbotools.colors(5)](sbotools.colors.5.md), [sbotools.conf(5)](sbotools.conf.5.md), [sbotools.hints(5)](sbotools.hints.5.md), dialog(1),
tput(1)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
