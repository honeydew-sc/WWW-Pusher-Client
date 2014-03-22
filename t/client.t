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

my $client = WWW::Pusher::Client->new(
    app_key => $ENV{PUSHER_KEY},
    channel => 'my_channel'
);

isa_ok($client, 'WWW::Pusher::Client');
ok($client->ws_url =~ m/ws\.pusherapp\.com.*app.*protocol.*client.*version/, 'ws_url is formatted properly');

$client->send('hello');

done_testing;
