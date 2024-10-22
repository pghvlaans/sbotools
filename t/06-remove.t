#!/usr/bin/env perl

use 5.16.0;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Capture::Tiny qw/ capture_merged /;
use FindBin '$RealBin';
use lib $RealBin;
use Test::Sbotools qw/ make_slackbuilds_txt set_lo sbopinstall sbopremove restore_perf_dummy /;

if ($ENV{TEST_INSTALL}) {
	plan tests => 14;
} else {
	plan skip_all => 'Only run these tests if TEST_INSTALL=1';
}
$ENV{TEST_ONLINE} //= 0;

sub cleanup {
	capture_merged {
		system(qw!/sbin/removepkg nonexistentslackbuild!);
		system(qw!/sbin/removepkg nonexistentslackbuild4!);
		system(qw!/sbin/removepkg nonexistentslackbuild5!);
		system(qw!/sbin/removepkg nonexistentslackbuild7!);
		system(qw!/sbin/removepkg nonexistentslackbuild8!);
		unlink "$RealBin/LO/nonexistentslackbuild/perf.dummy";
		unlink "$RealBin/LO/nonexistentslackbuild4/perf.dummy";
		unlink "$RealBin/LO/nonexistentslackbuild5/perf.dummy";
		unlink "$RealBin/LO/nonexistentslackbuild7/perf.dummy";
		unlink "$RealBin/LO/nonexistentslackbuild8/perf.dummy";
		system(qw!rm -rf /tmp/SBo/nonexistentslackbuild-1.0!);
		system(qw!rm -rf /tmp/SBo/nonexistentslackbuild4-1.0!);
		system(qw!rm -rf /tmp/SBo/nonexistentslackbuild5-1.0!);
		system(qw!rm -rf /tmp/SBo/nonexistentslackbuild7-1.0!);
		system(qw!rm -rf /tmp/SBo/nonexistentslackbuild8-1.0!);
		system(qw!rm -rf /tmp/package-nonexistentslackbuild!);
		system(qw!rm -rf /tmp/package-nonexistentslackbuild4!);
		system(qw!rm -rf /tmp/package-nonexistentslackbuild5!);
		system(qw!rm -rf /tmp/package-nonexistentslackbuild7!);
		system(qw!rm -rf /tmp/package-nonexistentslackbuild8!);
	};
}

cleanup();
make_slackbuilds_txt();
set_lo("$RealBin/LO");
restore_perf_dummy();

# 1: sbopremove nonexistentslackbuild
sbopinstall 'nonexistentslackbuild', { input => "y\ny", test => 0 };
sbopremove 'nonexistentslackbuild', { input => "y\ny", expected => qr/Remove nonexistentslackbuild\b.*Removing 1 package\(s\)/s };

# 2: sbopremove nonexistentslackbuild5
sbopinstall 'nonexistentslackbuild4', { input => "y\ny\ny", test => 0 };
sbopremove 'nonexistentslackbuild5', { input => "y\ny", expected => qr/Remove nonexistentslackbuild5\b.*Removing 1 package\(s\)/s };

# 3: sbopremove nonexistentslackbuild4
sbopinstall 'nonexistentslackbuild5', { input => "y\ny", test => 0 };
sbopremove 'nonexistentslackbuild4', { input => "y\ny\ny", expected => qr/Remove nonexistentslackbuild4\b.*Remove nonexistentslackbuild5\b.*Removing 2 package\(s\)/s };

# 4: sbopremove nonexistentslackbuild4 nonexistentslackbuild5
sbopinstall 'nonexistentslackbuild4', { input => "y\ny\ny", test => 0 };
sbopremove qw/ nonexistentslackbuild4 nonexistentslackbuild5 /, { input => "y\ny\ny",
	expected => qr/Remove nonexistentslackbuild4\b.*Remove nonexistentslackbuild5\b.*Removing 2 package\(s\)/s };

# 5: sbopremove namethatdoesntexist slackbuildthatisntinstalld
sbopremove qw/ nonexistentslackbuildwhosenamedoesntexist nonexistentslackbuild /,
	{ exit => 1, expected => "Unable to locate nonexistentslackbuildwhosenamedoesntexist in the SlackBuilds.org tree.\nnonexistentslackbuild is not installed from SlackBuilds.org.\n" };

# 6-7: sbopremove nonexistentslackbuild [x2] and say no
sbopinstall 'nonexistentslackbuild', { input => "y\ny", test => 0 };
sbopremove qw/ nonexistentslackbuild nonexistentslackbuild /, { input => "y\nn", expected => qr/Remove nonexistentslackbuild\b.*want to continue.*Exiting/s };
sbopremove 'nonexistentslackbuild', { input => "n", expected => qr/Ignoring.*Nothing to remove/s };
sbopremove 'nonexistentslackbuild', { input => "y\ny", test => 0 };

# 8-12: sbopremove check that still needed sbos aren't removed
sbopinstall qw/ nonexistentslackbuild4 nonexistentslackbuild7 /, { input => "y\ny\ny\ny", test => 0 };
sbopremove 'nonexistentslackbuild4', { input => "y\nn", expected => sub { ! /nonexistentslackbuild5 / } };
TODO: {
	todo_skip 'sbopremove: not able to see if a dep needed by more than one installed thing is still needed', 1;
	sbopremove qw/ nonexistentslackbuild4 nonexistentslackbuild7 /, { input => "\n\n\n\n\n", expected => qr/nonexistentslackbuild5/ };
}
sbopremove qw/ nonexistentslackbuild4 nonexistentslackbuild5 /, { input => "y\ny\nn", expected => qr/nonexistentslackbuild4 nonexistentslackbuild5/ };
sbopremove qw/ -a nonexistentslackbuild4 /, { input => "y\nn\ny", expected => qr/nonexistentslackbuild5 : required by nonexistentslackbuild7/ };
sbopremove 'nonexistentslackbuild7', { input => "y\ny\ny", expected => qr/nonexistentslackbuild5/ };

# 13: sbopremove shows readme for %README% dep
sbopinstall 'nonexistentslackbuild8', { input => "y\ny", test => 0 };
sbopremove 'nonexistentslackbuild8', { input => "y\ny\ny", expected => qr/But has to be read/ };

# 14: sbopremove nointeractive
sbopinstall 'nonexistentslackbuild', { input => "y\ny", test => 0 };
sbopremove qw'--nointeractive nonexistentslackbuild nonexistentslackbuild', { input => "y\ny", expected => qr/Removing 1 package\(s\)\nnonexistentslackbuild\n.*All operations/s };

# Cleanup
END {
	cleanup();
}
