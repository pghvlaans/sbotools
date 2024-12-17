package SBO::App::Remove;

# vim: ts=2:et
#
# authors: Luke Williams <xocel@iquidus.org>
#          Jacob Pipkin <j@dawnrazor.net>
#          Andreas Guldstrand <andreas.guldstrand@gmail.com>
# maintainer: K. Eugene Carlson <kvngncrlsn@gmail.com>
# license: MIT License

use 5.16.0;
use strict;
use warnings FATAL => 'all';
use SBO::Lib qw/ get_inst_names get_installed_packages get_sbo_location get_build_queue get_full_queue merge_queues get_required_by get_requires get_readme_contents get_reverse_reqs prompt show_version in lint_sbo_home /;
use Getopt::Long qw(GetOptionsFromArray :config bundling);

use parent 'SBO::App';

our $VERSION = '3.1';

lint_sbo_home();

sub _parse_opts {
  my $class = shift;
  my @ARGS = @_;

  my ($help, $vers, $alwaysask);

  GetOptionsFromArray(
    \@ARGS,
    'help|h'        => \$help,
    'version|v'     => \$vers,
    'alwaysask|a'   => \$alwaysask,
  );

  return { help => $help, vers => $vers, alwaysask => $alwaysask, args => \@ARGS, };
}

sub run {
  my $self = shift;

  if ($self->{help}) { $self->show_usage(); return 0; }
  if ($self->{vers}) { $self->show_version(); return 0; }
  if (!@{ $self->{args} }) { $self->show_usage(); return 1; }

  # current workflow:
  # * get names of all installed SBo packages
  # * compare commandline args to SBo packages as well as installed SBo packages
  # * add reverse deps to list if they're not a dep of something else (which is not also already on the list)
  # * confirm removal of each package on the list
  #   - while taking into account the options passed in such as $alwaysask
  #   - also offering to display README if %README% is passed
  # * remove the confirmed packages

  my @args = @{ $self->{args} };

  my @installed = @{ get_installed_packages('SBO') };
  my $installed = +{ map {; $_->{name}, $_->{pkg} } @installed };

  @args = grep { check_sbo($_, $installed) } @args;
  exit 1 unless @args;
  my %sbos = map { $_ => 1 } @args;

  my @remove = get_full_queue($installed, @args);

  my @confirmed;

  my $required_by = get_reverse_reqs($installed);
  for my $remove (@remove) {
    # if $remove was on the commandline, mark it as not needed,
    # otherwise check if it is needed by something else.
    my @required_by = get_required_by($remove->{name}, [map { $_->{name} } @confirmed], $required_by);
    my $needed = $sbos{$remove->{name}} ? 0 : @required_by;

    next if $needed and not $self->{alwaysask};

    push @confirmed, $remove if confirm($remove, $needed ? @required_by : ());
  }

  if (@confirmed) {
    $self->remove(@confirmed);
  } else {
    say "Nothing to remove.";
  }

  return 0;
}

sub show_usage {
  my $self = shift;
  my $fname = $self->{fname};

	print <<"EOF";
Usage: $fname [options] sbo

Options (defaults shown first where applicable):
  -h|--help:
    this screen.
  -v|--version:
    version information.
  -a|--alwaysask:
    always ask to remove, even if required by other packages on system.

Note: optional dependencies need to be removed separately.

EOF
	return 1;
}

sub check_sbo {
  my ($sbo, $installed) = @_;

  if (not get_sbo_location($sbo)) {
    say "Unable to locate $sbo in the slackbuilds.org tree.";
    return 0;
  }

  if (not exists $installed->{$sbo}) {
    say "$sbo is not installed from slackbuilds.org.";
    return 0;
  }

  return 1;
}

sub confirm {
  my ($remove, @required_by) = @_;

  if (@required_by) {
    say sprintf "%s : required by %s", $remove->{name}, join ' ', @required_by;
  } else {
    say $remove->{name};
  }

  if ($remove->{warning}) {
    say "Viewing the README before continuing is recommended.";
    if (prompt("Display README now?", default => 'yes')) {
      my $readme = get_readme_contents(get_sbo_location($remove->{name}));
      if (not defined $readme) {
        warn "Unable to open README for $remove->{name}.\n";
      } else {
        print "\n" . $readme;
      }
    }
  }

  if (prompt("Remove $remove->{name}?", default => @required_by ? 'no' : 'yes')) {
    say " * Added to remove queue.\n";
    return 1;
  }
  say " * Ignoring.\n";
  return 0;
}

sub remove {
  my $self = shift;
  my @confirmed = @_;

  say sprintf "Removing %d package(s).", scalar @confirmed;
  say join " ", map { $_->{name} } @confirmed;

  if (!prompt("\nAre you sure you want to continue?", default => 'no')) {
    return say 'Exiting.';
  }

  system("/sbin/removepkg", $_->{pkg}) for @confirmed;

  say "All operations have completed successfully.";
}

1;
