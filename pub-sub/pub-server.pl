
# Pub server
#
# A pub server sends out messages that subscribers are interested in. It
# will not send a message that a subscriber is not interested in, for
# efficiency.
#
# This can run fast enough to starve the event loop, causing the timers
# to stop.
#
# The bind/connect could be reversed. This could be a Pub client, and
# feed out requests to Sub servers.


use strict;
use warnings;
use feature qw( :5.14 );
use ZMQ::FFI;
use ZMQ::FFI::Constants qw(ZMQ_PUB);
use EV;
use AnyEvent;

use Getopt::Long;

my %opt = (
    rps => 100,
    size => 10000,
);
GetOptions( \%opt,
    'rps|r=i',
    'size|s=i',
);
my $delay = 1/$opt{rps};
my $msg = 'x' x $opt{size};

my ( $endpoint, @topics ) = @ARGV;

my $ctx = ZMQ::FFI->new;
my $sock = $ctx->socket( ZMQ_PUB );
$sock->bind( $endpoint );

my $count = 0;
my $t = AE::timer 0, $delay, sub {
    $count++;
    $sock->send( $topics[ $count % @topics ] . ' ' . $msg );
};

my $r = AE::timer 1, 1, sub {
    say "$count requests per second";
    $count = 0;
};

AE::cv->recv;
