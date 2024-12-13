package SBO::Lib::Repo;

use 5.016;
use strict;
use warnings;

our $VERSION = '3.1';

use SBO::Lib::Util qw/ %config prompt usage_error get_slack_branch get_slack_version get_slack_version_url script_error open_fh open_read in slurp _ERR_DOWNLOAD /;

use Cwd;
use File::Copy;
use File::Find;
use File::Path qw/ make_path remove_tree /;
use File::Temp qw/ tempfile /;
use Sort::Versions;

use Exporter 'import';

our @EXPORT_OK = qw{
  check_git_remote
  check_repo
  chk_slackbuilds_txt
  fetch_tree
  generate_slackbuilds_txt
  git_sbo_tree
  migrate_repo
  pull_sbo_tree
  rsync_sbo_tree
  slackbuilds_or_fetch
  update_tree
  verify_gpg

  $distfiles
  $repo_path
  $slackbuilds_txt
};

our %EXPORT_TAGS = (
  all => \@EXPORT_OK,
);

=pod

=encoding UTF-8

=head1 NAME

SBO::Lib::Repo - Routines for downloading and updating the SBo repo.

=head1 SYNOPSIS

  use SBO::Lib::Repo qw/ fetch_tree /;

  fetch_tree();

=head1 VARIABLES

=head2 $distfiles

By default $distfiles is set to C</usr/sbo/distfiles>, and it is where all the
downloaded sources are kept.

The location depends on the C<SBO_HOME> config setting.

=head2 $repo_path

By default $repo_path is set to C</usr/sbo/repo>, and it is where the
SlackBuilds.org tree is kept.

The location depends on the C<SBO_HOME> config setting.

=cut

# some stuff we'll need later
our $distfiles = "$config{SBO_HOME}/distfiles";
our $repo_path = "$config{SBO_HOME}/repo";
our $slackbuilds_txt = "$repo_path/SLACKBUILDS.TXT";

=head1 SUBROUTINES

=cut

=head2 check_git_remote

  my $bool = check_git_remote($path, $url);

C<check_git_remote()> will check if the repository at C<$path> is a git
repository and if so, it will check if it defined an C<origin> remote that
matches the C<$url>. If so, it will return a true value. Otherwise it will
return a false value.

=cut

