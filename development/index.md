# Development

Visit [pghvlaans/sbotools](https://github.com/pghvlaans/sbotools) for Issues, Pull Requests and the latest changes. The man pages from the `master` branch can be found [here](/sbotools/man/post-release/).

The `SBO::Lib::*` modules are documented in `man3`. These pages are not online, but are available in the source archive and upon package installation.

## Following Development

A separate repository called [sbotools-git-slackbuild](https://github.com/pghvlaans/sbotools-git-slackbuild) can be used to download a zip archive of (in principle) the latest commit on the `master` branch and make a Slackware package.

## Prospective Features

* `sbofind`: Add a flag for listing all reverse dependencies
* `sbohints`: Allow for pre-build commands

Nothing else for now, but requests are welcome and will receive due consideration.

## Ready for the Next Version

* `sboinstall`, `sboupgrade`: Add a summary with successful builds and time taken at the end
* `sboinstall`, `sboupgrade`: Don't warn the user about 'missing' scripts that are installed
* Add `/etc/sbotools/obsolete`: For -current users. A list of scripts that have been added to Slackware under different names, or are unnecessary build dependencies in -current. `sbocheck -O` or plain `sbocheck` with `OBSOLETE_CHECK` will download an updated copy from this website. GPG verification if `GPG_VERIFY`.
