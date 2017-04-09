#!/usr/bin/env perl

use Test::Most;

use lib 't/lib';
use MuPDFTestHelper;

use Try::Tiny;
use Renard::Incunabula::MuPDF::Inline;

my $pdf_ref_path = try {
	MuPDFTestHelper->test_data_directory->child(qw(PDF Adobe pdf_reference_1-7.pdf));
} catch {
	plan skip_all => "$_";
};

plan tests => 1;

subtest "Open document" => sub {
	my $ctx = Renard::Incunabula::MuPDF::Inline::context();
	my $doc;

	lives_ok {
		$doc = Renard::Incunabula::MuPDF::Inline::open_document($ctx, $pdf_ref_path);
	} "document was opened";

	my $num_pages = Renard::Incunabula::MuPDF::Inline::count_pages( $ctx, $doc );

	is( $num_pages, 1310, 'correct number of pages in document' );

	my $matrix = Renard::Incunabula::MuPDF::Inline::new_matrix();
	Renard::Incunabula::MuPDF::Inline::set_as_identity_matrix($matrix);
	use DDP; p $matrix;

	my $pixmap = Renard::Incunabula::MuPDF::Inline::render($ctx, $doc, 1, $matrix);
	use DDP; p $pixmap;


	use Modern::Perl;
	say "Width: "  . Renard::Incunabula::MuPDF::Inline::pixmap_width( $ctx, $pixmap );
	say "Height: " . Renard::Incunabula::MuPDF::Inline::pixmap_height( $ctx, $pixmap );

	my $samples = Renard::Incunabula::MuPDF::Inline::pixmap_samples_imager( $ctx, $pixmap );
	$samples->write( file => "inline-mupdf.png" );
	use DDP; p $samples;
};

done_testing;
