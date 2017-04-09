use Modern::Perl;
package Renard::Incunabula::MuPDF::Inline;
# ABSTRACT: MuPDF bindings using Inline::C

use strict;
use warnings;

use Alien::MuPDF;
use Dir::Self;
use File::Spec;

use Inline C => DATA =>
	enable => autowrap =>
	typemaps => File::Spec->catfile(__DIR__, 'typemaps'),
	with => [ qw(Alien::MuPDF) ];

1;

__DATA__
__C__

char* version() {
	return FZ_VERSION;
}

fz_context* context() {
	fz_context* ctx = fz_new_context(NULL, NULL, FZ_STORE_UNLIMITED);

	if( !ctx ) {
		croak("Context not created");
		return NULL;
	}

	/* Register the default file types to handle. */
	fz_try(ctx) {
		fz_register_document_handlers(ctx);
	} fz_catch(ctx) {
		fprintf(stderr, "cannot register document handlers: %s\n", fz_caught_message(ctx));
		fz_drop_context(ctx);
		return NULL;
	}

	return ctx;
}

/* fz_document *fz_open_document(fz_context *ctx, const char *filename); */
fz_document* open_document( fz_context* ctx, const char* filename ) {
	fz_document* ret;

	fz_try( ctx ) {
		ret = fz_open_document( ctx, filename );
	} fz_catch( ctx ) {
		ret = NULL;
		croak("%s: %s", __FUNCTION__, fz_caught_message(ctx));
	}

	return ret;
}

/*
#define MUPDF_WRAP( \
	wrapper_fn_name, return_type, failure_value, \
	real_fn_call, \
	... \
	) \
	\
	return_type wrapper_fn_name( fz_context *ctx, ##__VA_ARGS__ ) { \
		return_type ret; \
		fz_try( ctx ) { real_fn_call; } \
		fz_catch( ctx ) { ret = failure_value; } \
		return ret; \
	}

MUPDF_WRAP(open_document, fz_document*, NULL,
	ret = fz_open_document(ctx, filename),
	const char* filename )

*/
