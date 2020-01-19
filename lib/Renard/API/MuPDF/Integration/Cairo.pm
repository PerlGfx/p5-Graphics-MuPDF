use Renard::Incunabula::Common::Setup;
package Renard::API::MuPDF::Integration::Cairo;
# ABSTRACT: Integration with Cairo package

use Renard::API::MuPDF;
use Module::Load;

BEGIN {
	load 'Renard::API::Cairo';
	die "Integration with Cairo not supported"
		unless is_enabled();
}

classmethod to_Surface( $pixmap ) {
	return pixmap_samples(
		$pixmap
	);
}


1;
