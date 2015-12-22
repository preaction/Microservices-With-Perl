
# Sub client
#
# A sub client subscribes to one or more topics. The publisher will then
# send it messages on those topics, or any subtopics (the topic is
# a prefix match)
#
# This can run fast enough to starve the event loop, causing the timers
# to stop.
#
# The bind/connect could be reversed. This could be a Sub server, and
# subscribe to certain messages from Pub clients.


use strict;
use warnings;
use feature qw( :5.14 );
use ZMQ::FFI;
use ZMQ::FFI::Constants qw(ZMQ_SUB);
use EV;
use AnyEvent;

use Getopt::Long;

my ( $endpoint, @topics ) = @ARGV;

my $ctx = ZMQ::FFI->new;
my $sock = $ctx->socket( ZMQ_SUB );
$sock->connect( $endpoint );

$sock->subscribe( $_ ) for @topics;

my $count = 0;
my $msg;
my $w = AE::io $sock->get_fd, 0, sub {
    while ( $sock->has_pollin ) {
        $msg = $sock->recv;
        $count++;
    }
};

my $r = AE::timer 1, 1, sub {
    say "$count requests per second";
    $count = 0;
};

AE::cv->recv;
