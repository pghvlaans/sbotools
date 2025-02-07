package SBO::Lib::Readme;

use 5.016;
use strict;
use warnings;

our $VERSION = '3.4.2';

use SBO::Lib::Util qw/ prompt script_error slurp open_read open_fh _ERR_OPENFH usage_error wrapsay %config /;
use SBO::Lib::Tree qw/ is_local /;

use Exporter 'import';

our @EXPORT_OK = qw{
  ask_opts
  ask_other_readmes
  ask_user_group
  get_opts
  get_readme_contents
  get_user_group
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

C<ask_opts()> displays  C<$readme> and asks if options should be set. If no options
are set, it returns C<undef>. Saved options under C</var/log/sbotools/$sbo> are retrieved
and can be used again.

=cut

# provide an opportunity to set options or retrieve previously-used options
sub ask_opts {
  # TODO: check number of args
  script_error('ask_opts requires an argument.') unless @_;
  my ($sbo, $readme) = @_;
  say "\n". $readme;
  my ($opts_log) = "/var/log/sbotools/$sbo";
  my ($opts_bk) = "$opts_log.bk";
  if (-f $opts_log) {
    my ($prev_fh, $exit) = open_fh($opts_log, '<');
    if ($exit) {
      warn $prev_fh;
    } else {
      my $prev_opts = <$prev_fh>;
      if ($config{CLASSIC} ne "TRUE") {
        if (prompt("It looks like options were previously specified for $sbo:\n\n$prev_opts\n\nWould you like to use these options to build $sbo?", default => 'no')) {
          my $opts = $prev_opts;
	  return $opts;
        }
      }
    }
  }
  if (prompt("\nIt looks like $sbo has options; would you like to set any when the slackbuild is run?", default => 'no')) {
    my $ask = sub {
      chomp(my $opts = prompt("\nPlease supply any options here, or press Enter to skip: "));
      return $opts;
    };
    my $kv_regex = qr/[A-Z0-9]+=[^\s]+(|\s([A-Z]+=[^\s]+){0,})/;
    my $opts = $ask->();
    return() unless $opts;
    while ($opts !~ $kv_regex) {
      warn "Invalid input received.\n";
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
  my ($sbo, $location) = @_;
  my @readmes = sort grep { ! m!/README$! } glob "$location/README*";

  return unless @readmes;

  return unless prompt("\nIt looks like $sbo has additional README files. Would you like to view those as well?", default => 'yes');

  for my $fn (@readmes) {
    my ($display_fn) = $fn =~ m!/(README.*)$!;
    say "\n$display_fn:";
    say slurp $fn;
  }
}

=head2 ask_user_group

  my $bool = ask_user_group($cmds, $readme);

C<ask_user_group()> displays the C<$readme> and commands found in C<$cmds>, and
prompts for running the C<useradd> and C<groupadd> commands found. If so, the C<$cmds> are
returned; the return is otherwise C<undef>.

=cut

# offer to run any user/group add commands
sub ask_user_group {
  script_error('ask_user_group requires two arguments') unless @_ == 2;
  my ($cmds, $readme) = @_;
  say "\n". $readme;
  wrapsay "\nIt looks like this slackbuild requires the following command(s) to be run first:";
  say "    # $_" for @$cmds;
  return prompt('Run the commands prior to building?', default => 'yes') ? $cmds : undef;
}

=head2 get_opts

  my $bool = get_opts($readme);

C<get_opts()> checks the C<$readme> for defined options in the form KEY=VALUE.
It returns a true value if any are found, and a false value otherwise.

=cut

# see if the README mentions any options
sub get_opts {
  script_error('get_opts requires an argument.') unless @_ == 1;
  my $readme = shift;
  return $readme =~ /[A-Z0-9]+=[^\s]/ ? 1 : undef;
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

  my @cmds = @{ get_user_group($readme) };

C<get_user_group()> searches the C<$readme> for C<useradd> and
C<groupadd> commands, and returns them in an array reference.

=cut

# look for any (user|group)add commands in the README
sub get_user_group {
  script_error('get_user_group requires an argument.') unless @_ == 1;
  my $readme = shift;
  my @cmds = $readme =~ /^\s*#*\s*(useradd.*?|groupadd.*?)(?<!\\)\n/msg;
  return \@cmds;
}

=head2 user_prompt

  my ($cmds, $opts, $exit) = user_prompt($sbo, $location);

C<user_prompt()> is the main point of access to the other commands in C<Readme.pm>.
It calls subroutines to find options and commands, and then prompts the user for
installation. Three values are potentially returned.

In case of error, the first is the error message and the third is a true value.

If the user refuses the prompt to build C<$sbo>, the first value is C<'N'>.

If C<$sbo> is to be built, the first value is the commands that would run
in advance, or C<$undef> if none. The second value contains build options.

B<Note>: This should really be changed.

B<Note>: The previous note is old. I (KEC) agree that this subroutine is asked to do
quite a lot. Keeping it in place might be the most parsimonious thing to do, but I
have yet to look into the question closely.

=cut

# for a given sbo, check for cmds/opts, prompt the user as appropriate
sub user_prompt {
  script_error('user_prompt requires two arguments.') unless @_ == 2;
  my ($sbo, $location) = @_;
  if (not defined $location) { usage_error("Unable to locate $sbo in the SlackBuilds.org tree."); }
  my $readme = get_readme_contents($location);
  return "Could not open README for $sbo.", undef, _ERR_OPENFH if not defined $readme;
  if (is_local($sbo)) { print "\nFound $sbo in local overrides.\n"; }
  # check for user/group add commands, offer to run any found
  my $user_group = get_user_group($readme);
  my $cmds;
  $cmds = ask_user_group($user_group, $readme) if $$user_group[0];
  # check for options mentioned in the README
  my $opts = 0;
  $opts = ask_opts($sbo, $readme) if get_opts($readme);
  print "\n". $readme unless $opts;
  ask_other_readmes($sbo, $location);
  # we have to return something substantial if the user says no so that we
  # can check the value of $cmds on the calling side. we should be able to
  # assume that 'N' will  never be a valid command to run.
  return 'N' unless prompt("\nProceed with $sbo?", default => 'yes');
  return $cmds, $opts;
}

=head1 EXIT CODES

Readme.pm subroutines can return the following exit codes:

  _ERR_USAGE         1   usage errors
  _ERR_SCRIPT        2   script or module bug
  _ERR_OPENFH        6   failure to open file handles

=head1 SEE ALSO

SBO::Lib(3), SBO::Lib::Build(3), SBO::Lib::Download(3), SBO::Lib::Info(3), SBO::Lib::Pkgs(3), SBO::Lib::Repo(3), SBO::Lib::Tree(3), SBO::Lib::Util(3)

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
