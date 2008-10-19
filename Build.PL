use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'POE::Component::WWW::LimerickDB',
    license             => 'perl',
    dist_author         => q|Zoffix <'zoffix@cpan.org'>|,
    dist_version_from   => 'lib/POE/Component/WWW/LimerickDB.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'POE'                                      => 0.9999,
        'POE::Component::NonBlockingWrapper::Base' => 0.002,
        'WWW::LimerickDB'                          => 0.0304,
    },
    add_to_cleanup      => [ 'POE-Component-WWW-LimerickDB-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
