# NAME

WWW::Pusher::Client - Laughably incomplete Perl client for Pusher WS API

# VERSION

version 0.04

# SYNOPSIS

Pusher is a hosted API for the websocket protocol. WWW::Pusher::Client
is a laughably incomplete Perl client for their interface. It's really
only suited for joining one channel in its lifetime - `trigger` uses
only the most recent channel as defaults.

    use WWW::Pusher::Client;
    my $pusher =  WWW::Pusher::Client->new(
        auth_key => $ENV{AUTH_KEY},
        secret => $ENV{SECRET},
        channel => 'private-channel'
    );

    use JSON;
    $pusher->trigger('my_event', 'this is some data that isn\'t JSON');
    $pusher->trigger('my_event', to_json({
        json => 'json also works!'
    });

The main difference between this module and [WWW::Pusher](https://metacpan.org/pod/WWW::Pusher) is that
this module enables you to subscribe to channels like the WebSocket
Pusher clients allow you to do. [WWW::Pusher](https://metacpan.org/pod/WWW::Pusher) interacts with Pusher
via its HTTP API, which doesn't allow for subscriptions. On the other
hand, this module uses ["AnyEvent::WebSocket::Client"](#anyevent-websocket-client) to join
channels via websockets and receive real time messages in addition to
triggering them.

# METHODS

## new

Get a client to interact with the Pusher API. You can optionally pass
in a channel to subscribe to it after the initial connection, or
subscribe manually later on your own.

    use WWW::Pusher::Client;
    my $pusher =  WWW::Pusher::Client->new(
        auth_key => $ENV{AUTH_KEY},  // required
        secret => $ENV{SECRET},      // required
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

# SEE ALSO

Please see those modules/websites for more information related to this module.

- [WWW::Pusher](https://metacpan.org/pod/WWW::Pusher)

# BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/honeydew-sc/WWW-Pusher-Client/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

# AUTHOR

Daniel Gempesaw <gempesaw@gmail.com>

# CONTRIBUTORS

- Syohei YOSHIDA <syohex@gmail.com>
- gempesaw <gempesaw@gmail.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Daniel Gempesaw.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
