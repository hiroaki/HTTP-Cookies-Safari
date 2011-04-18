use ExtUtils::MakeMaker;

require 5.008;

eval "use Test::Manifest 1.21";
	
WriteMakefile
	(
	'NAME'          => 'HTTP::Cookies::Safari',
	'ABSTRACT'      => 'Cookie storage and management for Safari',
	'VERSION_FROM'  => 'lib/HTTP/Cookies/Safari.pm',
	'LICENSE'       => 'perl',
	'AUTHOR'        => 'brian d foy <bdfoy@cpan.org>',

	'PREREQ_PM'     => {
		'Date::Calc'            => '0',
		'HTTP::Cookies'         => '1.25',
		'Mac::PropertyList'     => '1.33',
		'Text::Diff'            => '0',
		},
	
	clean => { FILES => 'HTTP-Cookies-Safari-*' },
	);

