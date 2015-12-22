
# Pull server
#
# A pull server is good when there are multiple clients, but only one
# server. Push/pull is good for high throughput.
#
# This can run fast enough to starve the event loop, causing the timers
# to stop.
#
# The bind/connect could be reversed. This could be a Pull client, and
# get fed requests from a Push server.

use strict;
use warnings;
use feature qw( :5.14 );
use ZMQ::FFI;
use ZMQ::FFI::Constants qw(ZMQ_PULL);
use EV;
use AnyEvent;

my $ctx = ZMQ::FFI->new;
my $sock = $ctx->socket( ZMQ_PULL );
$sock->bind( $ARGV[0] );

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
