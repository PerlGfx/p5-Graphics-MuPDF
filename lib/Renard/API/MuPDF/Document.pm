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

1;
