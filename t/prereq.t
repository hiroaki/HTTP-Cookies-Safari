# $Id$
use strict;

use Test::More tests => 1;

SKIP: {
	eval { require Test::Prereq; };

	skip "Skipping POD tests---No Test::Prereq found", 1 if $@;

	Test::Prereq::prereq_ok();
	}