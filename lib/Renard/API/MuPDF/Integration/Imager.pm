use Renard::Incunabula::Common::Setup;
package Renard::API::MuPDF::Integration::Imager;
# ABSTRACT: Integration with Imager package

use Renard::API::MuPDF::Bindings;
use Module::Load;

BEGIN {
	load 'Imager';
	die "Integration with Imager not supported"
		unless Renard::API::MuPDF::Bindings::Integration_Imager_is_enabled();
}

classmethod to_Imager( $pixmap ) {
	return Renard::API::MuPDF::Bindings::Integration_Imager_pixmap_samples(
		$pixmap
	);
}

1;
