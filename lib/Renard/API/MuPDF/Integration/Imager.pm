use Renard::Incunabula::Common::Setup;
package Renard::API::MuPDF::Integration::Imager;
# ABSTRACT: Integration with Imager package

use Renard::API::MuPDF::Bindings;
use Module::Load;

BEGIN {
	load 'Imager';
}

classmethod to_Imager( $pixmap ) {
	return Renard::API::MuPDF::Bindings::Integration_Imager_pixmap_samples(
		$pixmap
	);
}

1;
