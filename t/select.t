use strict;
use warnings;
use Test::More;
use PoRoutine;

subtest 'select multiple poroutines' => sub {
    my $c1 = PoRoutine->channel;
    my $c2 = PoRoutine->channel;

    my %want = (
        $c1 => 'c1 value',
        $c2 => 'c2 value',
    );
    for my $c ($c1, $c2) {
        my $value = $want{$c};
        PoRoutine->go($c, sub { $c->send($value) });
    }

    my %got;
    while (1) {
        PoRoutine->select(
            $c1 => sub { $got{$c1} = $_ },
            $c2 => sub { $got{$c2} = $_ },
        ) or last;
    }

    is_deeply \%got, \%want, 'select could read from all channels';
};

done_testing;
