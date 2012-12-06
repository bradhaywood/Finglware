#!perl

use Test::More;

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
    }

    method tell {
        return "Name: " . $self->name . ", Age: " . $self->age;
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
}

package Student {   
    use Finglware;
    extends 'SchoolMember';

    attr ( 'marks' );

    method __init($name, $age, $marks) {
        $self->marks($marks);
        $self->SUPER::__init(@_);
    }
}

my $teacher = Teacher->new('Mr. Somers', 45, 35000);
my $student = Student->new('Nancy Wilson', 19, 75);

subtest 'checking inheritance' => sub {
    is $teacher->tell(), "Name: Mr. Somers, Age: 45" => 'Teacher OK';
    is $student->tell(), "Name: Nancy Wilson, Age: 19" => 'Student OK';
};

done_testing();
