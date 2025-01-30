# Util

[NAME](#name)\
[SYNOPSIS](#synopsis)\
[VARIABLES](#variables)\
[\$conf_dir](#$conf_dir)\
[\$conf_file](#$conf_file)\
[%config](#%config)\
[\@listings](#@listings)\
[SUBROUTINES](#subroutines)\
[build_cmp](#build_cmp)\
[check_multilib](#check_multilib)\
[get_arch](#get_arch)\
[get_kernel_version](#get_kernel_version)\
[get_optional](#get_optional)\
[get_sbo_from_loc](#get_sbo_from_loc)\
[get_slack_version](#get_slack_version)\
[get_slack_version_url](#get_slack_version_url)\
[get_slack_branch](#get_slack_branch)\
[idx](#idx)\
[in](#in)\
[indent](#indent)\
[lint_sbo_config](#lint_sbo_config)\
[on_blacklist](#on_blacklist)\
[open_fh](#open_fh)\
[open_read](#open_read)\
[print_failures](#print_failures)\
[prompt](#prompt)\
[read_config](#read_config)\
[read_hints](#read_hints)\
[save_options](#save_options)\
[script_error](#script_error)\
[show_version](#show_version)\
[slurp](#slurp)\
[uniq](#uniq)\
[usage_error](#usage_error)\
[version_cmp](#version_cmp)\
[wrapsay](#wrapsay)\
[EXIT CODES](#exit-codes)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[LICENSE](#license)

------------------------------------------------------------------------

## NAME

SBO::Lib::Util − Utility functions for SBO::Lib and the sbotools

## SYNOPSIS

    use SBO::Lib::Util qw/uniq/;\
\# (\'duplicate\');\
    my \@uniq = uniq(\'duplicate\', \'duplicate\');

## VARIABLES

### \$conf_dir

\$conf_dir is \"/etc/sbotools\".

### \$conf_file

\$conf_file is \"/etc/sbotools/sbotools.conf\".

### %config

All values default to \"FALSE\", but when read_config() is run, they
change according to the configuration. \"SBO_HOME\" is changed to
\"/usr/sbo\" if still \"FALSE\".

The supported keys are: \"NOCLEAN\", \"DISTCLEAN\", \"JOBS\",
\"PKG_DIR\", \"SBO_HOME\", \"LOCAL_OVERRIDES\", \"SLACKWARE_VERSION\",
\"REPO\", \"BUILD_IGNORE\", \"GPG_VERIFY\", \"RSYNC_DEFAULT\" and
\"STRICT_UPGRADES\".

### \@listings

An array with blacklisted scripts and optional dependency requests read
in from \"/etc/sbotools/sbotools.hints\". Only read_hints() should
interact with \@listings directly; in other situations, make a copy (see
e.g. \@on_blacklist().)

## SUBROUTINES

### build_cmp

    my $cmp = build_cmp($build1, $build2, $ver1, $ver2);

build_cmp() compares \$build1 with \$build2 while checking that \$ver1
and \$ver2 are different. If the build numbers are not the same and the
version numbers are, upgrading for a script bump may be in order.

### check_multilib

    my $ml = check_multilib();

check_multilib() for \"/etc/profile.d/32dev.sh\" existence. The sbotools
    use this file to build 32−bit packages on x64 architecture.

Returns 1 if so, and 0 otherwise.

### get_arch

    my $arch = get_arch();

get_arch() returns the machine architechture as reported by \"uname
−m\".

### get_kernel_version

    my $kv = get_kernel_version();

get_kernel_version() checks the version of the running kernel and
returns it in a format suitable for appending to a Slackware package
version.

### get_optional

    my $optional = get_optional($sbo)

get_optional() checks for user-requested optional dependencies for
\$sbo. Note that global array \@listings is copied.

### get_sbo_from_loc

    my $sbo = get_sbo_from_loc($location);

get_sbo_from_loc() returns the package name from the \$location passed
in.

### get_slack_version

    my $version = get_slack_version();

get_slack_version() returns the appropriate version of the SBo
reposiotry.

The program exits if the version is unsupported or if an error occurs.

### get_slack_version_url

    my $url = get_slack_version_url();

get_slack_version_url() returns the default URL for the given Slackware
version.

The program exits if the version is unsupported or if an error occurs.

### get_slack_branch

    my $url = get_slack_branch();

get_slack_branch() returns the default git branch for the given
Slackware version, if any. If the upstream repository does not have this
branch, an onscreen message appears.

### idx

    my $idx = idx($needle, \@haystack);

idx() looks for \$needle in \@haystack, and returns the index of where
it was found, or \"undef\" if it was not found.

### in

    my $found = in($needle, \@haystack);

in() looks for \$needle in \@haystack, and returns a true value if it
was found, and a false value otherwise.

### indent

    my $str = indent($indent, $text);

indent() indents every non-empty line in \$text by \$indent spaces and
returns the resulting string.

### lint_sbo_config

lint_sbo_config(\$running_script, %configs);

lint_sbo_config() takes the name of an sbotools script and a hash with
configuration parameters. It checks the validity of all parameters
except for GIT_BRANCH and REPO, exiting with an error message in case of
invalid options.

[sboconfig(1)](sboconfig.1.md) runs this subroutine to lint any requested parameter
changes; all other scripts lint the full configuration at startup.

### on_blacklist

    my $result = on_blacklist($sbo);

on_blacklist() checks whether \$sbo has been blacklisted. Note that
global array \@listings is copied.

### open_fh

    my ($ret, $exit) = open_fh($fn, $op);

open_fh() opens \$fn for reading and/or writing depending on \$op.

It returns two values: the file handle and the exit status. If the exit
status is non-zero, it returns an error message rather than a file
handle.

### open_read

    my ($ret, $exit) = open_read($fn);

open_read() opens \$fn for reading.

It returns two values: the file handle and the exit status. If the exit
status is non-zero, it returns an error message rather than a file
handle.

### print_failures

print_failures(\$failures);

print_failures() prints all failures in the \$failures array reference
to STDERR, if any.

There is no useful return value.

### prompt

exit unless prompt \"Should we continue?\", default =\> \"yes\";

prompt() prompts the user for an answer, optionally specifying a default
of \"yes\" or \"no\".

If the default has been specified, it returns a true value for 'yes' and
a false one for 'no'. Otherwise, it returns the content of the user's
answer.

Output is wrapped at 72 characters.

### read_config

read_config();

read_config() reads in the configuration settings from
\"/etc/sbotools/sbotools.conf\", updating the %config hash. If
\"SBO_HOME\" is \"FALSE\", it changes to \"/usr/sbo\". Additionally,
\"BUILD_IGNORE\" and \"RSYNC_DEFAULT\" are turned on if \"CLASSIC\" is
\"TRUE\".

There is no useful return value.

### read_hints

    our \@listings = read_hints()

read_hints() reads the contents of /etc/sbotools/sbotools.hints,
returning an array of optional dependency requests and blacklisted
scripts. read_hints() is used to populate global array \@listings, and
should only be called at the start and again when editing the hints
file.

### save_options

save_options(\$sbo, \$opts)

save_options() saves build options to \"/var/log/sbotools/sbo\". If the
file already exists and the user supplies no build options, the existing
file is retained.

### script_error

script_error();\
script_error(\$msg);

**script_error()** warns and exits, printing the following to STDERR:

A fatal script error has occurred. Exiting.

If a \$msg was supplied, it instead prints:

A fatal script error has occurred:\
\$msg.\
Exiting.

There is no useful return value.

### show_version

show_version();

show_version() prints the sbotools version and licensing information to
STDOUT.

There is no useful return value.

### slurp

    my $data = slurp($fn);

slurp() takes a filename in \$fn, opens it, and reads in the entire
file. The contents are then returned. On error, it returns \"undef\".

### uniq

    my \@uniq = uniq(@duplicates);

uniq() removes any duplicates from \@duplicates, otherwise returning the
list in the same order.

### usage_error

usage_error(\$msg);

usage_error() warns and exits, printing \$msg to STDERR. Error messages
wrap at 72 characters.

There is no useful return value.

### version_cmp

    my $cmp = version_cmp($ver1, $ver2);

version_cmp() compares \$ver1 with \$ver2. It returns 1 if \$ver1 is
higher, −1 if \$ver2 is higher and 0 if they are equal. It strips the
running kernel version, as well as any locale information that may have
been appended to the version strings.

### wrapsay

wrapsay(\$msg, \$trail);

wrapsay() outputs a message with the lines wrapped at 72 characters and
a trailing newline. There is no useful return value. Optional \$trail
outputs an extra newline if present.

Use this subroutine whenever it is either obvious that the output
exceeds 80 characters or the output includes a variable. \"say\" can be
used in other cases. wrapsay() should not be used on output that can be
piped for use in scripts (e.g., queue reports from [sbofind(1)](sbofind.1.md)).

## EXIT CODES

The sbotools share the following exit codes:

    \_ERR_USAGE 1 usage errors\
    \_ERR_SCRIPT 2 script or module bug\
    \_ERR_BUILD 3 errors when executing a SlackBuild\
    \_ERR_MD5SUM 4 download verification failure\
    \_ERR_DOWNLOAD 5 download failure\
    \_ERR_OPENFH 6 failure to open file handles\
    \_ERR_NOINFO 7 missing download information\
    \_ERR_F_SETD 8 fd−related temporary file failure\
    \_ERR_NOMULTILIB 9 lacking multilib capabilities when needed\
    \_ERR_CONVERTPKG 10 convertpkg−compat32 failure\
    \_ERR_NOCONVERTPKG 11 lacking convertpkg−compat32 when needed\
    \_ERR_INST_SIGNAL 12 the script was interrupted while building\
    \_ERR_CIRCULAR 13 attempted to calculate a circular dependency

## SEE ALSO

[SBO::Lib(3)](Lib.3.md), [SBO::Lib::Build(3)](Build.3.md), [SBO::Lib::Download(3)](Download.3.md),
[SBO::Lib::Info(3)](Info.3.md), [SBO::Lib::Pkgs(3)](Pkgs.3.md), [SBO::Lib::Pkgs(3)](Pkgs.3.md),
[SBO::Lib::Readme(3)](Readme.3.md), [SBO::Lib::Repo(3)](Repo.3.md), [SBO::Lib::Tree(3)](Tree.3.md)

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
