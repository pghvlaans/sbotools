# sbotools

**[sbotools](https://pghvlaans.github.io/sbotools/)** is a set of Perl scripts providing a ports-like automation interface to [SlackBuilds.org](https://www.slackbuilds.org/). Run **sbotool** for a TUI. The tools can also run independently for greater efficiency:

  * **sbocheck**: Fetch the latest version of SlackBuilds.org repository; check for version updates, build number changes and out-of-tree installed SlackBuilds. Perform shared object dependency and other package checks.
  * **sboclean**: Remove cruft by cleaning source archives, build directories and saved build options.
  * **sboconfig**: A command line interface for changing settings.
  * **sbocutleaves**: Interactively remove or list leaves, SBo packages without installed reverse dependencies.
  * **sbofind**: Search the local copy of the repository.
  * **sbohints**: Query and modify the blacklist and requests for optional dependencies and reverse
dependency rebuilds.
  * **sboinstall**: Install SlackBuilds with their dependencies; handle compat32 packages and build from templates.
  * **sboremove**: Interactively remove installed SlackBuilds along with any unused dependencies.
  * **sboupgrade**: Upgrade previously-installed SlackBuilds.

Features include dependency handling, using a custom git branch for the upstream repository, reverse dependency search and rebuild, batch mode, gpg verification and more. See **sbotools(1)** or **sbotool(1)** for a startup guide.

Script maintainers may be interested in the **[sbotest](https://github.com/pghvlaans/sbotest)** companion package for convenient reverse dependency build testing.

This repository is an **sbotools** revival, and was forked from the [pink-mist repository](https://github.com/pink-mist/sbotools), which covered development from version 0.1 through version 2.7. A debt of gratitude is owed to original author (and recent contributor) Jacob Pipkin, longtime maintainer Andreas Guldstrand and major contributor Luke Williams. This software would not exist without their efforts.

To make **sbotools** packages from the master branch, see [sbotools-git-slackbuild](https://github.com/pghvlaans/sbotools-git-slackbuild). For release **sbotools**, a SlackBuild is [available](https://slackbuilds.org/repository/15.0/system/sbotools/) at SlackBuilds.org.

## Slackware Support

**sbotools** currently supports Slackware 15.0 and beyond. For Slackware 14.0, 14.1 and 14.2, install `sbotools-4.0.2` at the latest. See the **sbotools** [downloads](https://pghvlaans.github.io/sbotools/downloads/) page.

## Most Recent Changes
#### Post-Release
  * sbofind: Show maintainer names unless in CLASSIC mode; search names with --maintainers.
  * sbotool: Show maintainer names in the per-script Operations screens.
  * Download.pm: Ignore content_disposition settings in wgetrc.
    * Thanks to worriedeland for the heads-up.
  * Added a setting FORCE_OBSOLETE to treat the obsolete scripts list as a supplementary blacklist on -current.
    * Do not use unless your repository does not remove outdated scripts.
    * Thanks to gbschenkel for raising this issue.

#### 4.2 - 2026-06-12
  * sbocutleaves: A new tool for managing leaves, i.e. packages without installed reverse dependencies.
    * Proposed and drafted by Jacob Pipkin.
  * sbotool: Added sbocutleaves functionality
  * sboclean, sbofind: Fix --wrap and --nowrap
  * sbocheck: Unless in Classic mode, separate upgradable and non-upgradable scripts in the output
  * sboinstall: With --reinstall, mention version changes
  * sboinstall: install and reinstall messaging reflects override scripts
  * sbotool: Hide ineffective settings when CLASSIC is TRUE
  * sboremove: Use --query to print the prospective removal prompt order
  * sboremove: Use --no-descriptions to suppress package descriptions
  * Readme.pm: Fix opening SlackBuilds for -compat32
  * sboinstall: Do not attempt automatic dependency rebuilds with --noinstall
  * sboinstall, sboupgrade: Use --get-only to verify and download sources for the queue with no other action
  * sboremove: Also display reverse dependencies for scripts named in the command line
  * sboinstall: Fix template creation with a non-existent directory
  * Readme.pm: Rework option detection for accuracy
  * Readme.pm: Offer to show all readme files before asking for options and UID/GID
  * Use a temporary staging directory with the real source files when building
    * Thanks to leoctrl for reporting a symlink-related bug
  * Added File::Copy::Recursive to ThirdParty
  * Added SBO_HOME/manual_downloads for stowing manual downloads
    * Thanks to dchmelik and shamefulCake1 for the feedback about managing manual downloads.
  * sboclean: Do not follow symlinks
  * sbofind: Do not show obsolete scripts in --queue output for -current

#### 4.1.4 - 2026-05-06
  * sbofind: Do not match "No tags found" in TAGS.txt
  * contrib: SCerovec shared a Debian-like sbotool theme
  * Allow for SlackBuilds without specified downloads
    * Thanks to SCerovec for the suggestion.
  * sbotool: Improve Settings menu readability
    * Thanks to SCerovec for the feedback.
  * More maintainable next-Slackware-version handling
  * Repo.pm: Display the mirror URL and branch when downloading
    * Thanks to fsLeg for the suggestion.
  * Added a setting NONET to block network access when running SlackBuilds
  * sboupgrade: Added --all-plus-failures
    * Thanks to dchmelik for the suggestion.
  * Added a hint for sboupgrade to ignore test failures for a script
  * sbohints: Fixed the long-form --replace-optional flag

## Previous Changes
See [ChangeLog.md](https://github.com/pghvlaans/sbotools/blob/master/SBO-Lib/ChangeLog.md) for a record of changes from version 1.9 onward.
