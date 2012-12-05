use Test::More tests => 5;

use HTTP::Cookies::Safari;

my %Domains = qw( .apple.com 6 );

my $jar = HTTP::Cookies::Safari->new( File => 't/Cookies.binarycookies' );
isa_ok( $jar, 'HTTP::Cookies' );

my $hash = $jar->{COOKIES};

my $domain_count = keys %$hash;
is( $domain_count, 1, 'Count of domains' );

for my $domain ( keys %Domains ) {
    my $domain_hash  = $hash->{ $domain }{ '/' };
    my $count        = keys %$domain_hash;
    is( $count, $Domains{$domain}, "$domain has $count cookies" );
}

is( $hash->{'.apple.com'}{'/'}{'s_invisit_n2_us'}[1], '16', 'Cookie has right value' );
is( $hash->{'.apple.com'}{'/'}{'s_invisit_n2_us'}[5], 1416911728, 'Cookie has right expires' );

#use Data::Dumper;
#$Data::Dumper::Indent = 1;
#print STDERR Dumper([$jar]);