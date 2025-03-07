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

    sboinstall [-d TRUE|FALSE] [-j #|FALSE] [-c TRUE|FALSE] \
               [-iopRr] [--create-template FILE] sbo_name (sbo_name)

    sboinstall [-d TRUE|FALSE] [-j #|FALSE] [-c TRUE|FALSE] \
               [-i] --use-template FILE

    sboinstall [-d TRUE|FALSE] [-j #|FALSE] [-c TRUE|FALSE] \
               [-ioqr] [--create-template FILE] --mass-rebuild

## DESCRIPTION

**sboinstall** is used to install SlackBuilds. If the **-r** flag is not
specified, **sboinstall** pulls the list of requirements from the *info*
file for any specified SlackBuild. This is a recursive operation over
all dependencies. **sboinstall** offers to install any non-installed
dependencies in the build queue, taking blacklisted scripts and optional
dependency specifications in [sbotools.hints(5)](sbotools.hints.5.md) into account. In case
of **\--reinstall**, scripts with automatic reverse dependency rebuilds
will have their reverse dependencies rebuilt as well. If circular
dependencies are detected, the script exits with an error message.

*README* files are parsed for **groupadd** and **useradd** commands, and
**sboinstall** offers to run them prior to building. If the *README* is
judged to document options in *KEY=VALUE* form, a prompt for setting
options appears. Any build options, whether passed interactively or in a
template, are saved to */var/log/sbotools* when the SlackBuild runs.

Please note that saved build options are not displayed when **CLASSIC**
is set to **TRUE**. See [sboconfig(1)](sboconfig.1.md) or [sbotools.conf(5)](sbotools.conf.5.md). When
running with **\--nointeractive**, saved build options are used
automatically unless **\--norecall** or **\--use-template** are passed
as well.

**sboinstall** attempts to download the sources from the *DOWNLOAD* or
*DOWNLOAD_x86_64* variables in the *info* file. If either the download
or the md5sum check fails, a new download is attempted from
<ftp://slackware.uk/sbosrcarch/> as a fallback measure.

**sboinstall** verifies the local repository with **gpg** if
**GPG_VERIFY** is **TRUE**. Only rsync repositories can be verified on
Slackware 14.0 and Slackware 14.1.

Root privileges are required to run **sboinstall**. If an invalid
configuration is detected in */etc/sbotools/sbotools.conf*, or if
invalid options are specified, the script exits with a diagnostic
message.

## OPTIONS

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

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

**-i\|\--noinstall**

Do not install the package at the end of the build process. It is left
in */tmp* (or *\$OUTPUT*) if **DISTCLEAN** is **FALSE**. Packages are
retained in **PKG_DIR** if so defined regardless of **DISTCLEAN**. See
[sboconfig(1)](sboconfig.1.md) and [sbotools.conf(5)](sbotools.conf.5.md).

**-j\|\--jobs (FALSE\|#)**

If **numerical**, pass to the **-j** argument when a SlackBuild invoking
**make** is run.

**-o\|\--norecall**

Do not reuse saved build options if running with **\--nointeractive**.

**-p\|\--compat32**

Create a compat32 package on multilib x86_64 systems. This requires the
**compat32-tools** package by Eric Hameleers. Please note that this
operation is not necessarily foolproof, and is unsupported by anyone in
principle. As a best practice, **\--compat32** should be combined with
**\--noinstall** and **\--distclean FALSE** so that the contents of the
package can be inspected prior to installation. GitHub Issues are
welcome in case of unexpected failure.

**-q\|\--reverse-rebuild**

Rebuild the reverse dependencies for the requested SlackBuilds. The
build queue also includes any missing dependencies for those scripts.
Incompatible with **\--compat32**, **\--norequirements**,
**\--use-template** and **\--mass-rebuild**.

**-r\|\--nointeractive**

Bypass all user prompts for the requested SlackBuilds. Dependency
resolution is bypassed as well except for **\--mass-rebuild** and
**\--reverse-rebuild**. Saved build options will be reused automatically
unless **\--norecall** or **\--use-template** are passed as well. Unless
it is obvious that dependency resolution and new build options are not
required, consider using a template instead.

If an operation with **\--nointeractive** would install an in-tree
*\_SBo* package in place of a package without this tag, a warning
message with a default "no" option appears.

**-R\|\--norequirements**

Bypass dependency resolution, but still show *README* and the user
prompts before proceeding with the build.

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

**\--mass-rebuild**

Generate build queues, rebuild and reinstall all in-tree *\_SBo*
SlackBuilds except for *compat32* builds. This is generally only useful
when the Slackware version has been upgraded or (occasionally) on
-current. Additional SlackBuilds may be installed when dependencies have
been added. If dependencies are installed with tags other than *\_SBo*,
or with no tag, a warning message (default "no") appears even with
**\--nointeractive** before they are added to the build queue.

In combination with **\--nointeractive**, saved build options are reused
automatically. Incompatible with **\--reverse-rebuild**,
**\--compat32**, **\--use-template** and **\--norequirements**.

If the mass rebuild process is interrupted after downloading has been
completed, whether by signal or by build failure, a template named
*resume.temp* is saved to **SBO_HOME**. If this file is present, the
mass rebuild restarts from the script after the script that failed when
**\--mass-rebuild** is used again.

## VARIABLES

Beyond the options contained in *README* files, certain variables are
relevant to nearly all SlackBuilds, and can be used when running
**sboinstall**.

**ARCH**

**ARCH** passes a CPU architecture to the build process, and is mostly
used to build **i?86** packages on **x86_64** machines and **compat32**
packages. **sboinstall** attempts to pass the correct architecture
automatically for such builds based on the contents of the SlackBuild.
This process is not necessarily bug-free; please do not hesitate to
report **compat32** issues.

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
[sboremove(1)](sboremove.1.md), [sboupgrade(1)](sboupgrade.1.md), [sbotools.conf(5)](sbotools.conf.5.md), [sbotools.hints(5)](sbotools.hints.5.md)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
