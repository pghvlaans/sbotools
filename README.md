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

## Changes
* Post-Release
  * Download.pm: Unlink existing symlinks with the same name as new ones
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

* 3.5 - 2025-03-26
  * sbofind: Use --exact-case to search for an exact match with case sensitivity
    * Thanks to leoctrl for the report.
  * man1: Add a variables section to the sboinstall and sboupgrade pages
    * Thanks to leoctrl for the suggestion.
  * sboclean, sboremove, sboinstall, sboupgrade: Exit with unknown options
    * Thanks to Slack Coder for the suggestion.
  * sbohints: Via Util.pm, only show optional dependencies once per script when listing
  * sboupgrade: Add --reverse-rebuild to rebuild a reverse dependency queue upon upgrade
  * sbotools.hints: Prepend a tilde to a script to request automatic reverse dependency rebuilds upon upgrade or reinstall
  * sbohints: Add and clear reverse dependency rebuild requests with -r and -cr
  * sboclean: Properly remove empty directories from distfiles
  * sboinstall: Honor automatic reverse dependency rebuilds with --reinstall
  * sboinstall, sboupgrade: Automatically reuse saved build options with --nointeractive unless passing --norecall
  * Readme.pm: Default "yes" when saved build options are offered
  * Download.pm: Do not ignore certificates with wget
    * Thanks to Slack Coder for the suggestion.
  * sboinstall: Do not attempt compat32 builds for noarch
  * Build.pm: Remove unnecessary ARCH modification
  * Util.pm: Add rationalize_queue for automatic reverse dependency rebuilds
  + Readme.pm: Only display README once
  * Add setting CPAN_IGNORE: Install scripts even if they are already installed from the CPAN
    * Thanks to 1-1sam for the suggestion.
  * Pkgs.pm: Properly ignore uninstalled CPAN modules
  * sbofind: Report on scripts installed from the CPAN, in whole or in part
  * sboinstall: Make --reverse-rebuild usable with --compat32; --use-template is incompatible
  * sboupgrade: Restore --compat32, which was deprecated in 2013 and partially removed in 2015
  * sbohints: --reset was blocked by mistake; unblocked
  * Tree.pm: Properly report compat32 scripts in LOCAL_OVERRIDES
  * sbocheck: Fix non-root --nopull when GPG_VERIFY is on
  * sbocheck: Fix build number display for scripts bumped in LOCAL_OVERRIDES
  * sboinstall: --mass-rebuild handles compat32 builds
  * sboinstall: packages without the \_SBo tag are skipped automatically if not interactive
  * sboinstall, sboupgrade: --batch runs interactively with dependency resolution; --dry-run shows the --batch queue and exits
  * Readme.pm: Do not nag the user about existent users and groups; account for other README files for useradd and groupadd
  * sbofind: Fix failure when LOCAL_OVERRIDES is specified but does not exist
  * sboinstall: Check for existent scripts in @ARGV for --use-template and --nointeractive only; look beyond first item
  * All scripts: Properly exit with code 0 with --help
  * sboinstall, sboupgrade: Allow --dry-run without root privileges

* 3.4.2 - 2025-02-07
  * Build.pm: When distcleaning, do not delete files that are needed later in the queue
  * sbohints: With --query, also report scripts that are optional dependencies; more grammatical output
  * Allow non-root users to call sbofind, non-destructive sbocheck, sboconfig and sbohints flags, -h and -v
    * Thanks to Slack Coder for the idea.
  * Install an SBO::Lib(3) summary man page; add exit code information to the other man 3 pages
  * sbocheck: Accept bundled flags (e.g. -gn)
  * sbocheck: Mark scripts that would not be upgraded with sboupgrade with an equals sign

* 3.4.1 - 2025-01-29
  * Bugfix: Use md5sum-specific subdirectories for distfiles to avoid improper overwriting
    * Thanks to tuxuser1 for the report.
  * sboclean: Adjust distfile handling to reflect new directory structure
  * Bugfix: Actually remove the package-\* directory
  * Bugfix: DISTCLEAN should not override NOCLEAN

* 3.4 - 2025-01-22
  * sboconfig: Run without flags or options to use an interactive menu
  * sboupgrade: Do not attempt to upgrade the build queue if the requested script does not need an upgrade
  * sbocheck: Display the installed build number for the build number check
  * Add setting STRICT_UPGRADES: Except for override packages, only upgrade when the version or build number is higher
    * Thanks to jansucan and drbeco for the request.
  * sboinstall: Use --reverse-rebuild to rebuild all reverse dependencies of a script
  + sbofind: Indicate if a script is blacklisted
  * sbohints: A new tool for modifying and querying the blacklist and optional dependency requests
  * sboinstall: Always give a distinct warning prompt when a package without the \_SBo tag would be replaced by adding it to the queue
  * sboinstall: Honor the blacklist when installing from templates
  * Handle circular dependency errors
  * Repo.pm: More accurate warning text in case of BADSIG

