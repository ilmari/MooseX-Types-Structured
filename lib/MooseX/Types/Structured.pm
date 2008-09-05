package MooseX::Types::Structured;

use MooseX::Types::Moose qw();
use MooseX::Types -declare => [qw( Dict Tuple Optional )];

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:JJNAPIORK';

=head1 NAME

MooseX::Types::Structured; Structured Type Constraints for Moose

=head1 SYNOPSIS

The following is example usage for this module

	package MyApp::Types
	TBD

=head1 DESCRIPTION

What this application does, why I made it etc.

=head1 TYPES

This class defines the following types and subtypes.

=cut


=head1 SEE ALSO

The following modules or resources may be of interest.

L<Moose>, L<MooseX::TypeLibrary>, L<Moose::Meta::TypeConstraint>

=head1 BUGS

No known or reported bugs.

=head1 AUTHOR

John Napiorkowski, C<< <jjnapiork@cpan.org> >>

=head1 COPYRIGHT & LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;








class_type "DateTime";
class_type "DateTime::Duration";
class_type "DateTime::TimeZone";
class_type "DateTime::Locale::root" => { name => "DateTime::Locale" };

subtype DateTime, as 'DateTime';
subtype Duration, as 'DateTime::Duration';
subtype TimeZone, as 'DateTime::TimeZone';
subtype Locale,   as 'DateTime::Locale';

subtype( Now,
    as Str,
    where { $_ eq 'now' },
    Moose::Util::TypeConstraints::optimize_as {
        no warnings 'uninitialized';
        !ref($_[0]) and $_[0] eq 'now';
    },
);

our %coercions = (
    DateTime => [
		from Num, via { 'DateTime'->from_epoch( epoch => $_ ) },
		from HashRef, via { 'DateTime'->new( %$_ ) },
		from Now, via { 'DateTime'->now },
    ],
    "DateTime::Duration" => [
		from Num, via { DateTime::Duration->new( seconds => $_ ) },
		from HashRef, via { DateTime::Duration->new( %$_ ) },
    ],
    "DateTime::TimeZone" => [
		from Str, via { DateTime::TimeZone->new( name => $_ ) },
    ],
    "DateTime::Locale" => [
        from Moose::Util::TypeConstraints::find_or_create_isa_type_constraint("Locale::Maketext"),
        via { DateTime::Locale->load($_->language_tag) },
        from Str, via { DateTime::Locale->load($_) },
    ],
);

for my $type ( "DateTime", DateTime ) {
    coerce $type => @{ $coercions{DateTime} };
}

for my $type ( "DateTime::Duration", Duration ) {
    coerce $type => @{ $coercions{"DateTime::Duration"} };
}

for my $type ( "DateTime::TimeZone", TimeZone ) {
	coerce $type => @{ $coercions{"DateTime::TimeZone"} };
}

for my $type ( "DateTime::Locale", Locale ) {
	coerce $type => @{ $coercions{"DateTime::Locale"} };
}

__PACKAGE__

__END__

=pod

=head1 NAME

MooseX::Types::DateTime - L<DateTime> related constraints and coercions for
Moose

=head1 SYNOPSIS

Export Example:

	use MooseX::Types::DateTime qw(TimeZone);

    has time_zone => (
        isa => TimeZone,
        is => "rw",
        coerce => 1,
    );

    Class->new( time_zone => "Africa/Timbuktu" );

Namespaced Example:

	use MooseX::Types::DateTime;

    has time_zone => (
        isa => 'DateTime::TimeZone',
        is => "rw",
        coerce => 1,
    );

    Class->new( time_zone => "Africa/Timbuktu" );

=head1 DESCRIPTION

This module packages several L<Moose::Util::TypeConstraints> with coercions,
designed to work with the L<DateTime> suite of objects.

=head1 CONSTRAINTS

=over 4

=item L<DateTime>

A class type for L<DateTime>.

=over 4

=item from C<Num>

Uses L<DateTime/from_epoch>. Floating values will be used for subsecond
percision, see L<DateTime> for details.

=item from C<HashRef>

Calls L<DateTime/new> with the hash entries as arguments.

=back

=item L<Duration>

A class type for L<DateTime::Duration>

=over 4

=item from C<Num>

Uses L<DateTime::Duration/new> and passes the number as the C<seconds> argument.

Note that due to leap seconds, DST changes etc this may not do what you expect.
For instance passing in C<86400> is not always equivalent to one day, although
there are that many seconds in a day. See L<DateTime/"How Date Math is Done">
for more details.

=item from C<HashRef>

Calls L<DateTime::Duration/new> with the hash entries as arguments.

=back

=item L<DateTime::Locale>

A class type for L<DateTime::Locale::root> with the name L<DateTime::Locale>.

=over 4

=item from C<Str>

The string is treated as a language tag (e.g. C<en> or C<he_IL>) and given to
L<DateTime::Locale/load>.

=item from L<Locale::Maktext>

The C<Locale::Maketext/language_tag> attribute will be used with L<DateTime::Locale/load>.

=item L<DateTime::TimeZone>

A class type for L<DateTime::TimeZone>.

=over 4

=item from C<Str>

Treated as a time zone name or offset. See L<DateTime::TimeZone/USAGE> for more
details on the allowed values.

Delegates to L<DateTime::TimeZone/new> with the string as the C<name> argument.

=back

=head1 SEE ALSO

L<MooseX::Types::DateTimeX>

L<DateTime>, L<DateTimeX::Easy>

=head1 VERSION CONTROL

L<http://code2.0beta.co.uk/moose/svn/MooseX-Types-DateTime/trunk>. Ask on
#moose for commit bits.

=head1 AUTHOR

Yuval Kogman E<lt>nothingmuch@woobling.orgE<gt>

John Napiorkowski E<lt>jjn1056 at yahoo.comE<gt>

=head1 COPYRIGHT

	Copyright (c) 2008 Yuval Kogman. All rights reserved
	This program is free software; you can redistribute
	it and/or modify it under the same terms as Perl itself.

=cut
