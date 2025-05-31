# Development

Visit [pghvlaans/sbotools](https://github.com/pghvlaans/sbotools) for Issues, Pull Requests and the latest changes. The man pages from the `master` branch can be found [here](/sbotools/man/post-release/).

The `SBO::Lib::*` modules are documented in `man3`. These pages are not online, but are available in the source archive and upon package installation.

## Following Development

A separate repository called [sbotools-git-slackbuild](https://github.com/pghvlaans/sbotools-git-slackbuild) can be used to download a zip archive of (in principle) the latest commit on the `master` branch and make a Slackware package.

## Prospective Features

* `sboinstall`: Rebuild all installed scripts in a series

Nothing else for now, but requests are welcome and will receive due consideration.

## Incoming

* A setting **ETC_PROFILE** to source profile.d scripts before building
* A setting **LOG_DIR** to save build logs in
* Add a reverse dependency build tester for script maintainers (the sbotest companion package)
