#!/usr/bin/env perl
#
# vim: set ts=4:noet
#
# Lib.pm
# shared functions for the sbo_ scripts.
#
# authors:  Jacob Pipkin <j@dawnrazor.net>
#           Luke Williams <xocel@iquidus.org>
#           Andreas Guldstrand <andreas.guldstrand@gmail.com>
# maintainer: K. Eugene Carlson <kvngncrlsn@gmail.com>
# license: MIT License

use 5.16.0;
use strict;
use warnings FATAL => 'all';

package SBO::Lib;
our $VERSION = '3.5';

=pod

=encoding UTF-8

=head1 NAME

SBO::Lib - Library for working with SlackBuilds.org.

=head1 SYNOPSIS

  use SBO::Lib qw/ :all /;

=head1 DESCRIPTION

SBO::Lib is the entry point for all the related modules, and simply re-exports all
exports. Each module is documented in its own man page.

=head2 SBO::Lib::Build

C<Build.pm> has routines for building Slackware packages from SlackBuilds.org. It covers
the build process from setting the queue through post-build cleaning.

=head2 SBO::Lib::Download

C<Download.pm> downloads, verifies and symlinks any needed source files before building the
queue begins.

=head2 SBO::Lib::Info

C<Info.pm> sanitizes and parses C<info> files; the information returned is used in version
comparions, dependency calculation and the source downloading process.

=head2 SBO::Lib::Pkgs

C<Pkgs.pm> interacts with the Slackware package database to provide tag and version information
for all installed packages.

=head2 SBO::Lib::Readme

C<Readme.pm> parses and displays C<README> files. It detects options and commands for
adding users and groups. Pre-installation user prompts and build option recall are
handled here.

=head2 SBO::Lib::Repo

C<Repo.pm> is responsible for fetching, updating and linting the local copy of the SlackBuilds.org
repository, as well as GPG verification and key addition.

=head2 SBO::Lib::Tree

C<Tree.pm> determines the location of scripts in the repository and local overrides directory.

=head2 SBO::Lib::Util

C<Util.pm> contains utility functions for C<SBO::Lib> and the sbotools. Configuration-related
shared variables and the shared exit codes can be found here.

=head1 EXIT CODES

The sbotools share the following exit codes:

  _ERR_USAGE         1   usage errors
  _ERR_SCRIPT        2   script or module bug
  _ERR_BUILD         3   errors when executing a SlackBuild
  _ERR_MD5SUM        4   download verification failure
  _ERR_DOWNLOAD      5   download failure
  _ERR_OPENFH        6   failure to open file handles
  _ERR_NOINFO        7   missing download information
  _ERR_F_SETD        8   fd-related temporary file failure
  _ERR_NOMULTILIB    9   lacking multilib capabilities when needed
  _ERR_CONVERTPKG    10  convertpkg-compat32 failure
  _ERR_NOCONVERTPKG  11  lacking convertpkg-compat32 when needed
  _ERR_INST_SIGNAL   12  the script was interrupted while building
  _ERR_CIRCULAR      13  attempted to calculate a circular dependency
  _ERR_USR_GRP       14  a required user or group is missing

=head1 SEE ALSO

SBO::Lib::Build(3), SBO::Lib::Download(3), SBO::Lib::Info(3), SBO::Lib::Pkgs(3), SBO::Lib::Readme(3), SBO::Lib::Repo(3), SBO::Lib::Tree(3), SBO::Lib::Util(3)

=cut

use SBO::Lib::Util qw/ :all /;
use SBO::Lib::Info qw/ :all /;
use SBO::Lib::Repo qw/ :all /;
use SBO::Lib::Tree qw/ :all /;
use SBO::Lib::Pkgs qw/ :all /;
use SBO::Lib::Build qw/:all /;
use SBO::Lib::Readme qw/ :all /;
use SBO::Lib::Download qw/ :all /;

use Exporter 'import';

our @EXPORT_OK = (
	@SBO::Lib::Util::EXPORT_OK,
	@SBO::Lib::Info::EXPORT_OK,
	@SBO::Lib::Repo::EXPORT_OK,
	@SBO::Lib::Tree::EXPORT_OK,
	@SBO::Lib::Pkgs::EXPORT_OK,
	@SBO::Lib::Build::EXPORT_OK,
	@SBO::Lib::Readme::EXPORT_OK,
	@SBO::Lib::Download::EXPORT_OK,
);

our %EXPORT_TAGS = (
	all => \@EXPORT_OK,
	util => \@SBO::Lib::Util::EXPORT_OK,
	info => \@SBO::Lib::Info::EXPORT_OK,
	repo => \@SBO::Lib::Repo::EXPORT_OK,
	tree => \@SBO::Lib::Tree::EXPORT_OK,
	pkgs => \@SBO::Lib::Pkgs::EXPORT_OK,
	build => \@SBO::Lib::Build::EXPORT_OK,
	readme => \@SBO::Lib::Readme::EXPORT_OK,
	download => \@SBO::Lib::Download::EXPORT_OK,
	const => $SBO::Lib::Util::EXPORT_TAGS{const},
	config => $SBO::Lib::Util::EXPORT_TAGS{config},
);

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

'ok';

__END__
