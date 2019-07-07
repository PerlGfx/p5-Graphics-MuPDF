use Renard::Incunabula::Common::Setup;
package Renard::API::MuPDF::Integration::Cairo;
# ABSTRACT: Integration with Cairo package

use Renard::API::MuPDF::Bindings;
use Module::Load;

BEGIN {
	load 'Renard::API::Cairo';
	die "Integration with Cairo not supported"
		unless Renard::API::MuPDF::Bindings::Integration_Cairo_is_enabled();
}

classmethod to_Surface( $pixmap ) {
	return Renard::API::MuPDF::Bindings::Integration_Cairo_pixmap_samples(
		$pixmap
	);
}


1;
