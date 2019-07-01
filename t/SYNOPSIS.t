#!/usr/bin/env perl
BEGIN { $ENV{PERL_STRICTURES_EXTRA} = 0 }
use strictures 2;
use Test2::V0;

unlink('test.db') if -e 'test.db';

open( my $fh, '<', 'lib/Curio/Role/DBIx/Connector.pm' );
my $content = do { local $/; <$fh> };
close $fh;

{
    package MyApp::Service::DB;

    sub my_config {
        my ($key) = @_;
        return {writer=>''} if $key eq 'db_username';
        return {writer=>'dbi:SQLite:dbname=test.db'};
    }

    sub my_secrets {
        return '';
    }
}

if ($content =~ m{=head1 SYNOPSIS\n\n\S.+?:\n\n(.+?)\n\S.+?:\n\n(.+?)\n=head1}s) {
    my @blocks = ($1, $2);
    my $count = 0;
    foreach my $block (@blocks) {
        $count++;
        local $@;
        my $ok = eval "$block; 1";
        die "Failed to run SYNOPSIS block #$count:\n$@" if !$ok;
    }
}

my $db = myapp_db('writer');

$db->run(sub{
    $_->do('INSERT INTO foo (bar) VALUES (32)');
});

my ($bar) = $db->run(sub{
    $_->selectrow_array('SELECT bar FROM foo');
});

is(
    $bar, 32,
    'works',
);

done_testing;
