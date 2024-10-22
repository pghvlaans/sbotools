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
	plan tests => 22;
} else {
	plan skip_all => 'Only run these tests if TEST_INSTALL=1';
}
$ENV{TEST_ONLINE} //= 0;

sub cleanup {
	capture_merged {
		system(qw!/sbin/removepkg nonexistentslackbuild!);
		system(qw!/sbin/removepkg nonexistentslackbuild4!);
		system(qw!/sbin/removepkg nonexistentslackbuild5!);
		system(qw!/sbin/removepkg nonexistentslackbuild6!);
		unlink "$RealBin/LO/nonexistentslackbuild/perf.dummy";
		unlink "$RealBin/LO/nonexistentslackbuild4/perf.dummy";
		unlink "$RealBin/LO/nonexistentslackbuild5/perf.dummy";
		unlink "$RealBin/LO/nonexistentslackbuild6/perf.dummy";
		system(qw!rm -rf /tmp/SBo/nonexistentslackbuild-1.0!);
		system(qw!rm -rf /tmp/SBo/nonexistentslackbuild4-1.0!);
		system(qw!rm -rf /tmp/SBo/nonexistentslackbuild5-1.0!);
		system(qw!rm -rf /tmp/SBo/nonexistentslackbuild6-1.0!);
		system(qw!rm -rf /tmp/package-nonexistentslackbuild!);
		system(qw!rm -rf /tmp/package-nonexistentslackbuild4!);
		system(qw!rm -rf /tmp/package-nonexistentslackbuild5!);
		system(qw!rm -rf /tmp/package-nonexistentslackbuild6!);
	};
}

cleanup();
make_slackbuilds_txt();
set_lo("$RealBin/LO");
system("mv /usr/sbo/repo/* /usr/sbo");
restore_perf_dummy();

# 1-3: sbopinstall nonexistentslackbuild
sbopinstall 'nonexistentslackbuild', { input => "y\ny", expected => qr/nonexistentslackbuild added to install queue.*Install queue: nonexistentslackbuild/s };
ok (! -e "$RealBin/LO/nonexistentslackbuild/perf.dummy", "Source symlink removed");
ok (-e "/usr/sbo/repo/SLACKBUILDS.TXT", "SLACKBUILDS.TXT has been migrated back to its proper place");
sbopremove 'nonexistentslackbuild', { input => "y\ny", test => 0 };

# 4: sbopinstall nonexistentslackbuild2
sbopinstall 'nonexistentslackbuild2', { exit => 0, expected => "Unable to locate nonexistentslackbuild3 in the SlackBuilds.org tree.\nDo you want to ignore it and continue? [n] ", input => "n" };

# 5: sbopinstall nonexistentslackbuild3
sbopinstall 'nonexistentslackbuild3', { exit => 1, expected => "Unable to locate nonexistentslackbuild3 in the SlackBuilds.org tree.\n" };

# 6: sbopinstall nonexistentslackbuild4
sbopinstall 'nonexistentslackbuild4', { input => "y\ny\ny",
	expected => qr/nonexistentslackbuild5 added to install queue.*nonexistentslackbuild4 added to install queue.*Install queue: nonexistentslackbuild5 nonexistentslackbuild4/s };
sbopremove 'nonexistentslackbuild5', { input => "y\ny", test => 0 };

# 7: sbopinstall nonexistentslackbuild5
sbopinstall 'nonexistentslackbuild5', { input => "y\ny", expected => qr/nonexistentslackbuild5 added to install queue.*Install queue: nonexistentslackbuild5/s };
sbopremove 'nonexistentslackbuild4', { input => "y\ny\ny", test => 0 };

# 8: sbopinstall nonexistentslackbuild4
sbopinstall 'nonexistentslackbuild4', { input => "y\ny\ny",
	expected => qr/nonexistentslackbuild5 added to install queue.*nonexistentslackbuild4 added to install queue.*Install queue: nonexistentslackbuild5 nonexistentslackbuild4/s };
sbopremove 'nonexistentslackbuild5', { input => "y\ny", test => 0 };

# 9: sbopinstall nonexistentslackbuild4
sbopinstall 'nonexistentslackbuild4', { input => "y\ny", expected => qr/nonexistentslackbuild5 added to install queue.*Install queue: nonexistentslackbuild5/s };
sbopremove 'nonexistentslackbuild4', 'nonexistentslackbuild5', { input => "y\ny\ny", test => 0 };

# 10: sbopinstall nonexistentslackbuild6
sbopinstall 'nonexistentslackbuild6', { input => "y\ny", expected => qr/aaa_base \(aaa_base-[^)]+\) is already installed.*nonexistentslackbuild6 added to install queue.*Install queue: nonexistentslackbuild6/s };

# 11-12: sbopinstall -i nonexistentslackbuild
sbopinstall qw/ -i nonexistentslackbuild /, { input => "y\ny", expected => qr/nonexistentslackbuild added to install queue/ };
ok(!-e "/var/log/packages/nonexistentslackbuild-1.0-noarch-1_SBo", "nonexistentslackbuild wasn't installed with -i");

# 13-14: sbopinstall nonexistentslackbuild
sbopinstall 'nonexistentslackbuild', { input => "y\nn", expected => qr/nonexistentslackbuild added to install queue/ };
ok(!-e "/var/log/packages/nonexistentslackbuild-1.0-noarch-1_SBo", "nonexistentslackbuild wasn't installed when saying no");

# 15: sbopinstall nonexistentslackbuild
sbopinstall 'nonexistentslackbuild', { input => "n", expected => sub { not /nonexistentslackbuild added to install queue/ } };

# 16: sbopinstall nonexistentslackbuild4
sbopinstall qw/ -R nonexistentslackbuild4 /, { input => "y\ny", expected => sub { not /nonexistentslackbuild5 added to install queue/ } };
sbopremove 'nonexistentslackbuild4', { input => "y\ny\n", test => 0 };

# 17: sbopinstall perl-Capture-Tiny
sbopinstall 'perl-Capture-Tiny', { expected => "perl-Capture-Tiny installed via the cpan.\n" };

# 18: sbopinstall perl-nonexistentcpan
sbopinstall 'perl-nonexistentcpan', { input => "n", expected => qr/Proceed with perl-nonexistentcpan/ };

# 19: check node status of slackbuild script
{
	my $sbo = "$RealBin/LO/nonexistentslackbuild/nonexistentslackbuild.SlackBuild";
	my $inode = (stat($sbo))[1];
	sbopinstall 'nonexistentslackbuild', { input => "y\ny", test => 0 };
	is((stat($sbo))[1], $inode, "inode didn't change");
}

# 20: check correct exit for compat32 on fake 32bit
{
	local $ENV{PATH} = "$RealBin/bin:$ENV{PATH}";

	sbopinstall '-p', 'foo', { expected => "compat32 only works on x86_64.\n", exit => 1 };
}

# 21-22: check --reinstall option
sbopinstall '--reinstall', 'nonexistentslackbuild', { input => "n", expected => qr/\Qnonexistentslackbuild (nonexistentslackbuild-1.0-noarch-1_SBo) is already installed. Do you want to reinstall from SBo? [n]\E/ };
sbopinstall '--reinstall', 'nonexistentslackbuild', { input => "y\ny\ny", expected => qr/nonexistentslackbuild .* is already installed[.] Do you want to reinstall.*Install queue: nonexistentslackbuild/s };

# Cleanup
END {
	cleanup();
}
