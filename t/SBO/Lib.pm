#!/usr/bin/env perl
#
# vim: set ts=4:noet
#
# Lib.pm
# shared functions for the sbo_ scripts.
#
# author: Jacob Pipkin <j@dawnrazor.net>
# date: Setting Orange, the 37th day of Discord in the YOLD 3178
# license: WTFPL <http://sam.zoy.org/wtfpl/COPYING>

use 5.12.3;
use warnings FATAL => 'all';
use strict;

package SBO::Lib 0.7;
my $version = "0.7";

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(get_slack_version chk_slackbuilds_txt check_home rsync_sbo_tree get_sbo_from_loc get_sbo_version get_download_info get_arch get_sbo_downloads get_filename_from_link compute_md5sum compare_md5s verify_distfile get_distfile get_symlink_from_filename check_x32 check_multilib rewrite_slackbuild revert_slackbuild check_distfiles create_symlinks grok_temp_file get_src_dir get_pkg_name clear_coe_bit perform_sbo do_convertpkg
	script_error
	open_fh
	open_read
	show_version
	slackbuilds_or_fetch
	fetch_tree
	update_tree
	get_installed_sbos
	get_available_updates
	do_slackbuild
	make_clean
	make_distclean
	do_upgradepkg
	get_sbo_location
	get_from_info
	get_tmp_extfn
	get_tmp_perlfn
);

#$< == 0 or die "This script requires root privileges.\n";

use Tie::File;
use Sort::Versions;
use Digest::MD5;
use File::Copy;
use File::Path qw(make_path remove_tree);
use Fcntl;
use File::Find;
use File::Temp qw(tempdir tempfile);
use Fcntl qw(F_SETFD F_GETFD);

our $tempdir = tempdir (CLEANUP => 1);

# subroutine for throwing internal script errors
sub script_error (;$) {
	exists $_[0] ? die "A fatal script error has occurred:\n$_[0]\nExiting.\n"
				 : die "A fatal script error has occurred: Exiting.\n";
}

# sub for opening files, second arg is like '<','>', etc
sub open_fh {
	exists $_[1] or script_error ('open_fh requires two arguments');
	unless ($_[1] eq '>') {
		-f $_[0] or script_error 'open_fh first argument not a file';
	}
	my ($file, $op) = @_;
	open my $fh, $op, $file or die "Unable to open $file.\n";
	return $fh;
}

sub open_read ($) {
	return open_fh shift, '<';
}

# pull in configuration, set sane defaults, etc.
our $conf_dir = '/etc/sbotools';
our $conf_file = "$conf_dir/sbotools.conf";
our %config = (
	NOCLEAN => 'FALSE',
	DISTCLEAN => 'FALSE',
	JOBS => 'FALSE',
	PKG_DIR => 'FALSE',
	SBO_HOME => 'FALSE',
);

# if the conf file exists, pull all the $key=$value pairs into a hash
my %conf_values;
if (-f $conf_file) {
	my $fh = open_read ($conf_file);
	my $text = do {local $/; <$fh>};
	%conf_values = $text =~ /^(\w+)=(.*)$/mg;
	close $fh;
}

for my $key (keys %config) {
	$config{$key} = $conf_values{$key} if exists $conf_values{$key};
}
$config{JOBS} = 'FALSE' unless $config{JOBS} =~ /^\d+$/;
$config{SBO_HOME} = '/usr/sbo' if $config{SBO_HOME} eq 'FALSE';

# some stuff we'll need later.
my $distfiles = "$config{SBO_HOME}/distfiles";
my $slackbuilds_txt = "$config{SBO_HOME}/SLACKBUILDS.TXT";
my $name_regex = '\ASLACKBUILD\s+NAME:\s+';

sub show_version () {
	say "sbotools version $version";
	say "licensed under the WTFPL";
	say "<http://sam.zoy.org/wtfpl/COPYING>";
}

# %supported maps what's in /etc/slackware-version to what's at SBo
sub get_slack_version () {
	my %supported = (
		'13.37.0' => '13.37',
		'14.0' => '13.37',
	);
	my $fh = open_read '/etc/slackware-version';
	chomp (my $line = <$fh>);
	close $fh;
	my $version = ($line =~ /\s+(\d+[^\s]+)$/)[0];
	die "Unsupported Slackware version: $version\n"
		unless $version ~~ %supported;
	return $supported{$version};
}

