use Renard::Incunabula::Common::Setup;
package Graphics::MuPDF::ColorSpace;
# ABSTRACT: Color space

use Graphics::MuPDF;
use Mu;

method BUILD($args) {
	my %device_name = (
		gray => \&device_gray,
		rgb  => \&device_rgb,
		bgr  => \&device_bgr,
		cmyk => \&device_cmyk,
		lab  => \&device_lab,
	);
	$device_name{ $args->{device} }->( $self, $args->{context} );
}

1;
