#!/usr/bin/env perl

use strict;
use warnings;

use lib qw(lib ../lib);
use POE qw/Component::WWW::LimerickDB/;

my $poco = POE::Component::WWW::LimerickDB->spawn;

POE::Session->create( package_states => [ main => [qw(_start results)] ], );

$poe_kernel->run;

sub _start {
    $poco->get( {
            event   => 'results',
            method  => 'get_cached',
            args    => [ 'random' ],
        }
    );
}

sub results {
    my $in_ref = $_[ARG0];

    if ( $in_ref->{error} ) {
        print "Error: $in_ref->{error}\n";
    }
    else {
        print "$in_ref->{out}{text}\n";
    }
    $poco->shutdown;
}



