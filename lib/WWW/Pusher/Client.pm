package WWW::Pusher::Client;
# ABSTRACT: Laughably incomplete Perl client for Pusher WS API

use strict;
use warnings;
use Moo;
use JSON;
use AnyEvent::WebSocket::Client;

has 'app_key' => (
    is => 'rw' ,
    required => 1
);

has 'channel' => (
    is => 'rw',
    required => 1
);

has 'scheme' => (
    is => 'rw',
    default => 'ws'
);

has 'port' => (
    is => 'rw',
    default => 80
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

        return $self->{scheme} . $self->{_pusher_base} . $self->{port}
        . "/app/" . $self->{app_key}
        . "?protocol=" . $self->{_protocol}
        . "&client=" . $self->{_client_name}
        . "&version=" . $self->{_version}
    }
);

has 'ws_conn' => (
    is => 'ro',
    lazy => 1,
    builder => sub {
        my $self = shift;
        return AnyEvent::WebSocket::Client->new->connect($self->ws_url)->recv;
    }
);

has '_pusher_base' => (
    is => 'ro',
    default => '://ws.pusherapp.com:'
);

has '_protocol' => (
    is => 'ro',
    default => 7
);

has '_client_name' => (
    is => 'ro',
    default => 'perl-pusher-client'
);

has '_version' => (
    is => 'ro',
    default => '0.001'
);


sub BUILD {
    my $self = shift;

    $self->ws_conn->on(next_message => sub {
                  $self->subscribe($self->channel);
              });

    $self->ws_conn->on(
        each_message => sub {
            my ($conn, $message) = @_;
            use Data::Dumper; use DDP;
            p @_;
            if ($message->body =~ /finish/) {
                $conn->close();
            }
        });
}

sub subscribe {
    my $self = shift;
    $self->ws_conn->send(to_json({
        event => 'pusher:subscribe',
        data => {
            channel => $self->channel
        }
    }));
}

sub send {
    my $self = shift;
    my $message = shift;
    my $event = shift // 'ws update';

    $self->ws_conn->send(to_json({
        event => $event,
        channel => $self->channel,
        data => $message
    }));
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

WWW::Pusher::Client - Laughably incomplete Perl client for Pusher WS API

=head1 VERSION

version 0.001

=head1 AUTHOR

Daniel Gempesaw <gempesaw@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Daniel Gempesaw.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
