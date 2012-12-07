#!perl

use Test::More;
use_ok 'Finglware';

type::struct( 'People' => {
    name => 'String',
    age  => 'Int',
});

my $person1 = People->new(
    name => 'Max Swell',
    age  => 27,
);

my $person2 = People->new(
    name => 'Fargle Thwomptlebottom',
    age  => 0,
);

is $person1->name(), 'Max Swell' => 'Person 1 name OK';
is $person2->name(), 'Fargle Thwomptlebottom' => 'Person 2 name OK';
is $person2->age(), 0, => 'Person 2 Age is zero';
$person2->age(3);

subtest 'ages are different' => sub {
    is $person2->age(), 3, => 'Updated Person 2s age to zero';
    is $person1->age(), 27 => 'Person 1s age did not change';
};

done_testing();
