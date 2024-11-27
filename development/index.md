# Development

Visit [pghvlaans/sbotools](https://github.com/pghvlaans/sbotools) for Issues, Pull Requests and the latest changes. The man pages from the `master` branch can be found [here](/sbotools/man/post-release/).

## Following Development

A separate repository called [sbotools-git-slackbuild](https://github.com/pghvlaans/sbotools-git-slackbuild) can be used to download a zip archive of (in principle) the latest commit on the `master` branch and make a Slackware package.

## Prospective Features

These features may be added in the future:

* Hints for optional dependencies
* Using (and generating?) `sqf` files
* Blacklist scripts

The above list is non-exhaustive and nothing on it is guaranteed to appear in `sbotools`.

## Refinement Needed

* Mass rebuild with `sboinstall`; use `sboinstall --mass-rebuild` or `sboinstall -r --mass-rebuild`
  * Needs blacklist and resume capabilities for non-interactive use

## Completed for 3.1

* Use multiple search terms in `sbofind`
