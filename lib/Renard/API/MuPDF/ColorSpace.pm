use Renard::Incunabula::Common::Setup;
package Renard::API::MuPDF::ColorSpace;
# ABSTRACT: Color space

use Mu;

method BUILD($args) {
	my %device_name = (
		gray => \&_device_gray,
		rgb  => \&_device_rgb,
		bgr  => \&_device_bgr,
		cmyk => \&_device_cmyk,
		lab  => \&_device_lab,
	);
	$device_name{ $args->{device} }->( $self, $args->{context} );
}

method _device_gray($context) {
	$self->Renard::API::MuPDF::Bindings::ColorSpace_build_device_gray($context);
}

method _device_rgb($context) {
	$self->Renard::API::MuPDF::Bindings::ColorSpace_build_device_rgb($context);
}

method _device_bgr($context) {
	$self->Renard::API::MuPDF::Bindings::ColorSpace_build_device_bgr($context);
}

method _device_cmyk($context) {
	$self->Renard::API::MuPDF::Bindings::ColorSpace_build_device_cmyk($context);
}

method _device_lab($context) {
	$self->Renard::API::MuPDF::Bindings::ColorSpace_build_device_lab($context);
}

method DESTROY() {
	$self->Renard::API::MuPDF::Bindings::ColorSpace_DESTROY;
}

1;

