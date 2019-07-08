#!/usr/bin/env perl

use Test::Most tests => 2;

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

subtest "All devices" => fun() {
	my $context = Renard::API::MuPDF::Context->new;
	my @devices = qw(gray rgb bgr cmyk lab);
	for my $device (@devices) {
		my $cs = Renard::API::MuPDF::ColorSpace->new(
			context => $context,
			device => $device,
		);
		ok $cs, "Device: $device";
	}
};

done_testing;
