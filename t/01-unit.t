#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::Exit;
use FindBin '$RealBin';
use lib "$RealBin/../SBO-Lib/lib";
use SBO::Lib qw/ %config check_multilib get_installed_packages get_local_outdated_versions get_readme_contents get_sbo_location get_sbo_locations indent open_fh script_error usage_error user_prompt /;
use Capture::Tiny qw/ capture_merged /;
use File::Temp 'tempdir';
use Cwd;

plan tests => 61;

# 1-2: test script_error();
{
	my $exit;
	my $out = capture_merged { $exit = exit_code { script_error(); }; };

	is ($exit, 2, 'script_error() exited with 2');
	is ($out, "A fatal script error has occurred. Exiting.\n", 'script_error() gave correct output');
}

# 3-4: test usage_error();
{
	my $exit;
	my $out = capture_merged { $exit = exit_code { usage_error('whatever'); }; };

	is ($exit, 1, 'usage_error() exited with 1');
	is ($out, "whatever\n", 'usage_error() gave correct output');
}

# 5-8: test open_fh();
{
	my $exit;
	my $out = capture_merged { $exit = exit_code { open_fh($0); }; };

	is ($exit, 2, 'open_fh() exited with 2');
	is ($out, "A fatal script error has occurred:\nopen_fh requires two arguments\nExiting.\n", 'open_fh() gave correct output');

	SKIP: {
		skip 'Tests invalid if ./foo/bar exists.', 2 if -e "$RealBin/foo/bar";
		my ($warn, $status) = open_fh("$RealBin/foo/bar/baz", '>');

		like ($warn, qr!Unable to open .*/foo/bar/baz\.\n!, 'open_fh() gave correct return value (1)');
		is ($status, 6, 'open_fh() gave correct return value (2)');
	}
}

# 9-13: test get_slack_version();
SKIP: {
	skip 'Tests invalid if /etc/slackware-version exists.', 5 if -e '/etc/slackware-version';

	local $config{SLACKWARE_VERSION} = 'FALSE';

	my $exit;
	my $out = capture_merged { $exit = exit_code{ SBO::Lib::get_slack_version(); }; };

	is ($exit, 2, 'get_slack_version() exited with 2');
	is ($out, "A fatal script error has occurred:\nopen_fh, /etc/slackware-version is not a file\nExiting.\n", 'get_slack_version() gave correct output');

	my ($fh) = open_fh('/etc/slackware-version', '>');
	print $fh "Slackware 0.0\n";
	close $fh;

	undef $exit;
	$out = capture_merged { $exit = exit_code{ SBO::Lib::get_slack_version(); }; };

	is ($exit, 1, 'get_slack_version() exited with 1');
	is ($out, "Unsupported Slackware version: 0.0\nSuggest you set the sbotools REPO setting to https://github.com/Ponce/slackbuilds.git\n\n", 'get_slack_version() gave correct output (Unsupported)');

	($fh) = open_fh('/etc/slackware-version', '>');
	print $fh "Slackware 14.1\n";
	close $fh;

	is (SBO::Lib::get_slack_version(), '14.1', 'get_slack_version() returned the correct version');

	unlink '/etc/slackware-version';
}

# 14-15: test indent();
is(indent(0, 'foo'), 'foo', 'indent(0,...) returns correctly');
is(indent(1, "foo\n\nbar"), " foo\n\n bar", 'indent(1,...) returns correctly');

# 16-20: test check_repo() and migrate_repo();
SKIP: {
	skip 'Test invalid if no SLACKBUILDS.TXT exists.', 5 if ! -e '/usr/sbo/repo/SLACKBUILDS.TXT';

	system(qw"cp /usr/sbo/repo/SLACKBUILDS.TXT /usr/sbo");
	system(qw"rm -rf", "$RealBin/repo.backup");
	system(qw"mv /usr/sbo/repo", "$RealBin/repo.backup");

	is (SBO::Lib::check_repo(), 1, 'check_repo() returned 1 when /usr/sbo/repo was empty');

	SBO::Lib::migrate_repo();
	ok (-e '/usr/sbo/repo/SLACKBUILDS.TXT', '/usr/sbo/repo/SLACKBUILDS.TXT moved back by migrate_repo()');

	system("mv /usr/sbo/repo/* /usr/sbo");
	system(qw! rmdir /usr/sbo/repo !);

	SBO::Lib::migrate_repo();
	ok (-d '/usr/sbo/repo', '/usr/sbo/repo correctly recreated by migrate_repo()');

	system(qw"rm /usr/sbo/repo/SLACKBUILDS.TXT");
	system(qw! rmdir /usr/sbo/repo !);

	system('touch', '/usr/sbo/repo');
	my $exit;
	my $out = capture_merged { $exit = exit_code { SBO::Lib::check_repo(); }; };

	is ($out, "Unable to create /usr/sbo/repo.\n\n", 'check_repo() output is good');
	is ($exit, 1, 'check-repo() exit code is good');

	system('rm', '/usr/sbo/repo');
	system("mv", "$RealBin/repo.backup", "/usr/sbo/repo");
}

