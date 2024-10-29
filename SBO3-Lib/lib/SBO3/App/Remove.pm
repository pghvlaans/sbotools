package SBO3::App::Remove;

# vim: ts=2:et
#
# authors: Luke Williams <xocel@iquidus.org>
#          Jacob Pipkin <j@dawnrazor.net>
#          Andreas Guldstrand <andreas.guldstrand@gmail.com>
# license: WTFPL <http://sam.zoy.org/wtfpl/COPYING>

use 5.16.0;
use strict;
use warnings FATAL => 'all';
use SBO3::Lib qw/ get_inst_names get_installed_packages get_sbo_location get_build_queue merge_queues get_requires get_readme_contents prompt show_version in /;
use Getopt::Long qw(GetOptionsFromArray :config bundling);

use parent 'SBO3::App';

our $VERSION = '1.0';

sub _parse_opts {
  my $class = shift;
  my @ARGS = @_;

  my ($help, $vers, $non_int, $alwaysask);

  GetOptionsFromArray(
    \@ARGS,
    'help|h'        => \$help,
    'version|v'     => \$vers,
    'nointeractive' => \$non_int,
    'alwaysask|a'   => \$alwaysask,
  );

  return { help => $help, vers => $vers, non_int => $non_int, alwaysask => $alwaysask, args => \@ARGS, };
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
  #   - while taking into account the options passed in such as $non_int, and $alwaysask
  #   - also offering to display README if %README% is passed
  # * remove the confirmed packages

  my @args = @{ $self->{args} };

  my @installed = @{ get_installed_packages('SBO3') };
  my $installed = +{ map {; $_->{name}, $_->{pkg} } @installed };

  @args = grep { check_sbo($_, $installed) } @args;
  exit 1 unless @args;
  my %sbos = map { $_ => 1 } @args;

  my @remove = get_full_queue($installed, @args);

  my @confirmed;

  if ($self->{non_int}) {
    @confirmed = @remove;
  } else {
    my $required_by = get_reverse_reqs($installed);
    for my $remove (@remove) {
      # if $remove was on the commandline, mark it as not needed,
      # otherwise check if it is needed by something else.
      my @required_by = get_required_by($remove->{name}, [map { $_->{name} } @confirmed], $required_by);
      my $needed = $sbos{$remove->{name}} ? 0 : @required_by;

      next if $needed and not $self->{alwaysask};

      push @confirmed, $remove if confirm($remove, $needed ? @required_by : ());
    }
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
    say "Unable to locate $sbo in the SlackBuilds.org tree.";
    return 0;
  }

  if (not exists $installed->{$sbo}) {
    say "$sbo is not installed from SlackBuilds.org.";
    return 0;
  }

  return 1;
}

sub get_full_queue {
  my ($installed, @sbos) = @_;

  my $remove_queue = [];
  my %warnings;
  for my $sbo (@sbos) {
    my $queue = get_build_queue([$sbo], \%warnings);
    @$queue = reverse @$queue;
    $remove_queue = merge_queues($remove_queue, $queue);
  }

  return map {; +{
      name => $_,
      pkg => $installed->{$_},
      defined $warnings{$_} ? (warning => $warnings{$_}) : ()
    } }
    grep { exists $installed->{$_} }
    @$remove_queue;
}

sub get_reverse_reqs {
  my $installed = shift;
  my %required_by;

  for my $inst (keys %$installed) {
    for my $req (@{ get_requires($inst) }) {
      $required_by{$req}{$inst} = 1 if exists $installed->{$req};
    }
  }

  return \%required_by;
}

sub get_required_by {
  my ($sbo, $confirmed, $required_by) = @_;
  my @dep_of;

  if ( $required_by->{$sbo} ) {
    for my $req_by (keys %{$required_by->{$sbo}}) {
      push @dep_of, $req_by unless in($req_by => @$confirmed);
    }
  }
  return @dep_of;
}

sub confirm {
  my ($remove, @required_by) = @_;

  if (@required_by) {
    say sprintf "%s : required by %s", $remove->{name}, join ' ', @required_by;
  } else {
    say $remove->{name};
  }

  if ($remove->{warning}) {
    say "It is recommended that you view the README before continuing.";
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
    say " * Added to remove queue\n";
    return 1;
  }
  say " * Ignoring\n";
  return 0;
}

sub remove {
  my $self = shift;
  my $non_int = $self->{non_int};
  my @confirmed = @_;

  say sprintf "Removing %d package(s)", scalar @confirmed;
  say join " ", map { $_->{name} } @confirmed;

  if (!$non_int and !prompt("\nAre you sure you want to continue?", default => 'no')) {
    return say 'Exiting.';
  }

  system("/sbin/removepkg", $_->{pkg}) for @confirmed;

  say "All operations have completed successfully.";
}

1;
