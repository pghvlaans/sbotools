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

    sbotest [-f|-s] [-j #|FALSE] [-akl /path|FALSE] \
            sbo_name (sbo_name)

    sbotest [-al /path|FALSE] [-S TRUE|FALSE] --archive-rebuild

## DISCLAIMER

**sbotest** is designed and intended to run in a build-testing
environment, such as a virtual machine or a **Docker** image. Missing
users and groups are added automatically when running **sbotest**, and
any packages installed as a result of testing are removed afterwards
unless they had been previously installed.

Using **sbotest** on a general-purpose Slackware installation is
**unsupported** and **unadvisable**.

## DESCRIPTION

**sbotest** is a reverse dependency build tester based on the
**sbotools** library. Called without options, it builds any requested
SlackBuilds with their first level of reverse dependencies. To test all
reverse dependencies of the requested scripts, use the
**\--full-reverse** option; **\--single** tests no reverse dependencies.

Each test target has a separate testing workflow. First, dependencies
saved to the **SBO_ARCHIVE** directory (default */usr/sbotest/archive*)
are installed to save time; see **CONFIGURATION** below for details. Any
missing users and groups are added, and [sboinstall(1)](sboinstall.1.md) is called.

Newly-built packages are saved to a timestamp-appended **PKG_DIR**. Any
packages that are not required for the following build are removed
afterwards. Packages without the *\_SBo* tag are unaffected, and no
package that is already installed when **sbotest** starts can be removed
or reinstalled.

**sbopkglint(1)** is run on all test targets once [sboinstall(1)](sboinstall.1.md) has
been called for the last time. A summary of results is displayed and
saved to *SBO_HOME/results/(timestamp).log*. Scripts that fail
**sbolint(1)** or **sbopkglint(1)**, or fail to build altogether, are
reported so that any issues can be taken care of before submitting
scripts to **SlackBuilds.org**.

The package archive can be kept current with **\--archive-rebuild**,
which rebuilds all version- and build-mismatched packages in the
archive, provided that they are not installed or on the blacklist. If
**STRICT_UPGRADES** is **TRUE**, only mismatched packages with lower
version or build numbers will be removed from the archive. By default,
all mismatched packages are removed.

## OPTIONS

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

**\--archive-rebuild**

Replace build- and version-mismatched packages in the archive,
*/usr/sbotest/archive* by default. Please note that installed and
blacklisted packages are ignored. If **STRICT_UPGRADES** is **TRUE**,
only mismatched packages with lower version or build numbers will be
removed from the archive.

If a script to be rebuilt has an automatic reverse dependency rebuild
request in */etc/sbotest/sbotest.hints*, its reverse dependencies are
rebuilt and replaced as well. See [sbotools.hints(5)](sbotools.hints.5.md) for details
about setting hints.

**-f\|\--full-reverse**

Test all reverse dependencies for the requested scripts rather than the
first level only.

**-s\|\--single**

Do not test reverse dependencies for any requested script.

**-a\|\--sbo-archive**

If **FALSE**, use the default archive directory at *SBO_HOME/archive*.
If an **absolute path**, use that as the archive directory.

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

**-S\|\--strict-upgrades**

If **TRUE**, delete only mismatched packages with lower version or build
numbers when running **\--archive-rebuild**. If **FALSE**, delete all
mismatched packages from the archive. Overrides the setting in
*/etc/sbotest/sbotest.conf*.

## TESTING STRATEGIES

There are three basic ways to test scripts with **sbotest**.

* Test against the upstream repository without changes.
* Test against a git branch with changes to be merged.
* Test against the upstream repository with changes in a local overrides directory.

The first case is the simplest, and requires no configuration beyond
setting **RSYNC_DEFAULT** or **REPO** in */etc/sbotest/sbotest.conf* as
appropriate.

To test upcoming changes in a git branch, set **GIT_BRANCH** to the name
of the branch and ensure that **REPO** is set if non-default. From here,
run **sbotest**. If multiple scripts are to be tested for submission,
using a single merged branch for testing may be convenient:

    git branch testbranch\
    git checkout testbranch\
    git merge rust-opt dos2unix fvwm3\
    git push \--set-upstream origin testbranch

To use a local overrides directory, set **LOCAL_OVERRIDES** to an
absolute path. Place directories for any script to be tested in the top
level and run **sbotest**. Removing these directories when testing is
complete is advisable.

Reusing built packages in future test runs saves time and resources. The
default archive directory is */usr/sbotest/archive*; packages stored
here are reinstalled in lieu of building when needed, provided they are
up-to-date. Copy packages from the test directories under (by default)
*/usr/sbotest/tests* to use them again later.

## CONFIGURATION

The default configuration directory is */etc/sbotest* with files
*sbotest.conf*, *sbotest.hints* and *obsolete* being recognized.
*obsolete* is relevant only if testing against Slackware -current. To
use an alternative configuration directory, set an environment variable
*SBOTEST_CONF_DIR*.

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
specified, packages built during the test run will be saved to a
timestamp-designated directory under that path, e.g.
*/usr/sbotest/tests/2025-05-31-16:27-tests*.

**LOG_DIR**

The default value is *SBO_HOME/logs*. Unless an **absolute path** is
specified, log files will be saved to a timestamp-designated directory
under that path.

**SBO_ARCHIVE**

This setting is used only when running **sbotest**, and has a default
value of *SBO_HOME/archive*. Any packages stored here will be installed
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

[sboinstall(1)](sboinstall.1.md), [sbotools.conf(5)](sbotools.conf.5.md), [sbotools.hints(5)](sbotools.hints.5.md), SBO::Lib(3),
SBO::Lib::Build(3), SBO::Lib::Info(3), SBO::Lib::Pkgs(3),
SBO::Lib::Repo(3), SBO::Lib::Tree(3), SBO::Lib::Util(3), sbolint(1),
sbopkglint(1)

## ACKNOWLEDGMENTS

**Jacob Pipkin**, **Luke Williams** and **Andreas Guldstrand** are the
original authors of **sbotools**.

**sbo-maintainer-tools** is written and maintained by **B. Watson**.

## AUTHOR

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
