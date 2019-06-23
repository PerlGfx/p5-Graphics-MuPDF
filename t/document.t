#!/usr/bin/env perl

use Renard::Incunabula::Common::Setup;
use Test::Most;

use Renard::Incunabula::Devel::TestHelper;
use Renard::API::MuPDF;
use Renard::API::MuPDF::Context;

my $pdf_ref_path = try {
	Renard::Incunabula::Devel::TestHelper->test_data_directory->child(qw(PDF Adobe pdf_reference_1-7.pdf));
} catch {
	plan skip_all => "$_";
};

plan tests => 1;

subtest "Open document" => sub {
	my $ctx = Renard::API::MuPDF::Context->new;
	my $doc;

	lives_ok {
		$doc = $ctx->open_document($pdf_ref_path);
	} "document was opened";

	#use DDP; p $ctx;
	#use DDP; p $doc;

	my $num_pages = $doc->pages;

	is( $doc->pages, 1310, 'correct number of pages in document' );
	#use DDP; p $doc->pages;

	#my $matrix = Renard::API::MuPDF::Matrix->identity;
	#use DDP; p $matrix;

	#my $pixmap = $ctx->render($doc, 1, $matrix);
	#use DDP; p $pixmap;


	use Modern::Perl;
	#say "Width: "  . $pixmap->width( $pixmap );
	#say "Height: " . $pixmap->height( $pixmap );

	#my $samples = Renard::API::MuPDF::Helper::Imager->to_imager( $pixmap );
	#$samples->write( file => "inline-mupdf.png" );
	#use DDP; p $samples;
};

done_testing;
