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
# license: WTFPL <http://sam.zoy.org/wtfpl/COPYING>

use 5.16.0;
use strict;
use warnings FATAL => 'all';

package SBO3::Lib;
our $VERSION = '1.1';

=pod

=encoding UTF-8

=head1 NAME

SBO3::Lib - Library for working with SlackBuilds.org.

=head1 SYNOPSIS

  use SBO3::Lib qw/ :all /;

=head1 DESCRIPTION

SBO3::Lib is the entry point for all the related modules, and is simply re-
exporting all of their exports.

=head1 SEE ALSO

=over

=item L<SBO3::Lib::Util>

=item L<SBO3::Lib::Info>

=item L<SBO3::Lib::Repo>

=item L<SBO3::Lib::Tree>

=item L<SBO3::Lib::Pkgs>

=item L<SBO3::Lib::Build>

=item L<SBO3::Lib::Readme>

=item L<SBO3::Lib::Download>

=back

=cut

use SBO3::Lib::Util qw/ :all /;
use SBO3::Lib::Info qw/ :all /;
use SBO3::Lib::Repo qw/ :all /;
use SBO3::Lib::Tree qw/ :all /;
use SBO3::Lib::Pkgs qw/ :all /;
use SBO3::Lib::Build qw/:all /;
use SBO3::Lib::Readme qw/ :all /;
use SBO3::Lib::Download qw/ :all /;

use Exporter 'import';

our @EXPORT_OK = (
	@SBO3::Lib::Util::EXPORT_OK,
	@SBO3::Lib::Info::EXPORT_OK,
	@SBO3::Lib::Repo::EXPORT_OK,
	@SBO3::Lib::Tree::EXPORT_OK,
	@SBO3::Lib::Pkgs::EXPORT_OK,
	@SBO3::Lib::Build::EXPORT_OK,
	@SBO3::Lib::Readme::EXPORT_OK,
	@SBO3::Lib::Download::EXPORT_OK,
);

our %EXPORT_TAGS = (
	all => \@EXPORT_OK,
	util => \@SBO3::Lib::Util::EXPORT_OK,
	info => \@SBO3::Lib::Info::EXPORT_OK,
	repo => \@SBO3::Lib::Repo::EXPORT_OK,
	tree => \@SBO3::Lib::Tree::EXPORT_OK,
	pkgs => \@SBO3::Lib::Pkgs::EXPORT_OK,
	build => \@SBO3::Lib::Build::EXPORT_OK,
	readme => \@SBO3::Lib::Readme::EXPORT_OK,
	download => \@SBO3::Lib::Download::EXPORT_OK,
	const => $SBO3::Lib::Util::EXPORT_TAGS{const},
	config => $SBO3::Lib::Util::EXPORT_TAGS{config},
);

unless ($< == 0) {
	warn "This script requires root privileges.\n";
	exit _ERR_USAGE;
}

=head1 AUTHORS

SBO::Lib was originally written by Jacob Pipkin <j@dawnrazor.net> with
contributions from Luke Williams <xocel@iquidus.org> and Andreas
Guldstrand <andreas.guldstrand@gmail.com>.

SBO3::Lib is maintained by K. Eugene Carlson <kvngncrlsn@gmail.com>.

=head1 LICENSE

The sbotools are licensed under the WTFPL <http://sam.zoy.org/wtfpl/COPYING>.

Copyright (C) 2012-2017, Jacob Pipkin, Luke Williams, Andreas Guldstrand.
Copyright (C) 2024, K. Eugene Carlson.

=cut

'ok';

__END__
