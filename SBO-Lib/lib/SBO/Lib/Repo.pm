package SBO::Lib::Repo;

use 5.016;
use strict;
use warnings;

our $VERSION = '3.4_RC';

use SBO::Lib::Util qw/ %config prompt usage_error get_slack_branch get_slack_version get_slack_version_url script_error open_fh open_read in slurp wrapsay _ERR_DOWNLOAD /;

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
  generate_slackbuilds_txt
  git_sbo_tree
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

SBO::Lib::Repo - Routines for downloading and updating the SBo repository.

=head1 SYNOPSIS

  use SBO::Lib::Repo qw/ update_tree /;

  update_tree();

=head1 VARIABLES

The location of all variables depends on the C<SBO_HOME> config setting.

=head2 $distfiles

C<$distfiles> defaults to C</usr/sbo/distfiles>, and it is where all
downloaded sources are kept.

=head2 $gpg_log

C<$gpg_log> defaults to C</usr/sbo/gpg.log>, and it is where the output
of the most recent C<gnupg> verification is kept.

=head2 $repo_path

C<$repo_path> defaults to C</usr/sbo/repo>, and it is where the
SlackBuilds.org tree is kept.

=head2 $slackbuilds_txt

C<$slackbuilds_txt> defaults to C</usr/sbo/repo/SLACKBUILDS.TXT>. It is
included in the official rsync repos, but not the git mirrors.
If this file exists, is non-empty and C<$repo_path> has an identical top-level
directory structure to the SlackBuilds.org tree, pulling into an existent
C<$repo_path> proceeds without prompting.

=cut

# some stuff we'll need later
our $distfiles = "$config{SBO_HOME}/distfiles";
our $repo_path = "$config{SBO_HOME}/repo";
our $gpg_log = "$config{SBO_HOME}/gpg.log";
our $slackbuilds_txt = "$repo_path/SLACKBUILDS.TXT";

=head1 SUBROUTINES

=cut

=head2 check_git_remote

  my $bool = check_git_remote($path, $url);

C<check_git_remote()> checks if the repository at C<$path> is a git repository.
If so, it checks for a defined C<origin> remote matching C<$url>. If so, it returns
a true value, and a false value otherwise.

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

C<check_repo()> is used when the tree is to be fetched or updated.
It checks if the path in C<$repo_path> exists and is an empty
directory, and returns a true value if so.

If C<$repo_path> exists and is non-empty, it is checked for
its resemblance to a complete SBo repository. The user receives
warning prompts varying in severity depending on whether
top-level directories not belonging to the repository exist, repository
top-level directories are missing or, in the worst case, both. Warnings are less
severe for C<git fetch>, which would not delete 'extra' files and
directories.

If C<$repo_path> contains all expected category directories and
no unexpected directories, C<check_repo()> returns a true value
if C<$slackbuilds_txt> is non-empty, and prompts the user if not.

If C<$repo_path> does not exist, creation is attempted, returning a true
value on success. Creation failure results in a usage error.

=cut

