#!/usr/bin/env perl

use Test::More tests => 4;

BEGIN {
    use_ok('POE');
    use_ok('POE::Component::NonBlockingWrapper::Base');
    use_ok('WWW::LimerickDB');
	use_ok( 'POE::Component::WWW::LimerickDB' );
}

diag( "Testing POE::Component::WWW::LimerickDB $POE::Component::WWW::LimerickDB::VERSION, Perl $], $^X" );
