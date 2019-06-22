#!/usr/bin/env perl

use Renard::Incunabula::Common::Setup;
use Test::Most;

use Renard::Incunabula::Devel::TestHelper;
use Renard::API::MuPDF;

my $pdf_ref_path = try {
	Renard::Incunabula::Devel::TestHelper->test_data_directory->child(qw(PDF Adobe pdf_reference_1-7.pdf));
} catch {
	plan skip_all => "$_";
};

plan tests => 1;

subtest "Open document" => sub {
	my $ctx = Renard::API::MuPDF::context();
	my $doc;

	lives_ok {
		$doc = Renard::API::MuPDF::open_document($ctx, $pdf_ref_path);
	} "document was opened";

	my $num_pages = Renard::API::MuPDF::count_pages( $ctx, $doc );

	is( $num_pages, 1310, 'correct number of pages in document' );

	my $matrix = Renard::API::MuPDF::identity_matrix();
	#use DDP; p $matrix;

	my $pixmap = Renard::API::MuPDF::render($ctx, $doc, 1, $matrix);
	#use DDP; p $pixmap;


	use Modern::Perl;
	say "Width: "  . Renard::API::MuPDF::pixmap_width( $ctx, $pixmap );
	say "Height: " . Renard::API::MuPDF::pixmap_height( $ctx, $pixmap );

	my $samples = Renard::API::MuPDF::pixmap_samples_imager( $ctx, $pixmap );
	$samples->write( file => "inline-mupdf.png" );
	#use DDP; p $samples;
};

done_testing;