sub check_repo {
  my @categories = qw{
    academic
    accessibility
    audio
    business
    desktop
    development
    games
    gis
    graphics
    ham
    haskell
    libraries
    misc
    multimedia
    network
    office
    perl
    python
    ruby
    system
  };
  if (-d $repo_path) {
    _race::cond '$repo_path could be deleted after -d check.';
    opendir(my $repo_handle, $repo_path);
    my $extra_dir;
    my $incomplete;
    my $is_empty;
    my $is_git_fetch;
    while (my $dir = readdir $repo_handle) {
      last unless in($dir => qw/ . .. /);
      $is_empty = 1;
    }
    close($repo_handle);
    # A git fetch will preserve untracked files; a git clone will not.
    if (-d "$repo_path/.git") {
      my $url = $config{REPO} unless $config{REPO} eq 'FALSE';
      $url = get_slack_version_url() unless defined $url;
      $is_git_fetch = check_git_remote($repo_path, $url);
    }
    unless ($is_empty) {
      opendir($repo_handle, $repo_path);
      my @found_dirs =
        grep { -d "$repo_path/$_" }
        grep { $_ !~ /^\./ }
        readdir($repo_handle);
      close($repo_handle);
      for my $found (@found_dirs) {
        $extra_dir = 1 if not grep(/^$found$/, @categories);
        last if $extra_dir;
      }
      for my $cat (@categories) {
        # The gis category was added in 14.1.
        next if $cat eq "gis";
        $incomplete = 1 if not grep(/^$cat$/, @found_dirs);
        last if $incomplete;
      }
      # Give different warning levels depending on how the repo
      # differs from expected and the fetch method.
      if ($extra_dir and $incomplete and not $is_git_fetch) {
        if (prompt("\nWARNING! $repo_path exists and is non-empty.\n\nIt has different top-level directories from an SBo repository.\n\nData loss is certain if you continue.\nContinue anyway?", default=>"no")) {
          return 1 if generate_slackbuilds_txt();
        } else {
          usage_error("$repo_path exists and is not empty. Exiting.");
        }
      } elsif ($extra_dir and $incomplete and $is_git_fetch) {
        if (prompt("\n$repo_path exists and is non-empty.\n\nIt has different top-level directories from an SBo repository.\n\nUntracked files will not be touched, but other files may be overwritten if you continue.\nContinue anyway?", default=>"no")) {
          return 1 if generate_slackbuilds_txt();
        } else {
          usage_error("$repo_path exists and is not empty. Exiting.");
        }
      } elsif ($incomplete and not $is_git_fetch) {
        if (prompt("\nWarning! $repo_path exists and is non-empty.\n\nIt may be an incomplete SBo repository.\n\nData loss is possible if you continue.\nContinue anyway?", default=>"no")) {
          return 1 if generate_slackbuilds_txt();
        } else {
          usage_error("$repo_path exists and is not empty. Exiting.");
        }
      } elsif ($incomplete and $is_git_fetch) {
        if (prompt("\n$repo_path exists and is non-empty.\n\nIt may be an incomplete SBo repository.\nContinue?", default=>"no")) {
          return 1 if generate_slackbuilds_txt();
        } else {
          usage_error("$repo_path exists and is not empty. Exiting.");
        }
      } elsif ($extra_dir and not $is_git_fetch) {
        if (prompt("\nWARNING! $repo_path exists and is non-empty.\n\nIt contains at least one top-level directory that does not belong to the repository.\n\nData loss is certain if you continue.\nContinue anyway?", default=>"no")) {
          return 1 if generate_slackbuilds_txt();
        } else {
          usage_error("$repo_path exists and is not empty. Exiting.");
        }
      } elsif ($extra_dir and $is_git_fetch) {
        if (prompt("\n$repo_path exists and is non-empty.\n\nIt contains at least one top-level directory that does not belong to the repository.\n\nUntracked files will not be touched, but other files may be overwritten if you continue.\nContinue?", default=>"no")) {
          return 1 if generate_slackbuilds_txt();
        } else {
          usage_error("$repo_path exists and is not empty. Exiting.");
        }
      } elsif (not -s $slackbuilds_txt and not $is_git_fetch) {
        if (prompt("\n$repo_path is non-empty, but has an identical top-level directory structure to an SBo repository.\n\nRegenerate $slackbuilds_txt and proceed?", default=>"no")) {
          return 1 if generate_slackbuilds_txt();
        } else {
          usage_error("$repo_path exists and is not empty. Exiting.");
        }
      }
    }
  } else {
    eval { make_path($repo_path) }
      or usage_error("Unable to create $repo_path.");
  }
  return 1;
}

=head2 generate_slackbuilds_txt

  my $bool = generate_slackbuilds_txt();

C<generate_slackbuilds_txt()> generates a minimal C<SLACKBUILDS.TXT> for
repositories that do not include this file. If the file cannot be opened for
write, it returns a false value. Otherwise, it returns a true value.

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

C<git_sbo_tree()> uses C<git clone --no-local> on the repository specified by C<$url> to the
C<$repo_path> if the C<$url> repository is not present. If it is, it runs
C<git fetch && git reset --hard origin>.

