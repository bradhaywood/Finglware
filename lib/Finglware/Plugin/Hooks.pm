package Finglware::Plugin::Hooks;

sub import {
    my ($class) = @_;
    my $caller = caller;
    # need to find a better way of doing this
    # to make it easier when creating plugins!
    Class::LOP->init('Finglware')->import_methods($caller, qw(
        after
        before
        around
        override
    )) unless scalar($caller) eq 'Finglware';
}

1;
