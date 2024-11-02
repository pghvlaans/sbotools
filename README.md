# sbotools3

**sbotools3** is the continuation of **sbotools**. It is a set of Perl scripts providing a ports-like automation interface to [slackbuilds.org](https://slackbuilds.org). Features include dependency handling, using a custom git branch, generating 32-bit and compat32 builds on multilib systems, and more.

A debt of gratitude is owed to the original author, Jacob Pipkin, longtime maintainer Andreas Guldstrand and major contributor Luke Williams. This software would not exist without their efforts.

**sbotools3** is [available](https://slackbuilds.org/repository/15.0/system/sbotools3/) on slackbuilds.org for Slackware 15.0.

For online man pages and executive summaries of all commands, see [man](/man/). Installation notes and the 1.0 release tarball are available at [Downloads](/downloads/). A record of changes to **sbotools3** and **sbotools** back to version 1.9 can be found in [ChangeLog](/ChangeLog.html). [Development](/development/) has links to **sbotools3**-related repositories and information about future plans.

## Why a Continuation?

**sbotools** has gone without commits for a number of years. During this time, the default URL for release Slackware beyond 14.2 became unusable, and building compat32 and 32-bit packages on multilib systems stopped working for nearly all SBo SlackBuilds. Both of these issues have been fixed in **sbotools3**.

Nonetheless, this repository was originally a simple fork adding a feature: Saving previously-used build options to be shown to the user when installing a SlackBuild again. In that spirit, the main focus of **sbotools3** has been to implement new functionality, some of which was originally planned by Andreas Guldstrand.

* Use a customizable git branch to clone the local repository
* New git-based default URLs, with the option to use default rsync URLs instead
* Optionally upgrade on build increments and report out-of-tree SlackBuilds
* Save build options and offer to re-use them
* Install bash completions to go with the existing zsh completions
