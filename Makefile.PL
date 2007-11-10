# $Id$
use ExtUtils::MakeMaker;

require 5.006;

eval "use Test::Manifest 1.14";
	
WriteMakefile
	(
	'NAME'          => 'HTTP::Cookies::Safari',
	'ABSTRACT'      => 'Cookie storage and management for Safari',
	'VERSION_FROM'  => 'lib/Safari.pm',
	'LICENSE'       => 'perl',
	'AUTHOR'        => 'brian d foy <bdfoy@cpan.org>',

	'PREREQ_PM'      => {
		'Date::Calc'            => '0',
		'HTTP::Cookies'         => '1.25',
		'Mac::PropertyList'     => '0.9',
		'Text::Diff'            => '0',
		},
	'PM'             => {
		'lib/Safari.pm' => '$(INST_LIBDIR)/Safari.pm',
		},
	'MAN3PODS'		 => {
		'lib/Safari.pm' => '$(INST_MAN3DIR)/HTTP::Cookies::Safari.3',
		},
	
	clean => { FILES => 'HTTP-Cookies-Safari-*' },
	);

