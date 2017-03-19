package Renard::Incunabula::MuPDF::Inline;

use strict;
use warnings;

use Alien::MuPDF;

use Inline C => DATA =>
	enable => autowrap =>
	with => [ qw(Alien::MuPDF) ];

1;

__DATA__
__C__

char* version() {
	return FZ_VERSION;
}
