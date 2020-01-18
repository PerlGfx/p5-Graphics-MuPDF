use Renard::Incunabula::Common::Setup;
package Renard::API::MuPDF::Document;
# ABSTRACT: MuPDF document

use Renard::API::MuPDF;
use Mu;

method BUILD($args) {
	$self->build_path($args->{context}, "" . $args->{path});
}

method pages() {
	$self->count_pages;
}

1;
