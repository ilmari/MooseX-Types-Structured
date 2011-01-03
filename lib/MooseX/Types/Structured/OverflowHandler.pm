package ## Hide from PAUSE
  MooseX::Types::Structured::OverflowHandler;

use Moose;

use overload '""' => 'name', fallback => 1;

=attr type_constraint

=cut

has type_constraint => (
    is       => 'ro',
    isa      => 'Moose::Meta::TypeConstraint',
    required => 1,
    handles  => [qw/check/],
);

=method name

=cut

sub name {
    my ($self) = @_;
    return 'slurpy ' . $self->type_constraint->name;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
