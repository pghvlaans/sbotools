# Development

Visit [pghvlaans/sbotools](https://github.com/pghvlaans/sbotools) for Issues, Pull Requests and the latest changes. The man pages from the `master` branch can be found [here](/sbotools/man/post-release/).

The `SBO::Lib::*` modules are documented in `man3`. These pages are not online, but are available in the source archive and upon package installation.

## Following Development

A separate repository called [sbotools-git-slackbuild](https://github.com/pghvlaans/sbotools-git-slackbuild) can be used to download a zip archive of (in principle) the latest commit on the `master` branch and make a Slackware package.

## Prospective Features

These features may be added in the future:

* New tool for working with `sbotools.hints`

Nothing on the above list is guaranteed to appear in `sbotools`.

## Arriving in Version 3.4

* Interactive mode for `sboconfig` (use without flags or options to access)
* Optionally, only upgrade on version and build increment (not difference)
* Rebuild a reverse dependency queue (use `sboinstall --reverse-rebuild`)
