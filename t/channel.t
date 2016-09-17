use strict;
use warnings;
use Test::More;
use PoRoutine;

subtest 'serialization' => sub {
    my $c = PoRoutine->channel;
    my %items = (
        string       => "a string",
        number       => 42,
        'scalar ref' => \"a ref to a string",
        'array ref'  => [12, "foo", {}],
        'hash ref'   => {num => 12, string => 'foo', array => []},
    );

    PoRoutine->go($c, sub {
        while (my $msg = $c->recv) {
            $c->send($msg);
        }
    });
    for my $type (sort keys %items) {
        my $want = $items{$type};
        $c->send($want);

        my $got = $c->recv;
        is_deeply $got, $want, "sent and received $type";
    }
    $c->close;
};

subtest 'multiple poroutines' => sub {
    my $c = PoRoutine->channel;

    my %want = (
        first  => 92,
        second => "foo",
    );
    for my $key (sort keys %want) {
        my $value = $want{$key};
        PoRoutine->go($c, sub { $c->send([$key, $value]) });
    }

    my %got;
    while (my $pair = $c->recv) {
        my ($key, $value) = @$pair;
        $got{$key} = $value;
    }

    is_deeply \%got, \%want, 'received messages from multiple poroutines';
};

done_testing;
