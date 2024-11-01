# sbosnap {#sbosnap align="center"}

[NAME](#NAME)\
[SYNOPSIS](#SYNOPSIS)\
[DESCRIPTION](#DESCRIPTION)\
[OPTIONS](#OPTIONS)\
[COMMANDS](#COMMANDS)\
[EXIT CODES](#EXIT%20CODES)\
[BUGS](#BUGS)\
[SEE ALSO](#SEE%20ALSO)\
[AUTHORS](#AUTHORS)\
[MAINTAINER](#MAINTAINER)\

------------------------------------------------------------------------

## NAME []{#NAME}

**sbosnap** - **slackbuilds.org** tree fetch and update command

## SYNOPSIS []{#SYNOPSIS}

sbosnap \[-h\|-v\]

sbosnap (fetch\|update)

## DESCRIPTION []{#DESCRIPTION}

**sbosnap** is used to download and update a local copy of the
**slackbuilds.org** tree, without the `*.tar.gz{,.asc}` files. Note that
**sbocheck(1)** also updates the tree and checks for updated and removed
SlackBuilds. **rsync** is used for rsync repositories, and **git** is
used for git repositories. **sbotools3** defaults to git unless
**RSYNC_DEFAULT** is **TRUE**. See **sboconfig(1)** or
**sbotools.conf(5)**.

## OPTIONS []{#OPTIONS}

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

## COMMANDS []{#COMMANDS}

**fetch**

Download a local copy of the *slackbuilds.org* tree. The copy will be
downloaded to the path in the **SBO_HOME** setting (see **sboconfig(1)**
and sbotools.conf(5)), `/usr/sbo` by default.

**update**

Update a previously fetched copy of the **slackbuilds.org** tree.

## EXIT CODES []{#EXIT CODES}

**sbosnap** can exit with the following codes:

0: all operations completed successfully.\
1: a usage error occurred, such as running sbosnap with no command.\
5: error downloading from the repository.

## BUGS []{#BUGS}

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools3/> are always welcome.

## SEE ALSO []{#SEE ALSO}

sbocheck(1), sboclean(1), sboconfig(1), sbofind(1), sboinstall(1),
sboremove(1), sboupgrade(1), sbotools.conf(5)

## AUTHORS []{#AUTHORS}

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER []{#MAINTAINER}

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
