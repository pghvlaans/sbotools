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

**sbofind** - search the local copy of the **slackbuilds.org** tree for
a given name

## SYNOPSIS

    sbofind [-h|-v]

    sbofind [-etiRrq] search_term

## DESCRIPTION

**sbofind** searches the names of all available SlackBuilds for a given
term. It reports back any SlackBuilds found along with path and version
information. This is equivalent to running

    cd /usr/ports; make search name=$search_term display=name,path

on a FreeBSD system. If the repository includes a *TAGS.txt* file, that
will be used to find additional results.

## OPTIONS

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

**-e\|\--exact**

Exact matching only.

**-t\|\--no-tags**

Exclude tags from the search.

**-i\|\--info**

Show the contents of the *info* file for each SlackBuild found.

**-r\|\--readme**

Show the contents of the *README* file for each SlackBuild found.

**-R\|\--reverse**

Show any reverse dependencies installed on the system. Please note that
this does not include optional dependencies or packages with tags other
than *\_SBo*.

**-q\|\--queue**

Show the build queue for each SlackBuild found.

## EXIT CODES

**sbofind** can exit with the following codes:

0: all operations were succesful.\
1: a usage error occured (i.e. **sbofind** ran with nothing to find)\
6: **sbofind** was unable to obtain a required file handle.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools3/> are always welcome.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboclean(1)](sboclean.1.md), [sboconfig(1)](sboconfig.1.md), [sboinstall(1)](sboinstall.1.md), [sboremove(1)](sboremove.1.md),
[sbosnap(1)](sbosnap.1.md), [sboupgrade(1)](sboupgrade.1.md), [sbotools.conf(5)](sbotools.conf.5.md)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
