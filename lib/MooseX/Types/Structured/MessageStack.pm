package MooseX::Types::Structured::MessageStack;
use Moose;

=attr level

=cut

has 'level' => (
    traits => ['Counter'],
    is => 'ro',
    isa => 'Num',
    required => 0,
    default => 0,
    handles => {
        inc_level => 'inc',
        dec_level => 'dec',
    },
);

=attr messages

=cut

has 'messages' => (
    traits => ['Array'],
    is => 'ro',
    isa => 'ArrayRef[HashRef]',
    required => 1,
    default => sub { [] },
    handles => {
        has_messages => 'count',
        add_message => 'push',
        all_messages => 'elements',
    },
);

=method as_string

=cut

sub as_string {
    my @messages = (shift)->all_messages;
    my @flattened_msgs =  map {
        "\n". (" " x $_->{level}) ."[+] " . $_->{message};
    } reverse @messages;

    return join("", @flattened_msgs);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
