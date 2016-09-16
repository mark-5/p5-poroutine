#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';

use PoRoutine;

my $c = PoRoutine->channel;
PoRoutine->go($c, sub {
    $c->send('PONG');    
});

warn ">>> sending PING\n";
$c->send('PING');
my $pong = $c->recv;
warn ">>> received $pong\n";
