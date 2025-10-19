package SBO::Lib::Help;

# vim: ts=2:et

use 5.016;
use strict;
use warnings;

our $VERSION = '4.0';

use Exporter 'import';

our @EXPORT_OK = qw{
  @help_batch
  @help_builds
  @help_clean
  @help_hints
  @help_list_mgmt
  @help_lists
  @help_main
  @help_operations
  @help_options
  @help_rebuilds
  @help_sboremove
  @help_search
  @help_solibs
};

our %EXPORT_TAGS = (
  all => \@EXPORT_OK,
);

our @help_batch = ('Installation - Help',

'Building queues can be done in either Batch or Interactive mode.

Running an installation or upgrade in Batch mode applies any saved build
options automatically and adds all needed items to the build queue
without prompting. The dry run is also displayed on the last
confimation screen if "Batch" is selected; reading it before starting a
batch operation is adivsed.

Selecting "Interactive" installs or upgrades the SlackBuilds
interactively. The user is prompted for the following at the command
line:

  * Adding items to the build queue
  * Applying saved build options or adding new ones (if applicable)
  * Adding missing users and groups

Packages without the "_SBo" tag are skipped automatically in Batch mode;
to deal with such packages, use "Replace" from the "Operations" screen
or run interactively.

Batch mode does not add missing users and groups; add them manually or
run interactively for a prompt.');

our @help_builds = ('Build Lists - Help',

'Select a SlackBuild from this screen to see its "Operations" menu. Use
the "Filter" button to search within the results.

"Filter" appears only for lists of more than one SlackBuild.');

our @help_clean = ('sboclean - Help',

'This menu interfaces with sboclean(1); three separate categories are
available to the root user for cleaning. Only applicable categories
are shown.

1. Distfiles

"Distfiles" are downloaded source files. They are stored in the
sbotools directory (default /usr/sbo) in md5-indexed directories under
distfiles, e.g. "/usr/sbo/distfiles/(md5)/source-1.1.tar.gz". Set the
sbotools DISTCLEAN setting to TRUE to delete source upon building.

2. Options

Build options are retained in "/var/log/sbotools" as per-script files.
A second dialog will appear with a list of SlackBuilds that have saved
options; choose one or more of these to remove the files (or "ALL" for
all saved options).

3. Working

"/tmp/SBo" is the default working directory; extracted source and
package directories are stored here. $TMP is used instead if it is set
in the user environment. Please note that everything in $TMP is deleted
if this option is used.');

our @help_hints = ('Hints - Help',

'sbotools recognizes three kinds of per-script hints. The root user can
add, modify and clear hints via the "Edit Hints" menu in the
"Operations" dialog for each SlackBuild.

1. Blacklist

Blacklisted SlackBuilds are not added to build queues, and sbotool does
not report them in the "Upgradable" list.

2. Auto-Rebuilds

If auto-rebuilding is turned on, offer to rebuild all reverse
dependencies of the SlackBuild when it is upgraded or otherwise rebuilt.

3. Optional Dependencies

A list of extra dependencies can be specified on a per-script basis.
The following dependency-related options may appear in "Edit Hints":

  Add Optional Deps:  Add one or more SlackBuilds to the list of
                      optional dependencies.
  Clear Optionals:    Remove one or more SlackBuilds from an existing
                      list.
  Clear all Optional: Remove the entire list of SlackBuilds.
  New Optional List:  Replace an existing list with a new one.

Please note that compat32 builds share hints with the corresponding
base SlackBuild.');

our @help_list_mgmt = ('List Management - Help',

'Use this screen to add or remove the SlackBuild from one or more of
these lists:

  * Install:  Build and install the SlackBuilds on the list.
  * Upgrade:  Upgrade the SlackBuilds on the list to the available
              version.
  * Remove:   Interactively remove listed SlackBuilds with unneeded
              dependencies.
  * Template: Make a template to install the SlackBuilds with
              "sboinstall --use-template" later.

Only applicable lists appear in the options. Use the "List Operations"
screen from Main Menu to implement or clear the lists.');

our @help_lists = ('List Operations - Help',

'Root users can place SlackBuilds on the Install, Upgrade and Remove
lists.  All users can place SlackBuilds on the Template list. List
operations use dependency resolution.

  * Install:  Build and install the SlackBuilds on the list.
  * Upgrade:  Upgrade the SlackBuilds on the list to the available
              version.
  * Remove:   Interactively remove listed SlackBuilds with unneeded
              dependencies.
  * Template: Make a template to install the SlackBuilds with
              "sboinstall --use-template" later.

Empty lists do not appear in the options. Use "Clear" to empty all of
the lists.');

our @help_main = ('Main Menu - Help',

'sbotool is a TUI to sbotools, a set of Perl scripts providing a Ports-
like interface to SlackBuilds.org. Although most sbotools functions can
be accomplished here, users are invited to view the man pages for the
individual tools to call them independently as well.

All sbotool menus are dynamic, and reflect available and potentially
effective operations. The following options can appear in Main Menu:

* Browse Repository
    View available SlackBuilds by series. Select a SlackBuild to see its
    "Operations" menu, which has per-script options and information. As
    in all lists of SlackBuilds, use the "Filter" button to search
    within the list.

* Clean sbotools Files
    Root only. Clean downloaded source, working directories or saved
    build options. Interactive and non-interactive deletion are both
    available.

* Fetch Repository
    Root only. Download or update the local copy of the SlackBuilds.org
    repository. See the "Settings" screen to use a non-default
    repository, git branch or location. Almost all sbotool options are
    unavailable until the repository has been fetched.

* Hints
    See active per-script hints. Root users can add, clear and edit
    hints for a SlackBuild by navigating to its "Operations" menu.

* Installed
    View, search and select installed in-tree SlackBuilds. Such
    packages installed without the "_SBo" or "_SBocompat32" tag are
    marked with "(NON-SBO)".

* List Operations
    SlackBuilds can be added to the Install, Upgrade, Remove and
    Template lists. Use this screen to perform the desired operation or
    clear the lists. Please note that all list operations have
    dependency resolution.

* Man Pages
    View sbotools-related man pages. They cover the individual tools
    and configuration files.

* Missing Solibs
    View, search and select SlackBuilds that have been found to have
    missing first-order shared object dependencies.

* Overrides
    View, search and select SlackBuilds in the local overrides
    directory. The LOCAL_OVERRIDES setting determines the location of
    the directory.

* Package Checks
    Perform a shared object dependency check on all _SBo packages or all
    installed packages. _SBo packages cna additionally be checked for
    perl, python and ruby incompatibilities. SlackBuilds with problems
    can be selected from "Missing Solibs", "Perl", "Python" or "Ruby"
    afterwards.

* Package Search
    Search available SlackBuilds by name and (optionally) description.
    If TAGS.txt is present, tags are searched as well.

* Perl
    View, search and select SlackBuilds found to be potentially
    incompatible with system perl.

* Python
    View, search and select SlackBuilds that were built against the
    wrong major python version.

* Rebuilds
    Perform (or, for non-root users, do dry runs) of large-scale
    rebuilds, either by series or for all installed _SBo SlackBuilds.

* Refresh
    If package operations or sbotools settings changes occur from
    outside of an sbotool instance while it is running, use this option
    to ensure that output is up-to-date.

* Ruby
    View, search and select SlackBuilds that were built against the
    wrong major ruby version.

* Settings
    View the current sbotools settings and see explanations of each one.
    As root, change any setting.

* Upgradable
    View, search and select from a list of upgradable SlackBuilds.

* Upgrade All (dry run)
    Perform a dry run of all available upgrades.

* Upgrade All
    Root only. Perform all available upgrades.');

our @help_operations = ('Script Operations - Help',

'Each available SlackBuild has an Operations menu, which is the main
point of contact for script information and actions. Use the "Main"
button to return to Main Menu.

The options displayed depend on the running user; ineffective actions
are ignored. If the number of available options is high, less-common
options appear in a second menu that can be reached from "more".

These options are always displayed in the first menu if available:

* Build Options
    As a non-root user, view saved build options for this SlackBuild. As
    root, edit or delete these options.

* Dry Run
    See how this SlackBuild would be installed (or reinstalled) with
    batch processing.

* Edit Hints
    Root only. Add, edit or remove hints for this SlackBuild.

* Edit Override
    Available for SlackBuilds in local overrides, provided that the
    running user has write permissions. Edit any text file in the
    directory. The text editor priority list is $EDITOR, $VISUAL and vi.

* Hints
    Non-root users. View active hints for this SlackBuild.

* Install
    Root only. Install the SlackBuild!

* Lists
    Root only. Add or remove the SlackBuild from lists for
    installation, upgrade, removal or template-making. The lists can be
    implemented using the "List Operations" screen from Main Menu.

* Reinstall
    Root only. Reinstall the SlackBuild. Optionally, reinstall its
    dependencies as well.

* Remove
    Root only. Interactively remove the SlackBuild and any of its
    unneeded dependencies.

* Replace
    Root only. If the SlackBuild is available in the repository but
    installed under a tag other than "_SBo" or "_SBocompat32", reinstall
    from the repository.

* RevDep (installed)
    View, search and select from installed reverse dependencies of this
    SlackBuild.

* Template List (+/-)
    Non-root only. Add (or remove) the SlackBuild from the Template
    list. Use the "List Operations" screen from Main Menu to implement
    the list. The saved template can be installed later with
    "sboinstall --use-template".

* Upgrade
    Root only. Upgrade the SlackBuild to the available version.

* View File
    Read any text file in the SlackBuild directory.

* more
    View a second menu with less-common options. Appears only if there
    are at least nine available options.

The remaining options can appear in the second menu:

* Add Override
    Available if the running user has write permissions for the local
    overrides directory. Copy the SlackBuild directory into overrides
    to make local changes.

* Dry Run (reverse)
    See how this SlackBuild and its reverse dependencies would be
    reinstalled with batch processing.

* Package Check
    Check this installed SlackBuild for missing shared object
    dependencies and perl, python and ruby incompatibility.

* Queue
    View, search and select from the build queue for the SlackBuild,
    provided that it has available dependencies. The queue is calculated
    automatically and respects per-script hints.

* Remove Override
    Available only if the running user has write permissions for the
    local overrides directory. Remove the SlackBuild from local
    overrides by deleting its override directory.

* RevDep (all)
    View, search and select from all available reverse dependencies of
    this SlackBuild.

* Reverse Rebuild
    Root only. Rebuild all installed reverse dependencies for this
    SlackBuild.

* Upgrade (reverse rebuild)
    Root only. Upgrade the SlackBuild to the available version and
    rebuild any installed reverse dependencies. This can be done
    automatically by turning on the Auto-Rebuild hint.

* compat32
    Display the Operations menu for the -compat32 version of the
    SlackBuild. This appears only on multilib-capable systems. Perl-
    based, noarch and single-architecture scripts are ineligible.
    compat32 appears in the first window if the -compat32 package is
    installed.');

our @help_options = ('Build Options - Help',

'Build options for individual SlackBuilds are saved to files in the
"/var/log/sbotools" directory. They can be added or edited by installing
or upgrading packages interactively.

Alternatively, the root user can use the "Edit Hints" menu from the
"Operations" dialog for each script. Simply edit the build option input
line after specifying "Edit" or "Clear". The "README" button displays
the README file for the SlackBuild. If the input line is left blank, the
current options are retained.

Build options can also be removed via "Clean sbotools Files" in "Main
Menu".

Please note that separate build options for compat32 are unsupported.');

our @help_rebuilds = ('Large-Scale Rebuilds - Help',

'Use this menu as root to carry out large-scale rebuilds of packages
saved with the "_SBo" and "_SBocompat32" tags. Only dry runs are
available to non-root users.

Please note that packages without one of these tags are skipped
automatically if "batch processing" is selected in the confirmation
prompts.

1. Mass Rebuild

Rebuild every SBo package installed to the system, accounting for new
dependencies, saved build options and per-script hints. If the queue
fails for any reason, a template file named "resume.temp" is saved
to the sbotools directory (/usr/sbo by default). sbotool offers to pick
up the mass rebuild from the SlackBuild after the one that failed if the
file is present.

2. Series Rebuild

Rebuild every package in a given series and their dependencies. Choose
a series from the list to proceed; only series with installed packages
are displayed.

3. Series Reverse

Like Series Rebuild, but also rebuild any reverse dependencies
installed to the system.');

our @help_sboremove = ('sboremove - Help',

'sboremove removes one or more packages and any of their unneeded
dependencies. The user is prompted before any package is designated for
removal, and before the final remove operation.');

our @help_search = ('Package Search - Help',

'Use this screen to search for SlackBuilds by name. To include
description strings as well, use the "Desc" button. Exact word matches
are listed first, followed by other matches. Select a script from the
list of results to see its Operations menu.

Script results lists can be refined further using the "Filter" button,
which applies an additional search to the list.');

our @help_solibs = ('Shared Object Checks - Help',

'Root and non-root users can perform per-package checks for missing
shared object dependencies (often called "solibs"). A log is saved to
"/var/log/sbocheck-so-check.log" if running as root, or to "/tmp"
otherwise.

If a package is missing a first-order solib dependency, the package
name, missing library or libraries and affected files are logged like
this:

  openttd 14.1:
    libicui18n.so.76:
      /usr/games/openttd
    libicuuc.so.76:
      /usr/games/openttd

Missing dependencies do not necessarily mean that a package is broken
outright, especially for repackages from binary.

The shared object check itself is written in perl. Its interaction with
binaries on the system is limited to reading ELF headers. Neither ldd(1)
nor readelf(1) is called at any point.');

=pod

=encoding UTF-8

=head1 NAME

SBO::Lib::Help - internal documentation for sbotool

=head1 SYNOPSIS

  use SBO::Lib::Help qw/ :all /;
  use SBO::Lib qw/ :help /;

  my $help_title = $help_main[0];
  my $help_text = $help_main[1];

=head1 DESCRIPTION

This module exports variables that populate the C<Help> messages in C<sbotool(1)>. The messages
themselves are arrays, with the first element being the title of the Help screen and the second
being the body text.

If edits are needed, please ensure that lines in the body text do not exceed 72 characters.

=head1 SEE ALSO

SBO::Lib(3), SBO::Lib::Build(3), SBO::Lib::Download(3), SBO::Lib::Info(3), SBO::Lib::Pkgs(3), SBO::Lib::Readme(3), SBO::Lib::Repo(3), SBO::Lib::Tree(3), SBO::Lib::Util(3)

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
