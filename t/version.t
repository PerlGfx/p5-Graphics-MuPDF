#!/usr/bin/env perl

use Test::Most tests => 1;
use Intertangle::API::MuPDF;

subtest "Test version function" => sub {
	like(
		Intertangle::API::MuPDF->version,
		qr/\d+\.\d+[a-z]*/,
		'FZ_VERSION is a version string');
};

done_testing;
