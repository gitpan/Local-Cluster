=head1 NAME

Local::Cluster::Server - Cluster server. Implements Cluster::Interface.

=cut
package Local::Cluster::Server;

use base Local::Cluster::Interface;

use warnings;
use strict;

use Local::Cluster::Config;

=head1 METHODS

=head2 run( conf => '/conf/dir', timeout => seconds )

Launches server with supplied parameter.

I<conf>: directory containing cluster configuration DB files

I<timeout>: refresh interval in seconds

=cut
sub run 
{
    my ( $this, %param ) = @_;

    $param{timeout} ||= 30;
    $this->{_run}{context} = +{ %param, time => 0 };

    TCPServer::Interface::run( $this );
}

sub _worker
{
    my ( $this, @queue ) = @_;
    my $context = $this->{_run}{context};
    my $conf = $context->{conf};
    my $md5 = $queue[0]->dequeue();

    $conf = $context->{conf} = Local::Cluster::Config->new( $conf )
        if ref $conf ne 'Local::Cluster::Config';

    if ( time - $context->{time} > $context->{timeout} )
    {
        if ( my %conf = $conf->load() )
        {
            $conf->update( %conf );
            $context->{zip} = $conf->zip();
            $context->{md5} = $conf->md5();
        }

        $context->{time} = time;
    }

    $queue[1]->enqueue( $md5 eq $context->{md5} ? 0 : $context->{zip} );
}

=head1 NOTE

See Local::Cluster

=cut

1;

__END__
