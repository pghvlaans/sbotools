package SBO::Lib::Readme;

# vim: ts=2:et

use 5.016;
use strict;
use warnings;

our $VERSION = '4.0';

use SBO::Lib::Util qw/ :const :colors error_code prompt script_error slurp open_read open_fh usage_error wrapsay %config /;
use SBO::Lib::Tree qw/ is_local /;

use Exporter 'import';
use File::Basename;

our @EXPORT_OK = qw{
  ask_opts
  ask_other_readmes
  ask_user_group
  get_readme_contents
  get_user_group
  user_group_exist
  user_prompt
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

=head2 ask_opts

  my $opts = ask_opts($sbo, $readme);

C<ask_opts()> asks if options should be set. If no options are set, it returns C<undef>.
Saved options under C</var/log/sbotools/$sbo> are retrieved and can be used again. For
C<compat32> packages, saved options are shared with the base script.

=cut

# provide an opportunity to set options or retrieve previously-used options
sub ask_opts {
  script_error('ask_opts requires at least one argument.') unless @_;
  my ($sbo, $readme) = @_;
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
        wrapsay_color $color_notice, "\nIt looks like options were previously specified for $sbo:\n";
        wrapsay "\n$prev_opts\n";
        if (prompt($color_notice, "\nWould you like to use these options to build $sbo?", default => 'yes')) {
          my $opts = $prev_opts;
          return $opts;
        }
      }
    }
  }
  return() unless $readme =~ /[A-Z0-9]+=[^\s]/;
  if (prompt($color_notice, "\nIt looks like $sbo has options; would you like to set any when the slackbuild is run?", default => 'no')) {
    my $ask = sub {
      chomp(my $opts = prompt($color_default, "\nPlease supply any options here, or press Enter to skip: "));
      return $opts;
    };
    my $kv_regex = qr/[A-Z0-9]+=[^\s]+(|\s([A-Z]+=[^\s]+){0,})/;
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

=head2 ask_other_readmes

  ask_other_readmes($sbo, $location);

C<ask_other_readmes()> checks for secondary README files for C<$sbo> in C<$location>.
It displays the files one by one upon prompt.

=cut

sub ask_other_readmes {
  script_error('ask_other_readmes requires two arguments.') unless @_ == 2;
  my ($sbo, $location) = @_;
  my @readmes = sort glob "$location/README?*";

  return unless @readmes;

  return unless (prompt($color_notice, "\nIt looks like $sbo has additional README files. Would you like to view those as well?", default => 'yes'));

  for my $fn (@readmes) {
    my $display_fn = basename $fn;
    wrapsay_color $color_notice, "\n$display_fn:";
    say slurp $fn;
  }
}

=head2 ask_user_group

  my $bool = ask_user_group($cmds);

C<ask_user_group()> takes the C<useradd(1)> and C<groupadd(1)> commands found in a
C<README> file and calls C<user_group_exist()>; if at least one of the specified
users or groups does not exist, it prompts for running the commands. If yes,
the C<$cmds> are returned, and C<undef> otherwise.

=cut

# offer to run any user/group add commands
sub ask_user_group {
  script_error('ask_user_group requires an argument') unless @_;
  my $cmds = shift;
  my $already_exist = user_group_exist(@$cmds);
  if ($already_exist) {
    wrapsay "\nRequired user(s) and group(s) already exist.";
    return undef;
  } else {
    wrapsay_color $color_lesser, "\nIt looks like this SlackBuild requires the following command(s) to be run first:";
    say "    # $_" for @$cmds;
    return prompt($color_lesser, 'Run the commands prior to building?', default => 'yes') ? $cmds : undef;
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

  my @cmds = @{ get_user_group($readme, $location) };

C<get_user_group()> searches the C<$readme> in C<$location> for C<useradd(1)> and
C<groupadd(1)> commands, and returns them in an array reference. If no
commands are found initially, it searches any other C<README*> files for
them.

=cut

# look for any (user|group)add commands in the README files
sub get_user_group {
  script_error('get_user_group requires two arguments.') unless @_ == 2;
  my ($readme, $location) = @_;
  $readme =~ s/'//g;
  my @cmds = $readme =~ /^\s*#*\s*(useradd.*?|groupadd.*?)(?<!\\)\n/msg;
  unless (@cmds) {
    my @readmes = sort glob "$location/README?*";
    if (@readmes) {
      for my $other_file (@readmes) {
        my $other_readme = slurp $other_file;
        @cmds = $other_readme =~ /^\s*#*\s*(useradd.*?|groupadd.*?)(?<!\\)\n/msg;
        last if @cmds;
      }
    }
  }
  return \@cmds;
}

=head2 user_group_exist

  my $user_group_exist = user_group_exist(@cmds);

C<user_group_exist()> takes an array of sugested commands generated by C<get_user_group()>,
returning a true value if the user and group exist and an undefined value if they do not.

=cut

sub user_group_exist {
  script_error('user_group_exist requires an argument.') unless @_;
  my @cmds = @_;
  FIRST: for my $cmd (@cmds) {
    my @cmd = split(' ', $cmd);
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
      close $fh;
      return undef;
    }
  }
  return 1;
}

=head2 user_prompt

  my ($proceed, $cmds, $opts) = user_prompt($sbo, $location);

C<user_prompt()> is the main point of access to the other commands in C<Readme.pm>.
It calls subroutines to find options and commands, and then prompts the user for
installation. It returns the answer to the installation prompt (true for 'yes' and
false for 'no'), the list of commands and the list of options.

The script exits if a non-empty C<README> file cannot be read.

=cut

# for a given sbo, check for cmds/opts, prompt the user as appropriate
sub user_prompt {
  script_error('user_prompt requires two arguments.') unless @_ == 2;
  my ($sbo, $location) = @_;
  my $cmds;
  my $opts = 0;
  my $readme = 0;
  unless (defined $location) { usage_error("Unable to locate $sbo in the SlackBuilds.org tree."); }
  wrapsay_color $color_lesser, "\nFound $sbo in local overrides." if is_local($sbo);
  $readme = get_readme_contents($location);
  if (defined $readme) {
    print "\n". $readme;
    # check for user/group add commands, offer to run any found
    my $user_group = get_user_group($readme, $location);
    $cmds = ask_user_group($user_group, $readme) if $$user_group[0];
  } elsif (-s "$location/README") {
    error_code("Unable to open README for $sbo; exiting.", _ERR_OPENFH);
  } else {
    wrapsay_color $color_lesser, "\n$sbo has an empty or nonexistent README file.";
  }
  my $prel_opts = ask_opts($sbo, $readme);
  chomp($opts = $prel_opts) if $prel_opts;
  ask_other_readmes($sbo, $location) if $readme;
  my $proceed = prompt($color_notice, "\nProceed with $sbo?", default => 'yes');
  return $proceed, $cmds, $opts;
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

SBO::Lib was originally written by Jacob Pipkin <j@dawnrazor.net> with
contributions from Luke Williams <xocel@iquidus.org> and Andreas
Guldstrand <andreas.guldstrand@gmail.com>.

=head1 MAINTAINER

SBO::Lib is maintained by K. Eugene Carlson <kvngncrlsn@gmail.com>.

=head1 LICENSE

The sbotools are licensed under the MIT License.

Copyright (C) 2012-2017, Jacob Pipkin, Luke Williams, Andreas Guldstrand.

Copyright (C) 2024-2025, K. Eugene Carlson.

=cut

1;
