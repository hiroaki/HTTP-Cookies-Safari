BEGIN {
	@classes = qw( HTTP::Cookies::Safari HTTP::Cookies::Safari::Plist HTTP::Cookies::Safari::BinaryCookies );
	}

use Test::More tests => scalar @classes;
	
foreach my $class ( @classes )
	{
	print "bail out! $class did not compile" unless use_ok( $class );
	}

