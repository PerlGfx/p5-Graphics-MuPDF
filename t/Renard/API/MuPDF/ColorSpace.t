#!/usr/bin/env perl

use Test::Most tests => 1;

use Renard::Incunabula::Common::Setup;
use Renard::API::MuPDF::Context;
use Renard::API::MuPDF::ColorSpace;


subtest "RGB device" => fun() {
	my $context = Renard::API::MuPDF::Context->new;
	my $rgb = Renard::API::MuPDF::ColorSpace->new(
		context => $context,
		device => 'rgb',
	);
	ok $rgb;
};

done_testing;
