#!perl 

use Test::More qw( no_plan ); #Random initial string...
use lib qw( lib ../lib ../../lib  ); #Just in case we are testing it in-place

use Net::Lujoyglamour;

my $dsn = 'dbi:SQLite:dbname=:memory:';
my $schema = Net::Lujoyglamour->connect($dsn);
$schema->deploy({ add_drop_tables => 1});

my $short = 1;
my $long = "uno.com/";
my $rs_url = $schema->resultset('Url');
my $new_url = $rs_url->new({ short => $short,
			     long => $long});
$new_url->insert;
my @all_urls = $rs_url->all;
is( $#all_urls, 0, "Length OK" );
is( $all_urls[0]->long_url, $long, "Result long retrieved" );
is( $all_urls[0]->short_url, $short, "Result short retrieved" );
my @valid_urls = qw( a aa aaa abcd ABCD AB_CD ABcdD _az_ );
push @valid_urls, "abcde_rst_uvwxyz";

for my $u ( @valid_urls ) {
  is( Net::Lujoyglamour::is_valid( $u), 1, "Valid URL $u" );
}

my @invalid_urls = ( "a"x($Net::Lujoyglamour::short_url_size +1),
		     "!!!!",
		     "abcdñ",
		     "¿Qué pasa?" );

for my $u (@invalid_urls ) {
  is( Net::Lujoyglamour::is_valid( $u), '', "Invalid URL $u" );
}

for (1..100) {
  my $candidate = $schema->generate_candidate_url;
  like( $candidate, qr/[$Net::Lujoyglamour::valid_short_urls]+/, "Candidate $candidate OK" );
  my $long_url = "this.is.a.long.url/".rand(1e6);
  $new_url =  $rs_url->new({ short => $candidate,
			       long => $long_url});
  $new_url->insert;
  my $url = $rs_url->single( { short => $candidate } );
  is( $url->long_url, $long_url, "Got $long_url back" );
}

for (1..100 ) {
  my $long_url = "this.is.a.long.url/".rand(1e6);
  my $short_url = $schema->create_new_short( $long_url );
  like( $short_url, qr/[$Net::Lujoyglamour::valid_short_urls]+/, "Generated $short_url for $long_url OK" );
}

my @wanted = qw( this is what like );
for my $w (@wanted ) {
  my $long_url = "this.is.a.longer.url/".rand(1e6);
  my $short_url = $schema->create_new_short( $long_url, $w );
  is( $short_url, $w, "Getting $w for $long_url");
}

eval {
    $schema->create_new_short('this.is.longer/qq', $wanted[0]);
};
like( $@, qr/URL/, "Error OK");

eval {
    $schema->create_new_short('!!!noURLhere!!!', "whatever");
};
like( $@, qr/URL/, "URL Error OK");
