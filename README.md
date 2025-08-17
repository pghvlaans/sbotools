# sbotools

**[sbotools](https://pghvlaans.github.io/sbotools/)** is a set of Perl scripts providing a ports-like automation interface to [SlackBuilds.org](https://www.slackbuilds.org/). The tools are:

  * **sbocheck**: Fetch the latest version of SlackBuilds.org repository; check for version updates, build number changes and out-of-tree installed SlackBuilds. Perform shared object dependency checks.
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
  * Replace most grep instances
  * Simplify location finding
  * Info.pm: Only attempt repairs on known-bad info files
  * sbofind: Simplify search
  * Build.pm: Speed up rationalize_queue
  * Util.pm: Clean up hint reading; faster in()
  * Info.pm: Parse each info file only once
  * Do not kludge compat32 dependency handling

#### 3.8 - 2025-08-14
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
  * Bugfix: Improve interrupt behavior
  * Bugfix: Fix rationalize_queue
  * Readme.pm: General clean-up; account for no-README case and using previously-specified options without detected options
  * sbocheck: Use --check-all-packages to check all packages (SBO or otherwise) for missing shared objects

## Previous Changes
See [ChangeLog.md](https://github.com/pghvlaans/sbotools/blob/master/SBO-Lib/ChangeLog.md) for a record of changes from version 1.9 onward.
