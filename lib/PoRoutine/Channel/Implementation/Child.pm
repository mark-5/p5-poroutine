package PoRoutine::Channel::Implementation::Child;
use strict;
use warnings;
use parent 'PoRoutine::Channel::Implementation';

sub ppid { shift->{ppid} }
sub pipe {
    my ($self) = @_;
    my $ppid   = $self->ppid;
    my $state  = $self->state;
    return $state->{_pipes}{$ppid};
}

sub recv {
    my ($self) = @_;
    my $pipe = $self->pipe or return;
    return $self->_pipe_recv($pipe);
}

sub send {
    my ($self, $data) = @_;
    my $pipe = $self->pipe;
    return $self->_pipe_send($pipe, $data);
}

1;
