package MyApp::Service::DB;

use MyApp::Config;
use MyApp::Secrets;

use Curio role => '::DBIx::Connector';
use strictures 2;

use Exporter qw( import );
our @EXPORT = qw( myapp_db );

key_argument 'key';

add_key 'main';
add_key 'analytics';

has key => (
    is       => 'ro',
    required => 1,
);

sub dsn {
    my ($self) = @_;
    return myapp_config()->{db}->{ $self->key() }->{dsn};
}

sub username {
    my ($self) = @_;
    return myapp_config()->{db}->{ $self->key() }->{username};
}

sub password {
    my ($self) = @_;
    return myapp_secret( $self->key() . '_' . $self->username() );
}

sub attributes {
    return { PrintError=>1 };
}

sub myapp_db {
    return __PACKAGE__->fetch( @_ )->connector();
}

1;
