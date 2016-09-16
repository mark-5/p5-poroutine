#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';

use PoRoutine;

my @jobs = (1 .. 10);

my $c = PoRoutine->channel;
PoRoutine->go($c, sub {
    while (my $job = $c->recv) {
        $c->send(work($job));
    }
}) for 1 .. 3;

$c->send($_) for @jobs;
warn ">>> sent @{[scalar @jobs]} jobs\n";

my $count = 0;
while (my $data = $c->recv) {
    process($data);
	$count++;

    $c->close if $count == @jobs;
}
warn ">>> received $count results total\n";
warn ">>> DONE!\n";
exit 0;


sub process {
	my ($square) = @_;
	warn "saw: $square\n";
}

sub work {
	my ($num) = @_;
	return $num*$num;
}
