use Renard::Incunabula::Common::Setup;
package Renard::API::MuPDF::Context;
# ABSTRACT: MuPDF context

use Renard::API::MuPDF::Bindings;
use Renard::API::MuPDF::Document;
use Mu;

method BUILD($args) {
	$self->Renard::API::MuPDF::Bindings::Context_build;
}

method open_document($path) {
	Renard::API::MuPDF::Document->new( context => $self, path => $path);
}

1;
