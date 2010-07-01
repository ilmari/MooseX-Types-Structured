BEGIN {
    use strict;
    use warnings;
    use Test::More tests=>27;
}

use Moose::Util::TypeConstraints;
use MooseX::Types::Structured qw(Dict Tuple Optional);
use MooseX::Types::Moose qw(Int Str ArrayRef HashRef);

# Create some TCs from which errors will be generated

my $simple_tuple = subtype 'simple_tuple', as Tuple[Int,Str];
my $simple_dict = subtype 'simple_dict', as Dict[name=>Str,age=>Int];

# Make sure the constraints we made validate as expected

ok $simple_tuple->check([1,'hello']), "simple_tuple validates: 1,'hello'";
ok !$simple_tuple->check(['hello',1]), "simple_tuple fails: 'hello',1";
ok $simple_dict->check({name=>'Vanessa',age=>34}), "simple_dict validates: {name=>'Vanessa',age=>34}";
ok !$simple_dict->check({name=>$simple_dict,age=>'hello'}), "simple_dict fails: {name=>Object, age=>String}";

## Let's check all the expected validation errors for tuple

like $simple_tuple->validate({a=>1,b=>2}),
 qr/Validation failed for 'simple_tuple' with value { a: 1, b: 2 }/,
 'Wrong basic type';

like $simple_tuple->validate(['a','b']),
 qr/failed for 'simple_tuple' with value \[ "a", "b" \]/,
 'Correctly failed due to "a" not an Int';

like $simple_tuple->validate([1,$simple_tuple]),
 qr/Validation failed for 'simple_tuple' with value \[ 1, MooseX::Meta::TypeConstraint::Structured/,
 'Correctly failed due to object not a Str';

like $simple_tuple->validate([1]),
 qr/Validation failed for 'Str' with value NULL/,
 'Not enought values';

like $simple_tuple->validate([1,'hello','too many']),
 qr/More values than Type Constraints!/,
 'Too Many values';

## And the same thing for dicts [name=>Str,age=>Int]

like $simple_dict->validate([1,2]),
 qr/ with value \[ 1, 2 \]/,
 'Wrong basic type';

like $simple_dict->validate({name=>'John',age=>'a'}),
 qr/failed for 'Int' with value a/,
 'Correctly failed due to age not an Int';

like $simple_dict->validate({name=>$simple_dict,age=>1}),
 qr/with value { age: 1, name: MooseX:/,
 'Correctly failed due to object not a Str';

like $simple_dict->validate({name=>'John'}),
 qr/failed for 'Int' with value NULL/,
 'Not enought values';

like $simple_dict->validate({name=>'Vincent', age=>15,extra=>'morethanIneed'}),
 qr/More values than Type Constraints!/,
 'Too Many values';

 ## TODO some with Optional (or Maybe) and slurpy

 my $optional_tuple = subtype 'optional_tuple', as Tuple[Int,Optional[Str]];
 my $optional_dict = subtype 'optional_dict', as Dict[name=>Str,age=>Optional[Int]];

 like $optional_tuple->validate({a=>1,b=>2}),
 qr/Validation failed for 'optional_tuple' with value { a: 1, b: 2 }/,
 'Wrong basic type';

like $optional_tuple->validate(['a','b']),
 qr/failed for 'Int' with value a/,
 'Correctly failed due to "a" not an Int';

like $optional_tuple->validate([1,$simple_tuple]),
 qr/failed for 'MooseX::Types::Structured::Optional\[Str\]' with value MooseX/,
 'Correctly failed due to object not a Str';

like $optional_tuple->validate([1,'hello','too many']),
 qr/More values than Type Constraints!/,
 'Too Many values';

like $optional_dict->validate([1,2]),
 qr/ with value \[ 1, 2 \]/,
 'Wrong basic type';

like $optional_dict->validate({name=>'John',age=>'a'}),
 qr/Validation failed for 'MooseX::Types::Structured::Optional\[Int\]' with value a/,
 'Correctly failed due to age not an Int';

like $optional_dict->validate({name=>$simple_dict,age=>1}),
 qr/with value { age: 1, name: MooseX:/,
 'Correctly failed due to object not a Str';

like $optional_dict->validate({name=>'Vincent', age=>15,extra=>'morethanIneed'}),
 qr/More values than Type Constraints!/,
 'Too Many values';

## Deeper constraints

my $deep_tuple = subtype 'deep_tuple',
  as Tuple[
    Int,
    HashRef,
    Dict[
      name=>Str,
      age=>Int,
    ],
  ];

ok $deep_tuple->check([1,{a=>2},{name=>'Vincent',age=>15}]),
  'Good Constraint';

{
    my $message = $deep_tuple->validate([1,{a=>2},{name=>'Vincent',age=>'Hello'}]);
    like $message,
      qr/Validation failed for 'MooseX::Types::Structured::Dict\[name,Str,age,Int\]'/,
      'Example deeper error';
}

like $simple_tuple->validate(["aaa","bbb"]),
  qr/'Int' with value aaa/,
  'correct deeper error';

like $deep_tuple->validate([1,{a=>2},{name=>'Vincent1',age=>'Hello1'}]),
  qr/'Int' with value Hello1/,
  'correct deeper error';

## Success Tests...

ok !$deep_tuple->validate([1,{a=>2},{name=>'John',age=>40}]), 'Validates ok';

## Deeper Tests...

my $deeper_tc = subtype
  as Dict[
    a => Tuple[
        Dict[
            a1a => Tuple[Int],
            a1b => Tuple[Int],
        ],
        Dict[
            a2a => Tuple[Int],
            a2b => Tuple[Int],
        ],
    ],
    b => Tuple[
        Dict[
            b1a => Tuple[Int],
            b1b => Tuple[Int],
        ],
        Dict[
            b2a => Tuple[Int],
            b2b => Tuple[Int],
        ],
    ],
  ];

{
    my $message = $deeper_tc->validate({a=>[{a1a=>[1],a1b=>[2]},{a2a=>[3],a2b=>[4]}],b=>[{b1a=>[5],b1b=>['AA']},{b2a=>[7],b2b=>[8]}]});
    warn $message;
}


