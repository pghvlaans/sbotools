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

**sbotool** - front-end to sbotools

## SYNOPSIS

    sbotool [-h|-v]

    sbotool [-d FILE]

## DESCRIPTION

**sbotool** is a meta-tool providing a front-end to all of the
**sbotools** based on **dialog(1)**. It can be run by root and non-root
users. The contents of the menus are dynamic and reflect available and
efficacious options. **sbotool** must be run as root (preferably in a
login shell reached from e.g. **su -**) to perform package
installations, upgrades and removals, and to fetch the repository.

The basic workflow is straightforward: navigate to a script with
**Browse Repository** or **Package Search** and choose from the list of
options in the menu. Installed, upgradable and override scripts can be
reached from **Installed SBo Packages**, **Upgradable SBo Packages** and
**Overrides**, respectively. **Main Menu** has options for large-scale
upgrades, rebuilds and shared object dependency checks.

**sbotools** calculates dependencies automatically, and individual
scripts can be added to the blacklist or have optional dependencies
specified using the script's **Hints** interface. Installations and
upgrades can be performed either interactively or non-interactively. If
the non-interactive *batch mode* is chosen, **sbotool** displays a dry
run on the final confirmation screen. To specify build options for a
particular script, install interactively or use **Add Build Options**
from the script menu screen ahead of time as root. Build options are
saved in the */var/log/sbotools* directory for future use.

Individual scripts can be added to lists for installation, upgrade and
removal as the root user. Any user may add to the template list; the
template produced can be implemented as root with **sboinstall
\--use-template**. Use **List Operations** from **Main Menu** to do the
chosen operation for the listed scripts. These lists do not persist when
**sbotool** is closed. List operations use dependency resolution.

If a utility other than **sbotool** installs, removes or upgrades
packages, or changes **sbotools** settings, while **sbotool** is
running, use the **Refresh** option in the main menu to ensure that the
output reflects these changes.

Although most **sbotools** operations can be accomplished in
**sbotool**, calling the scripts individually from the command line
provides superior efficiency and fine-tuned option control to
experienced users. See the **Man Pages** menu to read further user
documentation.

## STARTUP

A copy of the *SlackBuilds.org* repository must be fetched when using
**sbotools** for the first time, or when the **sbotools** directory has
been changed. Run **sbotool** as root and select the **Fetch
Repository** option. The local repository is saved to */usr/sbo/repo* by
default; the default upstream is the *SlackBuilds.org* **GitLab**
mirror, or the **Ponce repository** for Slackware -current.

**sbotools** has a number of potentially useful configuration settings,
including the upstream repository, git branch and location. To make
changes, run **sbotool** as root and enter the **Settings** menu. Select
a setting from the list to see an explanation and enter a new value. All
configuration values are documented in [sbotools.conf(5)](sbotools.conf.5.md).

**sbotool** uses **dialog(1)** for output. The color scheme and
appearance can be changed using a *dialogrc* file. Set the **DIALOGRC**
setting to an **absolute file path** to use an alternative *dialogrc*.
See */etc/dialogrc* for an example, or run

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
[sbotools.colors(5)](sbotools.colors.5.md), [sbotools.conf(5)](sbotools.conf.5.md), [sbotools.hints(5)](sbotools.hints.5.md), dialog(1)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
