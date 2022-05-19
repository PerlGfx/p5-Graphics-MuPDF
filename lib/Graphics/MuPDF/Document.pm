use Renard::Incunabula::Common::Setup;
package Graphics::MuPDF::Document;
# ABSTRACT: MuPDF document

use Graphics::MuPDF;
use Mu;

method BUILD($args) {
	$self->build_path($args->{context}, "" . $args->{path});
}

method pages() {
	$self->count_pages;
}

1;