* 3.3 - 2024-12-31
  * sboconfig: Allow versions "X.Y+" and "current"; more informative error messages
    * Thanks to dchmelik for the report.
  * Exit with invalid sbotools.conf parameters
  * sbocheck: Before fetch, offer to exit if the git branch does not exist
  * Repo.pm: Check for local repo similarity to SBo rather than relying on SLACKBUILDS.TXT
  * sbosnap: Redundant; replace with a compatibility symlink
  * Wrap variable-length onscreen messaging (that can't be piped), prompts and error messages at 72 characters
  * sboconfig: Use --reset to restore all default configuration values
  * Build.pm: Remove temporary directory in case of signal
  * Bugfix: When parsing info files, fix whitespace, unwanted lines, quotation and backslashes
    * Thanks to Geremias for the original report.
  * Info.pm: Tweak build number detection for an sbocheck performance boost

* 3.2.1 - 2024-12-20
  * Bugfix: sboinstall, sboupgrade GPG check for custom repositories (removed unneeded conditional)

* 3.2 - 2024-12-19
  * sbocheck: Do not use compact format for CLASSIC mode
  * Repo.pm: Prompt for regeneration if SLACKBUILDS.TXT is missing instead of erroring out
  * Set GPG_VERIFY to TRUE to verify with gpg in case of repo fetch, sboinstall or sboupgrade
    * Thanks to Slack Coder for the idea.
  * Bugfix: do not crash if sbotools.conf provides an improper value of SLACKWARE_VERSION
    * Thanks to dchmelik for the report.
  * Repo.pm: Offer to retry failed git fetch
  * Bugfix: sbocheck reports version differences between LOCAL_OVERRIDES and the repository
  * Util.pm: Read the hints file only once; allow multiple optional dependency specs for the same script
  * Lint the value of SBO_HOME before running anything other than sboconfig
    * Thanks to dchmelik for the report.
  * Repo.pm: Remove antiquated subroutine migrate_repo()
  * Install development man pages on SBO::Lib to man 3
    * Thanks to Charadon for the request.

* 3.1 - 2024-12-05
  * sbofind: Allow multiple search terms
  * Add a summary sbotools(1) man page with executive summaries and a startup guide
  * sboinstall: Use --mass-rebuild to rebuild all non-compat32 SlackBuilds
    * Thanks to Charadon for the request.
  * sboconfig: Fix incorrect misconfiguration warnings
  * sbocheck: More compact output.
    * Thanks to dchmelik for the feedback.
  * sbotools.hints: User-specified blacklist and optional dependency requests
  * Bugfix: Prevent undefined build number checks with a local override directory
  * Bugfix: Add a missing `git pull` for custom git branches
  * sboinstall: Use a resume file for --mass-rebuild
  * Clarify LOCAL_OVERRIDES documentation
  * Detect and handle next version (currently 15.1) more effectively
    * Thanks to Slack Coder for the feedback.
  * Adopt MIT License
    * Thanks to Slack Coder for the suggestion.

* 3.0 - 2024-11-22
  * sbocheck: Use --nopull to check for updated SlackBuilds without updating the tree
  * sboremove: Remove undocumented and dangerous nointeractive option
  * sbofind: Use --reverse to check for installed reverse dependencies
    * This feature was originally planned by Andreas Guldstrand.
  * Add setting CLASSIC; turn on BUILD_IGNORE and RSYNC_DEFAULT, and disable output added post-sbotools
  * Fix some --help verbiage

## Note
This repository was renamed from sbotools3 to sbotools prior to the release of sbotools-3.0.

* sbotools3 1.1 - 2024-11-03
  * Bugfix: incorrect variable name caused sboupgrade to rebuild when unneeded.

* sbotools3 1.0 - 2024-11-01
  * Change the git branch to match the Slackware version, or to a user-configured branch
    * The ability to specify a git branch was originally planned by Andreas Guldstrand.
  * Change the default URLs to support Slackware 15.0 and use git repositories
  * Use rsync default mirrors with RSYNC_DEFAULT (except for -current)
    * Thanks to Slack Coder for the feedback.
  * Detect build number changes and optionally upgrade
    * Thanks to qunying for the request.
  * Detect and report out-of-tree \_SBo SlackBuilds with sbocheck
    * This feature was originally planned by Andreas Guldstrand.
  * Save any build options when running a SlackBuild
  * Install bash completions; zsh completions have been updated
  * Install a default configuration file; tweak sboconfig to play somewhat nicely with it
    * Thanks to dcjud for the request.
  * Fix making -compat32 packages for non-i486 SlackBuilds
  * Fix building -compat32 packages from templates

## Historical Changes
Development from version 0.1 through 2.7 took place at [pink-mist/sbotools](https://github.com/pink-mist/sbotools/). Unless indicated otherwise, the changes below are thanks to Andreas Guldstrand.

* Post-2.7 - 2019
  * Add and install zsh completions
    * Thanks to contributor drgibbon.

* 2.7 - 2019-04-28
  * Actually fix the sbofind -e bug #71
      
* 2.6 - 2019-04-27
  * Compatibility with new perl versions where you need to escape { in regexp
    #75 #77 #78
    * Thanks to contributor pedrormjunior.
  * Add a --tries 5 option when downloading from sbosrcarch, which is a
    saner limit than the default of 20. #79
    * Thanks to contributor 9m9.
  * Change sboclean options --clean-dist and --clean-work to shorter forms #52
    * Thanks to contributor sighook
  * Add limited -current support using ponce's SBo repo for -current #73
    * Thanks to penduin for the report
  * Fix bug with sboinstall --reinstall -r #72
    * Thanks to montagdude for the report
  * Fix bug with sbofind -e #71
    * Thanks to drgibbon for the report

* 2.5 - 2018-02-14
  * Document download behaviour #66
    * Thanks to jonasdemoor for the request
  * Remake sbosnap and sboremove to have OO semantics
  * Strip -compat32 from slackbuild names when looking them up #65
    * Thanks to na3i09 for the report
  * Optimise searching in sbofind

* 2.4 - 2017-05-18
  * Rewrite sboremove from the ground up so it relies less on global state
  * Fix for parsing README with useradd/groupadd commands which span lines #57
    * Thanks to montagdude for the report
  * Add --reinstall option to sboinstall #58
  * Exit with error when sbosnap fails to sync with a repo #61
    * Thanks to montagdude for the report
  * Add version information to sbofind output #60

* 2.3 - 2017-01-21
  * Bugfix for parsing .info files with \ among the separators #55
    * Thanks to iluvatar1 for the report

* 2.2 - 2017-01-17
  * Bugfix for parsing .info files with trailing whitespace after a value #54

* 2.1 - 2017-01-14
  * Internals:
    - Adding internal documentation
    - Extract code to submodules for easier separation of concerns
  * New features:
    - Support for templates for installing things with specified options #38
      - Thanks to hackedhead for the request
    - Display other README files if the slackbuild comes with them #49
  * Bugfixes
    - sboinstall/sboremove disagreeing about a package being installed #44
    - sbocheck and sboupgrade misinterpreting version strings #45
      - Thanks to STDOUBT for the report
    - parsing .info files without leading space on second line #46
      - Thanks to chrish4cks for the report
    - local git repo gets partially chowned to root #47
      - Thanks to wgreenhouse for the report
    - stop excluding .tar.gz files when rsyncing #53

* 2.0 - 2016-07-02
  * Major new features
    * LOCAL_OVERRIDES setting

      Allows to keep a directory with local slackbuild dirs that will override
      whatever is found in the regular repository. #8 #13 #14 #15 #19 #20
    * SLACKWARE_VERSION setting

      Allows to specify the slackware version to sync from SBo. Previously only
      the version in your /etc/slackware-version was used for this, and if that
      had gotten updated in -current, you'd have needed to wait both for a new
      version of sbotools, as well as SBo to get the new repository online
      before sbotools would work for you again. #19
    * REPO setting

      This will override the SLACKWARE_VERSION setting. It's used to specify an
      absolute URL for the SBo repository you want to sync with. #6 #19 #27
    * Use sbosrcarch source archive if download fails #7 #19 #24
    * sboupgrade --all option to upgrade everything listed by sbocheck. #9 #19
      - Thanks to hackedhead for the request
    * Travis CI integration

      Every push will now cause the test-suite to be run. #18
    * Hundreds of new unit-tests. #18 #19 #23 #24 #25 #27 #28 #31 #32 #33 #35 #41 #43
    * sbofind will now also use tags if they're available #37
      - Thanks to contributor sighook
  * Minor/bugfixes/documentation fixes
    * Use system perl when running and installing sbotools.
    * sbocheck output changed. #10 #13 #20
    * Better debug messages on errors. #16
    * manpage fixes. #17
    * sboupgrade handles dependencies better. #12 #28
    * Update bundled Sort::Versions to 1.62.
    * sboinstall/upgrade/sbocheck: small bugfixes. #21 #35 #41 #43
      - Thanks to contributor tom-crane for the parallel builds fix
      - Thanks to Sammyboy for the kernel version report
    * sbosnap: display download progress, update git trees better. #26 #27
      - Thanks to travis-82 for the request

* 1.9 - 2015-11-27
  * Make it compatible with perls newer than 5.18
  * Lots of code cleanup
  * Rewrite build-queue code. #2
  * Fix issue when TMP is set. #4
  * Fix various bugs related to cleanup code
  * Change location of website
  * Fix downloading of multiple sources in newer slackbuilds. #5

