package
    fmt {
        sub Print {
            print @_;
        }

        sub Println {
            print @_, "\n";
        }

        sub Fprintf {
            printf @_;
        }
}

package
    type {
        sub number {
            my $i = shift;
            return $i =~ /[1-9](?:\d{0,2})(?:,\d{3})*(?:\.\d*[1-9])?|0?\.\d*[1-9]|0/;
        }

        sub float {
            my $f = shift;
            return $f =~ /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/;
        }

        sub struct {
            my ($name, $hash) = @_;
            {
                no strict 'refs';
                *{"${name}::new"} = sub {
                    my ($self, %args) = @_;
                    my $klass = {};
                    foreach my $key (keys %args) {
                        if ($hash->{$key}) {
                            my $type = $hash->{$key};
                            if (ref($type) eq 'CODE') {
                                $type = $type->($key);
                                if (ref($args{$key}) ne $type) {
                                    warn "Expecting a $type";
                                    return 0;
                                }
                            }
                            else {
                                if ($type eq 'String') {
                                    if (number($args{$key}) || $args{$key} !~ /\w+/) {
                                        warn "Expecting a string";
                                        return 0;
                                    }
                                }
                                elsif ($type eq 'Int') {
                                    if (! number($args{$key})) {
                                        warn "Expecting an integer";
                                        return 0;
                                    }
                                }
                                elsif ($type eq 'HashRef') {
                                    if (ref($args{$key}) ne 'HASH') {
                                        warn "Expecting a HashRef";
                                        return 0;
                                    }
                                }
                                elsif ($type eq 'ArrayRef') {
                                    if (ref($args{$key}) ne 'ARRAY') {
                                        warn "Expecting an ArrayRef";
                                        return 0;
                                    }
                                }
                                else {
                                    warn "Unknown type in struct";
                                    return 0;
                                }
                            }

                            $klass->{$key} = $args{$key};
                            *{"${name}::${key}"} = sub {
                                if (@_ > 1) { $_[0]->{$key} = $_[1]; }
                                return $_[0]->{$key};
                            };
                        }
                        else {
                            warn "No such key in struct ${name}: $key";
                            return 0;
                        }
                    }
                    return bless $klass, $name;
                };
            }
        }
}

package Finglware;

=head1 NAME

Finglware - A new way to look at Perl 5

=head1 DESCRIPTION

The best way to describe Finglware, is 'I want a different way of writing Perl 5, but not too different. I want all them boilerplate pragmas included in one module. I want 5.10 features imported by default. I'd like method modifiers, but I want them to be modular so I only load them when I need. I want a nicer, but minimal OOP framework to work with that's still flexible with automatic constructors and accessors. I want all of this, but I still want it to be fast. This module must also have a silly name.'. I think "Finglware" covers all of that. Especially the last requirement. Oh yeah, it has structs, too.

=head1 SYNOPSIS

=head2 Using structs

    use Finglware;
    
    type::struct( 'People' => {
        name => 'String',
        age  => 'Int',
        opt  => 'HashRef',
    });
    
    my $person1 = People->new(
        name => 'Ted Winkleman',
        age => 35,
        opt => { 'cant_eat' => 'cheese' }
    );

    my $person2 = People->new(
        name => 'Kelly Kroolberg',
        age => "25"
    );

    say "Person 1 is called " . $person1->name;
    say "Person 2 got married and changed her surname";
    $person2->name('Kelly Simpson');
    say "Person 2 is called " . $person2->name;
    
=head2 Inheritance

    # Base (Super) class
    package SchoolMember {
        use Finglware;
    
        # create attributes easily with "attr"
        # to give them values at start up, you can do so in __init
        # which is called after the constructor
        attr (
            'name',
            'age'
        );
    
        method __init($name, $age) {
            # you can set multiple attributes with "attr_set"
            $self->attr_set(
                name => $name,
                age  => $age,
            );
            say "New Member Started [$self]: " . $self->name;
        }
    
        method tell {
            say "Name: " . $self->name . ", Age: " . $self->age;
        }
    }
    
    package Teacher {
        use Finglware;
        extends 'SchoolMember';
    
        attr ( 'salary' );
    
        method __init($name, $age, $salary) {
            $self->salary($salary);
            $self->SUPER::__init(@_);
        }
    
        method tell {
            $self->SUPER::tell();
            say "Salary: " . $self->salary;
        }
    }

    package Student {   
        use Finglware;
        extends 'SchoolMember';
        
        attr ( 'marks' );
        
        method __init($name, $age, $marks) {
            $self->marks($marks);
            $self->SUPER::__init(@_);
        }

        method tell {
            $self->SUPER::tell();
            fmt::Println("Marks: " . $self->marks);
        }
    }

    my $teacher = Teacher->new('Mr. Somers', 45, 35000);
    my $student = Student->new('Nancy Wilson', 19, 75);
    my @members = ($teacher, $student);
    
    for my $member (@members) {
        $member->tell();
    }

=cut

use Class::LOP;
use Import::Into;
use Method::Signatures::Simple;
use B::Hooks::EndOfScope;

use namespace::clean;

our $VERSION = '0.001';

sub import {
    my ($class, %opts) = @_;
    my $caller = caller;

    $^H{feature_switch} =
    $^H{feature_say}    =
    $^H{feature_state}  = 1;

    Class::LOP->init($caller)
        ->warnings_strict
        ->create_constructor;

    my @methods = qw<attr attr_set extends>;
    if ($opts{with}) {
        if (grep { $_ eq 'hooks' } $opts{with}) {
            push @methods, qw(
                after
                before
                around
                override
            );
        }
    }

    Class::LOP->init($class)
        ->import_methods($caller, @methods);

    Method::Signatures::Simple->import::into($caller);

    on_scope_end {
        namespace::clean->clean_subroutines($caller, qw( method func ));
    };
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

sub attr {
    my $class = scalar caller();
    for my $acc (@_) {
        *{"${class}::${acc}"} = sub {
            if (@_ > 1) {
                $_[0]->{$acc} = $_[1];
            }

            return $_[0]->{$acc};
        };
    }
}

sub attr_set {
    my ($self, %attrs) = @_;
    for my $attr (keys %attrs) {
        $self->{$attr} = $attrs{$attr};
    }
}

sub extends {
    my (@mothers) = @_;
    Class::LOP->init(caller())
        ->extend_class(@mothers);
}

=head1 METHODS

Finglware supports method modifiers similar to Moose, with the same syntax. Modifiers available are: C<after>, C<before>, C<around> and C<override>.

=head2 Example modifier

    use Finglware with => 'hooks';
    func foo { say "Hi there" }
    
    override 'foo' => func {
        say "Hello, foo!"
    };

    # foo() now displays "Hello, foo!"

=head2 attr

Defines an attribute for the current class. The attribute can then be set and retrieved by the instance

    package MyClass {
        use Finglware;
        attr 'name';
        
        method __init {
            my $name = shift;
            $self->name( $name );
        }
    }

    my $class = MyClass->new('Sam');
    say $class->name; # Sam
    say $class->name('Barry'); # Barry

=head2 attr_set

Sets multiple attributes in one go.

    $self->attr_set(
        name => 'foo',
        bar  => 'baz',
        lang => 'perl
    );

    # or.. 

    method __init {
        my (%args) = @_;
        $self->attr_set(%args);
    }

=head1 AUTHOR

Brad Haywood <brad@perlpowered.com>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
        
1;
