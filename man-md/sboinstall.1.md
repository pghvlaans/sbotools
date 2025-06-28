# sboinstall

[NAME](#name)\
[SYNOPSIS](#synopsis)\
[DESCRIPTION](#description)\
[OPTIONS](#options)\
[VARIABLES](#variables)\
[EXIT CODES](#exit-codes)\
[BUGS](#bugs)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[MAINTAINER](#maintainer)

------------------------------------------------------------------------

## NAME

**sboinstall** - install SlackBuilds

## SYNOPSIS

    sboinstall [-h|-v]

    sboinstall [-dce TRUE|FALSE] [-j #|FALSE] [-Lk /path|FALSE] \
               [-DRiopr] [--batch|--dry-run] [--create-template FILE] \
               sbo_name (sbo_name)

    sboinstall [-dce TRUE|FALSE] [-j #|FALSE] [-Lk /path|FALSE] \
               [-Di] --use-template FILE

    sboinstall [-dce TRUE|FALSE] [-j #|FALSE] [-Lk /path|FALSE] \
               [-Dioqr] [--create-template FILE] --mass-rebuild

    sboinstall [-dce TRUE|FALSE] [-j #|FALSE] [-Lk /path|FALSE] \
               [-Dioqr] [--create-template FILE] --series-rebuild SERIES

## DESCRIPTION

**sboinstall** is used to install SlackBuilds. If the
**\--nointeractive** flag is not present, **sboinstall** pulls the list
of requirements from the *info* file for any specified SlackBuild. This
is a recursive operation over all dependencies. **sboinstall** offers to
install any non-installed dependencies in the build queue, taking the
hints in [sbotools.hints(5)](sbotools.hints.5.md) into account. In case of
**\--reinstall**, scripts with automatic reverse dependency rebuilds
have their reverse dependencies rebuilt as well. The script exits with
an error message if circular dependencies are detected.

*README* files are parsed for **groupadd** and **useradd** commands, and
**sboinstall** offers to run them prior to building if any of the
required users or groups do not exist. If the *README* is judged to
document options in *KEY=VALUE* form, a prompt for setting options
appears. Any build options, whether passed interactively or in a
template, are saved to */var/log/sbotools* when the SlackBuild runs.

*compat32* packages share saved build options with the corresponding
base script. Please note that saved build options are not displayed when
**CLASSIC** is set to **TRUE**. See [sboconfig(1)](sboconfig.1.md) or
[sbotools.conf(5)](sbotools.conf.5.md). When running with **\--nointeractive** or
**\--batch**, saved build options are used automatically unless
**\--norecall** or **\--use-template** are passed as well.

**sboinstall** attempts to download the sources from the *DOWNLOAD* or
*DOWNLOAD_x86_64* variables in the *info* file. If either the download
or the md5sum check fails, a new download is attempted from
<ftp://slackware.uk/sbosrcarch/> as a fallback measure.

**sboinstall** verifies the local repository with **gpg** if
**GPG_VERIFY** is **TRUE**. Only rsync repositories can be verified on
Slackware 14.0 and Slackware 14.1.

Root privileges are required to run **sboinstall** unless passing
**\--dry-run**. If an invalid configuration is detected in
*/etc/sbotools/sbotools.conf*, or if invalid options are specified, the
script exits with a diagnostic message.

## OPTIONS

**-c\|\--noclean (FALSE\|TRUE)**

If **TRUE**, do not clean working directories after building. These are
the build and *package-(sbo)* directories under */tmp/SBo* (or *\$TMP*).
Cleaning these directories can be set as default via the
[sboconfig(1)](sboconfig.1.md) command. See also [sbotools.conf(5)](sbotools.conf.5.md). This option
overrides the default.

**-D\|\--dry-run**

Non-interactively print the prospective build queue and exit.
**\--dry-run** reports SlackBuilds in the queue with *%README%* in
*REQUIRES*, saved build options to be used and **useradd** or
**groupadd** commands to be run. This makes **\--batch** considerably
safer for everyday use. **\--dry-run** can be used without root
privileges.

**-d\|\--distclean (FALSE\|TRUE)**

If **TRUE**, remove the source archives after building. They are
retained in md5sum-designated directories under *SBO_HOME/distfiles* by
default. The package archive (in */tmp* by default) is also removed.
This option can be set as default via the [sboconfig(1)](sboconfig.1.md) command. See
also [sbotools.conf(5)](sbotools.conf.5.md). This option overrides the default.

**-e\|\--etc-profile**

If **TRUE**, source any executable scripts in */etc/profile.d* named
*\*.sh* before running each SlackBuild in the build queue. This option
overrides the default.

**-i\|\--noinstall**

Do not install the package at the end of the build process. It is left
in */tmp* (or *\$OUTPUT*) if **DISTCLEAN** is **FALSE**. Packages are
retained in **PKG_DIR** if so defined regardless of **DISTCLEAN**. See
[sboconfig(1)](sboconfig.1.md) and [sbotools.conf(5)](sbotools.conf.5.md).

**-j\|\--jobs (FALSE\|#)**

If **numerical**, pass to the **-j** argument when a SlackBuild invoking
**make** is run.

**-k\|\--pkg-dir (FALSE\|/path)**

If an **absolute path**, save built packages here, overriding the value
of the **PKG_DIR** setting.

**-L\|\--log-dir (FALSE\|/path)**

If an **absolute path**, save build logs here, overriding the value of
the **LOG_DIR** setting. Logs are saved with the name of the script and
a timestamp.

**-o\|\--norecall**

Do not reuse saved build options if running with **\--nointeractive**.

**-p\|\--compat32**

Create a *compat32* package on multilib x86_64 systems. This requires
the **compat32-tools** package by Eric Hameleers. Please note that this
operation is not necessarily foolproof, and is unsupported by anyone in
principle. **\--compat32** can be combined with **\--noinstall** and
**\--distclean FALSE** so that the contents of the package can be
inspected prior to installation. GitHub Issues are welcome in case of
unexpected failure.

**sboinstall** will not attempt *compat32* builds for Perl-based or
*noarch* scripts. Incompatible with **\--mass-rebuild,
\--series-rebuild** and **\--use-template**.

**-q\|\--reverse-rebuild**

Rebuild the reverse dependencies for the requested SlackBuilds. The
build queue also includes any missing dependencies for those scripts.
With **\--compat32**, rebuild only installed *compat32* reverse
dependencies.

Incompatible with **\--norequirements**, **\--use-template** and
**\--mass-rebuild**.

**-r\|\--nointeractive**

Bypass all user prompts for the requested SlackBuilds. Dependency
resolution is bypassed as well except for **\--mass-rebuild**,
**\--series-rebuild**, **\--reverse-rebuild** and (extraneously)
**\--batch**. Saved build options will be reused automatically unless
**\--norecall** or **\--use-template** are passed as well. Unless it is
obvious that new build options and dependency resolution are not
required, consider using a template instead.

If an operation with **\--nointeractive** would install an in-tree
*\_SBo* package in place of a package without this tag, the build is
automatically skipped.

Overriden by **\--batch**.

**-R\|\--norequirements**

Bypass dependency resolution, but still show *README* and the user
prompts before proceeding with the build.

Incompatible with **\--batch**.

**\--reinstall**

Offer to reinstall all packages in the build queue. If any of the
packages have automatic reverse dependency rebuild requests, rebuild
their reverese dependency queues as well. See [sbohints(1)](sbohints.1.md) or
[sbotools.hints(5)](sbotools.hints.5.md).

**\--create-template (FILE)**

Create a template for one or more SlackBuilds including any pre-build
commands and build options and save to the specified **FILE**.

**\--use-template (FILE)**

Build using the template saved to **FILE.** This disables all user
prompts.

Incompatible with **\--compat32**, **\--series-rebuild**,
**\--mass-rebuild** and **\--reverse-rebuild**. To make *compat32*
packages from a template, consider using **\--create-template** with
**\--compat32** first.

**\--mass-rebuild**

Generate build queues, rebuild and reinstall all in-tree *\_SBo*
SlackBuilds. This is generally only useful when the Slackware version
has been upgraded or (occasionally) on -current. New SlackBuilds may be
installed when dependencies have been added.

In combination with **\--nointeractive** and **\--batch**, saved build
options are reused automatically.

Incompatible with **\--series-rebuild**, **\--reverse-rebuild**,
**\--compat32**, **\--use-template** and **\--norequirements**.

If the mass rebuild process is interrupted after downloading has been
completed, whether by signal or by build failure, a template named
*resume.temp* is saved to **SBO_HOME**. If this file is present, the
mass rebuild restarts from the script after the script that failed when
**\--mass-rebuild** is used again.

**\--series-rebuild (SERIES)**

Generate build queues, rebuild and reinstall all in-tree *\_SBo*
SlackBuilds from the **SERIES** series. In combination with
**\--reverse-rebuild**, rebuild and reinstall reverse dependencies of
these scripts as well. This is most potentially useful on Slackware
-current for the **python**, **perl**, **ruby** and **haskell** series.

In combination with **\--nointeractive** and **\--batch**, saved build
options are reused automatically.

Incompatible with **\--compat32**, **\--use-template**,
**\--mass-rebuild** and **\--norequirements**.

**\--batch**

Bypass all user prompts for the requested SlackBuilds, but perform
dependency resolution, even if none of **\--mass-rebuild**,
**\--series-rebuild** or **\--reverse-rebuild** are passed. Any saved
build options are used again unless **\--norecall** is passed as well.
If a script calls for **useradd** or **groupadd**, **sboinstall** exits
with an informative message if any specified user and group does not
exist.

This flag is not to be taken lightly, as it can cause new dependencies
to be installed without prompting. Usage in a production environment
without a well-maintained [sbotools.hints(5)](sbotools.hints.5.md) file or with unfamiliar
scripts is not advised. Consider running **sboinstall** with
**\--dry-run** first, which prints the **\--batch** build queue and
exits, to verify the upcoming operation.

Incompatible with **\--norequirements** and overrides
**\--nointeractive**.

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

## VARIABLES

Beyond the options contained in *README* files, certain variables are
relevant to nearly all SlackBuilds, and can be used when running
**sboinstall**.

**ARCH**

**ARCH** passes a CPU architecture to the build process, and is mostly
used to build **i?86** packages on **x86_64** machines and *compat32*
packages. **sboinstall** does not require **ARCH** to build *compat32*
packages. This process is not necessarily bug-free; please do not
hesitate to report *compat32* issues.

**BUILD**

**BUILD** sets the build number. Although it can be supplied at the
command line without compromising the build, please note that unless
**CLASSIC** or **BUILD_IGNORE** are set, [sbocheck(1)](sbocheck.1.md) and
[sboupgrade(1)](sboupgrade.1.md) will report the installed package as upgradable.

**OUTPUT**

**OUTPUT** is the directory where the package, source and working
directories are created, */tmp* by default. **sboinstall** recognizes
user-supplied values. Please note that packages are saved in the
directory specified by **PKG_DIR** if set.

**PKGTYPE**

The **PKGTYPE** variable sets the compression method for the resulting
package. **makepkg(1)** supports a number of values, including **tgz**
(the **SlackBuilds.org** default), **tar.gz**, **txz**, **tar.xz**,
**tbz**, **tar.bz2**, **tlz**, **tar.lz** and **tar.lzma**. Any of these
can be used without issue.

**TAG**

**TAG** sets the tag at the end of the package name, **\_SBo** by
default. Its use is not advisable with **sboinstall**. If a different
tag is supplied, [sbocheck(1)](sbocheck.1.md) and [sboupgrade(1)](sboupgrade.1.md) will fail to
report upgrades for the installed package.

**TMP**

**TMP** is **/tmp/SBo**, the directory where the source and working
directories are created. **sboinstall** recognizes user-supplied values.
Please note that packages are saved in the directory specified by
**PKG_DIR** if set.

**VERSION**

**VERSION** sets the version number. If changed at the command line, the
SlackBuild is highly unlikely to build successfully. To build a
different version, consider using the directory specified in
**LOCAL_OVERRIDES**.

## EXIT CODES

**sboinstall** can exit with the following codes:

0: all operations were succesful.\
1: a usage error occured, such as specifying invalid options.\
2: a script or module error occurred.\
3: a SlackBuild exited non-zero.\
4: unable to md5sum verify the source file(s).\
5: unable to download the source file(s).\
6: unable to obtain a required file handle.\
7: unable to get required info from the *info* file.\
8: unable to unset the exec-on-close bit on a temporary file.\
9: multilib has not been set up (where required).\
10: **convertpkg-compat32** exited non-zero.\
11: the **convertpkg-compat32** script cannot be found (where
required).\
12: interrupt signal received.\
13: circular dependencies detected.\
14: in **batch**, **nointeractive** or **dry-run**, required user or
group missing.\
15: GPG verification failed.\
16: reading keyboard input failed.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools/> are always welcome.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboclean(1)](sboclean.1.md), [sboconfig(1)](sboconfig.1.md), [sbofind(1)](sbofind.1.md), [sbohints(1)](sbohints.1.md),
[sboremove(1)](sboremove.1.md), [sboupgrade(1)](sboupgrade.1.md), [sbotools.conf(5)](sbotools.conf.5.md), [sbotools.hints(5)](sbotools.hints.5.md)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
