package SBO::App;

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
use File::Basename;

our $VERSION = '3.3';

sub new {
  my $class = shift;

  my $self = $class->_parse_opts(@_);
  $self->{fname} = basename( (caller(0))[1] );

  return bless $self, $class;
}

1;
