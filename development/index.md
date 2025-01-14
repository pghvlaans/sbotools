# Development

Visit [pghvlaans/sbotools](https://github.com/pghvlaans/sbotools) for Issues, Pull Requests and the latest changes. The man pages from the `master` branch can be found [here](/sbotools/man/post-release/).

The `SBO::Lib::*` modules are documented in `man3`. These pages are not online, but are available in the source archive and upon package installation.

## Version 3.4, Release Candidate

A release candidate for version 3.4 is now available in [Downloads](/sbotools/downloads/).

## Following Development

A separate repository called [sbotools-git-slackbuild](https://github.com/pghvlaans/sbotools-git-slackbuild) can be used to download a zip archive of (in principle) the latest commit on the `master` branch and make a Slackware package.

## Prospective Features

Nothing for now, but requests are welcome and will receive due consideration.

## Arriving in Version 3.4

* Interactive mode for `sboconfig` (use without flags or options to access)
* Optionally, only upgrade on version and build increment (not difference)
* Rebuild a reverse dependency queue (use `sboinstall --reverse-rebuild`)
* `sbohints`, a new tool for working with `sbotools.hints`
