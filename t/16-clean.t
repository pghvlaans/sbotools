#!/usr/bin/env perl

use 5.16.0;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Capture::Tiny qw/ capture_merged /;
use FindBin '$RealBin';
use lib $RealBin;
use Test::Sbotools qw/ make_slackbuilds_txt set_pkg_dir set_distclean set_noclean set_lo sbopinstall sbopclean sbopremove restore_perf_dummy set_sbo_home sbopupgrade /;
use SBO::Lib;
use File::Temp 'tempdir';

if ($ENV{TEST_INSTALL}) {
	plan tests => 17;
} else {
	plan skip_all => 'Only run these tests if TEST_INSTALL=1';
}

my $sboname = "nonexistentslackbuild";
my $perf    = "/usr/sbo/distfiles/perf.dummy";
sub cleanup {
	capture_merged {
		system('removepkg', $sboname);
		system(qw! rm -rf !, "/tmp/SBo/$sboname-1.0", "/tmp/SBo/$sboname-1.1");
	}
}

make_slackbuilds_txt();
set_lo("$RealBin/LO");
set_pkg_dir("FALSE");
delete $ENV{TMP};
delete $ENV{OUTPUT};
cleanup();
restore_perf_dummy();

# 1: check that build dir doesn't get cleaned
set_noclean("TRUE");
sbopinstall '-r', $sboname, { test => 0 };
ok (-e "/tmp/SBo/$sboname-1.0", "$sboname-1.0 exists when NOCLEAN set to true.");
cleanup();

# 2: check that build dir gets cleaned
set_noclean("FALSE");
sbopinstall '-r', $sboname, { test => 0 };
ok (!-e "/tmp/SBo/$sboname-1.0", "$sboname-1.0 is cleaned when NOCLEAN set to false.");
cleanup();

# 3-4: check that sbopclean cleans working dir
set_noclean("TRUE");
sbopinstall '-r', $sboname, { test => 0 };
ok (-e "/tmp/SBo/$sboname-1.0", "$sboname-1.0 exists before cleaning.");
sbopclean '-w', { test => 0 };
ok (!-e "/tmp/SBo/$sboname-1.0", "$sboname-1.0 was properly cleaned.");
cleanup();

# 5-6: check that sbopclean cleans distfiles dir
ok (-e $perf, "perf.dummy exists before cleaning distfiles.");
sbopclean '-d', { test => 0 };
ok (!-e $perf, "perf.dummy deleted after cleaning distfiles.");
restore_perf_dummy();

# 7-8: check that distclean setting cleans too
set_distclean("TRUE");
ok (-e $perf, "perf.dummy exists before sbopinstall with distclean true.");
sbopinstall '-r', $sboname, { test => 0 };
ok (!-e $perf, "perf.dummy cleaned after install with distclean.");
restore_perf_dummy();
cleanup();

# 9-10: check that distclean parameter cleans too
set_distclean("FALSE");
ok (-e $perf, "perf.dummy exists before sbopinstall with -d.");
sbopinstall '-r', '-d', 'TRUE', $sboname, { test => 0 };
ok (!-e $perf, "perf.dummy cleaned after install with -d.");
restore_perf_dummy();
cleanup();

# 11: check that sbopclean errors properly without arguments
sbopclean { exit => 1, expected => "You must specify at least one of -d or -w.\n" };

# 12: sbopclean -d with SBOHOME set
set_sbo_home(tempdir(CLEANUP => 1));
sbopclean '-d', { exit => 0, expected => "Nothing to do.\n" };

# 13-15: sbopclean -w [-i] with TMP set
{
	local $ENV{TMP} = tempdir(CLEANUP => 1);
	sbopclean qw/ -w -i /, { input => "n", expected => qr!\QRemove $ENV{TMP}/\E.*\Q? [n]\E! };
	sbopclean qw/ -w -i /, { input => "y\ny", expected => qr!\QRemove $ENV{TMP}/\E.*\Q? [n]\E! };
	sbopclean '-w', { input => "y", expected => qr/This will remove the entire contents of \Q$ENV{TMP}\E/ };
}

# 16: sbopupgrade -c TRUE
set_sbo_home("/usr/sbo");
sbopinstall qw/ -r nonexistentslackbuild /, { test => 0 };
set_lo "$RealBin/LO2";
sbopupgrade qw/ -c TRUE nonexistentslackbuild /, { input => "y\ny", test => 0 };
ok (-e "/tmp/SBo/$sboname-1.1", "$sboname-1.1 exists when NOCLEAN set to true in sbopupgrade.");
cleanup();

# 17: sbopupgrade -d TRUE
set_lo "$RealBin/LO";
sbopinstall qw/ -r nonexistentslackbuild /, { test => 0 };
set_lo "$RealBin/LO2";
sbopupgrade qw/ -d TRUE nonexistentslackbuild /, { input => "y\ny", test => 0 };
ok (!-e $perf, "perf.dummy cleaned after upgrade with -d.");
restore_perf_dummy();
cleanup();
