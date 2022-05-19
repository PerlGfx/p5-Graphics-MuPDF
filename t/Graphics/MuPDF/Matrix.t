#!/usr/bin/env perl

use Test::Most tests => 2;

use Renard::Incunabula::Common::Setup;
use Graphics::MuPDF::Matrix;

subtest "Identity matrix" => fun() {
	my $matrix = Graphics::MuPDF::Matrix->identity;
	is_deeply [ $matrix->as_List ], [ 1, 0, 0, 1, 0, 0 ];
};

subtest "New matrix" => fun() {
	my $matrix = Graphics::MuPDF::Matrix->new( a => 2, d => 4, f => 8 );
	is_deeply [ $matrix->as_List ], [ 2, 0, 0, 4, 0, 8 ];
};

done_testing;
