# PoRoutine

A po' man's implementation of goroutines

```
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
```

# DESCRIPTION

A stupid, lightweight implementation of goroutines in perl.
Relies heavily on forking.

# LIMITATIONS

The biggest limitation is that poroutines can only use channels to communicate with the parent process.

# TODO
* docs
* tests
* error handling
* cross poroutine communication

