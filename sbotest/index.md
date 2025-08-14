# sbotest

**sbotest** is a reverse dependency build tester based on the **sbotools** library.

This **sbotools** companion script is written with script maintainers in mind: Easily build and test scripts with their reverse dependencies in a single command. Maintain an archive for built dependencies and keep it up-to-date with **sbotest \--archive-rebuild**.

**sbotest** is configured separately from **sbotools**. See the contents of `/etc/sbotest`, or run **sbotest config** and **sbotest hints** to set options from the command line.

The [ChangeLog](ChangeLog.md) has a record of changes since the initial release. See the [man page](https://pghvlaans.github.io/sbotools/man/sbotest/release/sbotest.1.html) for more information about options and settings!

## Getting sbotest

A SlackBuild for **sbotest** is [available](https://slackbuilds.org/repository/15.0/system/sbotest/) on **SlackBuilds.org**. **sbotest** requires **sbotools-3.7** or above and **sbo-maintainer-tools**.

**sbotest** and **sbotools** source archives can be found at [Downloads](https://pghvlaans.github.io/sbotools/downloads/).

To use a development version:
* Use **[sbotools-git-slackbuild](https://github.com/pghvlaans/sbotools-git-slackbuild/)** to upgrade **sbotools** to version `20250812-f11d5af` at the oldest.
* Clone the **sbotest** repository.
* Run `./tools/source_to_slackbuild.sh` from the root of the local repository.
* Run the SlackBuild in `slackbuild/sbotest`.

Issues and requests are welcome; if running post-release **sbotest**, please indicate the most recent commit with the output of:

    git log | head -n 1

Post-release man pages can be found [here](https://pghvlaans.github.io/sbotools/man/sbotest/post-release/sbotest.1.html).

## Acknowledgments

**Jacob Pipkin**, **Luke Williams** and **Andreas Guldstrand** are the original authors of **sbotools**.

**B. Watson** is the author and maintainer of **[sbo-maintainer-tools](https://slackware.uk/~urchlay/repos/sbo-maintainer-tools)**.

## Disclaimer

**sbotest** was designed and intended to be run in a build-testing environment, such as a virtual machine or a Docker image. Using **sbotest** on a general-purpose Slackware installation is **unsupported** and **unadvisable**.
