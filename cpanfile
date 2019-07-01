requires 'namespace::clean' => '0.27';
requires 'perl' => '5.008001';
requires 'strictures' => '2.000001';

requires 'Curio' => '0.02';
requires 'Curio::Role' => '0.01';
requires 'DBIx::Connector' => '0.60';
requires 'Moo::Role' => '2.003000';
requires 'MooX::BuildArgs' => '0.08';
requires 'Types::Standard' => '1.002001';

on test => sub {
    requires 'Test2::V0' => '0.000094';
};
