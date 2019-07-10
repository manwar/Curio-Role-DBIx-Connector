package MyApp::Config;

use Types::Standard qw( HashRef );

use Curio;
use strictures 2;

use Exporter qw( import );
our @EXPORT = qw( myapp_config );

does_caching;

my $default_config = {
    db => {
        main => {
            dsn      => 'dbi:SQLite:dbname=:memory:',
            username => '',
        },
        analytics => {
            dsn      => 'dbi:SQLite:dbname=:memory:',
            username => '',
        },
    },
};

has config => (
    is      => 'ro',
    isa     => HashRef,
    default => sub{ $default_config },
);

sub myapp_config {
    return __PACKAGE__->fetch( @_ )->config();
}

1;
