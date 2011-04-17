=head1 NAME

Local::Cluster::Interface - Extends TCPServer::Interface.

=cut
package Local::Cluster::Interface;

use base TCPServer::Interface;

use warnings;
use strict;

use Local::Sysrw;

sub _server
{
    my ( $this, $socket, @queue ) = @_;
    my $buffer = '';

    Local::Sysrw->read( $socket, $buffer, 33 );

    if ( $buffer =~ /^([0-9a-f]{32})\b/ )
    {
        $queue[0]->enqueue( $1 );
        Local::Sysrw->write( $socket, $buffer )
            if $buffer = $queue[1]->dequeue();
    }
}

=head1 NOTE

See Local::Cluster

=cut

1;

__END__
