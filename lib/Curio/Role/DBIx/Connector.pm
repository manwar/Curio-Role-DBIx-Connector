package Curio::Role::DBIx::Connector;
our $VERSION = '0.01';

use DBIx::Connector;
use Scalar::Util qw( blessed );
use Types::Standard qw( InstanceOf ArrayRef );

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

has _custom_connector => (
    is       => 'ro',
    isa      => InstanceOf[ 'DBIx::Connector' ] | ArrayRef,
    init_arg => 'connector',
    clearer  => '_clear_custom_connector',
);

has connector => (
    is       => 'lazy',
    init_arg => undef,
);

sub _build_connector {
    my ($self) = @_;

    my $connector = $self->_custom_connector();
    $self->_clear_custom_connector();
    return $connector if blessed $connector;

    my $args = defined($connector) ? $connector : [];

    $args->[0] = $self->dsn();
    $args->[1] = $self->can('username') ? $self->username() : '';
    $args->[2] = $self->can('password') ? $self->password() : '';

    my $attr = { AutoCommit=>1 };
    $attr = { %$attr, %{ $self->attributes() } } if $self->can('attributes');
    $attr = { %$attr, %{ $args->[3] } } if $args->[3];
    $args->[3] = $attr;

    return DBIx::Connector->new( @$args );
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
    
    key_argument 'connection_key';
    export_function_name 'myapp_db';
    
    add_key 'writer';
    add_key 'reader';
    
    has connection_key => (
        is       => 'ro',
        required => 1,
    );
    
    sub dsn {
        my ($self) = @_;
        return myapp_config()->{db}->{ $self->connection_key() }->{dsn};
    }
    
    sub username {
        my ($self) = @_;
        return myapp_config()->{db}->{ $self->connection_key() }->{username};
    }
    
    sub password {
        my ($self) = @_;
        return myapp_secret( $self->connection_key() . '_' . $self->username() );
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

=head2 connector

Holds the L<DBIx::Connector> object.

May be passed as either a arrayref of arguments or a pre-created object.

If not specified, a new connector will be automatically built based on L</dsn>,
L</username>, L</password>, and L</attributes>.

=head1 REQUIRED METHODS

These methods must be declared in your Curio class.

=head2 dsn

This should return a L<DBI> C<$dsn>/C<$data_source>.  C<dbi:SQLite:dbname=:memory:>, for
example.

=head1 OPTIONAL METHODS

These methods may be declared in your Curio class.

=head2 username

Default to an empty string.

=head2 password

Default to an empty string.

=head2 attributes

Default to an empty hashref.

=head1 AUTOCOMMIT

The C<AutoCommit> L<DBI> attribute is defaulted to C<1>.  You can override this by either
doing so in L</attributes> or if you're passing an arrayref to L</connector> you can set
it there.

=head1 FEATURES

This role sets the L<Curio::Factory/does_caching> feature.

You can of course disable this feature.

    does_caching 0;

=head1 SUPPORT

Please submit bugs and feature requests to the
Curio-Role-DBIx-Connector GitHub issue tracker:

L<https://github.com/bluefeet/Curio-Role-DBIx-Connector/issues>

=head1 ACKNOWLEDGEMENTS

Thanks to L<ZipRecruiter|https://www.ziprecruiter.com/> for encouraging their employees to
contribute back to the open source ecosystem.  Without their dedication to quality
software development this distribution would not exist.

=head1 AUTHORS

    Aran Clary Deltac <bluefeet@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 Aran Clary Deltac

This program is free software: you can redistribute it and/or modify it under the terms of
the GNU General Public License as published by the Free Software Foundation, either
version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.
If not, see L<http://www.gnu.org/licenses/>.

=cut

