# Development

Visit [pghvlaans/sbotools](https://github.com/pghvlaans/sbotools) for Issues, Pull Requests and the latest changes. The man pages from the `master` branch can be found [here](/sbotools/man/post-release/).

The `SBO::Lib::*` modules are documented in `man3`. These pages are not online, but are available in the source archive and upon package installation.

## Following Development

A separate repository called [sbotools-git-slackbuild](https://github.com/pghvlaans/sbotools-git-slackbuild) can be used to download a zip archive of (in principle) the latest commit on the `master` branch and make a Slackware package.

## Prospective Features

* Allow `sboinstall --mass-rebuild` to handle *compat32* packages (post-3.5)

Nothing else for now, but requests are welcome and will receive due consideration.

## Incoming

The following feature changes will be included in version 3.5:

* `sbofind`: Use **\--exact-case** for case-sensitive exact matching
* Make reverse dependency handling more convenient
  * `sboupgrade`: Add **\--reverse-rebuild**
  * `sbotools.hints`: Request automatic reverse dependency rebuilds on a per-script basis
  * `sbohints`: Use **\--reverse** to add and clear reverse dependency rebuild requests
  * `sboinstall`: Honor automatic reverse dependency rebuild requests
  * `sboinstall`: Allow **\--reverse-rebuild** with **\--compat32**
* `sboupgrade`, `sboinstall`: Favor saved build options
  * With `--nointeractive`, automatically reuse saved options unless `--norecall` is passed or when building from a template
  * The default answer for the prompt to reuse saved options is now "yes"
* Improved CPAN handling
  * A new **CPAN_IGNORE** setting to skip the CPAN check altogether
  * `sbofind`: Report on installed CPAN modules, in whole or in part
  * `sboinstall`, `sboupgrade`: More informative CPAN-related output and more accurate installation blocking
* Add **\--compat32** back to `sboupgrade`
* Allow `sboupgrade --all` to handle *compat32* packages
