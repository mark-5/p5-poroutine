#!/usr/bin/env perl
use strict;
use warnings;

use PoRoutine;

my $c1 = PoRoutine->channel;
my $c2 = PoRoutine->channel;
PoRoutine->go($c1, sub {
    alarm (10);
    $c1->send($$) while sleep 1;
});
PoRoutine->go($c2, sub {
    alarm (20);
    $c2->send($$) while sleep 2;
});

while (1) {
    my $got = PoRoutine->select(
        $c1 => sub { shift },
        $c2 => sub { shift },
    ) or last;
    print "$got\n";
}
