package PoRoutine::Channel;
use strict;
use warnings;

use PoRoutine::Channel::Implementation::Child;
use PoRoutine::Channel::Implementation::Parent;

sub new {
    my ($class) = @_;
    my $self = bless {}, $class;

    $self->{_impl} = PoRoutine::Channel::Implementation::Parent->new(state => $self);
    return $self;
}

sub _add_pipe {
    my ($self, $id, $pipe)  = @_;
    $self->{_pipes}{$id}{r} = $pipe->{r};
    $self->{_pipes}{$id}{w} = $pipe->{w};
}

sub register_child  {
    my ($self, $pid, $pipe)  = @_;
    $self->_add_pipe($pid, $pipe);
}

sub become_child {
    my ($self, $pid, $pipe) = @_;
    for my $id (keys %{ $self->{_pipes} }) {
        my $old = delete $self->{_pipes}{$id};
        close $old->{r};
        close $old->{w};
    }

    $self->_add_pipe($pid, $pipe);
    $self->{_impl} = PoRoutine::Channel::Implementation::Child->new(state => $self, ppid => $pid);
}

sub _impl { shift->{_impl}  }

sub recv  { shift->_impl->recv(@_)      }
sub send  { shift->_impl->send(@_)      }
sub close { shift->_impl->close(@_)     }
sub pipes { values %{ shift->{_pipes} } }

=head1 NAME

PoRoutine::Channel

=head1 METHODS

=head2 recv

    my $msg = $c->recv;

Receive a previously sent message from the channel.

=head2 send($msg)

    $c->send($msg)

Send $msg to another process using the channel.

=head2 close

    $c->close()

Close the channel.

=cut

1;
