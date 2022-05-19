#!/usr/bin/env perl

use Renard::Incunabula::Common::Setup;
use Test::Most;

use Module::Load;
use Renard::Incunabula::Devel::TestHelper;
use Graphics::MuPDF;
use Graphics::MuPDF::Context;
use Graphics::MuPDF::Matrix;
use Graphics::MuPDF::ColorSpace;
use Graphics::MuPDF::Pixmap;

my $pdf_ref_path = try {
	Renard::Incunabula::Devel::TestHelper->test_data_directory->child(qw(PDF Adobe pdf_reference_1-7.pdf));
} catch {
	plan skip_all => "$_";
};

plan tests => 1;

subtest "Open document" => sub {
	my $ctx = Graphics::MuPDF::Context->new;
	my $doc;

	lives_ok {
		$doc = $ctx->open_document($pdf_ref_path);
	} "document was opened";

	my $num_pages = $doc->pages;

	is( $doc->pages, 1310, 'correct number of pages in document' );

	my $matrix = Graphics::MuPDF::Matrix->identity;
	my $rgb = Graphics::MuPDF::ColorSpace->new( context => $ctx, device => 'rgb' );
	my $page = 0;
	my $pixmap = Graphics::MuPDF::Pixmap->new_from_page_number(
		document => $doc, page => $page, matrix => $matrix,
		colorspace => $rgb, alpha => 0,
	);

	is $pixmap->width, 531, 'page width';
	is $pixmap->height, 666, 'page height';

	eval {
		load 'Graphics::MuPDF::Integration::Imager';
		1;
	} and do {
		lives_ok {
			my $samples = Graphics::MuPDF::Integration::Imager->to_Imager( $pixmap );
			$samples->write( file => "imager-mupdf.png" );
		} 'Imager integration';
	};

	eval {
		load 'Graphics::MuPDF::Integration::Cairo';
		1;
	} and do {
		lives_ok {
			my $surface = Graphics::MuPDF::Integration::Cairo->to_Surface( $pixmap );
			$surface->write_to_png('cairo-mupdf.png');
			1;
		} 'Cairo integration';
	};

	pass 'Finished document tests';
};

done_testing;
