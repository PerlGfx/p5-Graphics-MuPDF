#!/usr/bin/env perl

use Test::Most tests => 2;

use Renard::Incunabula::Common::Setup;
use Graphics::MuPDF::Context;
use Graphics::MuPDF::ColorSpace;

subtest "RGB device" => fun() {
	my $context = Graphics::MuPDF::Context->new;
	my $rgb = Graphics::MuPDF::ColorSpace->new(
		context => $context,
		device => 'rgb',
	);
	ok $rgb;
};

subtest "All devices" => fun() {
	my $context = Graphics::MuPDF::Context->new;
	my @devices = qw(gray rgb bgr cmyk lab);
	for my $device (@devices) {
		my $cs = Graphics::MuPDF::ColorSpace->new(
			context => $context,
			device => $device,
		);
		ok $cs, "Device: $device";
	}
};

done_testing;
