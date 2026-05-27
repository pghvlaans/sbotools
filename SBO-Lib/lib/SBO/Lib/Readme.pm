package SBO::Lib::Readme;

# vim: ts=2:et

use 5.016;
use strict;
use warnings;

our $VERSION = '4.1.4';

use SBO::Lib::Build qw/ $tempdir /;
use SBO::Lib::Util qw/ :const :colors error_code in prompt script_error slurp open_read open_fh uniq usage_error wrapsay %config /;
use SBO::Lib::Tree qw/ is_local /;

use Exporter 'import';
use File::Basename;
use File::Temp qw/ tempfile /;

our @EXPORT_OK = qw{
  ask_opts
  ask_previous
  display_readmes
  ask_user_group
  get_readme_contents
  get_user_group
  user_group_do_not_exist
  user_prompt
  validate_user_group
};

our %EXPORT_TAGS = (
  all => \@EXPORT_OK,
);

=pod

=encoding UTF-8

=head1 NAME

SBO::Lib::Readme - Routines for interacting with a typical SBo README file.

=head1 SYNOPSIS

  use SBO::Lib::Readme qw/ get_readme_contents /;

  print get_readme_contents($sbo);

=head1 SUBROUTINES

=cut

my @no_prompt = (
  "SRCVER",
  "BUILD",
  "OUTPUT",
  "PKGTYPE",
  "TAG",
  "TMP",
  "VERSION",
  "PATH",
  "LD_LIBRARY_PATH",
  "PYVER",
);

=head2 ask_opts

  my $opts = ask_opts($sbo, $location);

Users may be prompted to add options if saved options are not to be retrieved, provided
that a C<README> file associated with the script contains a variable assignment of the
form C<WORD=> (any case and accounts for quotes). The prompt appears if the SlackBuild
accepts the variable name from the environment, the C<README> shows an example of
calling the SlackBuild with the variable or the phrase "to the script/SlackBuild"
follows.

An option string is returned, if set.

=cut

