# sbosnap

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

**sbosnap** - **slackbuilds.org** tree fetch and update command

## SYNOPSIS

    sbosnap [-h|-v]

    sbosnap (fetch|update)

## DESCRIPTION

**sbosnap** is used to download and update a local copy of the
**slackbuilds.org** tree, without the **.tar.gz{,.asc}* files. Note that
[sbocheck(1)](sbocheck.1.md) also updates the tree and checks for updated and removed
SlackBuilds. **rsync** is used for rsync repositories, and **git** is
used for git repositories. **sbotools3** defaults to git unless
**RSYNC_DEFAULT** is **TRUE**. See [sboconfig(1)](sboconfig.1.md) or
[sbotools.conf(5)](sbotools.conf.5.md).

## OPTIONS

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

## COMMANDS

**fetch**

Download a local copy of the **slackbuilds.org** tree. The copy will be
downloaded to the path in the **SBO_HOME** setting (see [sboconfig(1)](sboconfig.1.md)
and [sbotools.conf(5)](sbotools.conf.5.md)), */usr/sbo* by default.

**update**

Update a previously fetched copy of the **slackbuilds.org** tree.

## EXIT CODES

**sbosnap** can exit with the following codes:

0: all operations completed successfully.\
1: a usage error occurred, such as running sbosnap with no command.\
5: error downloading from the repository.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools3/> are always welcome.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboclean(1)](sboclean.1.md), [sboconfig(1)](sboconfig.1.md), [sbofind(1)](sbofind.1.md), [sboinstall(1)](sboinstall.1.md),
[sboremove(1)](sboremove.1.md), [sboupgrade(1)](sboupgrade.1.md), [sbotools.conf(5)](sbotools.conf.5.md)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
