use Renard::Incunabula::Common::Setup;
package Renard::API::MuPDF::Document;
# ABSTRACT: MuPDF document

use Mu;
use Renard::API::MuPDF::Bindings;

method BUILD($args) {
	$self->Renard::API::MuPDF::Bindings::Document_build_path($args->{context}, "" . $args->{path});
}

method pages() {
	$self->Renard::API::MuPDF::Bindings::Document_count_pages;
}

method new_pixmap_from_page_number( $page, $ctm, $cs, $alpha ) {
	my $pixmap = Renard::API::MuPDF::Pixmap->new;

	$self->Renard::API::MuPDF::Bindings::Document_new_pixmap_from_page_number(
		$page, $ctm, $cs, $alpha,
		$pixmap
	);

	return $pixmap;
}

method DESTROY() {
	$self->Renard::API::MuPDF::Bindings::Document_DESTROY;
}

1;
