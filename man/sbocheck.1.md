# sbocheck {#sbocheck align="center"}

[NAME](#NAME)\
[SYNOPSIS](#SYNOPSIS)\
[DESCRIPTION](#DESCRIPTION)\
[OPTIONS](#OPTIONS)\
[BUGS](#BUGS)\
[SEE ALSO](#SEE%20ALSO)\
[AUTHORS](#AUTHORS)\
[MAINTAINER](#MAINTAINER)\

------------------------------------------------------------------------

## NAME

**sbocheck** - update a local **slackbuilds.org** tree and check for
updates.

## SYNOPSIS

sbocheck \[-h\|-v\]

## DESCRIPTION

**sbocheck** first updates a previously-fetched copy of the
**slackbuilds.org** tree (see **sbosnap(1)**) checks for available
upgrades, and reports what it finds. SlackBuilds with differing build
numbers are reported separately, as are any SlackBuilds marked `_SBo`
that are not found in the repository.

The three output categories are logged separately to
`/etc/sbocheck.log`, `/etc/sbocheck-bumps.log` and
`/etc/sbocheck-out-of-tree.log`.

## OPTIONS

**-h\|\--help**

Show help information.

**-v\|\--version**

Show version information.

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools3/> are always welcome.

## SEE ALSO

sboclean(1), sboconfig(1), sbofind(1), sboinstall(1), sboremove(1),
sbosnap(1), sboupgrade(1), sbotools.conf(5)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
