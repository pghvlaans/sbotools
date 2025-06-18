# sbotest

**sbotest** is a reverse dependency build tester based on the **sbotools** library.

This **sbotools** companion script was written with script maintainers in mind: Easily build and test scripts with their reverse dependencies in a single command. Maintain an archive for built dependencies and keep it up-to-date with **sbotest --archive-rebuild**.

See the [man page](https://pghvlaans.github.io/sbotools/man/sbotest/post-release/sbotest.1.html) for more information about options and settings!

## Trying sbotest

**sbotest** is not quite ready for a version release, which needs to wait for **sbotools-3.7**. In the meantime, please follow these steps if you would like to try **sbotest**:

* Use **[sbotools-git-slackbuild](https://github.com/pghvlaans/sbotools-git-slackbuild/)** to upgrade **sbotools** to version `20250616-0d4e3dd` at the oldest.
* Clone the **sbotest** repository.
* From the root directory, run `./tools/source_to_slackbuild.sh`.
* Run the SlackBuild in `slackbuild/sbotest`.

Issues and requests are welcome; please indicate the most recent commit with the output of:

    git log | head -n 1

## Acknowledgments

**Jacob Pipkin**, **Luke Williams** and **Andreas Guldstrand** are the original authors of **sbotools**.

**B. Watson** is the author and maintainer of **[sbo-maintainer-tools](https://slackware.uk/~urchlay/repos/sbo-maintainer-tools)**.

## Disclaimer

**sbotest** was designed and intended to be run in a build-testing environment, such as a virtual machine or a Docker image. Using **sbotest** on a general-purpose Slackware installation is **unsupported** and **unadvisable**.
