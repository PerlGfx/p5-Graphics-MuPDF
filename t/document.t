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
};

done_testing;
