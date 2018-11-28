#!/usr/bin/env perl

use Renard::Incunabula::Common::Setup;
use Test::Most;

use Renard::Incunabula::Devel::TestHelper;
use Renard::Incunabula::API::MuPDF::Inline;

my $pdf_ref_path = try {
	Renard::Incunabula::Devel::TestHelper->test_data_directory->child(qw(PDF Adobe pdf_reference_1-7.pdf));
} catch {
	plan skip_all => "$_";
};

plan tests => 1;

subtest "Open document" => sub {
	my $ctx = Renard::Incunabula::API::MuPDF::Inline::context();
	my $doc;

	lives_ok {
		$doc = Renard::Incunabula::API::MuPDF::Inline::open_document($ctx, $pdf_ref_path);
	} "document was opened";

	my $num_pages = Renard::Incunabula::API::MuPDF::Inline::count_pages( $ctx, $doc );

	is( $num_pages, 1310, 'correct number of pages in document' );

	my $matrix = Renard::Incunabula::API::MuPDF::Inline::new_matrix();
	Renard::Incunabula::API::MuPDF::Inline::set_as_identity_matrix($matrix);
	use DDP; p $matrix;

	my $pixmap = Renard::Incunabula::API::MuPDF::Inline::render($ctx, $doc, 1, $matrix);
	use DDP; p $pixmap;


	use Modern::Perl;
	say "Width: "  . Renard::Incunabula::API::MuPDF::Inline::pixmap_width( $ctx, $pixmap );
	say "Height: " . Renard::Incunabula::API::MuPDF::Inline::pixmap_height( $ctx, $pixmap );

	my $samples = Renard::Incunabula::API::MuPDF::Inline::pixmap_samples_imager( $ctx, $pixmap );
	$samples->write( file => "inline-mupdf.png" );
	use DDP; p $samples;
};

done_testing;
