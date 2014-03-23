# NAME

WWW::Pusher::Client - Laughably incomplete Perl client for Pusher WS API

# VERSION

version 0.02

# SYNOPSIS

Pusher is a hosted API for the websocket protocol. WWW::Pusher::Client
is a laughably incomplete Perl client for their interface. It's really
only suited for joining one channel in its lifetime - `bind` and
`trigger` both use the most recent channel as defaults.

    use WWW::Pusher::Client;
    my $pusher =  WWW::Pusher::Client->new(
        auth_key => $ENV{AUTH_KEY},
        secret => $ENV{SECRET},
        channel => 'private-channel'
    );

    $pusher->bind('my_event', sub {
        my $data = shift;
        print 'my_event: ' . $data;
    });

    $pusher->trigger('my_event', 'this is some data that isn\'t JSON');
    $pusher->trigger('my_event', to_json({
        json => 'json also works!'
    });

# METHODS

## new

Get a client to interact with the Pusher API. You can optionally pass
in a channel to subscribe to it after the initial connection, or
subscribe manually later on your own.

    use WWW::Pusher::Client;
    my $pusher =  WWW::Pusher::Client->new(
        auth_key => $ENV{AUTH_KEY},
        secret => $ENV{SECRET},
        channel => 'default-channel' // optional
    );

## subscribe

Subscribe to a Pusher channel; currently supporting public and private
channels, but not presence channels. The authentication for private
channels is automatically handled for you if your channel name is
prefixed with 'private-'.

    $pusher->subscribe('pubs-are-easy-to-join');
    $pusher->subscribe('private-channels-are-supported');

## trigger

Trigger an event & message on the currently subscribed channel.

    $pusher->trigger('my_event', 'this is the message!');

# AUTHOR

Daniel Gempesaw <gempesaw@gmail.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Daniel Gempesaw.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
