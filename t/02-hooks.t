#!perl
use Test::More tests => 1;
use Finglware with => 'hooks';

func greet() {
    return "Hello, World!";
}

override 'greet' => func() {
    return "G'day, mate!";
};

is greet(), "G'day, mate!" => 'Hook modifiers imported OK';

