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

This repository is for continuing **sbotools** development, and was forked from the [pink-mist repository](https://github.com/pink-mist/sbotools), which covered development from version 0.1 through version 2.7. A debt of gratitude is owed to the original author, Jacob Pipkin, longtime maintainer Andreas Guldstrand and major contributor Luke Williams. This software would not exist without their efforts.

To make **sbotools** packages from the master branch, see [sbotools-git-slackbuild](https://github.com/pghvlaans/sbotools-git-slackbuild). For release **sbotools**, a SlackBuild is [available](https://slackbuilds.org/repository/15.0/system/sbotools/) at SlackBuilds.org.

## Most Recent Changes
#### Post-Release
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
  * sboconfig, sbohints: Callable from sbotest with --config or --hints

#### 3.6 - 2025-05-10
  * Bugfix: Download.pm: Unlink existing symlinks with the same name as new ones
  * sboinstall, sboupgrade: Unless CLASSIC is on, display time taken and successful builds at the end
  * sbofind, sbocheck, sboconfig -l, sboinstall, sboupgrade, sboremove: Show a warning if the specified local overrides directory does not exist; exit if --batch or --nointeractive
    * Thanks to Slack Coder for the suggestion.
  * sboinstall, sboupgrade: Do not notify the user about 'missing' scripts that are already installed, or, on -current, are known to have been renamed and added to -current or obsoleted
    * Thanks to fourtysixandtwo for the feedback.
  * Added setting OBSOLETE_CHECK: Update the list of scripts at /etc/sbotools/obsolete from the sbotools home page when running sbocheck on -current
    * Inspired by the renames list on sbopkg.
  * sbofind: Use -A to show every reverse dependency in the repository; use -T to show the final level of reverse dependencies
  * Bugfix: Verify suspected circular reverse dependencies by checking a build queue
  * Add error codes for failed GPG verification and missing users or groups
  * Bugfix: Corrected some error codes
  * Bugfix: Fix all URI escapes in distfile names
    * Thanks to fourtysixandtwo and lockywolf for the report
  * sbocheck: Use --obsolete-check to download the list of obsolete scripts only; GPG verify with -g

## Previous Changes
See [ChangeLog.md](https://github.com/pghvlaans/sbotools/blob/master/SBO-Lib/ChangeLog.md) for a record of changes from version 1.9 onward.
