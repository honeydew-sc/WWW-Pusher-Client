#! /usr/bin/perl

use strict;
use warnings;
use Data::Printer;
use AnyEvent;
use Test::More;

BEGIN {
    unless (defined $ENV{PUSHER_KEY}) {
        plan skip_all => "Not running without PUSHER_KEY env var";
        done_testing;

        exit 0;
    }
}

my $fake_auth = '278d425bdf160c739803';
my $fake_secret = '7ad3773142a6692b25b8';

my $client = WWW::Pusher::Client->new(
    auth_key => $fake_auth,
    secret => $fake_secret
);

isa_ok($client, 'WWW::Pusher::Client');
ok($client->ws_url =~ m/ws\.pusherapp\.com.*app.*protocol.*client.*version/, 'ws_url is formatted properly');

$client->send('hello');

done_testing;