# does the SLACKBUILDS.TXT file exist in the sbo tree?
sub chk_slackbuilds_txt () {
	return -f $slackbuilds_txt ? 1 : 0;
}

# check for the validity of new $config{SBO_HOME}
sub check_home () {
	my $sbo_home = $config{SBO_HOME};
	if (-d $sbo_home) {
		opendir (my $home_handle, $sbo_home);
		FIRST: while (readdir $home_handle) {
			next FIRST if /^\.[\.]{0,1}$/;
			die "$sbo_home exists and is not empty. Exiting.\n";
		}
	} else {
		make_path ($sbo_home) or die "Unable to create $sbo_home.\n"; 
	}
}

# rsync the sbo tree from slackbuilds.org to $config{SBO_HOME}
sub rsync_sbo_tree () {
	my $slk_version = get_slack_version;
	my @arg = ('rsync', '-a', '--exclude=*.tar.gz', '--exclude=*.tar.gz.asc');
	push @arg, "rsync://slackbuilds.org/slackbuilds/$slk_version/*";
	my $out = system @arg, $config{SBO_HOME};
	say "Finished." and return $out;
}

# wrappers for differing checks and output
sub fetch_tree () {
	check_home;
	say "Pulling SlackBuilds tree...";
	rsync_sbo_tree, return 1;
}

sub update_tree () {
	fetch_tree, return unless chk_slackbuilds_txt;
	say "Updating SlackBuilds tree...";
	rsync_sbo_tree, return 1;
}

# if the SLACKBUILDS.TXT is not in $config{SBO_HOME}, we assume the tree has
# not been populated there; prompt the user to automagickally pull the tree.
sub slackbuilds_or_fetch () {
	unless (chk_slackbuilds_txt) {
		say 'It looks like you haven\'t run "sbosnap fetch" yet.';
		print "Would you like me to do this now? [y] ";
		<STDIN> =~ /^[Yy\n]/ ? fetch_tree () :
			die "Please run \"sbosnap fetch\"\n";
	}
	return 1;
}

