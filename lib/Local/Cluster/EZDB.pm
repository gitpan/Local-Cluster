=head1 NAME

Local::Cluster::EZDB - Extends Local::EZDB

=cut
package Local::Cluster::EZDB;

use base Local::EZDB;

use strict;
use warnings;

=head1 SCHEMA
 
 key TEXT NOT NULL,
 value TEXT NOT NULL,
 PRIMARY KEY ( key )

=cut
@Local::EZDB::SCHEMA =
(
    key   => 'TEXT NOT NULL PRIMARY KEY',
    value => 'TEXT NOT NULL',
);

=head1 METHODS

See base class for additional methods.

=head2 get()

Loads all tables into a HASH. Also see dump().
Returns HASH reference in scalar context.
Returns flattened HASH in list context.

=cut
sub get
{
    my $this = shift;
    my %config = map { $_ => scalar $this->dump( $_ ) } $this->table();

    return wantarray ? %config : \%config;
}

=head1 NOTE

See Local::Cluster

=cut

1;

__END__

