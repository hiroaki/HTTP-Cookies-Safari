# $Id$
use ExtUtils::MakeMaker;

sub ExtUtils::MM_Any::test_via_harness
		{
		my($self, $perl, $tests) = @_;

		return qq|\t$perl "-MTest::Manifest" | .
			qq|"-e" "run_t_manifest(\$(TEST_VERBOSE), '\$(INST_LIB)', | .
			qq|'\$(INST_ARCHLIB)')"\n|;
		}

WriteMakefile
        (
        'NAME'           => 'HTTP::Cookies::Safari',
        'VERSION_FROM'   => 'lib/Safari.pm',
 		'PREREQ_PM'      => {
 			'Date::Calc'            => '0',
 			'File::Find::Rule'      => '0',
 			'HTTP::Cookies'         => '1.25',
 			'Mac::PropertyList'     => '0',
 			'Test::Manifest'        => '0.9',
 			'Test::More'            => '0',
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

