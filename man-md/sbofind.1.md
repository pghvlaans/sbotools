# sbofind

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

**sbofind** - search the local copy of the **SlackBuilds.org** tree for
a given name or names

## SYNOPSIS

    sbofind [-h|-v]

    sbofind [-AERTetiqr] search_term (search_term)

## DESCRIPTION

**sbofind** searches the names of all available SlackBuilds for one or
more search terms. It reports back any SlackBuilds found along with path
and version information. This is equivalent to running

    cd /usr/ports; make search name=$search_term display=name,path

on a FreeBSD system. If the repository includes a *TAGS.txt* file, these
tags are searched to generate additional results.

Non-root users can call **sbofind** with any flags. **sbofind** issues a
warning if the directory specified with **LOCAL_OVERRIDES** does not
exist (see [sboconfig(1)](sboconfig.1.md) or [sbotools.conf(5)](sbotools.conf.5.md)). If an invalid
configuration is detected in */etc/sbotools/sbotools.conf*, the script
exits with a diagnostic message.

## OPTIONS

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

**-A\|\--all-reverse**

Show all reverse dependencies in the repository for each SlackBuild
found.

**-E\|\--exact-case**

Exact matching only (case-sensitive).

**-e\|\--exact**

Exact matching only (case-insensitive).

**-t\|\--no-tags**

Exclude tags from the search.

**-i\|\--info**

Show the contents of the *info* file for each SlackBuild found.

**-q\|\--queue**

Show the build queue for each SlackBuild found given the contents of
*/etc/sbotools/sbotools.hints*.

**-R\|\--reverse**

Show any reverse dependencies installed on the system. Please note that
optional dependencies must be specified in [sbotools.hints(5)](sbotools.hints.5.md) to be
included. Packages with tags other than *\_SBo* are not included.

**-r\|\--readme**

Show the contents of the *README* file for each SlackBuild found.

**-T\|\--top-reverse**

Show the top-level reverse dependencies, installed or not, for one or
more scripts.

## EXIT CODES

**sbofind** can exit with the following codes:

0: all operations were succesful.\
1: a usage error occured (e.g., incorrect options were passed to
**sbofind** ).\
2: a script or module error occurred.\
6: **sbofind** was unable to obtain a required file handle.\
13: circular dependencies detected.\
16: reading keyboard input failed.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools/> are always welcome.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboclean(1)](sboclean.1.md), [sboconfig(1)](sboconfig.1.md), [sbohints(1)](sbohints.1.md), [sboinstall(1)](sboinstall.1.md),
[sboremove(1)](sboremove.1.md), [sboupgrade(1)](sboupgrade.1.md), [sbotools.conf(5)](sbotools.conf.5.md), [sbotools.hints(5)](sbotools.hints.5.md)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
