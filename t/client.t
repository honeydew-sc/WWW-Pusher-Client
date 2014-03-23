#! /usr/bin/perl

use strict;
use warnings;
use Data::Printer;
use AnyEvent;
use Test::More;


# BEGIN {
#     unless (defined $ENV{PUSHER_KEY}) {
#         plan skip_all => "Not running without PUSHER_KEY env var";
#         done_testing;

#         exit 0;
#     }
# }

use_ok('WWW::Pusher::Client');

my $fake_key = '278d425bdf160c739803';
my $fake_secret = '7ad3773142a6692b25b8';

my $client = WWW::Pusher::Client->new(
    app_key => $fake_key,
    secret => $fake_secret
);

isa_ok($client, 'WWW::Pusher::Client');
ok($client->ws_url =~ m/ws\.pusherapp\.com.*app.*protocol.*client.*version/, 'ws_url is formatted properly');

SOCKET_AUTH: {
    $client->_socket_id('1234.1234');
    my $auth = $client->socket_auth('private-foobar');
    cmp_ok($auth, 'eq', '58df8b0c36d6982b82c3ecf6b4662e34fe8c25bba48f5369f135bf843651c3a4', 'fake auth matches');
}

# use Data::Dumper; use DDP;
# my $cv = AnyEvent->condvar;
# $cv->recv;

done_testing;
