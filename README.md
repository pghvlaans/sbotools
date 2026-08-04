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
  * sboupgrade: Accept -A for --all-plus-failures.
  * Util.pm: Reset the color at the end of colored lines, not afterwards.
  * sbocheck: Do not attempt /opt labeling with --lib-search.
  * sbocheck: List /opt-only packages failing the solib test separately.
  * sboinstall, sboupgrade: Build queue label prints in color.
  * Build.pm: By default, continue the queue after build failure, skipping SlackBuilds with failed dependencies.
    * Thanks to dchmelik for the suggestion.
  * Added an INSTANT_STOP setting, which offers to stop the queue as soon as one build fails.
    * If continuing, builds with failed dependencies are skipped.
    * If non-interactive, stop immediately.
  * sboinstall, sboupgrade: Use --instant-stop to override the INSTANT_STOP setting.
  * Build.pm: Use JSON::PP to write the mass rebuild resume queue.
  * sboremove: Fix extra newline.
  * sboupgrade: --all-plus-failures adds packages with missing solibs only in /opt to the queue if running interactively.
  * Notify about CPAN installations regardless of CPAN_IGNORE; remove CPAN_IGNORE from the recommended settings list.
  * Added a NICENESS setting; set an absolute niceness value for the build and package installation phase, or FALSE for whatever value the script started with.
    * Thanks to shamefulCake1 for the request.

#### 4.3 - 2026-07-31
  * {Build,Download}.pm: Properly handle failed downloads when continuing.
    * Thanks to fsLeg for the report.
  * Change the default SBO_HOME to /var/lib/sbotools.
    * Thanks to fourtysixandtwo for raising the issue.
  * sbocheck: Unless in CLASSIC mode, report any SlackBuilds orphaned upstream; skip with --no-orphans.
    * Thanks to J. Milgram for the proposal.
  * sbofind, sbotool: Show a removal warning when orphaned builds are displayed.
  * Util.pm: Allow SBO_HOME/distfiles to be a symlink to an existing directory.
  * sboclean: Verify a proper SBO_HOME before trying to clean distfiles.
  * Use color output by default; replace the COLOR setting with NOCOLOR.
  * Util.pm: Account for symlinks when detecting dangerous directory settings.
  * Solibs.pm, sbocheck, sboupgrade: Packages with missing solibs only in /opt are marked; improved disclaimer.
  * sboupgrade: --all-plus-failures skips packages with missing solibs only in /opt.
  * Run the solib tests after sbocheck and sboupgrade by default.
    * Replace the SO_CHECK setting with NO_SOCHECK.
    * sboupgrade: Replace --so-check with --no-socheck.
    * sbocheck: Use --no-socheck to skip the default check.
  * Util.pm: Use a relative symlink for SBO_HOME/manual_downloads.

#### 4.2.1 - 2026-07-23
  * sbofind: Show maintainer names unless in CLASSIC mode; search names with --maintainers.
  * sbotool: Show maintainer names in the per-script Operations screens.
  * Download.pm: Ignore content_disposition settings in wgetrc.
    * Thanks to worriedeland for the heads-up.
  * Added a setting FORCE_OBSOLETE to treat the obsolete scripts list as a supplementary blacklist on -current.
    * Do not use unless your repository does not remove outdated scripts.
    * Thanks to gbschenkel for raising this issue.
  * sboremove: Offer to remove installed dependencies of uninstalled packages.
  * SBO::Lib: AArch64 compatibility fixes.
    * Shared object checks
    * Handling for scripts supporting only 64- or 32-bit architecture
  * sbocheck: Search for files and packages depending on one or more libraries with --lib-search
  * Info.pm: Account for leading spaces in info files
  * Info.pm: Deal with potential pattern match warning in x64 and x32 checks
    * Thanks to leoctrl for the report.

## Previous Changes
See [ChangeLog.md](https://github.com/pghvlaans/sbotools/blob/master/SBO-Lib/ChangeLog.md) for a record of changes from version 1.9 onward.
