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
use SBO::Lib qw/ :colors get_installed_packages get_sbo_description get_sbo_locations get_sbo_location get_full_queue get_full_reverse get_readme_contents get_reverse_reqs in prompt show_version uniq lint_sbo_config error_code usage_error wrapsay %config @reverse_concluded $descriptions_generated /;
use Getopt::Long qw(GetOptionsFromArray :config bundling);

use parent 'SBO::App';

our $VERSION = '4.2.1';
our $options_ok;

sub _parse_opts {
  my $class = shift;
  my @ARGS = @_;

  my ($help, $vers, $alwaysask, $compat, $nocolor, $color, $nowrap, $wrap, $query, $no_desc);

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
    'query|q'       => \$query,
    'no-descriptions' => \$no_desc,
  );

  return { help => $help, vers => $vers, alwaysask => $alwaysask, compat => $compat, nocolor => $nocolor, color => $color, nowrap => $nowrap, wrap => $wrap, query => $query, no_desc => $no_desc, args => \@ARGS, };
}

sub run {
  my $self = shift;

  if ($self->{help}) {
    $self->show_usage();
    wrapsay "\nNon-root users can call sboremove with -q, -h and -v." unless $< == 0 or $self->{query};
    exit 0;
  }
  if ($self->{vers}) { $self->show_version(); return 0; }
  $config{COLOR} = $self->{color} ? 'TRUE' : 'FALSE' if $self->{color} xor $self->{nocolor};
  $config{NOWRAP} = $self->{nowrap} ? 'TRUE' : 'FALSE' if $self->{wrap} xor $self->{nowrap};
  if (!@{ $self->{args} }) {
    $self->show_usage();
    usage_error "\nNon-root users can call sboremove with -q, -h and -v." unless $< == 0 or $self->{query};
    usage_error "\nsboremove requires at least one argument.";
  }
  unless ($< == 0 or $self->{query}) {
    $self->show_usage();
    usage_error "\nNon-root users can call sboremove with -q, -h and -v.";
  }
  unless ($options_ok) {
    $self->show_usage();
    usage_error "\nOne or more invalid options detected.";
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
  # * compare commandline args to SBo and non-SBo packages
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
  my @installed_std = @{ get_installed_packages('STD') };
  my $installed_std = +{ map {; $_->{name}, $_->{pkg} } @installed_std };

  @args = grep { check_sbo($_, $installed_std) } @args;
  my $print_newline;
  for (@args) {
    unless (exists $installed->{$_}) {
      wrapsay_color $color_lesser, "$_ is not installed, but may have installed dependencies.";
      $print_newline = 1;
    }
  }
  print "\n" if $print_newline;
  unless (@args) { wrapsay_color $color_notice, "\nNothing to remove."; exit 0; }
  my %sbos = map { $_ => 1 } @args;

  my @remove = get_full_queue($installed, @args);
  unless (@remove) { wrapsay_color $color_notice, "\nNothing to remove."; exit 0; }

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
    # always prompt for requested scripts, even if they have reverse dependencies
    my $needed = $sbos{$remove->{name}} ? 0 : @required_by;

    next if $needed and not $self->{alwaysask};

    unless ($self->{query}) {
      push @confirmed, $remove if confirm($remove, $self, @required_by);
    } else {
      push @confirmed, $remove;
    }
  }

  if (@confirmed and not $self->{query}) {
    $self->remove(@confirmed);
  } elsif (@confirmed) {
    @confirmed = uniq @confirmed;
    wrapsay_color $color_notice, "Removal prompt order:";
    for (@confirmed) {
      my $description = get_sbo_description($_->{name}) unless $self->{no_desc};
      my $msg = defined $description ? "$_->{name} ($description)" : "$_->{name}";
      print "$msg\n";
    }
  } else {
    wrapsay_color $color_notice, "Nothing to remove.";
  }

  unless ($descriptions_generated or $self->{no_desc}) { wrapsay_color $color_lesser, "Run sbocheck to generate descriptions."; }

  return 0;
}

sub show_usage {
  my $self = shift;
  my $fname = $self->{fname};

	print <<"EOF";
Usage: $fname (options) sbo ...

Options (defaults shown first where applicable):
  -h|--help:
    this screen.
  -v|--version:
    version information.
  -a|--alwaysask:
    always ask to remove, even if required by other installed packages.
  --no-descriptions:
    do not show package descriptions.
  -p|--compat32:
    add -compat32 to all scripts on the command line.
  -q|--query:
    show the prospective removal prompt order and exit.

Note: optional dependencies need to be removed separately unless they are
specified in /etc/sbotools/sbotools.hints.
EOF
	return 1;
}

sub check_sbo {
  my ($sbo, $installed_std) = @_;

  unless (get_sbo_location($sbo)) {
    wrapsay_color $color_lesser, "Unable to locate $sbo in the SlackBuilds.org tree.";
    return 0;
  }

  if (exists $installed_std->{$sbo}) {
    wrapsay_color $color_lesser, "$sbo is not an SBo package. Skipping.";
    return 0;
  }

  return 1;
}

sub confirm {
  my ($remove, $self, @required_by) = @_;

  say $remove->{name};
  my $description = get_sbo_description($remove->{name}) unless $self->{no_desc};
  say $description if defined $description;

  if (@required_by) {
    wrapsay_color $color_warn, sprintf "Required by: %s", join ', ', @required_by;
  }

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

  my $grammar = @confirmed > 1 ? "packages" : "package";
  say sprintf "Removing %d $grammar.", scalar @confirmed;
  wrapsay join " ", map { $_->{name} } @confirmed;

  if (!prompt($color_warn, "\nAre you sure you want to continue?", default => 'no')) {
    return say "Exiting.";
  }

  system("/sbin/removepkg", $_->{pkg}) for @confirmed;

  wrapsay_color $color_notice, "All operations have completed successfully.";
}

1;
