package WWW::Pusher::Client;
# ABSTRACT: Laughably incomplete Perl client for Pusher WS API

use strict;
use warnings;
use 5.010_001;
use Moo;
use JSON;
use AnyEvent::WebSocket::Client;
use Digest::SHA qw(hmac_sha256_hex);

=head1 SYNOPSIS

Pusher is a hosted API for the websocket protocol. WWW::Pusher::Client
is a laughably incomplete Perl client for their interface. It's really
only suited for joining one channel in its lifetime - C<trigger> uses
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

The main difference between this module and L<WWW::Pusher> is that
this module enables you to subscribe to channels like the WebSocket
Pusher clients allow you to do. L<WWW::Pusher> interacts with Pusher
via its HTTP API, which doesn't allow for subscriptions.

=cut

has 'auth_key' => (
    is => 'rw' ,
    required => 1
);

has 'secret' => (
    is => 'rw',
    required => 1
);

has 'channel' => (
    is => 'rw',
    predicate => 'has_channel'
);

has 'client' => (
    is => 'rw',
    lazy => 1,
    default => sub { shift->{client} // AnyEvent::WebSocket::Client->new }
);

has 'ws_url' => (
    is => 'ro',
    lazy => 1,
    builder => sub {
        my $self = shift;

        return $self->_scheme . $self->_pusher_base . $self->_port
          . "/app/" . $self->auth_key
          . "?protocol=" . $self->_protocol
          . "&client=" . $self->_client_name
          . "&version=" . $self->_version
    }
);

has 'ws_conn' => (
    is => 'rw',
    lazy => 1,
    builder => sub {
        my $self = shift;
        return AnyEvent::WebSocket::Client->new->connect($self->ws_url)->recv;
    }
);

has '_scheme' => (
    is => 'ro',
    default => sub { 'ws' }
);

has '_port' => (
    is => 'ro',
    default => sub { 80 }
);

has '_pusher_base' => (
    is => 'ro',
    default => sub { '://ws.pusherapp.com:' }
);

has '_protocol' => (
    is => 'ro',
    default => sub { 7 }
);

has '_client_name' => (
    is => 'ro',
    default => sub { 'perl-pusher-client' }
);

has '_version' => (
    is => 'ro',
    default => sub { '0.001' }
);

has '_socket_id' => (
    is => 'rw',
);

=method new

Get a client to interact with the Pusher API. You can optionally pass
in a channel to subscribe to it after the initial connection, or
subscribe manually later on your own.

    use WWW::Pusher::Client;
    my $pusher =  WWW::Pusher::Client->new(
        auth_key => $ENV{AUTH_KEY},  // required
        secret => $ENV{SECRET},      // required
        channel => 'default-channel' // optional
    );

=cut

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

=method subscribe

Subscribe to a Pusher channel; currently supporting public and private
channels, but not presence channels. The authentication for private
channels is automatically handled for you if your channel name is
prefixed with 'private-'.

    $pusher->subscribe('pubs-are-easy-to-join');
    $pusher->subscribe('private-channels-are-supported');

=cut

sub subscribe {
    my $self = shift;
    my $data = {
        channel => $self->channel
    };

    # Private channels need a key:signature in the auth key for
    # acceptance.
    if ($self->channel =~ /^private\-/) {
        my $signature = $self->_socket_auth($self->channel);
        $data->{auth} = $self->auth_key . ':' . $signature;
    }

    $self->ws_conn->send(to_json({
        event => 'pusher:subscribe',
        data => $data
    }));
}

sub _socket_auth {
    my ($self, $channel) = @_;
    die 'Missing socket_id, sorry...' unless $self->_socket_id;

    my $plainSignature = $self->_socket_id . ':' . $channel;
    return hmac_sha256_hex($plainSignature, $self->secret);
}

=method trigger

Trigger an event & message on the currently subscribed channel.

    $pusher->trigger('my_event', 'this is the message!');

=cut

sub trigger {
    my $self = shift;
    my $event = shift // 'ws update';
    my $message = shift;

    $self->ws_conn->send(to_json({
        event => $event,
        channel => $self->channel,
        data => $message
    }));
}

=head1 SEE ALSO

WWW::Pusher

=cut

1;
