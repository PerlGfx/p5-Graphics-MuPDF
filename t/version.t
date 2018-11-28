#!/usr/bin/env perl

use Test::Most tests => 1;
use Renard::Incunabula::API::MuPDF::Inline;

subtest "Test version function" => sub {
	like
		Renard::Incunabula::API::MuPDF::Inline::version(),
		qr/\d+\.\d+[a-z]*/,
		'FZ_VERSION is a version string';
};

done_testing;
