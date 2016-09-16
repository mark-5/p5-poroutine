package PoRoutine::Channel::Implementation::Parent;
use strict;
use warnings;
use parent 'PoRoutine::Channel::Implementation';

use IO::Select;

sub _get_recv_pipe {
    my ($self) = @_;
    my @ready  = $self->_wait_for_recv();
    return $ready[int rand(scalar @ready)];
}

sub _wait_for_recv {
    my ($self) = @_;
    my %pipes  = map {$_->{r} => $_} $self->pipes;
    my $select = IO::Select->new(map $_->{r}, values %pipes);

    return map $pipes{$_}, $select->can_read;
}

sub _get_send_pipe {
    my ($self) = @_;
    my @ready  = $self->_wait_for_send();
    return $ready[int rand(scalar @ready)];
}

sub _wait_for_send {
    my ($self) = @_;
    my %pipes  = map {$_->{w} => $_} $self->pipes;
    my $select = IO::Select->new(map $_->{w}, values %pipes);

    return map $pipes{$_}, $select->can_write;
}

sub send {
    my ($self, $data) = @_;

    my $sent;
    until ($sent) {
        my $pipe = $self->_get_send_pipe        or return;
        $sent = $self->_pipe_send($pipe, $data) or $self->_pipe_close($pipe);
    }

    return $sent;
}

sub recv {
    my ($self) = @_;

    my $message;
    until ($message) {
        my $pipe = $self->_get_recv_pipe    or return;
        $message = $self->_pipe_recv($pipe) or $self->_pipe_close($pipe);
    }

    return $message;
}

1;
