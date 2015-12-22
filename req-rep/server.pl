
# Reply server
#
# A Reply server can handle replying to multiple connections, but must
# send a reply to the latest-received request. This makes it fine for
# blocking operations (though this example is non-blocking).

use strict;
use warnings;
use feature qw( :5.14 );
use ZMQ::FFI;
use ZMQ::FFI::Constants qw(ZMQ_REP);
use EV;
use AnyEvent;

my $ctx = ZMQ::FFI->new;
my $sock = $ctx->socket( ZMQ_REP );
$sock->bind( $ARGV[0] );

my $count = 0;

my $msg;
my $w = AE::io $sock->get_fd, 0, sub {
    while ( $sock->has_pollin ) {
        $msg = $sock->recv;
        $sock->send( '200 OK' );
        $count++;
    }
};

my $r = AE::timer 1, 1, sub {
    say "$count requests per second";
    $count = 0;
};


AE::cv->recv;