# 21-25: test check_repo();
SKIP: {
	skip 'Test invalid if no SLACKBUILDS.TXT exists.', 5 if ! -e '/usr/sbo/repo/SLACKBUILDS.TXT';

	my $exit;
	my $out = capture_merged { $exit = exit_code { SBO::Lib::check_repo(); }; };

	is ($exit, 1, 'check_repo() exited with 1');
	is ($out, "/usr/sbo/repo exists and is not empty. Exiting.\n\n", 'check_repo() gave correct output');

	system(qq'rm -rf "$RealBin/repo.backup"');
	system(qq'mv /usr/sbo/repo "$RealBin/repo.backup"');
	system(qq'mkdir /usr/sbo/repo');

	undef $exit;
	my $res;
	$out = capture_merged { $exit = exit_code { $res = SBO::Lib::check_repo(); }; };

	is ($exit, undef, "check_repo() didn't exit");
	is ($out, '', "check_repo() didn't print anything");
	is ($res, 1, "check_repo() returned correctly");

	system(qq'rmdir /usr/sbo/repo');
	system(qq'mv "$RealBin/repo.backup" /usr/sbo/repo');
}

# 26-27: test rsync_sbo_tree();
SKIP: {
	skip 'Test invalid if /foo-bar exists.', 2 if -e '/foo-bar';

	local $config{SLACKWARE_VERSION} = '14.1';

	my $res;
	my $out = capture_merged { $res = SBO::Lib::rsync_sbo_tree('/foo-bar'); };

	ok (!$res, q"rsync_sbo_tree('/foo-bar') returned false");
	like ($out, qr!rsync: change_dir "/foo-bar" failed!, q"rsync_sbo_tree('/foo-bar') gave correct output");
}

# 28-37: test git_sbo_tree(), check_git_remote(), generate_slackbuilds_txt(), and pull_sbo_tree();
{
	system(qw! mv /usr/sbo/repo /usr/sbo/backup !) if -d '/usr/sbo/repo';
	system(qw! mkdir -p /usr/sbo/repo/.git !);

	my $res;
	capture_merged { $res = SBO::Lib::git_sbo_tree(''); };
	is ($res, 0, q!git_sbo_tree('') returned 0!);

	system(qw! rm -r /usr/sbo/repo !) if -d '/usr/sbo/repo';
	system(qw! mkdir -p /usr/sbo/repo/.git !);
	my ($fh) = open_fh('/usr/sbo/repo/.git/config', '>');
	print $fh qq'[remote "origin"]\n'; print $fh "foo=bar\n"; print $fh "url=\n";
	close $fh;

	undef $res;
	capture_merged { $res = SBO::Lib::git_sbo_tree(''); };
	is ($res, 0, q!git_sbo_tree('') with .git/config returned 0 !);
	undef $res;
	capture_merged { $res = SBO::Lib::git_sbo_tree('foo'); };
	is ($res, 0, q!git_sbo_tree('foo') returned 0!);

	system(qw! rm -r /usr/sbo/repo !) if -d '/usr/sbo/repo';
	system(qw! mkdir -p /usr/sbo/repo/.git !);
	($fh) = open_fh('/usr/sbo/repo/.git/config', '>');
	print $fh qq'[remote "origin"]\n'; print $fh "[]";
	close $fh;

	undef $res;
	capture_merged { $res = SBO::Lib::check_git_remote('/usr/sbo/repo', 'foo'); };
	is ($res, 0, 'check_git_remote() returned 0');

	system(qw! rm -r /usr/sbo/repo !) if -d '/usr/sbo/repo';

	is (SBO::Lib::generate_slackbuilds_txt(), 0, 'generate_slackbuilds_txt() returned 0');

	system(qw! mkdir -p /usr/sbo/repo/foo/bar !);

	is (SBO::Lib::generate_slackbuilds_txt(), 1, 'generate_slackbuilds_txt() returned 1');

	system(qw! rm -r /usr/sbo/repo !) if -d '/usr/sbo/repo';
	system(qw! mv /usr/sbo/backup /usr/sbo/repo !) if -d '/usr/sbo/backup';

	my $sbohome = '/usr/sbo';
	system('mv', $sbohome, "$sbohome.bak");

	my $cwd = getcwd();
	undef $res;
	my $out = capture_merged { $res = SBO::Lib::git_sbo_tree(''); };

	is ($out, '', 'git_sbo_tree() no output');
	is ($res, 0, 'git_sbo_tree() returned 0');
	is (getcwd(), $cwd, 'git_sbo_tree() left us where we started');

	system('mv', "$sbohome.bak", $sbohome);
}

# 37: test get_installed_packages();
{
	system(qw!mv /var/log/packages /var/log/packages.backup!);
	system(qw!mkdir -p /var/log/packages!);
	system(qw!touch /var/log/packages/sbotoolstestingfile!);
	is (@{ get_installed_packages('SBO') }, 0, 'get_installed_packages() returned an empty arrayref');
	system(qw!rm -r /var/log/packages!);
	system(qw!mv /var/log/packages.backup /var/log/packages!);
}

