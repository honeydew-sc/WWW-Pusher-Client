# NAME

WWW::Pusher::Client - Laughably incomplete Perl client for Pusher WS API

# VERSION

version 0.02

# SYNOPSIS

Pusher is a hosted API for the websocket protocol. WWW::Pusher::Client
is a Perl client for their interface.

# METHODS

## new

Get a client to interact with the Pusher API. You can optionally pass in a channel to subscribe to it after the initial connection, or subscribe manually later on your own.

use WWW::Pusher::Client;
my $client =  WWW::Pusher::Client->new(
    app\_key => $ENV{PUSHER\_AUTH\_KEY},
    secret => $ENV{PUSHER\_SECRET},
    channel => $config->channel, // optional
);

sub BUILD {
    my $self = shift;

    $self->ws_conn->on(
        next_message => sub {
            my ($conn, $message) = @_;
            my $body = from_json($message->decoded_body);

            if ($body->{event} eq 'pusher:connection_established') {
                $self->_socket_id(from_json($body->{data})->{socket_id});

                $self->subscribe($self->channel) if $self->has_channel;
            }
            else {
                die 'Connection error?' . $message->decoded_body;
            }
        });
}

## subscribe

Subscribe to a Pusher channel; currently supporting public and private
channels, but not presence channels. The authentication for private
channels is automatically handled for you if your channel name is
prefixed with 'private-'.

    $pusher->subscribe('private-channel-with-auth');

## trigger

Trigger an event & message on the currently subscribed channel.

    $pusher->trigger('my_event', 'this is the message!');

# AUTHOR

Daniel Gempesaw <gempesaw@gmail.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Daniel Gempesaw.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
