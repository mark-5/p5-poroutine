package PoRoutine;
use strict;
use warnings;

use Carp;
use IO::Select qw();
use List::Util qw();
use PoRoutine::Channel;
use POSIX qw();

our $VERSION = '0.0.1';

our %CHANNELS;

sub go {
    my $class = shift;
    my $code  = pop;
    my @channels = @_;
    my %pipes    = map {$_ => _create_pipes()} @channels;

    my $pid = fork;
    croak "could not fork: $!" unless defined $pid;

    if ($pid) {
        for my $channel (@channels) {
            $channel->register_child($pid, $pipes{$channel}{child});
            close $_ for @{ $pipes{$channel}{parent} }{qw( r w )};
        }
        return;
    } else {
        my %keep = map {$_ => 1} @channels;
        $_->close for grep !$keep{$_}, values %PoRoutine::CHANNELS;

        for my $channel (@channels) {
            $channel->become_child(getppid(), $pipes{$channel}{parent});
            close $_ for @{ $pipes{$channel}{child} }{qw( r w )};
        }

        $code->(@channels);
        POSIX::_exit(0);
    }
}

sub _create_pipes {
    my $child  = {};
    my $parent = {};
    pipe( $parent->{r}, $child->{w}  ) or die $!;
    pipe( $child->{r},  $parent->{w} ) or die $!;
    $_->autoflush(1) for map @{$_}{qw(r w)}, $child, $parent;

    return {child => $child, parent => $parent};
}

sub channel {
    my ($class, @args) = @_;
    my $channel = PoRoutine::Channel->new(@args);

    $PoRoutine::CHANNELS{$channel} = $channel;
    return $channel;
}

sub select {
    my ($class, @args) = @_;
    my @pairs = List::Util::pairs(@args);

    my %pipes;
    for my $pair (@pairs) {
        my ($channel, $cb) = @$pair;
        for my $pipe (map $_->{r}, $channel->pipes) {
            $pipes{$pipe}{cb}      = $cb;
            $pipes{$pipe}{channel} = $channel;
            $pipes{$pipe}{pipe}    = $pipe;
        }
    }

    my ($cb, $message);
    
    my $s = IO::Select->new(map $_->{pipe}, values %pipes);
    while (not($message) and $s->handles) {
        my @ready   = $s->can_read;
        my $pipe    = $ready[int rand(scalar @ready)];
        my $channel = $pipes{$pipe}{channel};

        if ($message = $channel->recv) {
            $cb = $pipes{$pipe}{cb};
        } else {
            $s->remove($pipe);
        }
    }

    if ($cb) {
        local $_ = $message;
        return $cb->($message);
    } else {
        return;
    }
}

=head1 NAME

PoRoutine - A po' man's implementation of goroutines

=head1 STATUS

B<THIS IS EXPERIMENTAL!>

Anything can change at any time for no reason.

=head1 SYNOPSIS

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

=head1 DESCRIPTION

A stupid, dependency free implementation of goroutines in perl. Relies heavily on forking and pipes.

=head1 METHODS

=head2 channel

    my $c = PoRoutine->channel

Create a new PoRoutine::Channel

=head2 go(@channels, $code)

    PoRoutine->go($c, sub { $c->send( work() ) });

Run $code in a new process. Any PoRoutine::Channels used by $code must be passed to the go method.

=head2 select(($channel, $code), ...)

    my $result = PoRoutine->select(
        $c1 => sub { process1(shift) },
        $c2 => sub { process2(shift) },
    );

Wait for a PoRoutine::Channel to become ready for recv, and pass the result to the paired callback.

=head1 LIMITATIONS

Channels can only be used for communication between a parent proc and its children. Child PoRoutines cannot communicate with other children.

GoRoutine code is run in a forked process. This means that GoRoutines cannot manipulate variables in the parent process.

Data sent through pipes is serialized using Storable, which cannot handle code references.

=head1 TODO

=over

=item mature error handling

=item cross PoRoutine communication

=back

=cut

1;
