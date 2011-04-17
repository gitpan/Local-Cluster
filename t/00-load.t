#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Local::Cluster' );
}

diag( "Testing Local::Cluster $Local::Cluster::VERSION, Perl $], $^X" );
