#!/usr/bin/env perl

use 5.16.0;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Capture::Tiny qw/ capture_merged /;
use FindBin '$RealBin';
use lib $RealBin;
use Test::Sbotools qw/ sbopsnap set_repo set_sbo_home /;
use File::Temp 'tempdir';

plan tests => 4;

my $usage = <<'SBOSNAP';
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

# 1: sbopsnap errors without arguments
sbopsnap { exit => 1, expected => $usage };

# 2: sbopsnap invalid errors
sbopsnap 'invalid', { exit => 1, expected => $usage };

# 3: sbopsnap update when /usr/sbo/repo is empty
my $tmp = tempdir(CLEANUP => 1);
set_repo("file://$tmp");
capture_merged { system <<"END"; };
cd $tmp
git init
mkdir test
cp -a $RealBin/LO/nonexistentslackbuild test
git add test
git commit -m 'test'
END

sbopsnap 'update', { expected => qr/Pulling SlackBuilds tree[.][.][.]/ };

# 4-5: sbopsnap when SBO_HOME is set
my $tmphome = tempdir(CLEANUP => 1);
set_sbo_home($tmphome);

sbopsnap 'fetch', { test => 0, note => 1 };
note scalar `ls -R $tmphome`;
ok (-e "$tmphome/repo/test/nonexistentslackbuild/nonexistentslackbuild.info", 'SBo tree pulled to correct location');
