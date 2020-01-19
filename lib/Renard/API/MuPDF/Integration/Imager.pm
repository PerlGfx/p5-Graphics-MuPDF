use Renard::Incunabula::Common::Setup;
package Renard::API::MuPDF::Integration::Imager;
# ABSTRACT: Integration with Imager package

use Renard::API::MuPDF;
use Module::Load;

BEGIN {
	load 'Imager';
	die "Integration with Imager not supported"
		unless is_enabled();
}

classmethod to_Imager( $pixmap ) {
	return pixmap_samples(
		$pixmap
	);
}

1;
