# sbotools

**[sbotools](https://pghvlaans.github.io/sbotools/)** is a set of Perl scripts providing a ports-like automation interface to [SlackBuilds.org](https://www.slackbuilds.org/). Run **sbotool** for a TUI. The tools can also run independently for greater efficiency:

  * **sbocheck**: Fetch the latest version of SlackBuilds.org repository; check for version updates, build number changes and out-of-tree installed SlackBuilds. Perform shared object dependency and other package checks.
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

#### 4.1.3 - 2025-12-26
  * Build.pm: Retrieve the name of the last package created by a SlackBuild, not the first
  * Fixed a typo in the sbocheck bash completion
    * Thanks to fsLeg.
  * Readme.pm: Parse SlackBuilds for useradd and groupadd commands first
  * Readme.pm: Ask about options before asking about users and groups
  * Readme.pm: Handle SlackBuilds with variable user and group names and UID/GID
  * completions/zsh: Fix a number of broken lines
    * Thanks to Ndolam for the report and pointers.
  * completions/bash: Use SBO::Lib::* in preference to outside programs
  * Readme.pm: Better distinguish existing users and groups
  * sbotool: Add a button for missing users and groups
  * Download.pm: Handle download URLs requiring content disposition
    * Selectively add --content-disposition to the wget command, following slackrepo

## Previous Changes
See [ChangeLog.md](https://github.com/pghvlaans/sbotools/blob/master/SBO-Lib/ChangeLog.md) for a record of changes from version 1.9 onward.
