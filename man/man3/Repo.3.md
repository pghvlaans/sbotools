# Repo

[NAME](#name)\
[SYNOPSIS](#synopsis)\
[VARIABLES](#variables)\
[\$distfiles](#$distfiles)\
[\$gpg_log](#$gpg_log)\
[\$repo_path](#$repo_path)\
[\$slackbuilds_txt](#$slackbuilds_txt)\
[SUBROUTINES](#subroutines)\
[check_git_remote](#check_git_remote)\
[check_repo](#check_repo)\
[generate_slackbuilds_txt](#generate_slackbuilds_txt)\
[git_sbo_tree](#git_sbo_tree)\
[pull_sbo_tree](#pull_sbo_tree)\
[rsync_sbo_tree](#rsync_sbo_tree)\
[slackbuilds_or_fetch](#slackbuilds_or_fetch)\
[update_tree](#update_tree)\
[verify_git_commit](#verify_git_commit)\
[verify_rsync](#verify_rsync)\
[verify_gpg](#verify_gpg)\
[retrieve_key](#retrieve_key)\
[EXIT CODES](#exit-codes)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[LICENSE](#license)\

------------------------------------------------------------------------

## NAME

SBO::Lib::Repo − Routines for downloading and updating the SBo
repository.

## SYNOPSIS

use SBO::Lib::Repo qw/ update_tree /;\
update_tree();

## VARIABLES

The location of all variables depends on the \"SBO_HOME\" config
setting.

### \$distfiles

\$distfiles defaults to \"/usr/sbo/distfiles\", and it is where all
downloaded sources are kept.

### \$gpg_log

\$gpg_log defaults to \"/usr/sbo/gpg.log\", and it is where the output
of the most recent \"gnupg\" verification is kept.

### \$repo_path

\$repo_path defaults to \"/usr/sbo/repo\", and it is where the
SlackBuilds.org tree is kept.

### \$slackbuilds_txt

\$slackbuilds_txt defaults to \"/usr/sbo/repo/SLACKBUILDS.TXT\". It is
included in the official rsync repos, but not the git mirrors. If this
file exists, is non-empty and \$repo_path has an identical top-level
directory structure to the SlackBuilds.org tree, pulling into an
existent \$repo_path proceeds without prompting.

## SUBROUTINES

### check_git_remote

my \$bool = check_git_remote(\$path, \$url);

check_git_remote() checks if the repository at \$path is a git
repository. If so, it checks for a defined \"origin\" remote matching
\$url. If so, it returns a true value, and a false value otherwise.

### check_repo

my \$bool = check_repo();

check_repo() is used when the tree is to be fetched or updated. It
checks if the path in \$repo_path exists and is an empty directory, and
returns a true value if so.

If \$repo_path exists and is non-empty, it is checked for its
resemblance to a complete SBo repository. The user receives warning
prompts varying in severity depending on whether top-level directories
not belonging to the repository exist, repository top-level directories
are missing or, in the worst case, both. Warnings are less severe for
\"git fetch\", which would not delete 'extra' files and directories.

If \$repo_path contains all expected category directories and no
unexpected directories, check_repo() returns a true value if
\$slackbuilds_txt is non-empty, and prompts the user if not.

If \$repo_path does not exist, creation is attempted, returning a true
value on success. Creation failure results in a usage error.

### generate_slackbuilds_txt

my \$bool = generate_slackbuilds_txt();

generate_slackbuilds_txt() generates a minimal \"SLACKBUILDS.TXT\" for
repositories that do not include this file. If the file cannot be opened
for write, it returns a false value. Otherwise, it returns a true value.

### git_sbo_tree

my \$bool = git_sbo_tree(\$url);

git_sbo_tree() uses \"git clone −−no−local\" on the repository specified
by \$url to the \$repo_path if the \$url repository is not present. If
it is, it runs \"git fetch && git reset −−hard origin\".

If \"GIT_BRANCH\" is set, or if the running or configured Slackware
version has a recommended git branch, existence is checked with \"git
ls−remote\". If the branch does not exist, the user is prompted to
continue. The script continues with the upstream default branch if the
repo is to be cloned, or with the existing branch otherwise.

If \"GPG_VERIFY\" is \"TRUE\", \"gnupg\" verification proceeds with
verify_git_commit(\$branch) at the end of the subroutine.

### pull_sbo_tree

pull_sbo_tree();

pull_sbo_tree() pulls the SlackBuilds.org repository tree from the
default in %supported for the running Slackware version (accounting for
\"SLACKWARE_VERSION\", \"RSYNC_DEFAULT\" and \"REPO\").

Version support verification occurs in get_slack_version_url() via
get_slack_version(); see SBO::Lib::Util(3).

### rsync_sbo_tree

my \$bool = rsync_sbo_tree(\$url);

rsync_sbo_tree() syncs the SlackBuilds.org repository to \$repo_path
from the \$url provided.

If \"GPG_VERIFY\" is \"TRUE\", \"gnupg\" verification proceeds with
verify_rsync(\"fullcheck\") at the end of the subroutine.

### slackbuilds_or_fetch

slackbuilds_or_fetch();

slackbuilds_or_fetch() is called from [sbocheck(1)](sbocheck.1.md), [sbofind(1)](sbofind.1.md),
[sboinstall(1)](sboinstall.1.md) and sboupdate(1). It checks for the file
\"SLACKBUILDS.TXT\" in \$repo_path. If this file is empty or does not
exist, it offers to check the local repository and fetch the tree.

### update_tree

update_tree();

update_tree() checks for \"SLACKBUILDS.TXT\" in \$repo_path to determine
an appropriate onscreen message. It then updates the SlackBuilds.org
tree.

The local repository is checked for existence and similarity to the SBo
repository before any update proceeds.

### verify_git_commit

verify_git_commit(\$branch);

verify_git_commit() attempts to verify the GPG signature of the most
recent git commit, if any.

Git commit verification is unavailable for Slackware 14.0 and Slackware
14.1. A user prompt for continuation appears if \"GPG_VERIFY\" is
\"TRUE\".

### verify_rsync

verify_rsync(\$fullcheck);

verify_rsync() checks the signature of CHECKSUMS.md5.asc, prompting the
user to download the public key if not present. If \"fullcheck\" is
passed (i.e., when syncing the local repository), md5sum verification is
performed as well.

Failure at any juncture leaves a lockfile \".rsync.lock\" in
\"SBO_HOME\", which prevents script installation and upgrade until the
issue has been resolved, \"GPG_TRUE\" is set to \"FALSE\" or the
lockfile is removed.

### verify_gpg

verify_gpg();

\"verify_gpg\" determines whether a git repo is in use, and then runs
\"gnupg\" verification. It is exportable, and is currently used in
[sboinstall(1)](sboinstall.1.md), [sboupgrade(1)](sboupgrade.1.md) and [sbocheck(1)](sbocheck.1.md).

### retrieve_key

retrieve_key(\$fingerprint);

\"retrieve_key\" attempts to retrieve a missing public key from
\"hkp://keyserver.ubuntu.com:80\" and add it to the keyring.

\"gnupg\" output is saved to \$key_log, and the output of \"gpg
−−no−batch −−search−keys\" is displayed with a prompt to ensure that the
user can trust the key.

## EXIT CODES

Repo.pm subroutines can return the following exit codes:

\_ERR_USAGE 1 usage errors\
\_ERR_SCRIPT 2 script or module bug\
\_ERR_DOWNLOAD 5 download failure

## SEE ALSO

[SBO::Lib(3)](Lib.3.md), [SBO::Lib::Build(3)](Build.3.md), [SBO::Lib::Download(3)](Download.3.md),
[SBO::Lib::Info(3)](Info.3.md), [SBO::Lib::Pkgs(3)](Pkgs.3.md), [SBO::Lib::Pkgs(3)](Pkgs.3.md),
[SBO::Lib::Readme(3)](Readme.3.md), [SBO::Lib::Tree(3)](Tree.3.md), [SBO::Lib::Util(3)](Util.3.md)

## AUTHORS

SBO::Lib was originally written by Jacob Pipkin \<j (at) dawnrazor (dot)
net\> with contributions from Luke Williams \<xocel (at) iquidus (dot)
org\> and Andreas Guldstrand \<andreas (dot) guldstrand (at) gmail (dot)
com\>.

SBO::Lib is maintained by K. Eugene Carlson \<kvngncrlsn (at) gmail
(dot) com\>.

## LICENSE

The sbotools are licensed under the MIT License.

Copyright (C) 2012−2017, Jacob Pipkin, Luke Williams, Andreas
Guldstrand.

Copyright (C) 2024−2025, K. Eugene Carlson.

------------------------------------------------------------------------
