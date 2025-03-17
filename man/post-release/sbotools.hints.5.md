# sbotools.hints

[NAME](#name)\
[DESCRIPTION](#description)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[MAINTAINER](#maintainer)

------------------------------------------------------------------------

## NAME

**sbotools.hints** - blacklist, reverse dependency rebuild and optional
dependency requests for **sbotools**

## DESCRIPTION

The */etc/sbotools/sbotools.hints* file is used to blacklist scripts,
request optional dependencies and request automatic reverse dependency
rebuilds. Please note that all requests apply equally to the *compat32*
versions of the scripts; specific requests for *compat32* scripts are
unsupported.

If a script is blacklisted, it can neither be included in build queues
nor removed by [sboremove(1)](sboremove.1.md). To blacklist a script, place it on its
own line with no whitespace, prepending an exclamation mark:

    !javacc 

Blacklist entries supersede optional dependency requests.

To ask [sboupgrade(1)](sboupgrade.1.md) to rebuild a script's reverse dependencies upon
upgrade or reinstall, place the name of the script on its own line with
no whitespace, prepending a tilde:

    ~libmodplug 

Many scripts on **SlackBuilds.org** have optional dependencies. To make
**sbotools** recognize one or more optional dependencies for a script,
make a space-delineated list of optional dependencies and place the name
of the script at the end:

    libcacard spice libiscsi qemu

Commented lines are ignored. There should not be whitespace to the left
of any entry.

[sbohints(1)](sbohints.1.md) can also be used to interface with this file.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboclean(1)](sboclean.1.md), [sboconfig(1)](sboconfig.1.md), [sbofind(1)](sbofind.1.md), [sbohints(1)](sbohints.1.md),
[sboinstall(1)](sboinstall.1.md), [sboremove(1)](sboremove.1.md), [sboupgrade(1)](sboupgrade.1.md), [sbotools.conf(5)](sbotools.conf.5.md)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
