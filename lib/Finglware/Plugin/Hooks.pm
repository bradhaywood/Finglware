package Finglware::Plugin::Hooks;

sub import {
    my ($class) = @_;
    my $caller = caller;
    # need to find a better way of doing this
    # to make it easier when creating plugins!
    Class::LOP->init($class)->import_methods($caller, qw(
        after
        before
        around
        override
    )) unless scalar($caller) eq 'Finglware';
}

sub after {
    my ($name, $code) = @_;

    Class::LOP->init(caller())->add_hook(
        type    => 'after',
        name    => $name,
        method  => $code,
    );
}

sub before {
    my ($name, $code) = @_;                                                                                                                       
    Class::LOP->init(caller())->add_hook(
        type    => 'before',
        name    => $name,
        method  => $code,
    );
}

sub around {
    my ($name, $code) = @_;                                                                                                                       
    Class::LOP->init(caller())->add_hook(
        type    => 'around',
        name    => $name,
        method  => $code,
    );
}

sub override {
    my ($name, $code) = @_;

    Class::LOP->init(caller())->override_method(
        $name,
        $code
    );
}

1;
