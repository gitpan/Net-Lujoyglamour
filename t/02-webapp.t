#!perl 

use Test::More qw( no_plan ); 
use lib qw( lib ../lib ../../lib  ); #Just in case we are testing it in-place

use Net::Lujoyglamour::WebApp;

my $dsn = 'dbi:SQLite:dbname=:memory:';

my $this_dir = $ENV{'PWD'};
my $template_dir;
if ( $this_dir =~ /t$/ ) {
    $template_dir = $this_dir;
} else {
    $template_dir= "$this_dir/t";
}

my $app = new Net::Lujoyglamour::WebApp 
    PARAMS => { dsn => $dsn,
		domain => 'te.st' },
    TMPL_PATH => $template_dir;
isa_ok( $app, 'Net::Lujoyglamour::WebApp', "WebApp OK" );


$ENV{CGI_APP_RETURN_ONLY} = 1;
my $output = $app->run();
like($output, qr/Lujoyglamour/, "output is good");