If C<GIT_BRANCH> is set, or if the running or configured Slackware version has a
recommended git branch, existence is checked with C<git ls-remote>. If the branch does not
exist, the user is prompted to continue. The script continues with the upstream default
branch if the repo is to be cloned, or with the existing branch otherwise.

If C<GPG_VERIFY> is C<TRUE>, C<gnupg> verification proceeds with C<verify_git_commit($branch)>
at the end of the subroutine.

=cut

sub git_sbo_tree {
  script_error('git_sbo_tree requires an argument.') unless @_ == 1;
  my $url = shift;
  my $cwd = getcwd();
  my $res;
  my $branch;
  my $backup_branch;
  my $branchres;
  if ($config{GIT_BRANCH} eq 'FALSE' and $url ne "https://github.com/Ponce/slackbuilds.git") {
    $branch = get_slack_branch();
  } elsif ($config{GIT_BRANCH} ne 'FALSE') {
    $branch = $config{GIT_BRANCH};
  }
  if ($branch) {
    $branchres = system(qw/ git ls-remote --exit-code /, $url, $branch) == 0;
    if (not $branchres) {
      if (-d "$repo_path/.git" and check_git_remote($repo_path, $url)) {
        chdir $repo_path or return 0;
        $backup_branch = slurp("$repo_path/.git/HEAD");
        $backup_branch =~ s|.*/||s;
        $backup_branch =~ s|\n||s;
        $backup_branch = "branch $backup_branch";
        chdir $cwd;
      } else {
        $backup_branch = "origin";
      }
      unless (prompt("\nThis git repository does not have a branch named $branch.\nContinue with $backup_branch?", default => 'no')) {
        usage_error("Exiting.");
      }
    }
  } else {
    $branchres = 0;
  }
  if (-d "$repo_path/.git" and check_git_remote($repo_path, $url)) {
    _race::cond '$repo_path can be deleted after -d check.';
    chdir $repo_path or return 0;
    $res = eval {
      die unless system(qw! git fetch !) == 0; # if system() doesn't return 0, there was an error
      _race::cond 'The git repo could be changed or deleted here.';
      die unless system(qw! git reset --hard origin !) == 0;
      unlink "$repo_path/SLACKBUILDS.TXT";
      if ($branchres) {
        die unless system(qw/ git checkout /, $branch) == 0;
        system(qw! git pull !);
      }
      1;
    };
  } else {
    chdir $config{SBO_HOME} or return 0;
    remove_tree($repo_path) if -d $repo_path;
    $res = system(qw/ git clone --no-local /, $url, $repo_path) == 0;
    if ($res) {
      chdir $repo_path or return 0;
      if($branchres) {
        die unless system(qw/ git checkout /, $branch) == 0;
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

=head2 pull_sbo_tree

  pull_sbo_tree();

C<pull_sbo_tree()> pulls the SlackBuilds.org repository tree from
the default in C<%supported> for the running Slackware version (accounting
for C<SLACKWARE_VERSION>, C<RSYNC_DEFAULT> and C<REPO>).

Version support verification occurs in C<get_slack_version_url()>
via C<get_slack_version()>; see C<SBO::Lib::Util(3)>.

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
    if ($res == 0) {
      if (prompt("Sync from $url failed. Retry?", default => 'no')) {
        generate_slackbuilds_txt() if not -s $slackbuilds_txt;
        return pull_sbo_tree();
      }
    }
  }

  if ($res == 0) { warn "Could not sync from $url.\n"; exit _ERR_DOWNLOAD; }

  my $wanted = sub { chown 0, 0, $File::Find::name; };
  find($wanted, $repo_path) if -d $repo_path;
  if ($res and not -s $slackbuilds_txt) {
    generate_slackbuilds_txt();
  }
}

=head2 rsync_sbo_tree

  my $bool = rsync_sbo_tree($url);

C<rsync_sbo_tree()> syncs the SlackBuilds.org repository to C<$repo_path> from
the C<$url> provided.

If C<GPG_VERIFY> is C<TRUE>, C<gnupg> verification proceeds with C<verify_rsync("fullcheck")>
at the end of the subroutine.

=cut

# rsync the sbo tree from slackbuilds.org to $repo_path
sub rsync_sbo_tree {
  script_error('rsync_sbo_tree requires an argument.') unless @_ == 1;
  my $url = shift;
  $url .= '/' unless $url =~ m!/$!; # make sure $url ends with /
  my @info;
  # only Slackware versions above 14.1 have an rsync that supports --info=progress2
  if (versioncmp(get_slack_version(), '14.1') == 1) { @info = ('--info=progress2'); }
  my @args = ('rsync', @info, '-a', '--delete', $url);
  my $res = system(@args, $repo_path) == 0;
  if ($config{GPG_VERIFY} eq "TRUE") {
    return 0 unless $res;
    return verify_rsync("fullcheck");
  } else { return $res; }
}

=head2 slackbuilds_or_fetch

  slackbuilds_or_fetch();

C<slackbuilds_or_fetch()> is called from C<sbocheck(1)>, C<sbofind(1)>, C<sboinstall(1)>
and C<sboupdate(1)>. It checks for the file C<SLACKBUILDS.TXT> in
C<$repo_path>. If this file is empty or does not exist, it offers to check the local
repository and fetch the tree.

=cut

# if SLACKBUILDS.TXT is not in $repo_path, the tree may not have been
# populated; prompt the user to check $repo_path and fetch.
sub slackbuilds_or_fetch {
  unless (-s $slackbuilds_txt) {
    if (prompt("$slackbuilds_txt is empty or missing.\nCheck $repo_path and fetch the repository now?", default => 'yes')) {
      update_tree();
    } elsif (-d $repo_path) {
      wrapsay "Please check the contents of $repo_path, and then run \"sbocheck\".";
      exit 0;
    } else {
      say "Please run \"sbocheck\"";
      exit 0;
    }
  }
  return 1;
}

=head2 update_tree

  update_tree();

C<update_tree()> checks for C<SLACKBUILDS.TXT> in C<$repo_path> to determine an
appropriate onscreen message. It then updates the SlackBuilds.org tree.

The local repository is checked for existence and similarity to the SBo repository
before any update proceeds.

=cut

sub update_tree {
  if (-s $slackbuilds_txt) {
    say 'Updating SlackBuilds tree...';
  } else {
    say 'Pulling SlackBuilds tree...';
  }
  check_repo();
  pull_sbo_tree(), return 1;
}

=head2 verify_git_commit

  verify_git_commit($branch);

C<verify_git_commit()> attempts to verify the GPG signature of the most
recent git commit, if any.

Git commit verification is unavailable for Slackware 14.0 and Slackware 14.1.
A user prompt for continuation appears if C<GPG_VERIFY> is C<TRUE>.

=cut

sub verify_git_commit {
  script_error('verify_git_commit requires an argument.') unless @_ == 1;
  # verifying git commits is only supported for 14.2 onwards
  if (versioncmp(get_slack_version(), '14.1') != 1) {
    if (prompt("Git verification is unsupported for Slackware 14.0 and 14.1. Proceed anyway?", default => 'no')) {
      return 1;
    } else {
      usage_error("Exiting. Consider using rsync or change GPG_VERIFY to FALSE.");
    }
  }
  my $branch = shift;
  my $res;
  {
    unlink $gpg_log if -f $gpg_log;
    open OLDERR, '>&', \*STDERR;
    open STDERR, '>', $gpg_log;
    $res = system(qw/ git verify-commit /, $branch) == 0;
    close STDERR;
    open STDERR, '>&', \*OLDERR;
    wrapsay "Commit signature verified. See $gpg_log." if $res;
  }
  return $res if $res;
  # send stderr from --raw to file to determine reason for failure
  # if no output from "verify commit", it simply wasn't a signed commit
  my ($fh, $tempfile) = tempfile(DIR => "$config{SBO_HOME}");
  `git verify-commit --raw $branch 2> $tempfile`;
  if (not -s $tempfile) {
    unlink $tempfile if -f $tempfile;
    usage_error("The most recent commit on this git branch is unsigned.\n\nExiting. To use this branch, set GPG_VERIFY to FALSE.");
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
  # EXPSIG/EXPKEYSIG: warning and exit
  # Note: EXPSIG was unimplemented in gnupg as of December 2024.
  if (grep(/EXPKEYSIG|EXPSIG/, @raw)) {
    usage_error("The most recent commit on this git branch was signed with an expired key.\n\nExiting.");
  }
  # BADSIG: big warning and exit
  if (grep(/BADSIG/, @raw)) {
    usage_error("WARNING! The most recent commit on this git branch has a bad signature.\n\nUsing this repository is strongly discouraged. Exiting.");
  }
  # REVKEYSIG: warning and exit
  if (grep(/REVKEYSIG/, @raw)) {
    usage_error("WARNING! The most recent commit on this git branch was signed with a revoked key.\n\nUsing this repository is probably a bad idea. Exiting.");
  }
}

=head2 verify_rsync

  verify_rsync($fullcheck);

C<verify_rsync()> checks the signature of CHECKSUMS.md5.asc, prompting the user to download
the public key if not present. If "fullcheck" is passed (i.e., when syncing the local
repository), md5sum verification is performed as well.

Failure at any juncture leaves a lockfile C<.rsync.lock> in C<SBO_HOME>, which prevents
script installation and upgrade until the issue has been resolved, C<GPG_TRUE> is set to
C<FALSE> or the lockfile is removed.

=cut

sub verify_rsync {
  script_error('verify_rsync requires an argument.') unless @_ == 1;
  my $fullcheck = shift;
  my $rsync_lock = "$config{SBO_HOME}/.rsync.lock";
  if (-f $rsync_lock and not $fullcheck) {
    usage_error("\nThe previous rsync verification failed. Please run sbocheck.\n\nExiting.");
  }
  unlink $gpg_log if -f $gpg_log;
  # This file indicates that a full verification on fetch failed, or that
  # CHECKSUMS.md5 was altered afterwards.
  chdir $repo_path or return 0;
  my $tempfile = tempfile(DIR => "$config{SBO_HOME}");
  my $checksum_asc_ok;
  my $res;
  {
    open OLDERR, '>&', \*STDERR;
    open STDERR, '>', $gpg_log;
    if (versioncmp(get_slack_version(), '14.0') == 1) {
      $checksum_asc_ok = system(qw/ gpg --status-file /, $tempfile, qw/ --verify CHECKSUMS.md5.asc /) == 0;
      wrapsay "CHECKSUMS.md5.asc verified. See $gpg_log." if $checksum_asc_ok;
    } else {
      # CHECKSUMS.md5.asc is unsigned in the 14.0 repository; check all .asc files
      say "\nChecking .asc files...";
      $checksum_asc_ok = system(qw/ gpg --status-file /, $tempfile, qw! --verify system/sbotools.tar.gz.asc !) == 0;
      if ($checksum_asc_ok) {
        my @ascs = split(' ', `find . -name "*.asc"`);
        for my $asc (@ascs) {
          my $ascres = system(qw/ gpg --verify /, $asc) == 0;
          if (not $ascres) {
            $checksum_asc_ok = 0;
            last;
          }
        }
      }
      wrapsay ".asc files verified. See $gpg_log." if $checksum_asc_ok;
    }
    close STDERR;
    open STDERR, '>&', \*OLDERR;
  }
  my @raw = split(" ", slurp($tempfile));
  unlink $tempfile;
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
      return verify_rsync($fullcheck) if $newkey;
    }
    # REVKEYSIG: warning and exit
    if (grep(/REVKEYSIG/, @raw)) {
      system(qw/ touch /, $rsync_lock);
      usage_error("\nWARNING! CHECKSUMS.md5 was signed with a revoked key.\n\nUsing this repository is probably a bad idea. Exiting.");
    }
    # EXPKEYSIG/EXPSIG: warning and exit
    # Note: EXPSIG was unimplemented in gnupg as of December 2024.
    if (grep(/EXPKEYSIG|EXPSIG/, @raw)) {
      system(qw/ touch /, $rsync_lock);
      usage_error("\nCHECKSUMS.md5 was signed with an expired key.\n\nExiting.");
    }
  }
  if ($fullcheck) {
    if (not $checksum_asc_ok) {
      system(qw/ touch /, $rsync_lock);
      # BADSIG: big warning and exit
      if (grep(/BADSIG/, @raw)) {
        usage_error("\nWARNING! CHECKSUMS.md5 has a bad signature.\n\nUsing this repository is strongly discouraged. Exiting.");
      }
    }
    chdir $repo_path or return 0;
    # --ignore-missing is only available in 14.2 onwards.
    if(versioncmp(get_slack_version(), '14.1') == 1) {
      $res = system("tail +13 CHECKSUMS.md5 | md5sum -c --ignore-missing --quiet -") == 0;
    } else {
      # Disregard missing files in 14.0 and 14.1 as well.
      my $md5temp = "$repo_path/CHECKSUMS.temp.md5";
      unlink $md5temp if -f $md5temp;
      my ($temp_fh, $exit) = open_fh($md5temp, '>');
      return 0 if $exit;
      my @checksum_lines = split('\n', slurp("CHECKSUMS.md5"));
      for my $checksum_line (@checksum_lines){
        my $checksum_file = $checksum_line;
        $checksum_file =~ s/^.*\s//s;
        print { $temp_fh } "$checksum_line\n" if -f $checksum_file;
      }
      close $temp_fh;
      if (-f $md5temp) {
        $res = system(qw/ md5sum -c --quiet /, $md5temp) == 0;
        unlink $md5temp;
      } else {
        $res = 0;
      }
    }
    if ($res) {
      # All is well, so release the lock, if any.
      unlink($rsync_lock) if -f $rsync_lock;
      return $res;
    } else {
      system(qw/ touch /, $rsync_lock);
      usage_error("\nOne or more md5 errors was detected after sync.\n\nRemove $rsync_lock or turn off GPG verification with caution.\n\nExiting.");
    }
  }
  if (not $checksum_asc_ok) {
    system(qw/ touch /, $rsync_lock);
    usage_error("\nThe contents of CHECKSUMS.md5 have been altered. Please run sbocheck.\n\nExiting.") unless $checksum_asc_ok;
  }
  return 1;
}

=head2 verify_gpg

  verify_gpg();

C<verify_gpg> determines whether a git repo is in use, and then
runs C<gnupg> verification. It is exportable, and is currently used in
C<sboinstall(1)>, C<sboupgrade(1)> and C<sbocheck(1)>.

=cut

sub verify_gpg {
  my $url = $config{REPO};
  if ($url eq 'FALSE') {
    $url = get_slack_version_url();
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

C<retrieve_key> attempts to retrieve a missing public key from
C<hkp://keyserver.ubuntu.com:80> and add it to the keyring.

C<gnupg> output is saved to C<$key_log>, and the output of
C<gpg --no-batch --search-keys> is displayed with a prompt to ensure
that the user can trust the key.

=cut

sub retrieve_key {
  script_error('retrieve_key requires an argument.') unless @_ == 1;
  my $fingerprint = shift;
  my $res;
  my $key_log = "$config{SBO_HOME}/.key_download-$fingerprint.log";
  say "\nThe public key for GPG verification is missing.";
  say "Searching by keyid $fingerprint...\n";
  unlink $key_log if -f $key_log;
  open OLDERR, '>&', \*STDERR;
  open STDERR,'>', $key_log;
  system(qw! gpg --no-tty --batch --keyserver hkp://keyserver.ubuntu.com:80 --search-keys !, $fingerprint);
  if (prompt("Download and add this key?", default => "no")) {
    {
      $res = system(qw\ gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-key \, $fingerprint) == 0;
      close STDERR;
      open STDERR, '>&', \*OLDERR;
    }
    if ($res) {
      print("The key has been added. See $key_log.\n");
      return $res;
    } else {
      print("Failed to add the key. See $key_log.\n");
      return 0;
    }
  } else {
    close STDERR;
    open STDERR, '>&', \*OLDERR;
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

Copyright (C) 2024-2025, K. Eugene Carlson.

=cut

1;
