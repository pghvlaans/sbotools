#!/usr/bin/env perl

use 5.16.0;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Capture::Tiny qw/ capture_merged /;
use FindBin '$RealBin';
use lib $RealBin;
use Test::Sbotools qw/ make_slackbuilds_txt sbopcheck sbopclean sbopconfig sbopfind sbopinstall sbopremove sbopsnap sbopupgrade /;

plan tests => 14;

make_slackbuilds_txt();

# 1-8: test -h output of sbo* scripts

## sbopcheck
sbopcheck '-h', { expected => <<'SBOCHECK' };
Usage: sbopcheck

Options:
  -h|--help:
    this screen.
  -v|--version:
    version information.

SBOCHECK

## sbopclean
sbopclean '-h', { expected => <<'SBOCLEAN' };
Usage: sbopclean (options) [package]

Options:
  -h|--help:
    this screen.
  -v|--version:
    version information.
  -d|--dist:
    clean distfiles.
  -w|--work:
    clean working directories.
  -i|--interactive:
    be interactive.

SBOCLEAN

## sbopconfig
my $sbopconfig = <<'SBOCONFIG';
Usage: sbopconfig [options] [arguments]

Options:
  -h|--help:
    this screen.
  -v|--version:
    version information.
  -l|--list:
    show current options.

Config options (defaults shown):
  -c|--clean FALSE:
      NOCLEAN: if TRUE, do NOT clean up after building by default.
  -d|--distclean FALSE:
      DISTCLEAN: if TRUE, DO clean distfiles by default after building.
  -j|--jobs FALSE:
      JOBS: numeric -j setting to feed to make for multicore systems.
  -p|--pkg-dir FALSE:
      PKG_DIR: set a directory to store packages in.
  -s|--sbo-home /usr/sbo:
      SBO_HOME: set the SBo directory.
  -o|--local-overrides FALSE:
      LOCAL_OVERRIDES: a directory containing local overrides.
  -V|--slackware-version FALSE:
      SLACKWARE_VERSION: use the SBo repository for this version.
  -r|--repo FALSE:
      REPO: use a repository other than SBo.

SBOCONFIG
sbopconfig '-h', { expected => $sbopconfig };
sbopconfig { expected => $sbopconfig };

## sbopfind
my $sbopfind = <<'SBOFIND';
Usage: sbopfind (search_term)

Options:
  -h|--help:
    this screen.
  -v|--verison:
    version information.
  -e|--exact:
    only exact matching.
  -t|--no-tags:
    exclude tags from search.
  -i|--info:
    show the .info for each found item.
  -r|--readme:
    show the README for each found item.
  -q|--queue:
    show the build queue for each found item.

Example:
  sbopfind libsexy

SBOFIND
sbopfind '-h', { expected => $sbopfind };
sbopfind { expected => $sbopfind, exit => 1 };

## sbopinstall
my $sbopinstall = <<'SBOINSTALL';
Usage: sbopinstall [options] sbo
       sbopinstall --use-template file

Options (defaults shown first where applicable):
  -h|--help:
    this screen.
  -v|--version:
    version information.
  -c|--noclean (FALSE|TRUE):
    set whether or not to clean working files/directories after the build.
  -d|--distclean (TRUE|FALSE):
   set whether or not to clean distfiles afterward.
  -i|--noinstall:
    do not run installpkg at the end of the build process.
  -j|--jobs (FALSE|#):
    specify "-j" setting to make, for multicore systems; overrides conf file.
  -p|--compat32:
    install an SBo as a -compat32 pkg on a multilib x86_64 system.
  -r|--nointeractive:
    non-interactive; skips README and all prompts.
  -R|--norequirements:
    view the README but do not parse requirements, commands, or options.
  --reinstall:
    Ask to reinstall any already-installed packages in the requirement list.
  --create-template (FILE):
    create a template with specified requirements, commands, and options.
  --use-template (FILE):
    use a template created by --create-template to install requirements with
    specified commands and options. This also enables the --nointeractive flag.

SBOINSTALL
sbopinstall '-h', { expected => $sbopinstall };
sbopinstall { expected => $sbopinstall, exit => 1 };

## sbopremove
my $sbopremove = <<'SBOREMOVE';
Usage: sbopremove [options] sbo

Options (defaults shown first where applicable):
  -h|--help:
    this screen.
  -v|--version:
    version information.
  -a|--alwaysask:
    always ask to remove, even if required by other packages on system.

Note: optional dependencies need to be removed separately.

SBOREMOVE
sbopremove '-h', { expected => $sbopremove };
sbopremove { expected => $sbopremove, exit => 1 };

## sbopsnap
my $sbopsnap = <<'SBOSNAP';
Usage: sbopsnap [options|command]

Options:
  -h|--help:
    this screen.
  -v|--version:
    version information.

Commands:
  fetch: initialize a local copy of the slackbuilds.org tree.
  update: update an existing local copy of the slackbuilds.org tree.
          (generally, you may prefer "sbopcheck" over "sbopsnap update")

SBOSNAP
sbopsnap '-h', { expected => $sbopsnap };
sbopsnap { expected => $sbopsnap, exit => 1 };

## sbopupgrade
my $sbopupgrade = <<'SBOUPGRADE';
Usage: sbopupgrade (options) [package]

Options (defaults shown first where applicable):
  -h|--help:
    this screen.
  -v|--version:
    version information.
  -c|--noclean (FALSE|TRUE):
    set whether or not to clean working directories after building.
  -d|--distclean (TRUE|FALSE):
    set whether or not to clean distfiles afterward.
  -f|--force:
    force an update, even if the "upgrade" version is the same or lower.
  -i|--noinstall:
    do not run installpkg at the end of the build process.
  -j|--jobs (FALSE|#):
    specify "-j" setting to make, for multicore systems; overrides conf file.
  -r|--nointeractive:
    non-interactive; skips README and all prompts.
  -z|--force-reqs:
    when used with -f, will force rebuilding an SBo's requirements as well.
  --all
    this flag will upgrade everything reported by sbopcheck(1).

SBOUPGRADE
sbopupgrade '-h', { expected => $sbopupgrade };
sbopupgrade { expected => $sbopupgrade, exit => 1 };

