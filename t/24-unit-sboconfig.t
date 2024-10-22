#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::Exit;
use FindBin '$RealBin';
use lib $RealBin;
use Test::Sbotools qw/ load /;
use Capture::Tiny qw/ capture_merged /;
use File::Temp 'tempdir';
use Cwd;

plan tests => 2;

# 1-2: sbopconfig unit tests...
{
	load('sbopconfig');

	my $exit;
	my $out = capture_merged { $exit = exit_code { main::config_write(); }; };

	is ($out, "A fatal script error has occurred:\nconfig_write requires at least two arguments.\nExiting.\n", "sbopconfig's config_write() gave correct output");
	is ($exit, 2, "sbopconfig's config_write() gave correct exit status");
}
