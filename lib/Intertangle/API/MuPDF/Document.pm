use Renard::Incunabula::Common::Setup;
package Intertangle::API::MuPDF::Document;
# ABSTRACT: MuPDF document

use Intertangle::API::MuPDF;
use Mu;

method BUILD($args) {
	$self->build_path($args->{context}, "" . $args->{path});
}

method pages() {
	$self->count_pages;
}

1;
