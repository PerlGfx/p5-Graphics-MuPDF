use Renard::Incunabula::Common::Setup;
package Intertangle::API::MuPDF::Context;
# ABSTRACT: MuPDF context

use Intertangle::API::MuPDF;
use Intertangle::API::MuPDF::Document;
use Mu;

method BUILD($args) {
	$self->_build;
}

method open_document($path) {
	Intertangle::API::MuPDF::Document->new( context => $self, path => $path);
}

1;
