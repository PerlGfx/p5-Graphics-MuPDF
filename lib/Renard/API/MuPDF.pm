use Renard::Incunabula::Common::Setup;
package Renard::API::MuPDF;
# ABSTRACT: MuPDF bindings using Inline::C

use Module::Load;

eval { load 'Imager' };
eval { load 'Cairo' };

require XSLoader;
XSLoader::load(
	__PACKAGE__,
	$Renard::API::MuPDF::{VERSION} ? ${ $Renard::API::MuPDF::{VERSION} } : ()
);

=classmethod version

MuPDF version

Returns C<Str>.

=cut

1;
=head1 SEE ALSO

L<Repository information|http://project-renard.github.io/doc/development/repo/p5-Renard-API-MuPDF/>

=cut
