package POE::Component::WWW::LimerickDB;

use warnings;
use strict;

our $VERSION = '0.0103';

use POE;
use base 'POE::Component::NonBlockingWrapper::Base';
use WWW::LimerickDB;

sub _methods_define {
    return ( get => '_wheel_entry' );
}

sub get {
    $poe_kernel->post( shift->{session_id} => get => @_ );
}

sub _check_args {
    my ( $self, $args_ref ) = @_;

    return
        unless defined $args_ref->{method};

    return 1;
}

sub _prepare_wheel {
    my $self = shift;
    $self->{obj} = WWW::LimerickDB->new( %{ $self->{obj_args} || {} } );
}

sub _process_request {
    my ( $self, $in_ref ) = @_;

    my $method = $in_ref->{method};

    my $out = $self->{obj}->$method( @{ $in_ref->{args} || [] } );
    if ( defined $out ) {
        $in_ref->{out} = $out;
    }
    else {
        $in_ref->{error} = $self->{obj}->error;
    }
}


1;
__END__

=head1 NAME

POE::Component::WWW::LimerickDB - non-blocking wrapper around WWW::LimerickDB

=head1 SYNOPSIS

    use strict;
    use warnings;

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
            print "$in_ref->{out}\n";
        }
        $poco->shutdown;
    }

Using event based interface is also possible, of course.

=head1 DESCRIPTION

The module is a non-blocking wrapper around L<WWW::LimerickDB>
which provides interface to fetch limericks from L<http://limerickdb.com/>

=head1 CONSTRUCTOR

=head2 C<spawn>

    my $poco = POE::Component::WWW::LimerickDB->spawn;

    POE::Component::WWW::LimerickDB->spawn(
        alias => 'lime',
        obj_args => {
            new_line => ' / ',
        },
        options => {
            debug => 1,
            trace => 1,
            # POE::Session arguments for the component
        },
        debug => 1, # output some debug info
    );

The C<spawn> method returns a
POE::Component::WWW::LimerickDB object. It takes a few arguments,
I<all of which are optional>. The possible arguments are as follows:

=head3 C<alias>

    ->spawn( alias => 'lime' );

B<Optional>. Specifies a POE Kernel alias for the component.

=head3 C<obj_args>

    obj_args => {
        new_line => ' / ',
    },

B<Optional>. Takes an hashref as an argument. This hashref will be directly dereferenced
to L<WWW::LimerickDB>'s constructor. See documentation for L<WWW::LimerickDB> for
possible keys/values.

=head3 C<options>

    ->spawn(
        options => {
            trace => 1,
            default => 1,
        },
    );

B<Optional>.
A hashref of POE Session options to pass to the component's session.

=head3 C<debug>

    ->spawn(
        debug => 1
    );

When set to a true value turns on output of debug messages. B<Defaults to:>
C<0>.

=head1 METHODS

=head2 C<get>

    $poco->get( {
            event       => 'event_for_output',
            method      => 'get_cached',
            args        => [ 'random' ],
            _blah       => 'pooh!',
            session     => 'other',
        }
    );

Takes a hashref as an argument, does not return a sensible return value.
See C<get> event's description for more information.

=head2 C<session_id>

    my $poco_id = $poco->session_id;

Takes no arguments. Returns component's session ID.

=head2 C<shutdown>

    $poco->shutdown;

Takes no arguments. Shuts down the component.

=head1 ACCEPTED EVENTS

=head2 C<get>

    $poe_kernel->post( lime => get => {
            event       => 'event_for_output',
            method      => 'get_cached',
            args        => [ 'random' ],
            _blah       => 'pooh!',
            session     => 'other',
        }
    );

Instructs the component to execute a specified method on L<WWW::LimerickDB> object.
Takes a hashref as an
argument, the possible keys/value of that hashref are as follows:

=head3 C<event>

    { event => 'results_event', }

B<Mandatory>. Specifies the name of the event to emit when results are
ready. See OUTPUT section for more information.

=head3 C<method>

    { method => 'get_cached' }

B<Mandatory>. Specifies the method to call on L<WWW::LimerickDB> object.
See documentation for L<WWW::LimerickDB> for possible methods.

=head3 C<args>

    { args => [ 'random' ] }

B<Optional>. If the method specified by the C<method> argument requires any arguments you
can pass them through C<args> argument. Takes an arrayref as a value. This arrayref will
be directly dereferenced into the method call.

=head3 C<session>

    { session => 'other' }

    { session => $other_session_reference }

    { session => $other_session_ID }

B<Optional>. Takes either an alias, reference or an ID of an alternative
session to send output to.

=head3 user defined

    {
        _user    => 'random',
        _another => 'more',
    }

B<Optional>. Any keys starting with C<_> (underscore) will not affect the
component and will be passed back in the result intact.

=head2 C<shutdown>

    $poe_kernel->post( lime => 'shutdown' );

Takes no arguments. Tells the component to shut itself down.

=head1 OUTPUT

    $VAR1 = {
        "out" => {
            "number" => 442,
            "text" => "There once was a lady from Wheeling \nwho professed to lack sexual
                feeling, \ntill a cynic named Boris \nbarely brushed her clitoris,
                \nand she had to be scraped from the ceiling.",
            "rating" => 54
        },
        'args' => [ 'random' ],
        'method' => 'get_cached'
    };

The event handler set up to handle the event which you've specified in
the C<event> argument to C<get()> method/event will recieve input
in the C<$_[ARG0]> in a form of a hashref. The possible keys/value of
that hashref are as follows:

=head2 C<out>

    "out" => {
        "number" => 442,
        "text" => "There once was a lady from Wheeling \nwho professed to lack sexual
            feeling, \ntill a cynic named Boris \nbarely brushed her clitoris,
            \nand she had to be scraped from the ceiling.",
        "rating" => 54
    },

If no errors occured the C<out> key will be present. Its value will be the return value
of the method that you called (specified in C<method> argument to C<get()> event/method)

=head2 C<error>

    { 'error' => 'Network error: 404 Not Found', }

If an error occured, the C<error> key will be present; its value will be the description
of the failure.

=head2 C<args>

    'args' => [ 'random' ],

If you specified the C<args> argument to the C<get()> event/method, it will be present
intact in the output hashref.

=head2 C<method>

    'method' => 'get_cached'

The C<method> argument spcified in the C<get()> event/method, will be present
intact in the output hashref.

=head2 user defined

    { '_blah' => 'foos' }

Any arguments beginning with C<_> (underscore) passed into the C<get()>
event/method will be present intact in the result.

=head1 SEE ALSO

L<POE>, L<WWW::LimerickDB>

=head1 AUTHOR

'Zoffix, C<< <'zoffix at cpan.org'> >>
(L<http://zoffix.com/>, L<http://haslayout.net/>, L<http://zofdesign.com/>)

=head1 BUGS

Please report any bugs or feature requests to C<bug-poe-component-www-limerickdb at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=POE-Component-WWW-LimerickDB>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc POE::Component::WWW::LimerickDB

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=POE-Component-WWW-LimerickDB>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/POE-Component-WWW-LimerickDB>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/POE-Component-WWW-LimerickDB>

=item * Search CPAN

L<http://search.cpan.org/dist/POE-Component-WWW-LimerickDB>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2008 'Zoffix, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

