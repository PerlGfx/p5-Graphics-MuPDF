use Renard::Incunabula::Common::Setup;
package Renard::API::MuPDF;
# ABSTRACT: MuPDF bindings using Inline::C

use Renard::API::MuPDF::Bindings;

method version() {
	Renard::API::MuPDF::Bindings::version();
}

1;
=head1 SEE ALSO

L<Repository information|http://project-renard.github.io/doc/development/repo/p5-Renard-API-MuPDF/>

=cut
