# Downloads

The 1.0 release is coming very soon, and will be available from this page.

In the meantime, a separate repository called [sbotools3-git-slackbuild](https://github.com/pghvlaans/sbotools3-git-slackbuild) can be used to download a zip archive of (in principle) the latest commit on the `master` branch and make a Slackware package.

`sbotools3` conflicts with `sbotools`. Uninstalling `sbotools` before installing `sbotools3` is recommended.

`sbotools3` installs a default configuration file to `/etc/sbotools/sbotools.conf`. Although an existing `sbotools.conf` will be compatible, some of the options are new. `sbotools` users may want to inspect `sbotools.conf.new` after building and installing `sbotools3` for the first time.
