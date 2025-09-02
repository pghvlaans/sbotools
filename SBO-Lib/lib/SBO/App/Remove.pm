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
use SBO::Lib qw/ :colors get_installed_packages get_sbo_description get_sbo_locations get_sbo_location get_full_queue get_full_reverse get_readme_contents get_reverse_reqs in prompt show_version lint_sbo_config error_code usage_error wrapsay %config @reverse_concluded /;
use Getopt::Long qw(GetOptionsFromArray :config bundling);

use parent 'SBO::App';

our $VERSION = '3.8.1';
our $options_ok;

sub _parse_opts {
  my $class = shift;
  my @ARGS = @_;

  my ($help, $vers, $alwaysask, $compat, $nocolor, $color, $nowrap, $wrap);

  $options_ok = GetOptionsFromArray(
    \@ARGS,
    'help|h'        => \$help,
    'version|v'     => \$vers,
    'alwaysask|a'   => \$alwaysask,
    'compat32|p'    => \$compat,
    'nocolor'       => \$nocolor,
    'color'         => \$color,
    'nowrap'        => \$nowrap,
    'wrap'          => \$wrap,
  );

  return { help => $help, vers => $vers, alwaysask => $alwaysask, compat => $compat, nocolor => $nocolor, color => $color, nowrap => $nowrap, wrap => $wrap args => \@ARGS, };
}

sub run {
  my $self = shift;

  if ($self->{help}) {
    $self->show_usage();
    wrapsay "This is a root-only script." unless $< == 0;
    exit 0;
  }
  if ($self->{vers}) { $self->show_version(); return 0; }
  $config{COLOR} = $self->{color} ? 'TRUE' : 'FALSE' if $self->{color} xor $self->{nocolor};
  $config{NOWRAP} = $self->{nowrap} ? 'TRUE' : 'FALSE' if $self->{wrap} xor $self->{nowrap};
  if (!@{ $self->{args} }) {
    $self->show_usage();
    usage_error "This is a root-only script." unless $< == 0;
  }
  unless ($< == 0) {
    $self->show_usage();
    usage_error "This is a root-only script.";
  }
  unless ($options_ok) {
    $self->show_usage();
    usage_error "One or more invalid options detected.";
  }

  lint_sbo_config($self, %config);
  get_sbo_locations();

  if ($config{LOCAL_OVERRIDES} ne "FALSE" and not -d $config{LOCAL_OVERRIDES}) {
    unless (prompt($color_lesser, "$config{LOCAL_OVERRIDES} is specified as the overrides directory, but does not exist.\nContinue anyway?", default => 'no')) {
      exit 1;
    }
  }

  # current workflow:
  # * get names of all installed SBo packages
  # * compare commandline args to SBo packages as well as installed SBo packages
  # * add reverse deps to list if they're not a dep of something else (which is not also already on the list)
  # * confirm removal of each package on the list
  #   - while taking into account the options passed in such as $alwaysask
  #   - also offering to display README if %README% is passed
  # * remove the confirmed packages

  my @prelim_args = @{ $self->{args} };
  my @args;
  if ($self->{compat}) {
    for my $sbo (@prelim_args) {
      push @args, "$sbo-compat32";
    }
  } else {
    @args = @prelim_args;
  }

  my @installed = @{ get_installed_packages('SBO') };
  my $installed = +{ map {; $_->{name}, $_->{pkg} } @installed };

  @args = grep { check_sbo($_, $installed) } @args;
  usage_error("sboremove requires at least one argument.") unless @args;
  my %sbos = map { $_ => 1 } @args;

  my @remove = get_full_queue($installed, @args);

  my @confirmed;

  my $required_by = get_reverse_reqs($installed);
  for my $remove (@remove) {
    # reset the shared array of concluded reverse queues
    splice @reverse_concluded;
    my @confirmed_names;
    push @confirmed_names, $_->{name} for @confirmed;
    my $check_name = $remove->{name};
    my @all_required_by = get_full_reverse($check_name, $installed, $required_by);
    my @required_by;
    for my $cand (@installed) {
      next unless in $cand->{name}, @all_required_by;
      # do not alert the user about being 'needed' by already-confirmed scripts
      push @required_by, $cand->{name} unless in $cand->{name}, @confirmed_names;
    }
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
Usage: $fname (options) sbo

Options (defaults shown first where applicable):
  -h|--help:
    this screen.
  -v|--version:
    version information.
  -a|--alwaysask:
    always ask to remove, even if required by other packages on system.
  -p|--compat32:
    remove compat32 scripts.

Note: optional dependencies need to be removed separately unless they are
specified in /etc/sbotools/sbotools.hints.

EOF
	return 1;
}

sub check_sbo {
  my ($sbo, $installed) = @_;

  unless (get_sbo_location($sbo)) {
    wrapsay "Unable to locate $sbo in the SlackBuilds.org tree.";
    return 0;
  }

  unless (exists $installed->{$sbo}) {
    wrapsay "$sbo is not installed from SlackBuilds.org.";
    return 0;
  }

  return 1;
}

sub confirm {
  my ($remove, @required_by) = @_;

  if (@required_by) {
    wrapsay sprintf "%s : required by %s", $remove->{name}, join ' ', @required_by;
  } else {
    say $remove->{name};
  }
  my $description = get_sbo_description($remove->{name});
  say $description if defined $description;

  if ($remove->{warning}) {
    wrapsay_color $color_lesser, "Viewing the README before continuing is recommended.";
    if (prompt($color_lesser, "Display README now?", default => 'yes')) {
      my $readme = get_readme_contents(get_sbo_location($remove->{name}));
      unless (defined $readme) {
        warn "Unable to open README for $remove->{name}.\n";
      } else {
        print "\n" . $readme;
      }
    }
  }

  my $default = "no";
  $default = "yes" unless @required_by;
  if (prompt($color_lesser, "Remove $remove->{name}?", default => $default)) {
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
  wrapsay join " ", map { $_->{name} } @confirmed;

  if (!prompt($color_warn, "\nAre you sure you want to continue?", default => 'no')) {
    return say "Exiting.";
  }

  system("/sbin/removepkg", $_->{pkg}) for @confirmed;

  wrapsay_color $color_notice, "All operations have completed successfully.";
}

1;
