# sboupgrade

[NAME](#name)\
[SYNOPSIS](#synopsis)\
[DESCRIPTION](#description)\
[OPTIONS](#options)\
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
               [-b TRUE|FALSE] [-fiprz] --all|sbo_name (sbo_name)

## DESCRIPTION

**sboupgrade** is used to upgrade SlackBuilds. If the **-r** flag is not
specified, **sboupgrade** will pull the list of requirements from the
.info file for any specified SlackBuild. This is a recursive operation
over all dependencies. **sboinstall** will offer to install any
non-installed dependencies in the build queue. This program will not
handle circular dependencies.

`README` files are parsed for **groupadd** and **useradd** commands, and
**sboinstall** will offer to run them prior to building. If the `README`
is judged to document options in *KEY=VALUE* form, a prompt for setting
options will appear. Any build options, whether passed interactively or
in a template, will be saved to `/var/log/sbotools` when the SlackBuild
runs.

**sboupgrade** will attempt to download the sources from the `DOWNLOAD`
or `DOWNLOAD_x86_64` variables in the `info` file. If either the
download or the md5sum check fails, a new download will be attempted
from <ftp://slackware.uk/sbosrcarch/> as a fallback measure. The
**\--all** flag may be passed to upgrade all eligible SlackBuilds
simultaneously.

## OPTIONS

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

**-b\|\--build-ignore (FALSE\|TRUE)**

If **TRUE**, do not perform upgrades unless the version number differs.
By default, upgrades also occur when the build number differs. This
setting and **\--force** are not the same; **\--force** will initiate
upgrades even if the build number is unchanged. This overrides the
**BUILD_IGNORE** setting in [sbotools.conf(5)](sbotools.conf.5.md).

**-c\|\--noclean (FALSE\|TRUE)**

If **TRUE**, do not clean working directories after building. These are
the build and *package-(sbo)* directories under `/tmp/SBo` (or `$TMP`).
Cleaning these directories can be set as default via the
[sboconfig(1)](sboconfig.1.md) command. See also [sbotools.conf(5)](sbotools.conf.5.md). This option
overrides the default.

**-d\|\--distclean (FALSE\|TRUE)**

If **TRUE**, then remove the source archives after building. They are
retained in `SBO_HOME/distfiles` by default. This option can be set as
default via the [sboconfig(1)](sboconfig.1.md) command. See also [sbotools.conf(5)](sbotools.conf.5.md).
This option overrides the default.

**-f\|\--force**

Force an upgrade, even if the installed version and build number are
equal to the **slackbuilds.org** version.

**-i\|\--noinstall**

Do not install the package at the end of the build process. It will be
left in `/tmp` (or `$OUTPUT`), or in **PKG_DIR** if so defined. See
[sboconfig(1)](sboconfig.1.md) and [sbotools.conf(5)](sbotools.conf.5.md).

**-j\|\--jobs (FALSE\|#)**

If numerical, pass to the **-j** argument when a SlackBuild invoking
**make** is run.

**-p\|\--compat32**

Create a -compat32 package on multilib x86_64 systems. This requires the
**compat32-tools** package by Eric Hameleers. Please note that this
operation is not necessarily foolproof, and is unsupported by anyone in
principle. As a best practice, **\--compat32** should be combined with
**\--noinstall** so that the contents of the package can be inspected
prior to installation. Ensure that the running shell has already sourced
`/etc/profile.d/32dev.{c,}sh` before running, and that the **DISTCLEAN**
option is set to **FALSE.** GitHub Issues are welcome in case of
unexpected failure.

**-r\|\--nointeractive**

Bypass all user prompts and all dependency resolution for the requested
SlackBuilds. Unless it is obvious that dependency resolution and build
options are not required, consider using a template instead.

**-z\|\--force-reqs**

In combination with **\--force**, rebuild dependencies that do not
require upgrades as well.

**\--all**

Upgrade all installed SlackBuilds that are eligible for upgrades. This
takes the **BUILD_IGNORE** setting into account. See [sboconfig(1)](sboconfig.1.md)
and [sbotools.conf(5)](sbotools.conf.5.md).

## EXIT CODES

**sboupgrade** can exit with the following codes:

0: all operations were succesful.\
1: a usage error occured, such as specifying invalid options.\
3: a SlackBuild exited non-zero.\
4: unable to md5sum verify the source file(s).\
5: unable to download the source file(s).\
6: unable to obtain a required file handle.\
7: unable to get required info from the .info file.\
8: unable to unset the exec-on-close bit on a temporary file.\
9: multilib has not been set up (where required).\
10: **convertpkg-compat32** exited non-zero.\
11: the **convertpkg-compat32** script cannot be found (where required).

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools3/> are always welcome.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboclean(1)](sboclean.1.md), [sboconfig(1)](sboconfig.1.md), [sbofind(1)](sbofind.1.md), [sboinstall(1)](sboinstall.1.md),
[sboremove(1)](sboremove.1.md), [sbosnap(1)](sbosnap.1.md), [sbotools.conf(5)](sbotools.conf.5.md)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
