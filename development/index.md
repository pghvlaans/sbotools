# Development

Visit [pghvlaans/sbotools](https://github.com/pghvlaans/sbotools) for Issues, Pull Requests and the latest changes. The man pages from the `master` branch can be found [here](/sbotools/man/post-release/).

The `SBO::Lib::*` modules are documented in `man3`. These pages are not online, but are available in the source archive and upon package installation.

## Following Development

A separate repository called [sbotools-git-slackbuild](https://github.com/pghvlaans/sbotools-git-slackbuild) can be used to download a zip archive of (in principle) the latest commit on the `master` branch and make a Slackware package.

## Prospective Features

These features may be added in the future:

* Rebuild a reverse dependency queue
* Detect an existing local repository more correctly
* More extensive pre-run configuration linting (currently, this is only done for `SBO_HOME`)

The above list is non-exhaustive and nothing on it is guaranteed to appear in `sbotools`.
