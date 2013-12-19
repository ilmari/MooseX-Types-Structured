package ## Hide from PAUSE
 MooseX::Meta::TypeCoercion::Structured;

use Moose;
extends 'Moose::Meta::TypeCoercion';

# We need to make sure we can properly coerce the structure elements inside a
# structured type constraint.  However requirements for the best way to allow
# this are still in flux.  For now this class is a placeholder.
# see also Moose::Meta::TypeCoercion.

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
