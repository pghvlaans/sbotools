# Lib

[NAME](#name)\
[SYNOPSIS](#synopsis)\
[DESCRIPTION](#description)\
[Build](#Build)\
[Download](#Download)\
[Info](#Info)\
[Pkgs](#Pkgs)\
[Readme](#Readme)\
[Repo](#Repo)\
[Tree](#Tree)\
[Util](#Util)\
[EXIT CODES](#exit-codes)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[LICENSE](#license)\

------------------------------------------------------------------------

## NAME

SBO::Lib − Library for working with SlackBuilds.org.

## SYNOPSIS

use SBO::Lib qw/ :all /;

## DESCRIPTION

SBO::Lib is the entry point for all the related modules, and simply
re-exports all exports. Each module is documented in its own man page.

### Build

\"Build.pm\" has routines for building Slackware packages from
SlackBuilds.org. It covers the build process from setting the queue
through post-build cleaning.

### Download

\"Download.pm\" downloads, verifies and symlinks any needed source files
before building the queue begins.

### Info

\"Info.pm\" sanitizes and parses \"info\" files; the information
returned is used in version comparions, dependency calculation and the
source downloading process.

### Pkgs

\"Pkgs.pm\" interacts with the Slackware package database to provide,
tag and version information for all installed packages.

### Readme

\"Readme.pm\" parses and displays \"README\" files. It detects options
and commands for adding users and groups. Pre-installation user prompts
and build option recall are handled here.

### Repo

\"Repo.pm\" is responsible for fetching, updating and linting the local
copy of the SlackBuilds.org repository, as well as GPG verification and
key addition.

### Tree

\"Tree.pm\" determines the location of scripts in the repository and
local overrides directory.

### Util

\"Util.pm\" contains utiliy functions for \"SBO::Lib\" and the sbotools.
Configuration-related shared variables and the shared exit codes can be
found here.

## EXIT CODES

The sbotools share the following exit codes:

\_ERR_USAGE 1 usage errors\
\_ERR_SCRIPT 2 script or module bug\
\_ERR_BUILD 3 errors when executing a SlackBuild\
\_ERR_MD5SUM 4 download verification failure\
\_ERR_DOWNLOAD 5 download failure\
\_ERR_OPENFH 6 failure to open file handles\
\_ERR_NOINFO 7 missing download information\
\_ERR_F_SETD 8 fd−related temporary file failure\
\_ERR_NOMULTILIB 9 lacking multilib capabilities when needed\
\_ERR_CONVERTPKG 10 convertpkg−compat32 failure\
\_ERR_NOCONVERTPKG 11 lacking convertpkg−compat32 when needed\
\_ERR_INST_SIGNAL 12 the script was interrupted while building\
\_ERR_CIRCULAR 13 attempted to calculate a circular dependency

## SEE ALSO

**Build**(3), **Download**(3),
**Info**(3), **Pkgs**(3), **Pkgs**(3),
**Readme**(3), **Repo**(3), **Tree**(3),
**Util**(3)

## AUTHORS

SBO::Lib was originally written by Jacob Pipkin \<j (at) dawnrazor (dot)
net\> with contributions from Luke Williams \<xocel (at) iquidus (dot)
org\> and Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot)
com\>.

SBO::Lib is maintained by K. Eugene Carlson \<kvngncrlsn (at) gmail
(dot) com\>.

## LICENSE

The sbotools are licensed under the MIT License.

Copyright (C) 2012−2017, Jacob Pipkin, Luke Williams, Andreas
Guldstrand.

Copyright (C) 2024−2025, K. Eugene Carlson.

------------------------------------------------------------------------
