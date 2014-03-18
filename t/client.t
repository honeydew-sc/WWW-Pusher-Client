#! /usr/bin/perl

use strict;
use warnings;
use Data::Printer;
use AnyEvent;
use Test::More;

BEGIN {
    unless (use_ok('WWW::Pusher::Client')) {
        BAIL_OUT("Couldn't load WWW::Pusher::Client");
        exit;
    }

    unless (defined $ENV{PUSHER_KEY}) {
        BAIL_OUT("You need a PUSHER_KEY, sorry");
    }
}

my $client = WWW::Pusher::Client->new(
    app_key => $ENV{PUSHER_KEY},
    channel => 'my_channel'
);

isa_ok($client, 'WWW::Pusher::Client');
ok($client->ws_url =~ m/ws\.pusherapp\.com.*app.*protocol.*client.*version/, 'ws_url is formatted properly');

$client->send('hello');
$DB::single=2;

done_testing;
