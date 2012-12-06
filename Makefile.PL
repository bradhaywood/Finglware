use 5.006;
use strict;
use warnings FATAL => 'all';
use inc::Module::Install;

name     'Finglware';
all_from 'lib/Finglware.pm';
author   q{Brad Haywood <brad@perlpowered.com>};
license  'artistic2';

perl_version 5.014;

tests_recursive('t');

resources (
   #homepage   => 'http://yourwebsitehere.com',
   #IRC        => 'irc://irc.perl.org/#Finglware',
   license    => 'http://www.perlfoundation.org/artistic_license_2_0',
   repository => 'https://github.com/bradhaywood/Finglware.git',
   bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Finglware',
);

configure_requires (
   'Module::Install' => 0,
);

build_requires (
   'Test::More' => 0,
);

requires (
   #'ABC'              => 1.6,
   #'Foo::Bar::Module' => 5.0401,
   'Method::Signatures::Simple',
   'B::Hooks::EndOfScope',
   'Import::Into',
   'Class::LOP',
   'namespace::clean',
);

install_as_cpan;
auto_install;
WriteAll;
