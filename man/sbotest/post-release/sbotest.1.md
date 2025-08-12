# sbotest

[NAME](#name)\
[SYNOPSIS](#synopsis)\
[DISCLAIMER](#disclaimer)\
[DESCRIPTION](#description)\
[OPTIONS](#options)\
[TESTING STRATEGIES](#testing-strategies)\
[CONFIGURATION](#configuration)\
[EXIT CODES](#exit-codes)\
[BUGS](#bugs)\
[SEE ALSO](#see-also)\
[ACKNOWLEDGMENTS](#acknowledgments)\
[AUTHOR](#author)

------------------------------------------------------------------------

## NAME

**sbotest** - build test SlackBuilds and their reverse dependencies

## SYNOPSIS

    sbotest [-h|-v]

    sbotest pull [-B BRANCH|FALSE] [-r URL|FALSE]

    sbotest [config|find|hints] \...

    sbotest [-f|-s] [-Akl /path|FALSE] [-j #|FALSE] \
            [-X TRUE|FALSE] [-D] [--no-archive|--archive-force] \
            sbo_name (sbo_name)

    sbotest [-Al /path|FALSE] [-SX TRUE|FALSE] [-j #|FALSE] \
            [-D] --archive-rebuild

    sbotest [-Al /path|FALSE] [-SX TRUE|FALSE] [-j #|FALSE] \
            [-D] --archive-reverse

## DISCLAIMER

**sbotest** is designed and intended to run in a clean build-testing
environment, such as a virtual machine or a **Docker** image. Missing
users and groups are added automatically when running **sbotest**, and
any packages installed as a result of testing are removed afterwards
unless they had been previously installed.

Using **sbotest** on a general-purpose Slackware installation is
**unsupported** and **unadvisable**.

## DESCRIPTION

**sbotest** is a reverse dependency build tester based on the
**sbotools** library. To fetch or update the repository before testing,
call **sbotest pull**. Select a git branch and repository URL by editing
*/etc/sbotest/sbotest.conf* or, temporarily, by passing
**\--git-branch** and **\--repo**. **sbotest** is also configurable at
the command line with **config**, and per-script hints can be applied
with **hints**. See [sboconfig(1)](sboconfig.1.md) and [sbohints(1)](sbohints.1.md) for more
details.

Called without options, **sbotest** builds any requested SlackBuilds
with their first level of reverse dependencies. Use **sbotest find
\--first-reverse** or pass **\--dry-run** for a list of scripts that
would be tested, if compatible. To test all reverse dependencies of the
requested scripts, use the **\--full-reverse** option; **\--single**
tests no reverse dependencies. Please note that already-installed
scripts can be tested only with **\--single**; the existing package on
the system is not replaced.

Each test target has a separate testing workflow. First, dependencies
saved to the **SBO_ARCHIVE** directory (default */usr/sbotest/archive*)
are installed to save time; see **CONFIGURATION** below for details. Any
missing users and groups are added, and [sboinstall(1)](sboinstall.1.md) is called.

Newly-built packages are saved to a timestamp-appended **PKG_DIR**. By
default, any dependencies (not test targets) built are saved to
**SBO_ARCHIVE** for future use; to change this, see **\--no-archive**
and **\--archive-force** below. Any packages that are not required for
the following build are removed afterwards. Packages without the *\_SBo*
tag are unaffected, and no package that is already installed when
**sbotest** starts can be removed or reinstalled.

Packages in the archive with missed rebuilds may lack required shared
object dependencies, which can in turn cause builds to fail. To check
all installed *\_SBo* packages for missing dependencies upon build test
failure, set **SO_CHECK** to **TRUE** or pass **\--so-check TRUE** to
**sbotest**.

**sbopkglint(1)** is run on all test targets once [sboinstall(1)](sboinstall.1.md) has
been called for the last time. A summary of results is displayed and
saved to *SBO_HOME/results/(timestamp).log*. Scripts that fail
**sbolint(1)** or **sbopkglint(1)**, or fail to build altogether, are
reported so that any issues can be taken care of before submitting
scripts to **SlackBuilds.org**.

To generate a report of potential operations, use **\--dry-run** with
any combination of other options.

Non-root users can run sbotest with **\--help**, **\--version** and
**\--dry-run. hints**, **config** and **find** can be run by anyone with
listing-related options.

## OPTIONS

**config**

Interface with [sboconfig(1)](sboconfig.1.md) to modify settings. All **sboconfig**
options can be used, with the addition of **\--sbo-archive**. See
**CONFIGURATION** below.

**find**

Interface with [sbofind(1)](sbofind.1.md) to search the local copy of the repository
for SlackBuilds. Scripts with up-to-date packages in the archive are
indicated. All **sbofind** options can be used.

**hints**

Interface with [sbohints(1)](sbohints.1.md) to modify per-script hints. All
**sbohints** options can be used.

**pull**

Fetch the upstream repository to *SBO_HOME/repo*. Flags other than
**\--git-branch** and **\--repo** have no effect.

**\--archive-rebuild**

Replace build- and version-mismatched packages in the archive,
*/usr/sbotest/archive* by default. Please note that installed and
blacklisted packages are ignored. If **STRICT_UPGRADES** is **TRUE**,
only mismatched packages with lower version or build numbers are removed
from the archive.

If a script to be rebuilt has an automatic reverse dependency rebuild
request in */etc/sbotest/sbotest.hints*, its reverse dependencies are
rebuilt and replaced as well. See [sbotools.hints(5)](sbotools.hints.5.md) for details
about setting hints.

Incompatible with **\--no-archive** and **\--archive-force**.

**\--archive-reverse**

Perform an archive rebuild as with **\--archive-rebuild**, but rebuild
all reverse dependencies as well.

Incompatible with **\--no-archive** and **\--archive-force**.

**-A\|\--sbo-archive**

If **FALSE**, use the default archive directory at *SBO_HOME/archive*.
If an **absolute path**, use that as the archive directory.

**\--archive-force**

When testing the requested scripts, copy all built packages into
**SBO_ARCHIVE**, */usr/sbotest/archive* by default. This includes even
requested scripts and their reverse dependencies.

Incompatible with **\--archive-rebuild**, **\--archive-reverse** and
**\-\--no-archive**.

**-B\|\--git-branch**

If **FALSE**, use the default git branch for the running version of
Slackware. If a **branch name**, use it in case of a git repository.
Must be used with **pull**.

**-D\|\--dry-run**

Generate a report on scripts to be tested, queued packages in the local
overrides directory and the number of archived packages to be reused. In
case of **\--archive-rebuild**or **\--archive-reverse**, additionally
report archived packages to be removed.

**-f\|\--full-reverse**

Test all reverse dependencies for the requested scripts rather than the
first level only. Use **sbotest find \--all-reverse** or pass
**\--dry-run** to see which scripts would be tested, if compatible.

**-s\|\--single**

Do not test reverse dependencies for any requested script. Enables
testing for scripts that have already been installed.

**-j\|\--jobs**

If **numeric**, pass to **make** with the **-j** flag.

**-k\|\--pkg-dir**

If **FALSE**, use the default package directory of
*SBO_HOME/tests/(timestamp)-tests*, e.g.
*/usr/sbotest/tests/2025-05-31-16:27-tests*. If an **absolute path**,
save packages built during the test run a timestamp-designated directory
under that path.

**-l\|\--log-dir**

If **FALSE**, use the default log directory of
*SBO_HOME/logs/(timestamp)-logs*. If an **absolute path**, save build
and **sbopkglint(1)** logs to that directory with a timestamp appended.

**\--no-archive**

Do not reuse any archived packages during the test run, and do not
archive built packages.

Incompatible with **\--archive-rebuild**, **\--archive-reverse** and
**\--archive-force**.

**-r\|\--repo**

If **FALSE**, use the default repository URL for the running Slackware
version. If a **URL**, pull from that URL. Must be used with **pull**.

**-S\|\--strict-upgrades**

If **TRUE**, delete only mismatched packages with lower version or build
numbers when running **\--archive-rebuild** or **\--archive-reverse**.
If **FALSE**, delete all mismatched packages from the archive. Overrides
the setting in */etc/sbotest/sbotest.conf*.

**-X\|\--so-check**

If **TRUE**, perform a missing shared object dependency check on all
installed *\_SBo* packages upon build test failure. Overrides the
setting in */etc/sbotest/sbotest.conf*.

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

## TESTING STRATEGIES

There are three basic ways to test scripts with **sbotest**. After using
**sbotest pull** to retrieve a new branch or the latest updates:

* Test against the upstream repository without changes.
* Test against a git branch with changes to be merged.
* Test against the upstream repository with changes in a local overrides directory.

The first case is the simplest, and requires no configuration beyond
setting **RSYNC_DEFAULT** or **REPO** in */etc/sbotest/sbotest.conf* as
appropriate.

To test upcoming changes in a git branch, set **GIT_BRANCH** to the name
of the branch and ensure that **REPO** is set if non-default.
Alternatively, specify with the **\--repo** and **\--git-branch**
options when running **sbotest pull**. From here, run **sbotest**. If
multiple scripts are to be tested for submission, using a single merged
branch for testing may be convenient:

    git branch testbranch
    git checkout testbranch
    git merge rust-opt dos2unix fvwm3
    git push --set-upstream origin testbranch

To use a local overrides directory, set **LOCAL_OVERRIDES** to an
absolute path. Place directories for any script to be tested in the top
level and run **sbotest**. Removing these directories when testing is
complete is advisable.

Reusing built packages in future test runs saves time and resources. The
default archive directory is */usr/sbotest/archive*; packages stored
here are reinstalled in lieu of building when needed, provided they are
up-to-date. During an **sbotest** run, all built dependencies are
archived by default. To archive all built packages (including testing
targets), use **\--archive-force**. Ignore the archive altogether with
**\--no-archive**.

The archive can be kept current with **\--archive-rebuild**. This
rebuilds all version- and build-mismatched packages in the archive,
provided that they are not installed or on the blacklist.
**\--archive-reverse** rebuilds all reverse dependencies as well. If
**STRICT_UPGRADES** is **TRUE**, only mismatched packages with lower
version or build numbers are removed from the archive. By default, all
mismatched packages are removed.

## CONFIGURATION

The default configuration directory is */etc/sbotest* with files
*sbotest.conf*, *sbotest.hints* and *obsolete* being recognized.
*obsolete* is relevant only if testing against Slackware -current. To
use an alternative configuration directory, set an environment variable
*SBOTEST_CONF_DIR*.

Configuration options and hints can be set from the command line with
**config** and **hints**, respectively.

Several default settings differ from base **sbotools**:

**ETC_PROFILE**

With a default of **TRUE**, source all executable scripts of the form
*\*.sh* in */etc/profile* before building each script.

**CPAN_IGNORE**

With a default of **TRUE**, build and install SlackBuilds regardless of
whether they have been installed from the CPAN.

**SBO_HOME**

The default value is */usr/sbotest*.

**PKG_DIR**

The default value is *SBO_HOME/tests*. Unless an **absolute path** is
specified, packages built during the test run are saved to a
timestamp-designated directory under that path, e.g.
*/usr/sbotest/tests/2025-05-31-16:27-tests*.

**LOG_DIR**

The default value is *SBO_HOME/logs*. Unless an **absolute path** is
specified, log files are saved to a timestamp-designated directory under
that path.

**SBO_ARCHIVE**

This setting is used only when running **sbotest**, and has a default
value of *SBO_HOME/archive*. Any packages stored here are installed
prior to calling [sboinstall(1)](sboinstall.1.md), provided that they:

* Are not test targets.
* Are required by the script to be tested.
* Are not already installed.
* Have versions and build numbers matching the local repository.

The archive can be kept in sync with the local repository by running
**sbotest** with **\--archive-rebuild**.

Hints may be specified in */etc/sbotest/sbotest.hints*. Saved build
options from **sbotools** are ignored. See [sbotools.conf(5)](sbotools.conf.5.md) and
[sbotools.hints(5)](sbotools.hints.5.md) for more information.

## EXIT CODES

**sbotest** can exit with the following codes:

0: all operations were succesful.\
1: a usage error occured, such as specifying invalid options.\
2: a script or module error occurred.\
6: unable to obtain a required file handle.\
7: unable to get required info from the *info* file.\
8: unable to unset the exec-on-close bit on a temporary file.\
12: interrupt signal received.\
13: circular dependencies detected.\
15: GPG verification failed.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotest/> are always welcome.

## SEE ALSO

[sboconfig(1)](sboconfig.1.md), [sbofind(1)](sbofind.1.md), [sbohints(1)](sbohints.1.md), [sboinstall(1)](sboinstall.1.md), [sbotools.conf(5)](sbotools.conf.5.md),
[sbotools.hints(5)](sbotools.hints.5.md), SBO::Lib(3), SBO::Lib::Build(3), SBO::Lib::Info(3),
SBO::Lib::Pkgs(3), SBO::Lib::Repo(3), SBO::Lib::Solibs(3),
SBO::Lib::Tree(3), SBO::Lib::Util(3), sbolint(1), sbopkglint(1)

## ACKNOWLEDGMENTS

**Jacob Pipkin**, **Luke Williams** and **Andreas Guldstrand** are the
original authors of **sbotools**.

**sbo-maintainer-tools** is written and maintained by **B. Watson**.

## AUTHOR

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
