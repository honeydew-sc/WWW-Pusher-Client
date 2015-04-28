#! /usr/bin/perl

use strict;
use warnings;
use AnyEvent;
use Test::More;

BEGIN {
    unless (use_ok('WWW::Pusher::Client')) {
        plan skip_all => "Not running without PUSHER_KEY env var";
        exit 0;
    }
}

my $fake_auth = '278d425bdf160c739803';
my $fake_secret = '7ad3773142a6692b25b8';

my $client = WWW::Pusher::Client->new(
    auth_key => $fake_auth,
    secret => $fake_secret
);

PUSHER_PROTOCOL: {
    isa_ok($client, 'WWW::Pusher::Client');
    ok($client->ws_url =~ m/ws\.pusherapp\.com.*app.*protocol.*client.*version/, 'ws_url is formatted properly');
}

SOCKET_AUTH: {
    $client->_socket_id('1234.1234');
    my $auth = $client->_socket_auth('private-foobar');
    cmp_ok($auth, 'eq', '58df8b0c36d6982b82c3ecf6b4662e34fe8c25bba48f5369f135bf843651c3a4', 'fake auth matches');
}

# my $cv = AnyEvent->condvar;
# $cv->recv;

done_testing;
