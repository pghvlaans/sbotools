# ChangeLog
* 3.4 - 2025-01-22
  * *sboconfig*: Run without flags or options to use an interactive menu
  * *sboupgrade*: Do not attempt to upgrade the build queue if the requested script does not need an upgrade
  * *sbocheck*: Display the installed build number for the build number check
  * Add setting **STRICT_UPGRADES**: Except for override packages, only upgrade when the version or build number is higher
  * *sboinstall*: Use **\--reverse-rebuild** to rebuild all reverse dependencies of a script
  + *sbofind*: Indicate if a script is blacklisted
  * *sbohints*: A new tool for modifying and querying the blacklist and optional dependency requests
  * *sboinstall*: Always give a distinct warning prompt when a package without the *\_SBo* tag would be replaced by adding it to the queue
  * *sboinstall*: Honor the blacklist when installing from templates
  * Handle circular dependency errors
  * *Repo.pm*: More accurate warning text in case of **BADSIG**

* 3.3 - 2024-12-31
  * *sboconfig*: Allow versions "X.Y+" and "current"; more informative error messages
  * Exit with invalid *sbotools.conf* parameters
  * *sbocheck*: Before fetch, offer to exit if the git branch does not exist
  * *Repo.pm*: Check for local repo similarity to SBo rather than relying on *SLACKBUILDS.TXT*
  * *sbosnap*: Redundant; replace with a compatibility symlink
  * Wrap variable-length onscreen messaging (that can't be piped), prompts and error messages at 72 characters
  * *sboconfig*: Use **\--reset** to restore all default configuration values
  * *Build.pm*: Remove temporary directory in case of signal
  * Bugfix: When parsing *info* files, fix whitespace, unwanted lines, quotation and backslashes
  * *Info.pm*: Tweak build number detection for an *sbocheck* performance boost

* 3.2.1 - 2024-12-20
  * Bugfix: *sboinstall*, *sboupgrade* GPG check for custom repositories (removed unneeded conditional)

* 3.2 - 2024-12-19
  * *sbocheck*: Do not use compact format for **CLASSIC** mode
  * *Repo.pm*: Prompt for regeneration if *SLACKBUILDS.TXT* is missing instead of erroring out
  * Set **GPG_VERIFY** to **TRUE** to verify with gpg in case of repo fetch, *sboinstall* or *sboupgrade*
  * Bugfix: do not crash if *sbotools.conf* provides an improper value of **SLACKWARE_VERSION**
  * *Repo.pm*: Offer to retry failed git fetch
  * Bugfix: *sbocheck* reports version differences between **LOCAL_OVERRIDES** and the repository
  * *Util.pm*: Read the hints file only once; allow multiple optional dependency specs for the same script
  * Lint the value of **SBO_HOME** before running anything other than *sboconfig*
  * *Repo.pm*: Remove antiquated subroutine *migrate_repo()*
  * Install development man pages on *SBO::Lib* to man 3

* 3.1 - 2024-12-05
  * *sbofind*: Allow multiple search terms
  * Add a summary **sbotools(1)** man page with executive summaries and a startup guide
  * *sboinstall*: Use **\--mass-rebuild** to rebuild all non-compat32 SlackBuilds
  * *sboconfig*: Fix incorrect misconfiguration warnings
  * *sbocheck*: More compact output.
  * *sbotools.hints*: User-specified blacklist and optional dependency requests
  * Bugfix: Prevent undefined build number checks with a local override directory
  * Bugfix: Add a missing `git pull` for custom git branches
  * sboinstall: Use a resume file for **\--mass-rebuild**
  * Clarify **LOCAL_OVERRIDES** documentation
  * Detect and handle next version (currently 15.1) more effectively
  * Adopt MIT License

* 3.0 - 2024-11-22
  * *sbocheck*: Use **\--nopull** to check for updated SlackBuilds without updating the tree
  * *sbofind*: Use **\--reverse** to check for installed reverse dependencies
  * Add setting **CLASSIC**: turn on **BUILD_IGNORE** and **RSYNC_DEFAULT**, and disable output added post-*sbotools*
  * Fix some **--help** verbiage

# sbotools3
*Note*: this repository was named `sbotools3` for a brief period in late 2024.

* 1.1 - 2024-11-03
  * Bugfix: incorrect variable name caused *sboupgrade* to rebuild when unneeded.

* 1.0 - 2024-11-01
  * Change the git branch to match the Slackware version, or to a user-configured branch
  * Change the default URLs to support Slackware 15.0 and use git repositories
  * Use rsync default mirrors with **RSYNC_DEFAULT** (except for -current)
  * Detect build number changes and optionally upgrade
  * Detect and report out-of-tree *_SBo* SlackBuilds with *sbocheck*
  * Save any build options when running a SlackBuild
  * Install *bash* completions; *zsh* completions have been updated
  * Install a default configuration file; tweak *sboconfig* to play somewhat nicely with it
  * Fix making -compat32 packages for non-i486 SlackBuilds
  * Fix building -compat32 packages from templates

## Historical Changes
*Note*: [pink-mist/sbotools](https://github.com/pink-mist/sbotools/) was the home of **sbotools** development during this time.

* Post-2.7 - 2019
  * Add and install *zsh* completions

* 2.7 - 2019-04-28
  * Actually fix the *sbofind* -e bug #71
      
* 2.6 - 2019-04-27
  * Compatibility with new *perl* versions where you need to escape *{* in regexp
    #75 #77 #78
  * Add a *\--tries 5* option when downloading from sbosrcarch, which is a
    saner limit than the default of 20. #79
  * Change *sboclean* options **\--clean-dist** and **\--clean-work** to shorter forms #52
  * Add limited -current support using ponce's *SBo* repo for -current #73
  * Fix bug with *sboinstall \--reinstall -r* #72
  * Fix bug with *sbofind -e* #71

* 2.5 - 2018-02-14
  * Document download behaviour #66
  * Remake *sbosnap* and *sboremove* to have OO semantics
  * Strip -compat32 from slackbuild names when looking them up #65
  * Optimise searching in *sbofind*

* 2.4 - 2017-05-18
  * Rewrite *sboremove* from the ground up so it relies less on global state
  * Fix for parsing *README* with *useradd*/*groupadd* commands which span lines #57
  * Add **\--reinstall** option to *sboinstall* #58
  * Exit with error when *sbosnap* fails to sync with a repo #61
  * Add version information to *sbofind* output #60

* 2.3 - 2017-01-21
  * Bugfix for parsing *.info* files with \ among the separators #55

* 2.2 - 2017-01-17
  * Bugfix for parsing *.info* files with trailing whitespace after a value #54

* 2.1 - 2017-01-14
  * Internals:
    - Adding internal documentation
    - Extract code to submodules for easier separation of concerns
  * New features:
    - Support for templates for installing things with specified options #38
    - Display other *README* files if the slackbuild comes with them #49
  * Bugfixes
    - *sboinstall*/*sboremove* disagreeing about a package being installed #44
    - *sbocheck* and *sboupgrade* misinterpreting version strings #45
    - parsing *.info* files without leading space on second line #46
    - local git repo gets partially chowned to root #47
    - stop excluding *.tar.gz* files when rsyncing #53

* 2.0 - 2016-07-02
  * Major new features
    * **LOCAL_OVERRIDES** setting

      Allows to keep a directory with local slackbuild dirs that will override
      whatever is found in the regular repository. #8 #13 #14 #15 #19 #20
    * **SLACKWARE_VERSION** setting

      Allows to specify the slackware version to sync from *SBo*. Previously only
      the version in your */etc/slackware-version* was used for this, and if that
      had gotten updated in -current, you'd have needed to wait both for a new
      version of *sbotools*, as well as *SBo* to get the new repository online
      before *sbotools* would work for you again. #19
    * **REPO** setting

      This will override the **SLACKWARE_VERSION** setting. It's used to specify an
      absolute URL for the *SBo* repository you want to sync with. #6 #19 #27
    * Use sbosrcarch source archive if download fails #7 #19 #24
    * *sboupgrade* **\--all** option to upgrade everything listed by *sbocheck*. #9 #19
    * Travis CI integration

      Every push will now cause the test-suite to be run. #18
    * Hundreds of new unit-tests. #18 #19 #23 #24 #25 #27 #28 #31 #32 #33 #35 #41 #43
    * *sbofind* will now also use tags if they're available #37
  * Minor/bugfixes/documentation fixes
    * Use system *perl* when running and installing *sbotools*.
    * *sbocheck* output changed. #10 #13 #20
    * Better debug messages on errors. #16
    * manpage fixes. #17
    * *sboupgrade* handles dependencies better. #12 #28
    * Update bundled *Sort::Versions* to 1.62.
    * *sboinstall*/*upgrade*/*sbocheck*: small bugfixes. #21 #35 #41 #43
    * *sbosnap*: display download progress, update git trees better. #26 #27

* 1.9 - 2015-11-27
  * Make it compatible with *perls* newer than 5.18
  * Lots of code cleanup
  * Rewrite build-queue code. #2
  * Fix issue when *TMP* is set. #4
  * Fix various bugs related to cleanup code
  * Change location of website
  * Fix downloading of multiple sources in newer slackbuilds. #5

