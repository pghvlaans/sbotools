# Development

Visit [pghvlaans/sbotools3](https://github.com/pghvlaans/sbotools3) for Issues, Pull Requests and the latest changes. The man pages from the `master` branch can be found [here](/sbotools3/man/post-release/).

## Following Development

A separate repository called [sbotools3-git-slackbuild](https://github.com/pghvlaans/sbotools3-git-slackbuild) can be used to download a zip archive of (in principle) the latest commit on the `master` branch and make a Slackware package.

## Prospective Features

These features may be added in the future:

* Using (and generating?) `sqf` files
* Blacklist scripts
  * I'm having second thoughts about adding a blacklist. Local overrides (and simply using tags other than `_SBo`) are alternatives, and blacklist-honoring build queue creation strikes me as failure-prone. If it goes in, it won't be for version 1.2.

The above list is non-exhaustive and nothing on it is guaranteed to appear in `sbotools3`.

## Done for Version 1.2 (ETA: Late November 2024)

* Run `sbocheck` without updating the tree (use `sbocheck -n`)
* `sbofind` reports installed reverse dependencies (use `sbofind -R`)
* "Classic Mode" setting for a more traditional `sbotools` look and feel
