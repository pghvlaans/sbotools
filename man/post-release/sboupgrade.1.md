# sboupgrade

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

**sboupgrade** - install or upgrade SlackBuilds

## SYNOPSIS

    sboupgrade [-h|-v]

    sboupgrade [-c TRUE|FALSE] [-d TRUE|FALSE] [-j #|FALSE] \
               [-b TRUE|FALSE] [-S TRUE|FALSE] [-fiopqrz] \
               [--batch|--dry-run] --all|sbo_name (sbo_name)

## DESCRIPTION

**sboupgrade** is used to upgrade SlackBuilds. If the
**\--nointeractive** flag is not present, **sboupgrade** pulls the list
of requirements from the *info* file for any specified SlackBuild. This
is a recursive operation over all dependencies. **sboupgrade** offers to
install any non-installed dependencies in the build queue, taking the
hints in [sbotools.hints(5)](sbotools.hints.5.md) into account. If circular dependencies
are detected, the script exits with an error message.

*README* files are parsed for **groupadd** and **useradd** commands, and
**sboupgrade** offers to run them prior to building if any of the
required users or groups do not exist. If the *README* is judged to
document options in *KEY=VALUE* form, a prompt for setting options
appears. Any build options used are saved to */var/log/sbotools* when
the SlackBuild runs.

*compat32* packages share saved build options with the corresponding
base script. Please note that saved build options are not displayed when
**CLASSIC** is set to **TRUE**. When running with **\--nointeractive**
or **\--batch** , saved build options are used automatically unless
**\--norecall** is passed as well. If **STRICT_UPGRADES** is **TRUE**,
upgrades are only performed for non-override packages if the version or
build number is apparently higher. See [sboconfig(1)](sboconfig.1.md) or
[sbotools.conf(5)](sbotools.conf.5.md).

**sboupgrade** attempts to download the sources from the *DOWNLOAD* or
*DOWNLOAD_x86_64* variables in the *info* file. If either the download
or the md5sum check fails, a new download is attempted from
<ftp://slackware.uk/sbosrcarch/> as a fallback measure. The **\--all**
flag may be passed to upgrade all eligible SlackBuilds simultaneously.

**sboupgrade** verifies the local repository with **gpg** if
**GPG_VERIFY** is **TRUE**. Only rsync repositories can be verified on
Slackware 14.0 and Slackware 14.1.

Root privileges are required to run **sboupgrade**. If an invalid
configuration is detected in */etc/sbotools/sbotools.conf*, or if
invalid options are specified, the script exits with a diagnostic
message.

## OPTIONS

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

**-b\|\--build-ignore (FALSE\|TRUE)**

If **TRUE**, do not perform upgrades unless the version number differs.
By default, upgrades also occur when the build number differs. This
setting and **\--force** are not the same; **\--force** initiates
upgrades even if the build number is unchanged. This overrides the
**BUILD_IGNORE** setting in [sbotools.conf(5)](sbotools.conf.5.md).

**-c\|\--noclean (FALSE\|TRUE)**

If **TRUE**, do not clean working directories after building. These are
the build and *package-(sbo)* directories under */tmp/SBo* (or *\$TMP*).
Cleaning these directories can be set as default via the
[sboconfig(1)](sboconfig.1.md) command. See also [sbotools.conf(5)](sbotools.conf.5.md). This option
overrides the default.

**-d\|\--distclean (FALSE\|TRUE)**

If **TRUE**, then remove the source archives after building. They are
retained in md5sum-designated directories under *SBO_HOME/distfiles* by
default. The package archive (in */tmp* by default) is also removed.
This option can be set as default via the [sboconfig(1)](sboconfig.1.md) command. See
also [sbotools.conf(5)](sbotools.conf.5.md). This option overrides the default.

**-f\|\--force**

Force an upgrade, even if the installed version and build number are
equal to the **SlackBuilds.org** version.

**-i\|\--noinstall**

Do not install the package at the end of the build process. It is left
in */tmp* (or *\$OUTPUT*) if **DISTCLEAN** is **FALSE**. Packages are
retained in **PKG_DIR** if so defined regardless of **DISTCLEAN**. See
[sboconfig(1)](sboconfig.1.md) and [sbotools.conf(5)](sbotools.conf.5.md). Incompatible with
**\--reverse-rebuild**.

**-j\|\--jobs (FALSE\|#)**

If numerical, pass to the **-j** argument when a SlackBuild invoking
**make** is run.

**-o\|\--norecall**

Do not reuse saved build options if running with **\--nointeractive** or
**\--batch**.

**-p\|\--compat32**

Create a *compat32* package on multilib x86_64 systems. This requires
the **compat32-tools** package by Eric Hameleers. Please note that this
operation is not necessarily foolproof, and is unsupported by anyone in
principle. **\--compat32** can be combined with **\--noinstall** and
**\--distclean FALSE** so that the contents of the package can be
inspected prior to installation. GitHub Issues are welcome in case of
unexpected failure.

**sboinstall** will not attempt *compat32* builds for Perl-based or
*noarch* scripts. Incompatible with **\--all**.

**-q\|\--reverse-rebuild**

Rebuild the reverse dependency queue after upgrading. Please note that
building against some packages, including **google-go-lang**, does not
work without first sourcing a version-specific profile script.
**\--reverse-rebuild** fails in such cases. Incompatible with
**\--noinstall**.

**-r\|\--nointeractive**

Bypass all user prompts and all dependency resolution for the requested
SlackBuilds except in case of reverse dependency rebuilds,
**\--reverse-rebuild** or (extraneously) **\--batch**. Saved build
options will be reused automatically unless **\--norecall** is passed as
well. Unless it is obvious that dependency resolution and new build
options are not required, using this option is not recommended.

Overridden by **\--batch**.

**-S\|\--strict-upgrades (FALSE\|TRUE)**

If **TRUE**, only perform upgrades if the incoming version or build
number is higher. This has no effect scripts in the local overrides
directory. This option can be set as default via [sboconfig(1)](sboconfig.1.md). See
also [sbotools.conf(5)](sbotools.conf.5.md). This option overrides the default.

**-z\|\--force-reqs**

In the same vein as **\--force**, upgrade the SlackBuild and its
dependencies, even if upgrades are not required.

Incompatible with **\--nointeractive**.

**\--all**

Upgrade all installed SlackBuilds that are eligible for upgrades,
including *compat32* packages. This takes the **BUILD_IGNORE** setting
into account. See [sboconfig(1)](sboconfig.1.md) and [sbotools.conf(5)](sbotools.conf.5.md).
Incompatible with **\--compat32**. Please note that SlackBuilds
installed from a **LOCAL_OVERRIDES** directory are upgraded only if the
version or build number from this directory varies.

**\--batch**

Bypass all user prompts for the requested SlackBuilds, but perform
dependency resolution, even if **\--reverse-rebuild** is not passed. Any
saved build options are used again unless **\--norecall** is passed as
well. If a script calls for **useradd** or **groupadd**, **sboupgrade**
exits with an informative message if any specified user or group does
not exist.

This flag is not to be taken lightly, as it can cause new dependencies
to be installed without prompting. Usage in a production environment
without a well-maintained [sbotools.hints(5)](sbotools.hints.5.md) file or with unfamiliar
scripts is not advised. For safer usage, consider running **sboupgrade**
with **\--dry-run** first, which prints the **\--batch** build queue and
exits, to verify the upcoming operation.

Overrides **\--nointeractive**.

**\--dry-run**

Non-interactively print the **\--batch** build queue and exit.
**\--dry-run** reports SlackBuilds in the queue with *%README%* in
*REQUIRES*, saved build options to be used and **useradd** or **groupadd
commands to be run. This makes \--batch** considerably safer for
everyday use.

## VARIABLES

Beyond the options contained in *README* files, certain variables are
relevant to nearly all SlackBuilds, and can be used when running
**sboupgrade**.

**ARCH**

**ARCH** passes a CPU architecture to the build process, and is mostly
used to build **i?86** packages on **x86_64** machines and *compat32*
packages. **sboupgrade** does not require **ARCH** to build *compat32*
packages. This process is not necessarily bug-free; please do not
hesitate to report *compat32* issues.

**BUILD**

**BUILD** sets the build number. Although it can be supplied at the
command line without compromising the build, please note that unless
**CLASSIC** or **BUILD_IGNORE** are set, [sbocheck(1)](sbocheck.1.md) and
**sboupgrade** will report the installed package as upgradable.

**OUTPUT**

**OUTPUT** is the directory where the package, source and working
directories are created, */tmp* by default. **sboupgrade** recognizes
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
default. Its use is not advisable with **sboupgrade**. If a different
tag is supplied, [sbocheck(1)](sbocheck.1.md) and **sboupgrade** will fail to report
upgrades for the installed package.

**TMP**

**TMP** is **/tmp/SBo**, the directory where the source and working
directories are created. **sboupgrade** recognizes user-supplied values.
Please note that packages are saved in the directory specified by
**PKG_DIR** if set.

**VERSION**

**VERSION** sets the version number. If changed at the command line, the
SlackBuild is highly unlikely to build successfully. To build a
different version, consider using the directory specified in
**LOCAL_OVERRIDES**.

## EXIT CODES

**sboupgrade** can exit with the following codes:

0: all operations were succesful.\
1: a usage error occured, such as specifying invalid options.\
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
13: circular dependencies detected.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools/> are always welcome.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboclean(1)](sboclean.1.md), [sboconfig(1)](sboconfig.1.md), [sbofind(1)](sbofind.1.md), [sbohints(1)](sbohints.1.md),
[sboinstall(1)](sboinstall.1.md), [sboremove(1)](sboremove.1.md), [sbotools.conf(5)](sbotools.conf.5.md), [sbotools.hints(5)](sbotools.hints.5.md)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
