# Readme

[NAME](#name)\
[SYNOPSIS](#synopsis)\
[SUBROUTINES](#subroutines)\
[ask_opts](#ask_opts)\
[ask_other_readmes](#ask_other_readmes)\
[ask_user_group](#ask_user_group)\
[get_opts](#get_opts)\
[get_readme_contents](#get_readme_contents)\
[get_user_group](#get_user_group)\
[user_prompt](#user_prompt)\
[EXIT CODES](#exit-codes)\
[SEE ALSO](#see-also)\
[AUTHORS](#authors)\
[LICENSE](#license)

------------------------------------------------------------------------

## NAME

SBO::Lib::Readme − Routines for interacting with a typical SBo README
file.

## SYNOPSIS

    use SBO::Lib::Readme qw/ get_readme_contents /;\
print get_readme_contents(\$sbo);

## SUBROUTINES

### ask_opts

    my $opts = ask_opts($sbo, $readme);

ask_opts() displays \$readme and asks if options should be set. If no
options are set, it returns \"undef\". Saved options under
\"/var/log/sbotools/\$sbo\" are retrieved and can be used again.

### ask_other_readmes

ask_other_readmes(\$sbo, \$location);

ask_other_readmes() checks for secondary README files for \$sbo in
\$location. It displays the files one by one upon prompt.

### ask_user_group

    my $bool = ask_user_group($cmds, $readme);

ask_user_group() displays the \$readme and commands found in \$cmds, and
prompts for running the \"useradd\" and \"groupadd\" commands found. If
so, the \$cmds are returned; the return is otherwise \"undef\".

### get_opts

    my $bool = get_opts($readme);

get_opts() checks the \$readme for defined options in the form
KEY=VALUE. It returns a true value if any are found, and a false value
otherwise.

### get_readme_contents

    my $contents = get_readme_contents($location);

get_readme_contents() opens the README file in \$location and returns
its contents. On error, it returns \"undef\".

### get_user_group

    my \@cmds = \@{ get_user_group($readme) };

get_user_group() searches the \$readme for \"useradd\" and \"groupadd\"
commands, and returns them in an array reference.

### user_prompt

    my ($cmds, $opts, $exit) = user_prompt($sbo, $location);

user_prompt() is the main point of access to the other commands in
\"Readme.pm\". It calls subroutines to find options and commands, and
then prompts the user for installation. Three values are potentially
returned.

In case of error, the first is the error message and the third is a true
value.

If the user refuses the prompt to build \$sbo, the first value is \'N\'.

If \$sbo is to be built, the first value is the commands that would run
in advance, or \$undef if none. The second value contains build options.

**Note**: This should really be changed.

**Note**: The previous note is old. I (KEC) agree that this module is
asked to do quite a lot. Keeping it in place might be the most
parsimonious thing to do, but I have yet to look into the question
closely.

## EXIT CODES

Readme.pm subroutines can return the following exit codes:

\_ERR_USAGE 1 usage errors\
\_ERR_SCRIPT 2 script or module bug\
\_ERR_OPENFH 6 failure to open file handles

## SEE ALSO

[SBO::Lib(3)](Lib.3.md), [SBO::Lib::Build(3)](Build.3.md), [SBO::Lib::Download(3)](Download.3.md),
[SBO::Lib::Info(3)](Info.3.md), [SBO::Lib::Pkgs(3)](Pkgs.3.md), [SBO::Lib::Pkgs(3)](Pkgs.3.md),
[SBO::Lib::Repo(3)](Repo.3.md), [SBO::Lib::Tree(3)](Tree.3.md), [SBO::Lib::Util(3)](Util.3.md)

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
