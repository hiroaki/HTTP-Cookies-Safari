# $Id$
BEGIN {
	use File::Find::Rule;
	@files = File::Find::Rule->file()->name( '*.pm' )->in( 'blib/lib' );
	}

use Test::More tests => scalar @files;

SKIP: {
	eval { require Test::Pod; };

	skip "Skipping POD tests---No Test::Pod found", scalar @files if $@;
	
	my $v = $Test::Pod::VERSION;
	skip "Skipping POD tests---Test::Pod $v deprecated. Update!", scalar @files
		unless $Test::Pod::VERSION >= 0.95;
			
	foreach my $file ( @files )
		{
		Test::Pod::pod_file_ok( $file );
		}

	}