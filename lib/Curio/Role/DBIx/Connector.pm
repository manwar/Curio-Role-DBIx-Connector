package Curio::Role::DBIx::Connector;
our $VERSION = '0.01';

use DBIx::Connector;
use Scalar::Util qw( weaken );
use Types::Common::String qw( NonEmptySimpleStr SimpleStr );
use Types::Standard qw( InstanceOf HashRef Undef );

use Moo::Role;
use strictures 2;
use namespace::clean;

with 'Curio::Role';
with 'MooX::BuildArgs';

after initialize => sub{
    my ($class) = @_;

    my $factory = $class->factory();

    $factory->does_caching( 1 );

    return;
};

has connector => (
    is  => 'lazy',
    isa => InstanceOf[ 'DBIx::Connector' ],
);
sub _build_connector {
    my ($self) = @_;

    my $dsn = $self->dsn();
    my $username = $self->can('username') ? $self->username() : '';
    my $password = $self->can('password') ? $self->password() : '';
    my $attributes = $self->can('attributes') ? $self->attributes() : {};

    my $db = DBIx::Connector->new(
        $dsn,
        $username,
        $password,
        {
            AutoCommit => 1,
            %$attributes,
        },
    );

    return $db;
}

1;
__END__

=encoding utf8

=head1 NAME

Curio::Role::DBIx::Connector - Build Curio classes around DBIx::Connector.

=head1 SYNOPSIS

Create a Curio class:

    package MyApp::Service::DB;
    
    use Curio role => '::DBIx::Connector';
    use strictures 2;
    
    use Exporter qw( import );
    our @EXPORT = qw( myapp_db );
    
    key_argument 'key';
    
    add_key 'writer';
    add_key 'reader';
    
    has key => (
        is       => 'ro',
        required => 1,
    );
    
    sub dsn {
        my ($self) = @_;
        return my_config( 'db_dsn' )->{ $self->key() };
    }
    
    sub username {
        my ($self) = @_;
        return my_config( 'db_username' )->{ $self->key() };
    }
    
    sub password {
        my ($self) = @_;
        return my_secrets( $self->key() );
    }
    
    sub attributes {
        return { PrintError=>1 };
    }
    
    sub myapp_db {
        return __PACKAGE__->fetch( @_ )->connector();
    }
    
    1;

Then use your new Curio class elsewhere:

    use MyApp::Service::DB;
    
    my $db = myapp_db('writer');
    
    $db->run(sub{
        $_->do( 'CREATE TABLE foo ( bar )' );
    });

=head1 DESCRIPTION

This role provides all the basics for building a Curio class
which wraps around L<DBIx::Connector>.

=head1 ATTRIBUTES

=head2 connector

    my $connector = MyApp::Service::DB->fetch('writer')->connector();

Holds the L<DBIx::Connector> object.

=head1 REQUIRED METHODS

=head2 dsn

    sub dsn { 'dbi:...' }

=head2 username

    sub username { '' }

=head2 password

    sub password { '' }

=head2 attributes

    sub attributes { {} }

C<AutoCommit> will be set to C<1> unless you directly override it
in this hashref.

See L<DBI/ATTRIBUTES-COMMON-TO-ALL-HANDLES>.

=head1 CACHING

This role sets the L<Curio::Factory/does_caching> feature.

You can of course disable this feature.

    does_caching 0;

=head1 SUPPORT

Please submit bugs and feature requests to the
Curio-Role-CHI GitHub issue tracker:

L<https://github.com/bluefeet/Curio-Role-CHI/issues>

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

