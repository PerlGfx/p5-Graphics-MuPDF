use Renard::Incunabula::Common::Setup;
package Graphics::MuPDF::Matrix;
# ABSTRACT: Matrix

use Graphics::MuPDF;

classmethod _build($args) {
	my %args = %$args;
	$args{$_} = exists $args{$_} ? $args{$_} : 0 for qw(a b c d e f);
	return build(@args{qw(a b c d e f)});
}

classmethod new(@args) {
	if( ref $args[0] ) {
		return $class->_build($args[0]);
	}

	return $class->_build(+{ @args });
}

method as_List() {
	( $self->a, $self->b, $self->c, $self->d, $self->e, $self->f, );
}

1;

