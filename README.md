# sbotools

**[sbotools](https://pghvlaans.github.io/sbotools/)** is a set of Perl scripts providing a ports-like automation interface to [SlackBuilds.org](https://www.slackbuilds.org/). The tools are:

  * **sbocheck**: Fetch the latest version of SlackBuilds.org repository; check for version updates, build number changes and out-of-tree installed SlackBuilds.
  * **sboclean**: Remove cruft by cleaning source archives, build directories and saved build options.
  * **sboconfig**: A command line interface for changing settings.
  * **sbofind**: Search the local copy of the repository.
  * **sbohints**: Query and modify the blacklist and requests for optional dependencies and reverse
dependency rebuilds.
  * **sboinstall**: Install SlackBuilds with their dependencies; handle compat32 packages and build from templates.
  * **sboremove**: Interactively remove installed SlackBuilds along with any unused dependencies.
  * **sboupgrade**: Upgrade previously-installed SlackBuilds.

Features include dependency handling, using a custom git branch for the upstream repository, reverse dependency search and rebuild, batch mode, gpg verification and more. See **sbotools(1)** for a startup guide.

Script maintainers may be interested in the **[sbotest](https://github.com/pghvlaans/sbotest)** companion package for convenient reverse dependency build testing.

This repository is an **sbotools** revival, and was forked from the [pink-mist repository](https://github.com/pink-mist/sbotools), which covered development from version 0.1 through version 2.7. A debt of gratitude is owed to the original author, Jacob Pipkin, longtime maintainer Andreas Guldstrand and major contributor Luke Williams. This software would not exist without their efforts.

To make **sbotools** packages from the master branch, see [sbotools-git-slackbuild](https://github.com/pghvlaans/sbotools-git-slackbuild). For release **sbotools**, a SlackBuild is [available](https://slackbuilds.org/repository/15.0/system/sbotools/) at SlackBuilds.org.

## Most Recent Changes
#### Post-Release
  * Bugfix: For most compatibility builds and when running in a 32-bit userland reporting a 64-bit kernel, call SlackBuilds with setarch
  * Repo.pm: Use --no-pager with git-log
  * sboinstall, sboupgrade: Do not attempt compat32 builds for 64- and 32-bit only scripts
  * sboinstall, sboupgrade: Filter ineligible compat32 scripts and unsupported or nonexistent scripts from the arguments
  * Add setting NOWRAP to disable autowrapping sbotools output
    * Thanks to shamefulCake1 for the request.
  * Add sbotools color output, and a setting COLOR to enable it
  * Add /etc/sbotools/sbotools.colors to customize colors
  * Leave a trailing line more consistently
  * Add --color and --nocolor options to all scripts except sboconfig
    * Thanks to SCerovec for the suggestion.
  * sboinstall: Report package installation time in the reinstall notification
    * Thanks to shamefulCake1 for the request.
  * sbofind: Report package installation status
  * sbocheck: Attempt to report why scripts are out-of-tree
  * Util.pm: Block /root, /home (and its top-level directories) and / as directory settings and for $TMP
  * sbocheck: Optionally check all SBO packages for missing shared objects
  * sboupgrade: Optionally check all SBO packages for relevant missing shared objects
  * Add setting SO_CHECK to enable automatic shared object checks for sbocheck and sboupgrade
  * sbocheck: Use --check-package to check a list of packages (SBO or otherwise) for missing shared objects
  * Add Solibs.pm, a new module for performing shared object checks

#### 3.7 - 2025-07-04
  * Optimize queue construction: Shared dependency handling and rationalize_queue
  * Add setting ETC_PROFILE: Source executable \*.sh scripts in /etc/profile.d before running every SlackBuild
  * Download.pm: Change URI unescape positioning to accommodate potential %2F
    * Thanks to Slack Coder for the advice.
  * sboremove: Show the full reverse queue in --alwaysask; add a --compat32 option
  * Bugfix: Error out gracefully when reading STDIN fails for prompts
  * Bugfix: Properly detect useradd and groupadd commands in single quotes
  * Bugfix: Fix handling build options from files with EOL
    * Thanks to leoctrl for the report.
  * Add configuration LOG_DIR for saving build logs
  * Add environment variable SBOTOOLS_CONF_DIR for setting an alternative configuration directory
  * sboinstall, sboupgrade: Add --log-dir and --pkg-dir
  * Bugfix: Send the RESET escape after running each SlackBuild to clean up after colorful build systems
  * sboinstall: Add --series-rebuild to rebuild and reinstall all SBo packages in a series with their dependencies
  * sbofind: Add --first-reverse to report all first-level reverse dependencies in the repository
  * Install to vendor_perl; install bundled Sort::Versions in SBO::ThirdParty to avoid collisions
  * sboconfig, sbohints, sbofind: Callable from sbotest with config, hints and find, respectively
  * Tree.pm: Speed up location finding for all available; relevant for reverse dependency calculation
  * sboconfig: Use --non-default to list only non-default options
  * Bugfix: For git, create new branches from upstream in lieu of reset and pull

## Previous Changes
See [ChangeLog.md](https://github.com/pghvlaans/sbotools/blob/master/SBO-Lib/ChangeLog.md) for a record of changes from version 1.9 onward.
