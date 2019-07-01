# NAME

Curio::Role::DBIx::Connector - Build Curio classes around DBIx::Connector.

# SYNOPSIS

Create a Curio class:

```perl
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
```

Then use your new Curio class elsewhere:

```perl
use MyApp::Service::DB;

my $db = myapp_db('writer');

$db->run(sub{
    $_->do( 'CREATE TABLE foo ( bar )' );
});
```

# DESCRIPTION

This role provides all the basics for building a Curio class
which wraps around [DBIx::Connector](https://metacpan.org/pod/DBIx::Connector).

# ATTRIBUTES

## connector

```perl
my $connector = MyApp::Service::DB->fetch('writer')->connector();
```

Holds the [DBIx::Connector](https://metacpan.org/pod/DBIx::Connector) object.

# REQUIRED METHODS

## dsn

```perl
sub dsn { 'dbi:...' }
```

## username

```perl
sub username { '' }
```

## password

```perl
sub password { '' }
```

## attributes

```perl
sub attributes { {} }
```

`AutoCommit` will be set to `1` unless you directly override it
in this hashref.

See ["ATTRIBUTES-COMMON-TO-ALL-HANDLES" in DBI](https://metacpan.org/pod/DBI#ATTRIBUTES-COMMON-TO-ALL-HANDLES).

# CACHING

This role sets the ["does\_caching" in Curio::Factory](https://metacpan.org/pod/Curio::Factory#does_caching) feature.

You can of course disable this feature.

```
does_caching 0;
```

# SUPPORT

Please submit bugs and feature requests to the
Curio-Role-CHI GitHub issue tracker:

[https://github.com/bluefeet/Curio-Role-CHI/issues](https://github.com/bluefeet/Curio-Role-CHI/issues)

# ACKNOWLEDGEMENTS

Thanks to [ZipRecruiter](https://www.ziprecruiter.com/)
for encouraging their employees to contribute back to the open
source ecosystem.  Without their dedication to quality software
development this distribution would not exist.

# AUTHORS

```
Aran Clary Deltac <bluefeet@gmail.com>
```

# COPYRIGHT AND LICENSE

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
along with this program.  If not, see [http://www.gnu.org/licenses/](http://www.gnu.org/licenses/).
