# sbocheck

[NAME](#name)\
[SYNOPSIS](#synopsis)\
[DESCRIPTION](#description)\
[OPTIONS](#options)\
[EXIT CODES](#exit-codes)\
[BUGS](#bugs)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[MAINTAINER](#maintainer)

------------------------------------------------------------------------

## NAME

**sbocheck** - perform **SlackBuilds.org** tree updates and package
checks

## SYNOPSIS

    sbocheck [-h|-v]

    sbocheck [-COXgn] [-t all,perl,python,ruby,solibs]

    sbocheck [-c] package [package]

    sbocheck [--color|--nocolor] [--wrap|--nowrap] \...

## DESCRIPTION

**sbocheck** updates or fetches a copy of the **SlackBuilds.org** tree,
checks for available upgrades and reports what it finds. If
**OBSOLETE_CHECK** is **TRUE**, updated copies of the script list at
**/etc/sbotools/obsolete** and the perl version history file at
**/etc/sbotools/perl_vers** are downloaded from
<https://pghvlaans.github.io/sbotools> if running Slackware -current
(see [sboconfig(1)](sboconfig.1.md) or [sbotools.conf(5)](sbotools.conf.5.md)).

SlackBuilds with differing build numbers are reported separately, as are
any SlackBuilds marked *\_SBo* that are not found in the repository or
local overrides (see [sboconfig(1)](sboconfig.1.md) or [sbotools.conf(5)](sbotools.conf.5.md)). Except
in **CLASSIC** mode, scripts in the report that would not be upgraded by
[sboupgrade(1)](sboupgrade.1.md) are marked with **=** (equals sign).

The three output categories are logged separately to
*/var/log/sbocheck.log*, */var/log/sbocheck-bumps.log* and
*/var/log/sbocheck-out-of-tree.log*. The out-of-tree and build number
increment checks are disabled when **CLASSIC** is **TRUE**; if
**STRICT_UPGRADES** is **TRUE**, apparent downgrades are reported with
"differs", but are not acted on by [sboupgrade(1)](sboupgrade.1.md) (see
[sboconfig(1)](sboconfig.1.md) or [sbotools.conf(5)](sbotools.conf.5.md)).

Upgrades to Slackware and third-party packages occasionally cause
breakage due to **\*.so** version differences. To check for missing
first-order shared object (solib) dependencies among all installed
in-tree *\_SBo* packages, use the **\--so-check** option. Each affected
package is logged to */var/log/sbocheck-solibs.log* if running as root,
or */tmp/sbocheck-solibs.log* otherwise. This log contains a list of
missing shared objects and the files that have first-order dependencies
on them. This can be done automatically on every **sbocheck** run by
setting **SO_CHECK** to **TRUE**. Please note that scripts repackaging
from binary packages occasionally trigger false positives. Such packages
generally do not require rebuilds.

Use **\--type** with any package-checking option to specify package
tests to run in a comma-separated list. The supported values are
currently **solibs** (default for no specification), **perl**,
**python**, **ruby** and **all**.

To check for updated SlackBuilds without updating the SlackBuilds tree,
pass the **\--nopull** option. **sbocheck** performs **gpg(1)**
verification upon pulling the tree if **GPG_VERIFY** is **TRUE** (see
[sboconfig(1)](sboconfig.1.md) or [sbotools.conf(5)](sbotools.conf.5.md)). The **\--gpg-verify** option
has the same effect. Passing both **\--gpg-verify** and **\--nopull**
verifies the repo in-place without fetching.

Please note that **sbosnap**, which was removed as an independent script
in **sbotools-3.3**, is a compatibility symlink to **sbocheck**.

Non-root users can only call **sbocheck** with the **\--nopull**,
**\--so-check**, **\--check-package**, **\--check-all-packages**,
**\--type**, **\--help** and **\--version** flags. **sbocheck** issues a
warning if the directory specified with **LOCAL_OVERRIDES** does not
exist (see [sboconfig(1)](sboconfig.1.md) or [sbotools.conf(5)](sbotools.conf.5.md)). If an invalid
configuration is detected in */etc/sbotools/sbotools.conf*, the script
exits with a diagnostic message.

## OPTIONS

**-C\|\--check-all-packages**

Check every package on the system, *\_SBo* or otherwise, for missing
shared objects. This option is usable even when there is no local copy
of the repository. Incompatible with **\--so-check** and
**\--check-package**. **solibs** are checked by default; use **\--type**
to specify other tests.

**-c\|\--check-package**

Check one or more package names for missing shared objects; the packages
need not be tagged with *\_SBo*. This option is usable even when there
is no local copy of the repository. Incompatible with **\--so-check**
and **\--check-all-packages**. **solibs** are checked by default; use
**\--type** to specify other tests.

**-g\|\--gpg-verify**

Use **gpg(1)** to verify the fetched repository, even if **GPG_VERIFY**
is **FALSE**. When called with **\--nopull**, verify the repo without
fetching.

**-O\|\--obsolete-check**

If running Slackware -current, download a copy of the obsolete script
list and the perl version history file from
<https://pghvlaans.github.io/sbotools> and verify with gpg(1) if
**GPG_VERIFY** is **TRUE** or **\--gpg-verify** is passed. Incompatible
with **\--nopull**.

**-n\|\--nopull**

Check for updated SlackBuilds without updating the SlackBuilds tree. The
**\--nopull** flag can be used without root privileges, but no log is
kept.

**-t\|\--type**

In combination with **\--so-check**, **\--check-all-packages** or
**\--pkg-check**, run the specified package checks in a comma-separated
list. Supported checks include:

**solibs** - The default option; using a package checking option without
**\--type** runs this test.

**perl** - Check for incompatible perl-based shared objects and binaries
based on timestamps. In addition to the currently-installed system
**perl** package, the first build dates for major **perl** versions on
Slackware (see */etc/sbotools/perl_vers*) and installation dates for
previously-installed **perl** packages are used to avoid false positives
for stock and built packages, respectively. Results are saved to
*sbocheck-perl.log*.

**python** - Check for *site-packages* irectories built against the
wrong major version, e.g. **python-3.12**. Results are saved to
*sbocheck-python.log*.

**ruby** - Check for gems built against the wrong major version, e.g.
**ruby-3.4**. Results are saved to *sbocheck-ruby.log*.

**all** - run all supported package checks.

Using **\--type** without another package checking option checks all
installed **\_SBo** packages.

**-X\|\--so-check**

Run package checks on all installed *\_SBo* packages; no other
operations are performed. **solibs** are checked by default; use
**\--type** to specify other tests. To do this automatically every time
**sbocheck** is run, set **SO_CHECK** to **TRUE** (see [sboconfig(1)](sboconfig.1.md)
or [sbotools.conf(5)](sbotools.conf.5.md)). Incompatible with **\--check-package** and
**\--check-all-packages**.

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

**\--color**

Turn on **sbotools** color output. See also [sbotools.colors(5)](sbotools.colors.5.md).

**\--nocolor**

Turn off **sbotools** color output.

**\--wrap**

Turn on **sbotools** word wrapping (default).

**\--nowrap**

Turn off **sbotools** word wrapping.

## EXIT CODES

**sbocheck** can exit with the following codes:

0: all operations were successful.\
1: a usage error occurred.\
2: a script or module error occurred.\
5: failed to download the tree.\
6: failed to open a required file handle.\
12: interrupt signal received.\
15: GPG verification failed.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools/> are always welcome.

## SEE ALSO

[sboclean(1)](sboclean.1.md), [sboconfig(1)](sboconfig.1.md), [sbofind(1)](sbofind.1.md), [sbohints(1)](sbohints.1.md), [sboinstall(1)](sboinstall.1.md),
[sboremove(1)](sboremove.1.md), [sbotool(1)](sbotool.1.md), [sboupgrade(1)](sboupgrade.1.md), [sbotools.colors(5)](sbotools.colors.5.md),
[sbotools.conf(5)](sbotools.conf.5.md), [sbotools.hints(5)](sbotools.hints.5.md), gpg(1)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
