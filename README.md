# NAME

PoRoutine - A po' man's implementation of goroutines

# SYNOPSIS

    my $c = PoRoutine->channel;
    PoRoutine->go($c, sub {
        while (my $job = $c->recv) {
            $c->send(work($job));
        }
    }) for 1 .. 5;

    $c->send($_) for @jobs;
    while (my $data = $c->recv) {
        process(data);
    }

# DESCRIPTION

A stupid, dependency free implementation of goroutines in perl. Relies heavily on forking and pipes.

# METHODS

## channel

    my $c = PoRoutine->channel

Create a new PoRoutine::Channel

## go(@channels, $code)

    PoRoutine->go($c, sub { $c->send( work() ) });

Run $code in a new process. Any PoRoutine::Channels used by $code must be passed to the go method.

## select(($channel, $code), ...)

    my $result = PoRoutine->select(
        $c1 => sub { process1(shift) },
        $c2 => sub { process2(shift) },
    );

Wait for a PoRoutine::Channel to become ready for recv, and pass the result to the paired callback.

# LIMITATIONS

Channels can only be used for communication between a parent proc and its children. Child PoRoutines cannot communicate with other children.

GoRoutine code is run in a forked process. This means that GoRoutines cannot manipulate variables in the parent process.

Data sent through pipes is serialized using Storable, which cannot handle code references.

# TODO

- mature error handling
- cross PoRoutine communication
