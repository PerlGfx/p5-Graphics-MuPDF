use Renard::Incunabula::Common::Setup;
package Graphics::MuPDF::Context;
# ABSTRACT: MuPDF context

use Graphics::MuPDF;
use Graphics::MuPDF::Document;
use Mu;

method BUILD($args) {
	$self->_build;
}

method open_document($path) {
	Graphics::MuPDF::Document->new( context => $self, path => $path);
}

1;
