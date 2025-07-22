# sbotools.colors

[NAME](#name)\
[DESCRIPTION](#description)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[MAINTAINER](#maintainer)

------------------------------------------------------------------------

## NAME

**sbotools.colors** - customize output colors for **sbotools**

## DESCRIPTION

The */etc/sbotools/sbotools.colors* file allows for customizing
**sbotools** output colors. To enable **sbotools** color output, set
**COLOR** to **TRUE**; see [sbotools.conf(5)](sbotools.conf.5.md) or [sboconfig(1)](sboconfig.1.md) for
details. Three color categories are available. **color_notice** is
**cyan** by default, and covers neutral prompts and selected
notifications. **color_lesser** is default **bold**, and is for lesser
warnings. **color_warn** marks errors and potentially serious warnings,
and defaults to **red bold**.

Color specifications follow a *KEY=VALUE* pattern; spaces are allowed,
quotation marks are optional and commented lines are ignored. If a color
is specified more than once, the last valid specification applies.

All colors must be specified with valid ANSI designations. For more
information, see the **Function Interface** section of
**Term::ANSIColor(3)**. If a color category has an invalid
specification, it uses the default color instead. Examples of valid
specifications include **yellow reverse** and **bright_black**.
**rRRRgGGGbBBB** specifications are also possible for true color output.
Please note that not all terminal emulators can handle all
specifications listed in **Term::ANSIColor(3)**.

To disable coloration for any color category, set it to **reset**.

To use a configuration directory other than */etc/sbotools*, export an
environment variable **SBOTOOLS_CONF_DIR** with an absolute path.

## SEE ALSO

[sbocheck(1)](sbocheck.1.md), [sboclean(1)](sboclean.1.md), [sboconfig(1)](sboconfig.1.md), [sbofind(1)](sbofind.1.md), [sbohints(1)](sbohints.1.md),
[sboinstall(1)](sboinstall.1.md), [sboremove(1)](sboremove.1.md), [sboupgrade(1)](sboupgrade.1.md), [sbotools.conf(5)](sbotools.conf.5.md),
[sbotools.hints(5)](sbotools.hints.5.md), Term::ANSIColor(3)

## AUTHORS

Jacob Pipkin \<j (at) dawnrazor (dot) net\>

Luke Williams \<xocel (at) iquidus (dot) org\>

Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot) com\>

## MAINTAINER

K. Eugene Carlson \<kvngncrlsn (at) gmail (dot) com\>

------------------------------------------------------------------------
