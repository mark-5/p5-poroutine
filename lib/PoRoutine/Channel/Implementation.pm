package PoRoutine::Channel::Implementation;
use strict;
use warnings;

use Storable qw();

sub new {
    my ($class, %args) = @_;
    return bless {%args}, $class;
}

sub state { shift->{state}      }
sub pipes { shift->state->pipes }

sub _pipe_recv {
    my ($self, $pipe) = @_;
    my $read;

    $read = $pipe->{r}->sysread(my($_size), 4);
    if (not $read) {
        # ... unless defined $read;
        $self->_pipe_close($pipe);
        return;
    }

    my $size = unpack 'I', $_size;
    $read = $pipe->{r}->sysread(my($frozen), $size);
    if (not $read) {
        # ... unless defined $read;
        $self->_pipe_close($pipe);
        return;
    }

    my $data = Storable::thaw($frozen);
    return $data->{data};
}

sub _pipe_send {
    my ($self, $pipe, $data) = @_;
    my $frozen = Storable::freeze({data => $data});
    my $size   = pack 'I', length($frozen);

    my $wrote = $pipe->{w}->syswrite("$size$frozen");
    unless ($wrote) {
        # ... unless defined $wrote
        $self->_pipe_close($pipe);
    }

    return $wrote;
}

sub _pipe_close {
    my ($self, $pipe) = @_;
    for my $id (keys %{ $self->{_pipes} }) {
        my $_pipe = $self->{_pipes}{$id};
        if ($pipe eq $_pipe) {
            delete $self->{_pipes}{$id};
        }
    }

    close $_ for $pipe->{r}, $pipe->{w};
}

sub close {
    my ($self) = @_;
    $self->_pipe_close($_) for $self->pipes;
}

1;
