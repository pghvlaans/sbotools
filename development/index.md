# Development

Visit [pghvlaans/sbotools](https://github.com/pghvlaans/sbotools) for Issues, Pull Requests and the latest changes. The man pages from the `master` branch can be found [here](/sbotools/man/post-release/).

The `SBO::Lib::*` modules are documented in `man3`. These pages are not online, but are available in the source archive and upon package installation.

## Following Development

A separate repository called [sbotools-git-slackbuild](https://github.com/pghvlaans/sbotools-git-slackbuild) can be used to download a zip archive of (in principle) the latest commit on the `master` branch and make a Slackware package.

## Prospective Features

Nothing for now, but requests are welcome and will receive due consideration.

## Incoming

The following feature changes will be included in version 3.5:

* `sbofind`: Use **\--exact-case** for case-sensitive exact matching
* Make reverse dependency handling more convenient
  * `sboupgrade`: Add **\--reverse-rebuild**
  * `sbotools.hints`: Request automatic reverse dependency rebuilds on a per-script basis
  * `sbohints`: Use **\--reverse** to add and clear reverse dependency rebuild requests
