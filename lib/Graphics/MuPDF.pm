use Renard::Incunabula::Common::Setup;
package Graphics::MuPDF;
# ABSTRACT: MuPDF bindings using Inline::C

use Module::Load;

eval { load 'Imager' };
eval { load 'Cairo' };

require XSLoader;
XSLoader::load(
	__PACKAGE__,
	$Graphics::MuPDF::{VERSION} ? ${ $Graphics::MuPDF::{VERSION} } : ()
);

=classmethod version

MuPDF version

Returns C<Str>.

=cut

1;
=head1 SEE ALSO



=cut
