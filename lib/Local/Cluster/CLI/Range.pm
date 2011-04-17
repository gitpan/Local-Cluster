=head1 NAME

Local::Cluster::CLI::Range - CLI for Cluster Range - expand/digest/count

=cut
package Local::Cluster::CLI::Range;

use warnings;
use strict;
use Carp;

use IO::Select;
use Pod::Usage;
use Getopt::Long;

use Local::Cluster::Range;
use Local::Sysrw;
use Local::CLI;

$| ++;

=head1 EXAMPLE

 use Local::Cluster::CLI::Range;

 Local::Cluster::CLI::Range->main
 (
     delimiter => "\n",
     timeout => 10,
     server => 'localhost:12345'
 );

=head1 SYNOPSIS

$exe B<--help>

[echo range .. |] $exe range ..
[B<--timeout seconds>] [B<--server svr:port>]

[echo range .. |] $exe range .. B<--count>
[B<--timeout seconds>] [B<--server svr:port>]

[echo range .. |] $exe range .. B<--expand> [B<--delimiter> token]
[B<--timeout seconds>] [B<--server svr:port>]

=cut
sub main
{
    my ( $class, %option ) = @_;

    map { croak "$_ not defined" if ! defined $option{$_} }
        qw( delimiter timeout server );

    my $delimiter = $option{delimiter};

    $delimiter =~ s/\n/newline/g;
    $delimiter =~ s/\t/tab/g;

    my $menu = Local::CLI->new
    (
        'h|help',"print help menu",
        'c|count','count of elements',
        'e|expand','expand into a list',
        'delimiter=s',"[ $delimiter ]",
        'timeout=i',"[ $option{timeout} ]",
        'server=s',"[ $option{server} ]",
    );

    my %pod_param = ( -input => __FILE__, -output => \*STDERR );

    Pod::Usage::pod2usage( %pod_param )
        unless Getopt::Long::GetOptions( \%option, $menu->option() );

    if ( $option{h} )
    {
        warn join "\n", "Default value in [ ]", $menu->string(), "\n";
        return 0;
    }

    croak "poll: $!\n" unless my $select = IO::Select->new();

    my ( $buffer, $length );

    $select->add( *STDIN );

    map { $length = Local::Sysrw->read( $_, $buffer ) }
        $select->can_read( 0.1 );

    push @ARGV, split /\s+/, $buffer if $length;

    Pod::Usage::pod2usage( %pod_param ) unless @ARGV;

    my $range = Local::Cluster::Range
        ->setenv( map { $_ => $option{$_} } qw( timeout server ) )
        ->new( \@ARGV );

    if ( $option{e} )
    {
        local $, = $option{delimiter};
        local $\ = "\n";

        print $range->list();
    }
    else
    {
        printf "%s\n", $option{c} ? $range->size() : $range->string();
    }
}

=head1 NOTE

See Local::Cluster

=cut

1;

__END__
