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
	plan tests => 11;
} else {
	plan skip_all => 'Only run these tests if TEST_INSTALL=1';
}

sub cleanup {
	capture_merged {
		system(qw!/sbin/removepkg envsettingtest!);
		system(qw!/sbin/removepkg envsettingtest2!);
		system(qw!/sbin/removepkg otherreadmes!);
		unlink "$RealBin/LO-readme/envsettingtest/perf.dummy";
		unlink "$RealBin/LO-readme/envsettingtest2/perf.dummy";
		unlink "$RealBin/LO-readme/otherreadmes/perf.dummy";
		system(qw!rm -rf /tmp/SBo/envsettingtest-1.0!);
		system(qw!rm -rf /tmp/SBo/envsettingtest2-1.0!);
		system(qw!rm -rf /tmp/SBo/otherreadmes-1.0!);
		system(qw!rm -rf /tmp/package-envsettingtest!);
		system(qw!rm -rf /tmp/package-envsettingtest2!);
		system(qw!rm -rf /tmp/package-otherreadmes!);
	};
}

cleanup();
make_slackbuilds_txt();
set_lo("$RealBin/LO-readme");
restore_perf_dummy();

# 1: sbopinstall envsettingtest - fail
sbopinstall 'envsettingtest', { input => "n\ny\ny", exit => 3, expected => qr{It looks like envsettingtest has options; would you like to set any when the slackbuild is run.*FOO isn't bar!.*envsettingtest: envsettingtest.SlackBuild return non-zero}s };

# 2: sbopinstall envsettingtest - fail 2
sbopinstall 'envsettingtest', { input => "y\nFOO=foo\ny\ny", exit => 3, expected => qr{Please supply any options here, or enter to skip:.*FOO isn't bar!.*envsettingtest: envsettingtest.SlackBuild return non-zero}s };

# 3: sbopinstall envsettingtest - success
sbopinstall 'envsettingtest', { input => "y\nFOO=bar\ny\ny", expected => qr{Please supply any options here, or enter to skip:.*Install queue: envsettingtest.*Cleaning for envsettingtest-1[.]0}s };
sbopremove 'envsettingtest', { input => "y\ny", test => 0 };

# 4: sbopinstall envsettingtest2 - fail prereq
sbopinstall 'envsettingtest2', { input => "n\ny\ny\nFOO=quux\ny\ny\nn", exit => 3, expected => qr{It looks like envsettingtest has options.*Proceed with envsettingtest.*It looks like envsettingtest2 has options.*Please supply any options here.*Install queue: envsettingtest envsettingtest2.*FOO isn't bar!.*envsettingtest: envsettingtest.SlackBuild return non-zero}s };

# 5: sbopinstall envsettingtest2 - success
sbopinstall 'envsettingtest2', { input => "y\nFOO=bar\ny\ny\nFOO=quux\ny\ny", expected => qr{It looks like envsettingtest has options.*Please supply any options here.*It looks like envsettingtest2 has options.*Please supply any options here.*Install queue: envsettingtest envsettingtest2.*Cleaning for envsettingtest2-1[.]0}s };
sbopremove 'envsettingtest2', { input => "n\ny\ny\ny", test => 0 };

# 6: sbopinstall envsettingtest - don't supply an option even if you say you intend to
sbopinstall 'envsettingtest', { input => "y\n\nn", expected => qr/Please supply any options here/ };

# 7-8: supply an erroneous option
sbopinstall 'envsettingtest', { input => "y\nFOO\nFOO=bar\nn", expected => qr/Invalid input received[.]/ };
sbopinstall 'envsettingtest', { input => "y\nFOO\n\nn", expected => qr/Invalid input received[.]/ };

# 9-10: sbopinstall commandinreadme
SKIP: {
	skip "Only run useradd/groupadd commands under Travis CI", 2 unless (defined $ENV{TRAVIS} and $ENV{TRAVIS} eq 'true');
	skip "Only run useradd/groupadd commands if there is no test user/group", 2, if (defined getgrnam('test') or defined getpwnam('test'));

	sbopinstall 'commandinreadme', { input => "y\ny\ny", expected => qr{It looks like this slackbuild requires the following command\(s\) to be run first:.*groupadd -g 199 test.*useradd -u 199 -g 199 -d /tmp test.*Shall I run them prior to building.*}s };
	sbopremove 'commandinreadme', { input => "y\ny", test => 0 };

	sbopinstall 'commandinreadme', { input => "y\ny\ny", expected => qr/groupadd.*exited non-zero/ };
	sbopremove 'commandinreadme', { input => "y\ny", test => 0 };
	capture_merged { system(qw/ userdel test /); system(qw/ groupdel test /); };
}

# 11: sbopinstall otherreadmes
sbopinstall 'otherreadmes', { input => "y\ny\ny", expected => qr/It looks like.*Would you like to see.*README.*SlackBuilds[.]org.*SLACKWARE/s };

# Cleanup
END {
	cleanup();
}
