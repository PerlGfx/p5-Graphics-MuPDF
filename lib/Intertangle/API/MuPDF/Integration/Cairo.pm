use Renard::Incunabula::Common::Setup;
package Intertangle::API::MuPDF::Integration::Cairo;
# ABSTRACT: Integration with Cairo package

use Intertangle::API::MuPDF;
use Module::Load;

BEGIN {
	load 'Intertangle::API::Cairo';
	die "Integration with Cairo not supported"
		unless is_enabled();
}

classmethod to_Surface( $pixmap ) {
	return pixmap_samples(
		$pixmap
	);
}


1;
