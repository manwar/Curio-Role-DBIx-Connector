requires 'namespace::clean' => '0.27';
requires 'perl' => '5.008001';
requires 'strictures' => '2.000001';

requires 'Curio::Role' => '0.02';
requires 'DBIx::Connector' => '0.53';
requires 'Moo::Role' => '2.003000';
requires 'Types::Common::String' => '1.002001';
requires 'Types::Standard' => '1.002001';

requires 'Scalar::Util';

on test => sub {
    requires 'Test2::V0' => '0.000094';

    requires 'Curio' => '0.02';
    requires 'Exporter';
};
