use Renard::Incunabula::Common::Setup;
package Graphics::MuPDF::Integration::Imager;
# ABSTRACT: Integration with Imager package

use Graphics::MuPDF;
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