# pull an array of hashes, each hash containing the name and version of an sbo
# currently installed.
sub get_installed_sbos () {
	my @installed;
	# $1 == name, $2 == version
	my $regex = qr#/([^/]+)-([^-]+)-[^-]+-[^-]+$#;
	for my $path (</var/log/packages/*_SBo>) {
		my ($name, $version) = ($path =~ $regex)[0,1];
		push @installed, {name => $name, version => $version};
	}
	return \@installed;
}

# search the SLACKBUILDS.TXT for a given sbo's directory
sub get_sbo_location ($) {
	exists $_[0] or script_error 'get_sbo_location requires an argument.';
	my $sbo = shift;
	my $regex = qr#LOCATION:\s+\.(/[^/]+/$sbo)$#;
	my $fh = open_read $slackbuilds_txt;
	while (my $line = <$fh>) {
		if (my $loc = ($line =~ $regex)[0]) {
			return "$config{SBO_HOME}$loc";
		}
	}
	return;
}

# pull the sbo name from a $location: $config{SBO_HOME}/system/wine, etc.
sub get_sbo_from_loc ($) {
	exists $_[0] or script_error 'get_sbo_from_loc requires an argument.';
	return (shift =~ qr#/([^/]+)$#)[0];
}

# pull piece(s) of data, GET, from the $sbo.info file under LOCATION.
sub get_from_info (%) {
	my %args = (
		LOCATION	=> '',
		GET			=> '',
		@_
	);
	unless ($args{LOCATION} && $args{GET}) {
		script_error 'get_from_info requires LOCATION and GET.';
	}
	state $vars = {PRGNAM => ['']};
	my $sbo = get_sbo_from_loc $args{LOCATION};
	return $$vars{$args{GET}} if $$vars{PRGNAM}[0] eq $sbo;
	# if we're here, we haven't read in the .info file yet.
	my $fh = open_read "$args{LOCATION}/$sbo.info";
	# suck it all in, clean it all up, stuff it all in $vars.
	my $contents = do {local $/; <$fh>};
	$contents =~ s/("|\\\n)//g;
	$vars = {$contents =~ /^(\w+)=(.*)$/mg};
	# fill the hash with array refs - even for single values,
	# since consistency here is a lot easier than sorting it out later
	for my $key (keys %$vars) {
		if ($$vars{$key} =~ /\s/) {
			my @array = split ' ', $$vars{$key};
			$$vars{$key} = \@array;
		} else {
			$$vars{$key} = [$$vars{$key}];
		}
	}
	return exists $$vars{$args{GET}} ? $$vars{$args{GET}} : 0;
}

# find the version in the tree for a given sbo (provided a location)
sub get_sbo_version ($) {
	exists $_[0] or script_error 'get_sbo_version requires an arguments';
	my $version = get_from_info (LOCATION => shift, GET => 'VERSION');
	return $$version[0] ? $$version[0] : 0;
}

# for each installed sbo, find out whether or not the version in the tree is
# newer, and compile an array of hashes containing those which are
sub get_available_updates () {
	my @updates;
	my $pkg_list = get_installed_sbos; 
	FIRST: for my $key (keys @$pkg_list) {
		my $location = get_sbo_location $$pkg_list[$key]{name};
		# if we can't find a location, assume invalid and skip
		next FIRST unless defined $location;
		my $version = get_sbo_version $location;
		if (versioncmp ($version, $$pkg_list[$key]{version}) == 1) {
			push @updates, {
				name		=> $$pkg_list[$key]{name},
				installed	=> $$pkg_list[$key]{version},
				update		=> $version
			};
		}
	}
	return \@updates;
}

# get downloads and md5sums from an sbo's .info file, first 
# checking for x86_64-specific info if we are told to
sub get_download_info (%) {
	my %args = (
		LOCATION 	=> 0,
		X64 		=> 1,
		@_
	);
	$args{LOCATION} or script_error 'get_download_info requires LOCATION.';
	my ($get, $downs, $md5s, %return);
	$get = ($args{X64} ? 'DOWNLOAD_x86_64' : 'DOWNLOAD');
	$downs = get_from_info (LOCATION => $args{LOCATION}, GET => $get);
	# did we get nothing back, or UNSUPPORTED/UNTESTED?
	if ($args{X64}) {
		my $nothing;
		if (! $$downs[0]) {
			$nothing = 1;
		} elsif ($$downs[0] =~ qr/^UN(SUPPOR|TES)TED$/) {
			$nothing = 1;
		}
		if ($nothing) {
			$args{X64} = 0;
			$downs = get_from_info (LOCATION => $args{LOCATION},
				GET => 'DOWNLOAD');
		}
	}
	# if we still don't have any links, something is really wrong.
	return unless $$downs[0];
	# grab the md5s and build a hash
	$get = $args{X64} ? 'MD5SUM_x86_64' : 'MD5SUM';
	$md5s = get_from_info (LOCATION => $args{LOCATION}, GET => $get);
	return unless $$md5s[0];
	$return{$$downs[$_]} = $$md5s[$_] for (keys @$downs);
	return %return;
}

sub get_arch () {
	chomp (my $arch = `uname -m`);
	return $arch;
}

# TODO: should probably combine this with get_download_info
sub get_sbo_downloads (%) {
	my %args = (
		LOCATION	=> '',
		32			=> 0,
		@_
	);
	$args{LOCATION} or script_error 'get_sbo_downloads requires LOCATION.';
	my $location = $args{LOCATION};
	-d $location or script_error 'get_sbo_downloads given a non-directory.';
	my $arch = get_arch; 
	my %dl_info;
	if ($arch eq 'x86_64') {
		%dl_info = get_download_info (LOCATION => $location) unless $args{32};
	} 
	unless (keys %dl_info > 0) {
		%dl_info = get_download_info (LOCATION => $location, X64 => 0);
	}
	return %dl_info;
}

# given a link, grab the filename from the end of it
sub get_filename_from_link ($) {
	exists $_[0] or script_error 'get_filename_from_link requires an argument';
	return "$distfiles/". (shift =~ qr#/([^/]+)$#)[0];
}

# for a given file, computer its md5sum
sub compute_md5sum ($) {
	-f $_[0] or script_error 'compute_md5sum requires a file argument.';
	my $fh = open_read shift;
	my $md5 = Digest::MD5->new;
	$md5->addfile ($fh);
	my $md5sum = $md5->hexdigest;
	close $fh;
	return $md5sum;
}

sub compare_md5s ($$) {
	exists $_[1] or script_error 'compare_md5s requires two arguments.';
	my ($first, $second) = @_;
	return $first eq $second ? 1 : 0;
}

# for a given distfile, see whether or not it exists, and if so, if its md5sum
# matches the sbo's .info file
sub verify_distfile ($$) {
	exists $_[1] or script_error 'check_distfile requires two arguments.';
	my ($link, $info_md5sum) = @_;
	my $filename = get_filename_from_link $link;
	return unless -d $distfiles;
	return unless -f $filename;
	my $md5sum = compute_md5sum $filename;
	return compare_md5s $info_md5sum, $md5sum;
}

# for a given distfile, attempt to retrieve it and, if successful, check its
# md5sum against that in the sbo's .info file
sub get_distfile ($$) {
	exists $_[1] or script_error 'get_distfile requires an argument';
	my ($link, $exp_md5) = @_;
	my $filename = get_filename_from_link $link;
	mkdir $distfiles unless -d $distfiles;
	chdir $distfiles;
	system ("wget --no-check-certificate $link") == 0 or
		die "Unable to wget $link\n";
	my $md5sum = compute_md5sum $filename;
	# can't do anything if the link in the .info doesn't lead to a good d/l
	compare_md5s $md5sum, $exp_md5 or die "md5sum failure for $filename.\n";
	return 1;
}

# for a given distfile, what will be the full path of the symlink?
sub get_symlink_from_filename ($$) {
	exists $_[1] or script_error
		'get_symlink_from_filename requires two arguments';
	-f $_[0] or script_error
		'get_symlink_from_filename first argument is not a file';
	my ($filename, $location) = @_;
	return "$location/". ($filename =~ qr#/([^/]+)$#)[0];
}

# determine whether or not a given sbo is 32-bit only
sub check_x32 ($) {
	exists $_[0] or script_error 'check_x32 requires an argument.';
	my $dl = get_from_info (LOCATION => shift, GET => 'DOWNLOAD_x86_64');
	return $$dl[0] =~ /UN(SUPPOR|TES)TED/ ? 1 : 0;
}

# can't do 32-bit on x86_64 without this file, so we'll use it as the test to
# to determine whether or not an x86_64 system is setup for multilib
sub check_multilib {
	return 1 if -f '/etc/profile.d/32dev.sh';
	return;
}

# make a backup of the existent SlackBuild, and rewrite the original as needed
sub rewrite_slackbuild ($$%) {
	exists $_[1] or script_error 'rewrite_slackbuild requires two arguments.';
	my ($slackbuild, $tempfn, %changes) = @_;
	copy ($slackbuild, "$slackbuild.orig") or
		die "Unable to backup $slackbuild to $slackbuild.orig\n";
	my $tar_regex = qr/(un|)tar .*$/;
	my $makepkg_regex = qr/makepkg/;
	my $libdir_regex = qr/^\s*LIBDIRSUFFIX="64"\s*$/;
	my $make_regex = qr/^\s*make(| \Q||\E exit 1)$/;
	my $arch_regex = qr/\$VERSION-\$ARCH-\$BUILD/;
	# tie the slackbuilds, because this is the easiest way to handle this.
	tie my @sb_file, 'Tie::File', $slackbuild;
	for my $line (@sb_file) {
		# get the output of the tar and makepkg commands. hope like hell that v
		# is specified among tar's arguments
		if ($line =~ $tar_regex || $line =~ $makepkg_regex) {
			$line = "$line | tee -a $tempfn";
		}
		# then check for and apply any %changes
		if (exists $changes{libdirsuffix}) {
			$line =~ s/64/$changes{libdirsuffix}/ if $line =~ $libdir_regex;
		}
		if (exists $changes{make}) {
			$line =~ s/make/make $changes{make}/ if $line =~ $make_regex;
		}
		if (exists $changes{arch_out}) {
			$line =~ s/\$ARCH/$changes{arch_out}/ if $line =~ $arch_regex;
		}
	}
	untie @sb_file;
	return 1;
}

# move a backed-up .SlackBuild file back into place
sub revert_slackbuild ($) {
	exists $_[0] or script_error 'revert_slackbuild requires an argument';
	my $slackbuild = shift;
	if (-f "$slackbuild.orig") {
		unlink $slackbuild if -f $slackbuild;
		rename "$slackbuild.orig", $slackbuild;
	}
	return 1;
}

# for each $download, see if we have it, and if the copy we have is good,
# otherwise download a new copy
sub check_distfiles (%) {
	exists $_[0] or script_error 'check_distfiles requires an argument.';
	my %dists = @_;
	for my $link (keys %dists) {
		my $md5sum = $dists{$link};
		unless (verify_distfile $link, $md5sum) {
			die unless get_distfile $link, $md5sum;
		}
	}
	return 1;
}

# given a location and a list of download links, assemble a list of symlinks,
# and create them.
sub create_symlinks ($%) {
	exists $_[1] or script_error 'create_symlinks requires two arguments.';
	my ($location, %downloads) = @_;
	my @symlinks;
	for my $link (keys %downloads) {
		my $filename = get_filename_from_link $link;
		my $symlink = get_symlink_from_filename $filename, $location;
		push @symlinks, $symlink;
		symlink $filename, $symlink;
	}
	return @symlinks;
}

# pull the untarred source directory or created package name from the temp
# file (the one we tee'd to)
sub grok_temp_file (%) {
	my %args = (
		FH		=> '',
		REGEX	=> '',
		CAPTURE	=> 0,
		@_
	);
	unless ($args{FH} && $args{REGEX}) {
		script_error 'grok_temp_file requires two arguments';
	}
	my $fh = $args{FH};
	seek $fh, 0, 0;
	my $out;
	FIRST: while (my $line = <$fh>) {
		if ($line =~ $args{REGEX}) {
			$out = ($line =~ $args{REGEX})[$args{CAPTURE}];
			last FIRST;
		}
	}
	return $out;
}

# wrappers around grok_temp_file
sub get_src_dir ($) {
	exists $_[0] or script_error 'get_src_dir requires an argument';
	return grok_temp_file (FH => shift, REGEX => qr#^([^/]+)/#);
}

sub get_pkg_name ($) {
	exists $_[0] or script_error 'get_pkg_name requires an argument';
	return grok_temp_file (FH => shift, 
		REGEX => qr/^Slackware\s+package\s+([^\s]+)\s+created\.$/);
}

# clear the close-on-exec bit from a temp file handle
sub clear_coe_bit ($) {
	exists $_[0] or script_error 'clear_coe_bit requires an argument';
	my $fh = shift;
	fcntl ($fh, F_SETFD, 0) or die "no unset exec-close thingy\n";
	return $fh;
}

# return a filename from a temp fh for use externally
sub get_tmp_extfn ($) {
	exists $_[0] or script_error 'get_tmp_extfn requires an argument.';
	my $fh = clear_coe_bit shift;
	return '/dev/fd/'. fileno $fh;
}

# return a filename from a temp fh for use internally
sub get_tmp_perlfn ($) {
	exists $_[0] or script_error 'get_tmp_perlfn requires an argument.';
	my $fh = clear_coe_bit shift;
	return '+<=&'. fileno $fh;
}

# prep and run .SlackBuild
sub perform_sbo (%) {
	my %args = (
		OPTS		=> 0, 
		JOBS		=> 0,
		LOCATION	=> '',
		ARCH		=> '',
		C32			=> 0,
		X32			=> 0,
		@_
	);
	unless ($args{LOCATION} && $args{ARCH}) {
		script_error 'perform_sbo requires LOCATION and ARCH.';
	}
	my $location = $args{LOCATION};
	my $sbo = get_sbo_from_loc $location;
	my ($cmd, %changes);
	# figure out any changes we need to make to the .SlackBuild
	$changes{make} = "-j $args{JOBS}" if $args{JOBS};
	if ($args{ARCH} eq 'x86_64' and ($args{C32} || $args{X32})) {
		if ($args{C32}) {
			$changes{libdirsuffix} = '';
		} elsif ($args{X32}) {
			$changes{arch_out} = 'i486';
		}
		$cmd = ". /etc/profile.d/32dev.sh &&";
	}
	$cmd .= "/bin/sh $location/$sbo.SlackBuild";
	$cmd = "$args{OPTS} $cmd" if $args{OPTS};
	my $tempfh = tempfile (DIR => $tempdir);
	my $fn = get_tmp_extfn $tempfh;
	rewrite_slackbuild "$location/$sbo.SlackBuild", $fn, %changes;
	chdir $location, my $out = system $cmd;
	revert_slackbuild "$location/$sbo.SlackBuild";
	die unless $out == 0;
	my $pkg = get_pkg_name $tempfh;
	my $src = get_src_dir $tempfh;
	return $pkg, $src;
}

# run convertpkg on a package to turn it into a -compat32 thing
sub do_convertpkg ($) {
	exists $_[0] or script_error 'do_convertpkg requires an argument.';
	my $pkg = shift;
	my $tempfh = tempfile (DIR => $tempdir);
	my $fn = get_tmp_extfn $tempfh;
	my $cmd = "/usr/sbin/convertpkg-compat32 -i $pkg -d /tmp | tee $fn";
	system ($cmd) == 0 or die;
	unlink $pkg;
	return get_pkg_name $tempfh;
}

# "public interface", sort of thing.
sub do_slackbuild (%) {
	my %args = (
		OPTS		=> 0, 
		JOBS		=> 0,
		LOCATION	=> '',
		COMPAT32	=> 0,
		@_
	);
	$args{LOCATION} or script_error 'do_slackbuild requires LOCATION.';
	my $location = $args{LOCATION};
	my $sbo = get_sbo_from_loc $location;
	my $arch = get_arch; 
	my $multi = check_multilib;
	my $version = get_sbo_version $location;
	my $x32;
	# ensure x32 stuff is set correctly, or that we're setup for it
	if ($args{COMPAT32}) {
		die "compat32 only works on x86_64.\n" unless $arch eq 'x86_64';
		die "compat32 requires multilib.\n" unless $multi;
		die "compat32 requires /usr/sbin/convertpkg-compat32.\n"
				unless -f '/usr/sbin/convertpkg-compat32';
	} else {
		if ($arch eq 'x86_64') {
			$x32 = check_x32 $args{LOCATION};
			if ($x32 && ! $multi) {
				die "$sbo is 32-bit which requires multilib on x86_64.\n";
			}
		}
	}
	# get a hash of downloads and md5sums, ensure we have 'em, symlink 'em
	my %downloads = get_sbo_downloads (
		LOCATION => $location,
		32 => $args{COMPAT32}
	);
	check_distfiles %downloads;
	my @symlinks = create_symlinks $args{LOCATION}, %downloads;
	# setup and run the .SlackBuild itself
	my ($pkg, $src) = perform_sbo (
		OPTS => $args{OPTS},
		JOBS => $args{JOBS},
		LOCATION => $location,
		ARCH => $arch,
		C32 => $args{COMPAT32},
		X32 => $x32,
	);
	do_convertpkg $pkg if $args{COMPAT32};
	unlink $_ for @symlinks;
	return $version, $pkg, $src;
}

# remove work directories (source and packaging dirs under /tmp/SBo)
sub make_clean ($$$) {
	exists $_[1] or script_error 'make_clean requires two arguments.';
	my ($sbo, $src, $version) = @_;
	say "Cleaning for $sbo-$version...";
	my $tmpsbo = "/tmp/SBo";
	remove_tree ("$tmpsbo/$src") if -d "$tmpsbo/$src";
	remove_tree ("$tmpsbo/package-$sbo") if -d "$tmpsbo/package-$sbo";
	return 1;
}

# remove distfiles
sub make_distclean (%) {
	my %args = (
		SRC			=> '',
		VERSION		=> '',
		LOCATION	=> '',
		@_
	);
	unless ($args{SRC} && $args{VERSION} && $args{LOCATION}) {
		script_error 'make_distclean requires four arguments.';
	}
	my $sbo = get_sbo_from_loc $args{LOCATION};
	make_clean $sbo, $args{SRC}, $args{VERSION};
	say "Distcleaning for $sbo-$version...";
	# remove any distfiles for this particular SBo
	my %downloads = get_sbo_downloads (LOCATION => $args{LOCATION});
	for my $key (keys %downloads) {
		my $filename = get_filename_from_link $key;
		unlink $filename if -f $filename;
	}
	return 1;
}

# run upgradepkg for a created package
sub do_upgradepkg ($) {
	exists $_[0] or script_error 'do_upgradepkg requires an argument.';
	system ('/sbin/upgradepkg', '--reinstall', '--install-new', shift);
	return 1;
}
