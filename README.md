# sbotools

**sbotools** is a set of Perl scripts providing a ports-like automation interface to [SlackBuilds.org](https://slackbuilds.org). Features include dependency handling, using a custom git branch, generating 32-bit and compat32 builds on multilib systems, reverse dependency search and rebuild, gpg verification and more.

[This repository](https://github.com/pghvlaans/sbotools/) is for continuing **sbotools** development, and was forked from the [pink-mist repository](https://github.com/pghvlaans/pink-mist/sbotools/), which covered development from version 1.9 through version 2.7.

A debt of gratitude is owed to the original author, Jacob Pipkin, longtime maintainer Andreas Guldstrand and major contributor Luke Williams. This software would not exist without their efforts.

For online man pages and executive summaries of all commands, see [man](/sbotools/man/). Installation notes and release tarballs are available at [Downloads](/sbotools/downloads/). A record of changes to **sbotools-3.x** and **sbotools** back to version 1.9 can be found in [ChangeLog](/sbotools/ChangeLog/). [Development](/sbotools/development/) has links to **sbotools**-related repositories and information about future plans.

A SlackBuild for **sbotools** is [available](https://slackbuilds.org/repository/15.0/system/sbotools/) on SlackBuilds.org.

To verify commits (excluding resolved PR, which are verified with GitHub's key), use [GPG_KEY](/sbotools/downloads/GPG_KEY). Key updated 2024-12-15.

## Why a Fork?

The previous **sbotools** repository had gone without commits for a number of years. During this time, the default URL for release Slackware beyond 14.2 became unusable, and building compat32 and 32-bit packages on multilib systems stopped working for nearly all SBo SlackBuilds. Both of these issues have been fixed in **sbotools-3.x**.

Nonetheless, this repository was originally a simple fork adding a feature: Saving previously-used build options to be shown to the user when installing a SlackBuild again. In that spirit, the main focus of this fork of **sbotools** has been to implement new functionality, some of which was originally planned by Andreas Guldstrand.

## What's New, Compared to Version 2.7?
**sbotools-3.x** is Slackware 15.0-compatible. While [ChangeLog](/sbotools/ChangeLog/) has a more complete list of changes, here are some of the highlights:

* Blacklist and request optional dependencies with `sbotools.hints` and/or `sbohints`
* Use a customizable git branch to clone the local repository
* New git-based default URLs, with the option to use default rsync URLs instead
* Optionally upgrade on build increments and report out-of-tree SlackBuilds
* Save build options and offer to re-use them
* Search and rebuild installed reverse dependencies
* Optionally use GPG to verify git commits and rsync clones

Those who prefer a more traditional **sbotools** experience can use the **CLASSIC** metasetting to disable most new on-screen messaging and lock other settings to version 2.7 behavior. [sbotools2](https://git.server.ky/slackcoder/sbotools2/about/), a Slackware 15.0-compatible **sbotools-2.7** maintenance fork by Slack Coder, may also be of interest.
