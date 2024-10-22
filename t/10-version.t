#!/usr/bin/env perl

use 5.16.0;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Capture::Tiny qw/ capture_merged /;
use FindBin '$RealBin';
use lib $RealBin;
use lib "$RealBin/../SBO-Lib/lib";
use Test::Sbotools qw/ make_slackbuilds_txt sbopcheck sbopclean sbopconfig sbopfind sbopinstall sbopremove sbopsnap sbopupgrade /;
use SBO::Lib;

plan tests => 8;

make_slackbuilds_txt();

my $version = $SBO::Lib::VERSION;
my $ver_text = <<"VERSION";
sbotools version $version
licensed under the WTFPL
<http://sam.zoy.org/wtfpl/COPYING>
VERSION

# 1-8: test -v output of sbo* scripts
sbopcheck '-v', { expected => $ver_text };
sbopclean '-v', { expected => $ver_text };
sbopconfig '-v', { expected => $ver_text };
sbopfind '-v', { expected => $ver_text };
sbopinstall '-v', { expected => $ver_text };
sbopremove '-v', { expected => $ver_text };
sbopsnap '-v', { expected => $ver_text };
sbopupgrade '-v', { expected => $ver_text };

