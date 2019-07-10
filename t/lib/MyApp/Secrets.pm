package MyApp::Secrets;

use Types::Standard qw( HashRef );

use Curio;
use strictures 2;

use Exporter qw( import );
our @EXPORT = qw( myapp_secret );

does_caching;

my $default_secrets = {
    main_ => '',
    analytics_ => '',
};

has secrets => (
    is      => 'ro',
    isa     => HashRef,
    default => sub{ $default_secrets },
);

sub myapp_secret {
    my $key = pop;
    return __PACKAGE__->fetch( @_ )->secrets->{ $key };
}

1;
