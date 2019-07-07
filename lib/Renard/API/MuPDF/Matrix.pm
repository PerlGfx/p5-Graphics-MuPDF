use Renard::Incunabula::Common::Setup;
package Renard::API::MuPDF::Matrix;
# ABSTRACT: Matrix

use Renard::API::MuPDF::Bindings;

classmethod _build($args) {
	my %args = %$args;
	$args{$_} = exists $args{$_} ? $args{$_} : 0 for qw(a b c d e f);
	return Renard::API::MuPDF::Bindings::Matrix_build(@args{qw(a b c d e f)});
}

classmethod new(@args) {
	if( ref $args[0] ) {
		return $class->_build($args[0]);
	}

	return $class->_build(+{ @args });
}

classmethod identity() {
	return Renard::API::MuPDF::Bindings::Matrix_identity();
}

method a() { $self->Renard::API::MuPDF::Bindings::Matrix_a; }
method b() { $self->Renard::API::MuPDF::Bindings::Matrix_b; }
method c() { $self->Renard::API::MuPDF::Bindings::Matrix_c; }
method d() { $self->Renard::API::MuPDF::Bindings::Matrix_d; }
method e() { $self->Renard::API::MuPDF::Bindings::Matrix_e; }
method f() { $self->Renard::API::MuPDF::Bindings::Matrix_f; }

method as_List() {
	( $self->a, $self->b, $self->c, $self->d, $self->e, $self->f, );
}

1;

