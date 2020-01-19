#!/usr/bin/env perl

use Renard::Incunabula::Common::Setup;
use Test::Most;

use Module::Load;
use Renard::Incunabula::Devel::TestHelper;
use Renard::API::MuPDF;
use Renard::API::MuPDF::Context;
use Renard::API::MuPDF::Matrix;
use Renard::API::MuPDF::ColorSpace;
use Renard::API::MuPDF::Pixmap;

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

	my $num_pages = $doc->pages;

	is( $doc->pages, 1310, 'correct number of pages in document' );

	my $matrix = Renard::API::MuPDF::Matrix->identity;
	my $rgb = Renard::API::MuPDF::ColorSpace->new( context => $ctx, device => 'rgb' );
	my $page = 0;
	my $pixmap = Renard::API::MuPDF::Pixmap->new_from_page_number(
		document => $doc, page => $page, matrix => $matrix,
		colorspace => $rgb, alpha => 0,
	);

	is $pixmap->width, 531, 'page width';
	is $pixmap->height, 666, 'page height';

	eval {
		load 'Renard::API::MuPDF::Integration::Imager';
		1;
	} and do {
		lives_ok {
			my $samples = Renard::API::MuPDF::Integration::Imager->to_Imager( $pixmap );
			$samples->write( file => "imager-mupdf.png" );
		} 'Imager integration';
	};

	eval {
		load 'Renard::API::MuPDF::Integration::Cairo';
		1;
	} and do {
		lives_ok {
			my $surface = Renard::API::MuPDF::Integration::Cairo->to_Surface( $pixmap );
			$surface->write_to_png('cairo-mupdf.png');
			1;
		} 'Cairo integration';
	};

	pass 'Finished document tests';
};

done_testing;
