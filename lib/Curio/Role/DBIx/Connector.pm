package Curio::Role::DBIx::Connector;
our $VERSION = '0.01';

use DBIx::Connector;
use Types::Standard qw( InstanceOf HashRef );
use Types::Common::String qw( NonEmptySimpleStr SimpleStr );

use Moo::Role;
use strictures 2;
use namespace::clean;

with 'Curio::Role';

after initialize => sub{
    my ($class) = @_;

    my $factory = $class->factory();

    $factory->does_caching( 1 );

    return;
};

has dsn => (
    is      => 'lazy',
    isa     => NonEmptySimpleStr,
    builder => 'default_dsn',
);

has username => (
    is      => 'lazy',
    isa     => SimpleStr,
    builder => 'default_username',
);

sub password {
    my ($self) = @_;
    return $self->default_password();
}

has attributes => (
    is      => 'lazy',
    isa     => HashRef,
    builder => 'default_attributes',
);

has connector => (
    is  => 'lazy',
    isa => InstanceOf[ 'DBIx::Connector' ],
);

sub _build_connector {
    my ($self) = @_;

    return DBIx::Connector->new(
        $self->dsn(),
        $self->username(),
        $self->password(),
        {
            AutoCommit => 1,
            %{ $self->attributes() },
        },
    );
}

1;
__END__

=encoding utf8

=head1 NAME

Curio::Role::DBIx::Connector - Build Curio classes around DBIx::Connector.

=head1 SYNOPSIS

Create a Curio class:

    package MyApp::Service::DB;
    
    use MyApp::Config;
    use MyApp::Secrets;
    
    use Curio role => '::DBIx::Connector';
    use strictures 2;
    
    key_argument 'key';
    export_function_name 'myapp_db';
    
    add_key 'writer';
    add_key 'reader';
    
    has key => (
        is       => 'ro',
        required => 1,
    );
    
    sub default_dsn {
        my ($self) = @_;
        return myapp_config()->{db}->{ $self->key() }->{dsn};
    }
    
    sub default_username {
        my ($self) = @_;
        return myapp_config()->{db}->{ $self->key() }->{username};
    }
    
    sub default_password {
        my ($self) = @_;
        return myapp_secret( $self->key() . '_' . $self->username() );
    }
    
    sub default_attributes {
        return {};
    }
    
    1;

Then use your new Curio class elsewhere:

    use MyApp::Service::DB qw( myapp_db );
    
    my $db = myapp_db('writer')->connector();
    
    $db->run(sub{
        $_->do( 'CREATE TABLE foo ( bar )' );
    });

=head1 DESCRIPTION

This role provides all the basics for building a Curio class which wraps around
L<DBIx::Connector>.

=head1 OPTIONAL ARGUMENTS

=head2 dsn

The L<DBI> C<$dsn>/C<$data_source> argument.  If not specified it will be retrieved from
L</default_dsn>.

=head2 username

The L<DBI> C<$username>/C<$user> argument.  If not specified it will be retrieved from
L</default_username>.

=head2 attributes

The L<DBI> C<%attr> argument.  If not specified it will be retrieved from
L</default_attributes>.

C<AutoCommit> will be set to C<1> unless it is directly overridden in this hashref.

See L<DBI/ATTRIBUTES-COMMON-TO-ALL-HANDLES>.

=head2 connector

Holds the L<DBIx::Connector> object.

If not specified as an argument, a new connector will be automatically built based on
L</dsn>, L</username>, L</password>, and L</attributes>.

=head1 ATTRIBUTES

=head2 password

Returns the password as provided by L</default_password>.

=head1 REQUIRED METHODS

These methods must be implemented by the class which consumes this role.

=head2 default_dsn

=head2 default_username

=head2 default_password

=head2 default_attributes

=head1 FEATURES

This role sets the L<Curio::Factory/does_caching> feature.

You can of course disable this feature.

    does_caching 0;

=head1 SUPPORT

Please submit bugs and feature requests to the
Curio-Role-DBIx-Connector GitHub issue tracker:

L<https://github.com/bluefeet/Curio-Role-DBIx-Connector/issues>

=head1 ACKNOWLEDGEMENTS

Thanks to L<ZipRecruiter|https://www.ziprecruiter.com/>
for encouraging their employees to contribute back to the open
source ecosystem.  Without their dedication to quality software
development this distribution would not exist.

=head1 AUTHORS

    Aran Clary Deltac <bluefeet@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 Aran Clary Deltac

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see L<http://www.gnu.org/licenses/>.

=cut

