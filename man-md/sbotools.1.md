# sbotools

[NAME](#name)\
[DESCRIPTION](#description)\
[BUGS](#bugs)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[MAINTAINER](#maintainer)

------------------------------------------------------------------------

## NAME

**sbotools** - Perl scripts providing a ports-like interface to
**slackbuilds.org**

## DESCRIPTION

**sbotools** is a set of Perl scripts that collectively provide a
ports-like interface to **slackbuilds.org**. Each tool is documented in
its own man page.

[sbocheck(1)](sbocheck.1.md)

Fetch the latest version of the upstream SlackBuilds repository. Check
for version updates, build number changes and out-of-tree installed
SlackBuilds with the *\_SBo* tag.

[sboclean(1)](sboclean.1.md)

Remove cruft by cleaning source archives, build directories and saved
build options.

[sboconfig(1)](sboconfig.1.md)

A command line interface for changing */etc/sbotools/sbotools.conf*.

[sbofind(1)](sbofind.1.md)

Search the local copy of the repository for SlackBuilds. Optionally,
display build queues, *README* and *info* files and installed reverse
dependencies.

[sboinstall(1)](sboinstall.1.md)

Install SlackBuilds with their dependencies. Handle compat32 packages
and create or build from templates.

[sboremove(1)](sboremove.1.md)

Interactively remove installed SlackBuilds along with any unused
dependencies.

[sbosnap(1)](sbosnap.1.md)

Fetch or update the upstream SlackBuilds repository with **fetch** and
**update**.

[sboupgrade(1)](sboupgrade.1.md)

Upgrade previously-installed SlackBuilds.

For details about all configuration options in *sbotools.conf*, see
[sbotools.conf(5)](sbotools.conf.5.md).

## BUGS

None known. If found, Issues and Pull Requests to
<https://github.com/pghvlaans/sbotools/> are always welcome.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboclean(1)](sboclean.1.md), [sboconfig(1)](sboconfig.1.md), [sbofind(1)](sbofind.1.md), [sboinstall(1)](sboinstall.1.md),
[sboremove(1)](sboremove.1.md), [sbosnap(1)](sbosnap.1.md), [sboupgrade(1)](sboupgrade.1.md), [sbotools.conf(5)](sbotools.conf.5.md)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
