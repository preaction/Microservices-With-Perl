
# Request client
#
# A Request client can only have one request in-flight at a time, making
# it suboptimal for high throughput.

use strict;
use warnings;
use feature qw( :5.14 );
use ZMQ::FFI;
use ZMQ::FFI::Constants qw(ZMQ_REQ);
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

my $ctx = ZMQ::FFI->new;
my $sock = $ctx->socket( ZMQ_REQ );
$sock->connect( $ARGV[0] );

my $waiting = 0;
my $w = AE::io $sock->get_fd, 0, sub {
    while ( $sock->has_pollin ) {
        $sock->recv;
        $waiting = 0;
    }
};

my $count = 0;
my $t = AE::timer 0, $delay, sub {
    return if $waiting;
    $count++;
    $sock->send( $msg );
    $waiting = 1;
};

my $r = AE::timer 1, 1, sub {
    say "$count requests per second";
    $count = 0;
};

AE::cv->recv;
