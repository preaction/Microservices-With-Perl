
# Push client
#
# A push client just keeps sending out messages, making it optimal for
# high throughput.
#
# This can run fast enough to starve the event loop, causing the timers
# to stop.
#
# The bind/connect could be reversed. This could be a Push server, and
# feed out requests to Pull clients.


use strict;
use warnings;
use feature qw( :5.14 );
use ZMQ::FFI;
use ZMQ::FFI::Constants qw(ZMQ_PUSH);
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
my $sock = $ctx->socket( ZMQ_PUSH );
$sock->connect( $ARGV[0] );

my $count = 0;
my $t = AE::timer 0, $delay, sub {
    $count++;
    $sock->send( $msg );
};

my $r = AE::timer 1, 1, sub {
    say "$count requests per second";
    $count = 0;
};

AE::cv->recv;