# 38-40: test get_sbo_location() and get_sbo_locations();
{
	my $exit;
	my $out = capture_merged { $exit = exit_code { get_sbo_location([]); }; };

	is ($exit, 2, 'get_sbo_location([]) exited with 2');
	is ($out, "A fatal script error has occurred:\nget_sbo_location requires an argument.\nExiting.\n", 'get_sbo_location([]) gave correct output');

	SKIP: {
		skip 'Test invalid if no SLACKBUILDS.TXT exists.', 1 if ! -e '/usr/sbo/repo/SLACKBUILDS.TXT';
		local $config{LOCAL_OVERRIDES} = 'FALSE';
		my %res = get_sbo_locations('nonexistentslackbuild');

		is (%res+0, 0, q"get_sbo_locations('nonexistentslackbuild') returned an empty hash");
	}
}

# 41: test get_local_outdated_versions();
{
	local $config{LOCAL_OVERRIDES} = 'FALSE';
	is(scalar get_local_outdated_versions(), 0, 'get_local_outdated_versions() returned an empty list');
}

# 42: test get_filename_from_link();
{
	is (SBO::Lib::get_filename_from_link('/'), undef, "get_filename_from_link() returned undef");
}

# 43-46: test revert_slackbuild();
{
	my $tmp = tempdir(CLEANUP => 1);
	is (SBO::Lib::revert_slackbuild("$tmp/foo"), 1, "revert_slackbuild() returned 1");

	system('touch', "$tmp/foo.orig");
	is (SBO::Lib::revert_slackbuild("$tmp/foo"), 1, "revert_slackbuild() returned 1");
	ok (-f "$tmp/foo", 'foo.orig renamed to foo');
	ok (!-f "$tmp/foo.orig", 'foo.orig is no more');
}

# 47: test get_src_dir();
SKIP: {
    skip 'Test invalid if /foo-bar exists.', 1 if -e '/foo-bar';
	my $scalar = '';
	open(my $fh, '<', \$scalar) or skip "Could not open needed filehandle", 1;

	local $SBO::Lib::Build::tmpd = "/foo-bar";
	is (scalar @{ SBO::Lib::get_src_dir($fh) }, 0, "get_src_dir() returned an empty array ref");
}

# 48: test get_readme_contents();
{
	my @ret = get_readme_contents(undef);
	is ($ret[0], undef, "get_readme_contents() returned undef");
}

# 49-50: test user_prompt();
{
	my $exit;
	my $out = capture_merged { $exit = exit_code { user_prompt('foo', undef); }; };

	is ($exit, 1, 'user_prompt() exited with 1');
	is ($out, "Unable to locate foo in the SlackBuilds.org tree.\n", 'user_prompt() gave correct output');
}

# 51-53: test perform_sbo();
SKIP: {
	skip 'Tests invalid if /foo exists.', 3 if -e "/foo";

	my @res = SBO::Lib::perform_sbo(JOBS => 'FALSE', LOCATION => '/foo', ARCH => 1);

	is ($res[0], "Unable to backup /foo/foo.SlackBuild to /foo/foo.SlackBuild.orig\n", 'perform_sbo returned correct pkg');
	is ($res[1], undef, 'perform_sbo returned correct src');
	is ($res[2], 6, 'perform_sbo returned correct exit');
}

# 54-60: test version_cmp();
{
	chomp(my $kv = `uname -r`);
	$kv =~ s/-/_/g;

	my @res = map { SBO::Lib::version_cmp(@$_); } [ '1.0', '1.0' ], [ "1.0_$kv", '1.0' ], [ '1.0', "1.0_$kv" ], [ "1.0_$kv", "1.0_$kv" ];

	is ($res[0], 0, "version_cmp(1.0, 1.0) returned 0");
	is ($res[1], 0, "version_cmp(1.0_k, 1.0) returned 0");
	is ($res[2], 0, "version_cmp(1.0, 1.0_k) returned 0");
	is ($res[3], 0, "version_cmp(1.0_k, 1.0_k) returned 0");

	no warnings 'redefine';
	local *SBO::Lib::Util::get_kernel_version = sub { "foo_bar" };

	is (SBO::Lib::version_cmp('1.0', '1.0_foo_bar'), 0, "version_cmp(1.0, 1.0_foo_bar) returned 0");

  is (SBO::Lib::version_cmp('1.0_en_US', '1.0'), 0, "version_cmp(1.0_en_US, 1.0) returned 0");
  is (SBO::Lib::version_cmp('1.0', '1.0_en_US'), 0, "version_cmp(1.0, 1.0_en_US) returned 0");
}

# 61: test check_multilib();
{
	my $file = "/etc/profile.d/32dev.sh";

	my $moved = rename $file, "$file.orig";

	is (check_multilib(), undef, "check_multilib() returned undef when $file was missing");

	rename "$file.orig", $file if $moved;
}
