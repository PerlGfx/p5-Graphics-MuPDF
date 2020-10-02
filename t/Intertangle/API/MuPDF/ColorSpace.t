#!/usr/bin/env perl

use Test::Most tests => 2;

use Renard::Incunabula::Common::Setup;
use Intertangle::API::MuPDF::Context;
use Intertangle::API::MuPDF::ColorSpace;

subtest "RGB device" => fun() {
	my $context = Intertangle::API::MuPDF::Context->new;
	my $rgb = Intertangle::API::MuPDF::ColorSpace->new(
		context => $context,
		device => 'rgb',
	);
	ok $rgb;
};

subtest "All devices" => fun() {
	my $context = Intertangle::API::MuPDF::Context->new;
	my @devices = qw(gray rgb bgr cmyk lab);
	for my $device (@devices) {
		my $cs = Intertangle::API::MuPDF::ColorSpace->new(
			context => $context,
			device => $device,
		);
		ok $cs, "Device: $device";
	}
};

done_testing;
