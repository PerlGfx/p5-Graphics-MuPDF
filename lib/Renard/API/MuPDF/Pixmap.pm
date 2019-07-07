use Renard::Incunabula::Common::Setup;
package Renard::API::MuPDF::Pixmap;
# ABSTRACT: Pixmap

use Mu;
use Renard::API::MuPDF::Bindings;

classmethod new_from_page_number( :$document, :$page, :$matrix, :$colorspace, :$alpha = 0 ) {
	my $pixmap = bless {}, $class;
	$document->Renard::API::MuPDF::Bindings::Document_new_pixmap_from_page_number(
		$page, $matrix, $colorspace, 0,
		$pixmap
	);
	$pixmap;
}

method width() {
	$self->Renard::API::MuPDF::Bindings::Pixmap_width;
}

method height() {
	$self->Renard::API::MuPDF::Bindings::Pixmap_height;
}

method DESTROY() {
	$self->Renard::API::MuPDF::Bindings::Pixmap_DESTROY;
}

1;
