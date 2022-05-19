#!/usr/bin/env perl

use Test::Most tests => 1;
use Graphics::MuPDF;

subtest "Test version function" => sub {
	like(
		Graphics::MuPDF->version,
		qr/\d+\.\d+[a-z]*/,
		'FZ_VERSION is a version string');
};

done_testing;
