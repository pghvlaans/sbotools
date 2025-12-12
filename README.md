# sbotools

**[sbotools](https://pghvlaans.github.io/sbotools/)** is a set of Perl scripts providing a ports-like automation interface to [SlackBuilds.org](https://www.slackbuilds.org/). Run **sbotool** for a TUI. The tools can also run independently for greater efficiency:

  * **sbocheck**: Fetch the latest version of SlackBuilds.org repository; check for version updates, build number changes and out-of-tree installed SlackBuilds. Perform shared object dependency checks.
  * **sboclean**: Remove cruft by cleaning source archives, build directories and saved build options.
  * **sboconfig**: A command line interface for changing settings.
  * **sbofind**: Search the local copy of the repository.
  * **sbohints**: Query and modify the blacklist and requests for optional dependencies and reverse
dependency rebuilds.
  * **sboinstall**: Install SlackBuilds with their dependencies; handle compat32 packages and build from templates.
  * **sboremove**: Interactively remove installed SlackBuilds along with any unused dependencies.
  * **sboupgrade**: Upgrade previously-installed SlackBuilds.

Features include dependency handling, using a custom git branch for the upstream repository, reverse dependency search and rebuild, batch mode, gpg verification and more. See **sbotools(1)** or **sbotool(1)** for a startup guide.

Script maintainers may be interested in the **[sbotest](https://github.com/pghvlaans/sbotest)** companion package for convenient reverse dependency build testing.

This repository is an **sbotools** revival, and was forked from the [pink-mist repository](https://github.com/pink-mist/sbotools), which covered development from version 0.1 through version 2.7. A debt of gratitude is owed to the original author, Jacob Pipkin, longtime maintainer Andreas Guldstrand and major contributor Luke Williams. This software would not exist without their efforts.

To make **sbotools** packages from the master branch, see [sbotools-git-slackbuild](https://github.com/pghvlaans/sbotools-git-slackbuild). For release **sbotools**, a SlackBuild is [available](https://slackbuilds.org/repository/15.0/system/sbotools/) at SlackBuilds.org.

## Slackware Support

**sbotools** currently supports Slackware 15.0 and beyond. For Slackware 14.0, 14.1 and 14.2, install `sbotools-4.0.2` at the latest. See the **sbotools** [downloads](https://pghvlaans.github.io/sbotools/downloads/) page.

## Most Recent Changes
#### Post-Release
  * Build.pm: Retrieve the name of the last package created by a SlackBuild, not the first
  * Fixed a typo in the sbocheck bash completion
    * Thanks to fsLeg.
  * Readme.pm: Parse SlackBuilds for useradd and groupadd commands first

#### 4.1.2 - 2025-11-21
  * sbocheck: Perl test properly checks perl-involved shared objects

#### 4.1.1 - 2025-11-20
  * sboupgrade: --nowrap properly disables sbotools wrapping
    * Thanks to leoctrl for the report.
  * sboremove: Fix dependency ordering when running on multiple scripts
  * Solibs.pm: Figure out perl, python and ruby information only when tests are to be run
  * sboinstall: --noinstall can build any installed package if --reinstall is used
  * sboinstall, sboupgrade: Better on-screen messages with --noinstall
  * Build.pm: Better maintain dependency chains in rationalize_queue()
  * Build.pm: rationalize_queue() deals with the entire build queue for each script
  * Build.pm: Share warnings and completed build queues
  * sbotool: Fix GIT_BRANCH settings editor
  * Solibs.pm: Stock package check picks up \_slack15.0, e.g.
  * sbotool: Streamline the settings menu
    * Thanks to SCerovec for the feedback.
  * Note recommended non-default settings
  * sbotool: Hide and unhide items in Operations instead of using a second menu

#### 4.1 - 2025-10-31
  * Drop support for Slackware 14.0, 14.1 and 14.2
  * sbocheck, sbotool: Add a perl package compatibility test
  * sbocheck: --obsolete-check also downloads the perl version history file
  * sbotool: Add a reinstallation button for build test failure lists

#### 4.0.2 - 2025-10-31
  * sbotool: Package test fixes

#### 4.0.1 - 2025-10-27
  * sbotool: Clarified the batch installation prompt
    * Thanks to SCerovec for the feedback.
  * sbotool: Titles for command confirmation windows
  * sbocheck: Write a log to /tmp for non-root package tests
  * sbotool: Added a script selection menus for SlackBuilds that failed package tests
  * sbotool: List and mark non-SBo installations in the "Installed" menu
  * sbocheck: Add --types to choose one or more package checks: solibs (default), python, ruby or all
    * Thanks to fourtysixandtwo for the suggestion.
    * Coming next version: perl
  * sbotool: Incorporate the python and ruby checks
  * sboconfig: Replace the interactive questionnaire with the sbotool Settings menu
    * Thanks to SCerovec for the suggestion.
  * sboinstall, sbotool: Use a comma-separated list to specify multiple series for --series-rebuild
  * sbocheck: Exit with invalid options
  * Repo.pm: Exit when the user declines a pubkey download
  * Removed broken symlinks from t/
  * sboupgrade: Match sbocheck solib log formatting
  * sbotool: Add a button to delete local override files
  * sbotool: Offer to create a non-existent overrides directory after setting it
  * sbotool: Do not offer batch mode if unavailable

## Previous Changes
See [ChangeLog.md](https://github.com/pghvlaans/sbotools/blob/master/SBO-Lib/ChangeLog.md) for a record of changes from version 1.9 onward.