sub check_git_remote {
  script_error('check_git_remote requires two arguments.') unless @_ == 2;
  my ($path, $url) = @_;
  return 0 unless -f "$path/.git/config";
  my ($fh, $exit) = open_read("$path/.git/config");
  return 0 if $exit;

  while (my $line = readline($fh)) {
    chomp $line;
    if ($line eq '[remote "origin"]') {
      REMOTE: while (my $remote = readline($fh)) {
        last REMOTE if $remote =~ /^\[/;
        return 1 if $remote =~ /^\s*url\s*=\s*\Q$url\E$/;
        return 0 if $remote =~ /^\s*url\s*=/;
      }
    }
  }
  return 0;
}

=head2 check_repo

  my $bool = check_repo();

C<check_repo()> is used when SLACKBUILDS.txt cannot be found.
It checks if the path in C<$repo_path> exists and is an empty
directory, and returns a true value if so.

If C<$repo_path> exists and is non-empty, it is malformed, and the user
is prompted to delete it to proceed. A usage error results if deletion
is declined.

If C<$repo_path> does not exist, creation will be attempted, returning a true
value on success. Creation failure results in a usage error.

=cut

sub check_repo {
  if (-d $repo_path) {
    _race::cond '$repo_path could be deleted after -d check.';
    opendir(my $repo_handle, $repo_path);
    FIRST: while (my $dir = readdir $repo_handle) {
      next FIRST if in($dir => qw/ . .. /);
      if (prompt("SLACKBUILDS.TXT is missing and the fetch cannot proceed. Delete $repo_path?", default=>"no")) {
        remove_tree($repo_path);
	return check_repo();
      } else {
        usage_error("$repo_path exists and is not empty. Exiting.\n");
      }
    }
  } else {
    eval { make_path($repo_path) }
      or usage_error("Unable to create $repo_path.\n");
  }
  return 1;
}

=head2 chk_slackbuilds_txt

  my $bool = chk_slackbuilds_txt();

C<chk_slackbuilds_txt()> checks if the file C<SLACKBUILDS.TXT> exists in the
correct location, and returns a true value if it does, and a false value
otherwise.

Before the check is made, it attempts to call C<migrate_repo()> so it doesn't
give a false negative if the repository hasn't been migrated to its sbotools
2.0 location yet.

=cut

# does the SLACKBUILDS.TXT file exist in the sbo tree?
sub chk_slackbuilds_txt {
  if (-f "$config{SBO_HOME}/SLACKBUILDS.TXT") { migrate_repo(); }
  return -f $slackbuilds_txt ? 1 : undef;
}

=head2 fetch_tree

  fetch_tree();

C<fetch_tree()> will make sure the C<$repo_path> exists and is empty, and then
fetch the SlackBuilds.org repository tree there.

If the C<$repo_path> is not empty, it will exit with a usage error.

=cut

sub fetch_tree {
  check_repo();
  say 'Pulling SlackBuilds tree...';
  pull_sbo_tree(), return 1;
}

=head2 generate_slackbuilds_txt

  my $bool = generate_slackbuilds_txt();

C<generate_slackbuilds_txt()> will generate a minimal C<SLACKBUILDS.TXT> for a
repository that doesn't come with one. If it fails, it will return a false
value. Otherwise it will return a true value.

=cut

sub generate_slackbuilds_txt {
  my ($fh, $exit) = open_fh($slackbuilds_txt, '>');
  return 0 if $exit;

  opendir(my $dh, $repo_path) or return 0;
  my @categories =
    grep { -d "$repo_path/$_" }
    grep { $_ !~ /^\./ }
    readdir($dh);
  close $dh;

  for my $cat (@categories) {
    opendir(my $cat_dh, "$repo_path/$cat") or return 0;
    while (my $package = readdir($cat_dh)) {
      next if in($package => qw/ . .. /);
      next unless -f "$repo_path/$cat/$package/$package.info";
      print { $fh } "SLACKBUILD NAME: $package\n";
      print { $fh } "SLACKBUILD LOCATION: ./$cat/$package\n";
    }
    close $cat_dh;
  }
  close $fh;
  return 1;
}

=head2 git_sbo_tree

  my $bool = git_sbo_tree($url);

C<git_sbo_tree()> will C<git clone> the repository specified by C<$url> to the
C<$repo_path> if the C<$url> repository isn't already there. If it is, it will
run C<git fetch && git reset --hard origin>.

If any command fails, it will return a false value. Otherwise it will return a
true value.

=cut

sub git_sbo_tree {
  script_error('git_sbo_tree requires an argument.') unless @_ == 1;
  my $url = shift;
  my $cwd = getcwd();
  my $res;
  my $branch;
  my $branchres;
  if ($config{GIT_BRANCH} eq 'FALSE' and $url ne "https://github.com/Ponce/slackbuilds.git") {
    $branch = get_slack_branch();
  } elsif ($config{GIT_BRANCH} ne 'FALSE') {
    $branch = $config{GIT_BRANCH};
  }
  if (-d "$repo_path/.git" and check_git_remote($repo_path, $url)) {
    _race::cond '$repo_path can be deleted after -d check.';
    chdir $repo_path or return 0;
    $res = eval {
      die unless system(qw! git fetch !) == 0; # if system() doesn't return 0, there was an error
      _race::cond 'The git repo could be changed or deleted here.';
      die unless system(qw! git reset --hard origin !) == 0;
      unlink "$repo_path/SLACKBUILDS.TXT";
      if ($branch) {
        $branchres=system(qw/ git checkout /, $branch) == 0;
        if (not $branchres) { say "\nThis git repository does not have a branch named $branch. Remaining in the default branch.\n"; }
        else { system(qw! git pull !); }
      }
    };
  } else {
    chdir $config{SBO_HOME} or return 0;
    remove_tree($repo_path) if -d $repo_path;
    $res = system(qw/ git clone --no-local /, $url, $repo_path) == 0;
    if ($res) {
      chdir $repo_path or return 0;
      if($branch) {
        $branchres=system(qw/ git checkout /, $branch) == 0;
        if (not $branchres) { say "\nThis git repository does not have a branch named $branch. Remaining in the default branch.\n"; }
      }
    }
  }
  _race::cond '$cwd could be deleted here';
  if ($config{GPG_VERIFY} eq 'TRUE') {
    return verify_git_commit($branch) if $branchres;
    return verify_git_commit("origin");
  } else {
    return 1 if chdir $cwd and $res;
    return 0;
  }
}

=head2 migrate_repo

  migrate_repo();

C<migrate_repo()> moves an old sbotools 1.x repository to the location it needs
to be in for sbotools 2.x. This means every directory and file except for the
C<distfiles> directory in (by default) C</usr/sbo/> gets moved to
C</usr/sbo/repo>.

=cut

# Move everything in /usr/sbo except distfiles and repo dirs into repo dir
sub migrate_repo {
  make_path($repo_path) unless -d $repo_path;
  _race::cond '$repo_path can be deleted between being made and being used';
  opendir(my $dh, $config{SBO_HOME});
  foreach my $entry (readdir($dh)) {
    next if in($entry => qw/ . .. repo distfiles /);
    move("$config{SBO_HOME}/$entry", "$repo_path/$entry");
  }
  close $dh;
}

=head2 pull_sbo_tree

  pull_sbo_tree();

C<pull_sbo_tree()> will pull the SlackBuilds.org repository tree from
C<rsync://slackbuilds.org/slackbuilds/$ver/> or whatever the C<REPO>
configuration variable has been set to.

C<$ver> is the version of Slackware you're running, provided it is supported,
or whatever you've set in the C<SLACKWARE_VERSION> configuration variable.

=cut

sub pull_sbo_tree {
  my $url = $config{REPO};
  if ($url eq 'FALSE') {
    $url = get_slack_version_url();
  } else {
    unlink($slackbuilds_txt);
  }
  my $res = 0;
  if ($url =~ m!^rsync://!) {
    $res = rsync_sbo_tree($url);
  } else {
    $res = git_sbo_tree($url);
  }

  if ($res == 0) { warn "Could not sync from $url.\n"; exit _ERR_DOWNLOAD; }

  my $wanted = sub { chown 0, 0, $File::Find::name; };
  find($wanted, $repo_path) if -d $repo_path;
  if ($res and not chk_slackbuilds_txt()) {
    generate_slackbuilds_txt();
  }
}

=head2 rsync_sbo_tree

  my $bool = rsync_sbo_tree($url);

C<rsync_sbo_tree()> syncs the SlackBuilds.org repository to C<$repo_path> from
the C<$url> provided.

=cut

# rsync the sbo tree from slackbuilds.org to $repo_path
sub rsync_sbo_tree {
  script_error('rsync_sbo_tree requires an argument.') unless @_ == 1;
  my $url = shift;
  $url .= '/' unless $url =~ m!/$!; # make sure $url ends with /
  my @info;
  # only slackware versions above 14.1 have an rsync that supports --info=progress2
  if (versioncmp(get_slack_version(), '14.1') == 1) { @info = ('--info=progress2'); }
  my @args = ('rsync', @info, '-a', '--delete', $url);
  my $res = system(@args, $repo_path) == 0;
  if ($config{GPG_VERIFY}) {
    return 0 unless $res;
    return verify_rsync("fullcheck");
  } else { return $res; }
}

=head2 slackbuilds_or_fetch

  slackbuilds_or_fetch();

C<slackbuilds_or_fetch()> will check if there is a C<SLACKBUILDS.TXT> in the
C<$repo_path>, and if not, offer to run C<sbosnap fetch> for you.

=cut

# if the SLACKBUILDS.TXT is not in $repo_path, we assume the tree has
# not been populated there; prompt the user to automagickally pull the tree.
sub slackbuilds_or_fetch {
  unless (chk_slackbuilds_txt()) {
    say 'It looks like "sbosnap fetch" has not yet been run.';
    if (prompt("Fetch the repository now?", default => 'yes')) {
      fetch_tree();
    } else {
      say 'Please run "sbosnap fetch"';
      exit 0;
    }
  }
  return 1;
}

=head2 update_tree

  update_tree();

C<update_tree()> will check if there is a C<SLACKBUILDS.TXT> in the
C<$repo_path>, and if not, will run C<fetch_tree()>. Otherwise it will update
the SlackBuilds.org tree.

=cut

sub update_tree {
  fetch_tree(), return() unless chk_slackbuilds_txt();
  say 'Updating SlackBuilds tree...';
  pull_sbo_tree(), return 1;
}

=head2 verify_git_commit

  verify_git_commit($branch);

C<verify_git_commit()> attempts to verify the GPG signature of the most
recent git commit, if any.

=cut

sub verify_git_commit {
  script_error('verify_git_commit requires an argument.') unless @_ == 1;
  my $branch = shift;
  say "";
  my $res = system(qw/ git verify-commit /, $branch) == 0;
  return $res if $res;
  # send stderr from --raw to file to determine reason for failure
  # if no output from "verify commit", it simply wasn't a signed commit
  my ($fh, $tempfile) = tempfile(DIR => "$config{SBO_HOME}");
  `git verify-commit --raw $branch 2> $tempfile`;
  if (not -s $tempfile) {
    unlink $tempfile if -f $tempfile;
    usage_error("The most recent commit on this git branch is unsigned.\n\nExiting. To use this branch, set GPG_VERIFY to FALSE.\n");
  }
  my @raw = split(" ", slurp($tempfile));
  close $fh;
  unlink($tempfile);
  # ERRSIG: signed, but public key is missing; attempt download
  if (grep(/ERRSIG/, @raw)) {
    my $fingerprint;
    my $next = 0;
    for my $word (@raw) {
      if ($next) {
        $fingerprint = $word if $next;
	last;
      }
      $next = 1 if $word eq "ERRSIG";
    }
    my $newkey = retrieve_key($fingerprint);
    return verify_git_commit($branch) if $newkey;
  }
  # EXPSIG/EXPKEYSIG: warning and exit (note: EXPSIG is unimplemented in gnupg as of 2024-12-10)
  if (grep(/EXPKEYSIG|EXPSIG/, @raw)) {
    usage_error("The most recent commit on this git branch was signed with an expired key.\n\nExiting.\n");
  }
  # BADSIG: big warning and exit
  if (grep(/BADSIG/, @raw)) {
    usage_error("WARNING! The most recent commit on this git branch was signed with a bad key.\n\nUsing this repository is strongly discouraged. Exiting.\n");
  }
  # REVKEYSIG: warning and exit
  if (grep(/REVKEYSIG/, @raw)) {
    usage_error("WARNING! The most recent commit on this git branch was signed with a revoked key.\n\nUsing this repository is probably a bad idea. Exiting.\n");
  }
}

=head2 verify_rsync

  verify_rsync($fullcheck);

C<verify_rsync()> checks the signature of CHECKSUMS.md5.asc, prompting the user to download
the public key if unavailable. If "fullcheck" is passed (i.e., when syncing the local
repository), md5 verification is performed as well. Failure at any juncture leaves a lockfile
.rsync.lock in SBO_HOME, which prevents script installation and upgrade until the issue has
been resolved, GPG_TRUE is set to FALSE or the lockfile is removed.

=cut

sub verify_rsync {
  script_error('verify_rsync requires an argument.') unless @_ == 1;
  my $fullcheck = shift;
  # This file indicates that a full verification on fetch failed, or that
  # CHECKSUMS.md5 was altered afterwards.
  my $rsync_lock = "$config{SBO_HOME}/.rsync.lock";
  chdir $repo_path;
  my $tempfile = tempfile(DIR => "$config{SBO_HOME}");
  my $checksum_asc_ok = system(qw/ gpg --status-file /, $tempfile, qw/ --verify CHECKSUMS.md5.asc /) == 0;
  my @raw = split(" ", slurp($tempfile));
  unlink $tempfile;
  if ($fullcheck) {
    if (not $checksum_asc_ok) {
      # ERRSIG: signed, but public key is missing; attempt download
      if (grep(/ERRSIG/, @raw)) {
	my $fingerprint;
	my $next = 0;
        for my $word (@raw) {
          if ($next) {
            $fingerprint = $word if $next;
            last;
          }
          $next = 1 if $word eq "ERRSIG";
        }
        my $newkey = retrieve_key($fingerprint);
        return verify_rsync("fullcheck") if $newkey;
      }
      # Every other failure scenario requires the lock file.
      system(qw/ touch /, $rsync_lock);
      # EXPKEYSIG/EXPSIG: warning and exit (note: EXPSIG is unimplemented in gnupg as of 2024-12-10)
      if (grep(/EXPKEYSIG|EXPSIG/, @raw)) {
        usage_error("\nCHECKSUMS.md5 was signed with an expired key.\n\nExiting.\n");
      }
      # BADSIG: big warning and exit
      if (grep(/BADSIG/, @raw)) {
        usage_error("\nWARNING! CHECKSUMS.md5 was signed with a bad key.\n\nUsing this repository is strongly discouraged. Exiting.\n");
      }
      # REVKEYSIG: warning and exit
      if (grep(/REVKEYSIG/, @raw)) {
        usage_error("\nWARNING! CHECKSUMS.md5 was signed with a revoked key.\n\nUsing this repository is probably a bad idea. Exiting.\n");
      }
    } else {
      chdir("$repo_path");
      my $res = system("tail +13 CHECKSUMS.md5 | md5sum -c --ignore-missing --quiet -") == 0;
      if ($res) {
        # All is well, so release the lock, if any.
        unlink($rsync_lock) if -f $rsync_lock;
        return $res;
      } else {
        system(qw/ touch /, $rsync_lock);
        usage_error("\nOne or more md5 errors was detected after sync.\n\nRemove $rsync_lock or turn off GPG verification with caution.\n\nExiting.\n");
      }
    }
  } elsif (-f $rsync_lock) {
    usage_error("\nThe previous rsync verification failed. Please run sbocheck.\n\nExiting.\n");
  } else {
    if (not $checksum_asc_ok) {
      system(qw/ touch /, $rsync_lock);
      usage_error("\nThe contents of CHECKSUMS.md5 have been altered. Please run sbocheck.\n\nExiting.\n") unless $checksum_asc_ok;
    }
    return 1;
  }
}

=head2 verify_gpg

  verify_gpg();

C<verify_gpg> determines whether a git repo is in use, and then
runs GnuPG verification. It can be called from outside Repo.pm.

=cut

sub verify_gpg {
  my $url = $config{REPO};
  if ($url eq 'FALSE') {
    $url = get_slack_version_url();
  } else {
    usage_error("The origins of $repo_path are unclear.\n\nPlease check your REPO, VERSION and RSYNC_DEFAULT settings. Exiting.");
  }
  if ($url =~ m!^rsync://!) {
    return verify_rsync(0);
  } else {
    chdir $repo_path or return 0;
    my $branch;
    if (-f "$repo_path/.git/HEAD") {
      $branch = slurp("$repo_path/.git/HEAD");
      $branch =~ s|.*/||s;
      $branch =~ s|\n||s;
    }
    return verify_git_commit($branch) if $branch;
    usage_error("$repo_path appears to be neither a git nor an rsync mirror.\n\nPlease check your REPO, VERSION and RSYNC_DEFAULT settings. Exiting.");
  }
}

=head2 retrieve_key

  retrieve_key($fingerprint);

C<retrieve_key> attempts to retrieve a missing public key and add it to
the keyring.

=cut

sub retrieve_key {
  script_error('retrieve_key requires an argument.') unless @_ == 1;
  my $fingerprint = shift;
  say "\nThe public key for GPG verification is missing.";
  say "Searching by keyid $fingerprint...\n";
  open STDERR, '>', '/dev/null';
  system(qw! gpg --no-tty --batch --keyserver hkp://keyserver.ubuntu.com:80 --search-keys !, $fingerprint);
  say "";
  if (prompt("Download and add this key?", default => "no")) {
    my $res = system(qw\ gpg --keyserver hkp://keyserver.ubuntu.com:80 --receive-keys \, $fingerprint) == 0;
    close STDERR;
    if ($res) {
      print("Key $fingerprint has been added.");
      return $res;
    } else {
      print("Adding key $fingerprint failed.");
      return 0;
    }
  } else {
    close STDERR;
    return 0;
  }
}

=head1 AUTHORS

SBO::Lib was originally written by Jacob Pipkin <j@dawnrazor.net> with
contributions from Luke Williams <xocel@iquidus.org> and Andreas
Guldstrand <andreas.guldstrand@gmail.com>.

SBO::Lib is maintained by K. Eugene Carlson <kvngncrlsn@gmail.com>.

=head1 LICENSE

The sbotools are licensed under the MIT License.

Copyright (C) 2012-2017, Jacob Pipkin, Luke Williams, Andreas Guldstrand.
Copyright (C) 2024, K. Eugene Carlson.

=cut

1;