# provide an opportunity to set options or retrieve previously-used options
sub ask_opts {
  script_error('ask_opts requires two arguments.') unless @_ == 2;
  my ($sbo, $location) = @_;
  my $real_name = $sbo;
  my @readmes = sort glob "$location/README*";
  my $readmes = @readmes;
  unless (@readmes) {
    wrapsay_color $color_lesser, "$sbo has no README files.";
    return ();
  }
  my $can_prompt;
  my $readme;
  my @check_terms;
  for (@readmes) {
    my $next_readme = slurp $_;
    if (defined $next_readme) {
      $readme = defined $readme ? $readme . "\n" . $next_readme : $next_readme;
    }
  }
  my @readme = split "=", $readme;
  return() unless @readme > 1;
  my $count = 0;
  for (@readme) {
    last if ++$count eq @readme;
    my @line = split " ", $_;
    next unless defined $line[-1];
    next unless $line[-1] =~ /^(|\(|\[|"|'|`|)+[\w]+$/ and $readme[$count] =~ /^[^\s]/;
    $line[-1] =~ s/(|"|'|`|\[|\()//g;
    next if in $line[-1], @no_prompt;
    if ($line[-1] =~ /^VAR/) {
      $can_prompt = 1;
      last;
    }
    if ($readme[$count] =~ /((|ba)sh\s|\.\/)\Q$real_name\E.SlackBuild/i or $readme[$count] =~ /to the (script|SlackBuild)/i) {
      $can_prompt = 1;
      last;
    }
    push @check_terms, $line[-1];
  }
  unless ($can_prompt) {
    my $slackbuild_location = "$location/$real_name.SlackBuild";
    my $slackbuild = slurp $slackbuild_location;
    return 0 unless defined $slackbuild;
    for (@check_terms) {
      if ($slackbuild =~ /[\W]+(\$\Q$_\E[\W]+|\Q$_\E(\Q^^\E|\Q,,\E|\}|:(|-|=)))/) {
        $can_prompt = 1;
        last;
      }
    }
  }
  return() unless $can_prompt;
  if (prompt($color_notice, "\n$sbo appears to have options; set options for running the SlackBuild?", default => 'no')) {
    my $ask = sub {
      chomp(my $opts = prompt($color_default, "\nPlease supply any options here, or press Enter to skip: "));
      return $opts;
    };
    my $kv_regex = qr/[\w]+=[^\s]+(|\s([\w]+=[^\s]+){0,})/;
    my $opts = $ask->();
    return() unless $opts;
    while ($opts !~ $kv_regex) {
      warn_color $color_lesser, "Invalid input received.";
      $opts = $ask->();
      return() unless $opts;
    }
    return $opts;
  }
  return();
}

=head2 ask_previous

  my $opts = ask_previous($sbo);

C<ask_previous()> takes the name of a SlackBuild and checks for saved options
under the C</var/log/sbotools> directory. If options have been saved, the user
is prompted for reuse. The saved options are returned if yes.

=cut

sub ask_previous {
  script_error('ask_previous requires one argument.') unless @_ == 1;
  my ($sbo) = shift;
  my $real_name = $sbo;
  $real_name =~ s/-compat32$//;
  my $opts_log = "/var/log/sbotools/$real_name";
  if (-f $opts_log) {
    my ($fh, $exit) = open_fh($opts_log, '<');
    if ($exit) {
      warn_color $color_lesser, $fh;
    } else {
      my $prev_opts = <$fh>;
      if ($config{CLASSIC} ne "TRUE") {
        wrapsay_color $color_notice, "\nOptions were previously specified for $sbo:\n";
        wrapsay "\n$prev_opts\n";
        if (prompt($color_notice, "\nUse these options to build $sbo?", default => 'yes')) {
          my $opts = $prev_opts;
          return $opts;
        }
      }
    }
  }
}

=head2 ask_user_group

  my $bool = ask_user_group($cmds);

C<ask_user_group()> takes the C<useradd(1)> and C<groupadd(1)> commands found in a
C<README> file and calls C<user_group_do_not_exist()>; if at least one of the specified
users or groups does not exist, it prompts for running the commands. If yes,
the C<$cmds> are returned, and C<undef> otherwise.

=cut

# offer to run any user/group add commands
sub ask_user_group {
  script_error('ask_user_group requires an argument') unless @_;
  my $cmds = shift;
  my $nonexistent = user_group_do_not_exist(@$cmds);
  unless (@$nonexistent) {
    wrapsay "\nRequired user(s) and group(s) already exist.";
    return undef;
  } else {
    wrapsay_color $color_lesser, "\nThis SlackBuild requires the following command(s) to be run first:";
    say "    # $_" for @$nonexistent;
    return prompt($color_lesser, 'Run the command(s) prior to building?', default => 'yes') ? $nonexistent : undef;
  }
}

=head2 display_readmes

  display_readmes($sbo, $location);

C<display_readmes()> checks for README files in C<$location>. It displays C<README> in
all cases, and additional files one by one in alphabetical order upon prompt.

=cut

sub display_readmes {
  script_error('display_readmes requires two arguments.') unless @_ == 2;
  my ($sbo, $location) = @_;
  my @readmes = sort glob "$location/README*";
  return unless @readmes;
  my (@display_readmes, @display_fns);
  for (@readmes) {
    my $display_fn = basename $_;
    if (chomp(my $display = slurp $_)) {
      push @display_readmes, $display;
      push @display_fns, $display_fn
    } else {
      wrapsay_color $color_lesser, "$display_fn exists, but is empty or could not be read.";}
    }
  return unless @display_readmes;

  my $readme_count = @display_readmes;
  my $count = 0;

  for my $fn (@readmes) {
    my $display_count = $count + 1;
    my $next = $display_count + 1;
    wrapsay_color $color_notice, "\n$sbo: $display_fns[$count] ($display_count of $readme_count)";
    say $display_readmes[$count];
    $count++;
    return if $count eq @readmes;
    my $next_fn = $display_fns[$count];
    return unless (prompt($color_notice, "\nView $display_fns[$count]? ($next of $readme_count)", default => 'yes'));
  }
}

=head2 get_readme_contents

  my $contents = get_readme_contents($location);

C<get_readme_contents()> opens the README file in C<$location> and returns
its contents. On error, it returns C<undef>.

=cut

sub get_readme_contents {
  script_error('get_readme_contents requires an argument.') unless @_ == 1;
  return undef unless defined $_[0];
  my $readme = slurp(shift . '/README');
  return $readme;
}

=head2 get_user_group

  my @cmds = @{ get_user_group($sbo, $location, $opts) };

C<get_user_group()> searches the C<SlackBuild> for C<$sbo> in C<$location>
for C<useradd(1)> and C<groupadd(1)> commands, and returns them in an array
reference. If no commands are found initially, it searches any C<README*>
files for them.

Some SlackBuilds allow the user to set user and group names and ID numbers
with variables. Optionally pass an option string C<$opt> if interactive or
if an existing build options file is to be used.

=cut

# look for any (user|group)add commands in the README files and
# SlackBuild
sub get_user_group {
  script_error('get_user_group requires at least two arguments.') unless @_ > 1;
  my ($sbo, $location, $opts) = @_;
  my @cmds;
  $sbo =~ s/-compat32$//;
  my $slackbuild_file = "$location/$sbo.SlackBuild";
  my $slackbuild = slurp $slackbuild_file;
  my @slackbuild = split "\n", $slackbuild;
  $slackbuild =~ s/('|"|`)\n/\n/g;
  $slackbuild =~ s/useradd/\nuseradd/g;
  $slackbuild =~ s/groupadd/\ngroupadd/g;
  my @preliminary_cmds = $slackbuild =~ /^(useradd.*?|groupadd.*?)(?<!\\)\n/msg;
  @cmds = verify_user_group(@preliminary_cmds) if @preliminary_cmds;
  unless (@cmds) {
    my @readmes = sort glob "$location/README*";
    if (@readmes) {
      for my $other_file (@readmes) {
        my $readme = slurp $other_file;
        $readme =~ s/'//g;
        $readme =~ s/('|"|`)\n/\n/g;
        $readme =~ s/useradd/\nuseradd/g;
        $readme =~ s/groupadd/\ngroupadd/g;
        @preliminary_cmds = $readme =~ /^(useradd.*?|groupadd.*?)(?<!\\)\n/msg;
        @cmds = verify_user_group(@preliminary_cmds) if @preliminary_cmds;
        last if @cmds;
      }
    }
  }
  @cmds = uniq sort @cmds if @cmds;
  # everything from here on down is for SlackBuilds with
  # variable user and group names, of which there were about
  # twenty as of December 2025
  my $needs_parse = 0;
  for (@cmds) {
    if ($_ =~ /\$/) {
      $needs_parse = 1;
      last;
    }
  }
  if ($needs_parse) {
    my @parse_script;
    for (@slackbuild) { push @parse_script, $_ if $_ =~ /^\S+=/ and not $_ =~ /^#/ and not $_ =~ /^\S+\s+[^#]+$/; }
    if (@parse_script) {
      my $echo_string;
      for (@cmds) {
        my $escaped_cmd = $_;
        $escaped_cmd =~ s/(?=[^\\])"/\\"/g;
        $escaped_cmd =~ s/(?=[^\\])'/\\'/g;
        push @parse_script, "echo $escaped_cmd";
      }
      my ($fh, $parse_script) = tempfile(DIR => "/tmp");
      my $exit;
      ($fh, $exit) = open_fh($parse_script, '>');
      error_code("SlackBuild had variable UID/GID specifications, and writing a parse script failed.", _ERR_OPENFH) if $exit;
      print {$fh} "$_\n" for (@parse_script);
      close $fh;
      my @parse_output;
      if ($opts) {
        @parse_output = split "\n", `$opts /bin/bash $parse_script`;
      } else {
        @parse_output = split "\n", `/bin/bash $parse_script`;
      }
      unlink $parse_script;
      @cmds = @parse_output if @parse_output;
    }
  }
  return \@cmds;
}

=head2 user_group_do_not_exist

  my @nonexistent = @{ user_group_do_not_exist(@cmds) };

C<user_group_do_not_exist()> takes an array of sugested commands generated by C<get_user_group()>,
returning those that do not exist on the system in an array reference.

=cut

sub user_group_do_not_exist {
  script_error('user_group_do_not_exist requires an argument.') unless @_;
  my @cmds = @_;
  my @nonexistent;
  FIRST: for my $cmd (@cmds) {
    my @cmd = split(' ', $cmd);
    my @existent;
    my $type = shift @cmd;
    my $person = pop @cmd;
    my $file = $type eq "useradd" ? "/etc/passwd" : "/etc/group";
    my ($fh, $exit) = open_fh($file, '<');
    if ($exit) {
      # If this happens, the user has much more urgent problems
      # than installing a SlackBuild!
      error_code("$file could not be opened for reading.", _ERR_OPENFH);
    } else {
      for my $line (<$fh>) {
        my @words = split(':', $line);
        if (shift @words eq $person) {
          close $fh;
          next FIRST;
        }
      }
      push @nonexistent, $cmd;
      close $fh;
    }
  }
  @nonexistent = uniq @nonexistent;
  return \@nonexistent;
}

=head2 user_prompt

  my ($proceed, $cmds, $opts) = user_prompt($sbo, $location, $get_only);

C<user_prompt()> is the main point of access to the other commands in C<Readme.pm>.
Except in the download-only case, it calls subroutines to find options and commands,
and then prompts the user for installation. It returns the answer to the installation
prompt (true for 'yes' and false for 'no'), the list of commands and the list of
options.

=cut

# for a given sbo, check for cmds/opts, prompt the user as appropriate
sub user_prompt {
  script_error('user_prompt requires three arguments.') unless @_ == 3;
  my ($sbo, $location, $get_only) = @_;
  my $cmds;
  my $opts = 0;
  unless (defined $location) { usage_error("Unable to locate $sbo in the SlackBuilds.org tree."); }
  wrapsay_color $color_lesser, "\nFound $sbo in local overrides." if is_local($sbo);
  display_readmes($sbo, $location);
  my $prel_opts;
  unless ($get_only) {
    $prel_opts = ask_previous($sbo);
    $prel_opts = $prel_opts ? $prel_opts : ask_opts($sbo, $location);
  }
  chomp($opts = $prel_opts) if $prel_opts;
  # check for user/group add commands, offer to run any found
  my $user_group = get_user_group($sbo, $location, $opts) unless $get_only;
  $cmds = ask_user_group($user_group) if not $get_only and $$user_group[0];
  my $proceed_label = $get_only ? "Download source for" : "Proceed with";
  my $proceed = prompt($color_notice, "\n$proceed_label $sbo?", default => 'yes');
  return $proceed, $cmds, $opts;
}

=head2 verify_user_group

  my @cmds = verify_user_group(@preliminary_cmds);

C<verify_user_group()> checks for required options and sanitizes C<useradd> and
C<groupadd> commands found in C<SlackBuilds> and C<README> files. An array with
correct commands is returned.

=cut

sub verify_user_group {
  script_error("verify_user_group requires an argument.") unless @_;
  my @preliminary_cmds = @_;
  my @cmds;
  for (@preliminary_cmds) {
    if ($_ =~ /^useradd/) {
      next unless $_ =~ /-u\s[^-]/;
    } else {
      next unless $_ =~ /-g\s[^-]/;
    }
    $_ =~ s/(\\(n|t)|#\s*$)//g;
    $_ =~ s/\\"/"/g;
    if ($_ =~ /^useradd/ and not $_ =~ /-g/) {
      my @useradd = split " ", $_;
      my $user = pop @useradd;
      push @useradd, "-g", $user, $user;
      $_ = join " ", @useradd;
    }
    push @cmds, $_;
  }
  return @cmds;
}

=head1 EXIT CODES

Readme.pm subroutines can return the following exit codes:

  _ERR_USAGE         1   usage errors
  _ERR_SCRIPT        2   script or module bug
  _ERR_OPENFH        6   failure to open file handles
  _ERR_STDIN         16  reading keyboard input failed

=head1 SEE ALSO

SBO::Lib(3), SBO::Lib::Build(3), SBO::Lib::Download(3), SBO::Lib::Info(3), SBO::Lib::Pkgs(3), SBO::Lib::Repo(3), SBO::Lib::Solibs(3), SBO::Lib::Tree(3), SBO::Lib::Util(3), groupadd(1), useradd(1)

=head1 AUTHORS

SBO::Lib was originally written by Jacob Pipkin <jacob.pipkin@icloud.com> with
contributions from Luke Williams <xocel@iquidus.org> and Andreas
Guldstrand <andreas.guldstrand@gmail.com>.

=head1 MAINTAINER

SBO::Lib is maintained by K. Eugene Carlson <kvngncrlsn@gmail.com>.

=head1 LICENSE

The sbotools are licensed under the MIT License.

Copyright (C) 2012-2017, Jacob Pipkin, Luke Williams, Andreas Guldstrand.

Copyright (C) 2024-2026, K. Eugene Carlson.

Copyright (C) 2026, K. Eugene Carlson, Jacob Pipkin.

=cut

1;
