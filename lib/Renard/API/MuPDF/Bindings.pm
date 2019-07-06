# vim: fdm=marker
use Modern::Perl;
use Renard::Incunabula::Common::Setup;
package Renard::API::MuPDF::Bindings;
# ABSTRACT: MuPDF binding functions

use strict;
use warnings;

BEGIN {
	require Imager;
	require Cairo;
	require Renard::API::Cairo;
}

use Alien::MuPDF;
use Dir::Self;
use File::Spec;

use Renard::API::MuPDF::Bindings::Inline C => DATA =>
	ccflagsex => "-std=c99",
	enable => autowrap =>
	typemaps => File::Spec->catfile(__DIR__, 'mupdf.map'),
	filters => 'Preprocess',
	with => [ qw(Alien::MuPDF Imager Renard::API::Cairo) ];

1;
__DATA__
__C__

/* Preprocessor {{{ */
#define MUPDF_TRY_CATCH_VOID(_ctx, real_fn_call) \
	do { \
		fz_try( _ctx ) { \
			real_fn_call; \
		} fz_catch( _ctx ) { \
			croak("%s (%s:%d): %s", __FUNCTION__, __FILE__, __LINE__, fz_caught_message(_ctx)); \
		} \
	} while(0)
/* }}} */
/* Types {{{ */
STATIC MGVTBL mupdf_mg_vtbl = { 0, 0, 0, 0, 0, 0, 0, 0 };


typedef enum InternalKind {
	Context,
	Document,
	Pixmap,
	ColorSpace
} Renard__API__MuPDF__InternalKind;

typedef struct {
	fz_context* ctx;
} Renard__API__MuPDF__Context;

typedef struct {
	fz_context* ctx;
	fz_document* doc;
} Renard__API__MuPDF__Document;

typedef struct {
	fz_context* ctx;
	fz_pixmap* pix;
} Renard__API__MuPDF__Pixmap;

typedef struct {
	fz_context* ctx;
	fz_colorspace* cs;
} Renard__API__MuPDF__ColorSpace;

typedef struct {
	Renard__API__MuPDF__InternalKind kind;
	union {
		Renard__API__MuPDF__Context*    context;
		Renard__API__MuPDF__Document*   document;
		Renard__API__MuPDF__Pixmap*     pixmap;
		Renard__API__MuPDF__ColorSpace* colorspace;
	};
} Renard__API__MuPDF__Internal;


void _mupdf_attach_mg( SV* sv, void* ptr ) {
	sv_magicext (SvRV(sv), NULL, PERL_MAGIC_ext, &mupdf_mg_vtbl,
		(const char *)ptr, 0);
}

MAGIC *
_mupdf_find_mg (SV * sv) {
	MAGIC *mg;

	if (SvTYPE (sv) < SVt_PVMG)
		return NULL;

	if ((mg = mg_findext(sv, PERL_MAGIC_ext, &mupdf_mg_vtbl))) {
		assert (mg->mg_ptr);
		return mg;
	}

	return NULL;
}

Renard__API__MuPDF__Internal*
mupdf_get_object (SV * sv)
{
	MAGIC *mg;

	if (!(mg = _mupdf_find_mg(SvRV (sv))))
		return NULL;

	return (Renard__API__MuPDF__Internal*) mg->mg_ptr;
}

/* }}} */
/* Meta {{{ */
char* version() {
	return FZ_VERSION;
}
/* }}} */
/* Context {{{ */
void Context_build(SV* self) {
	fz_context* ctx = fz_new_context(NULL, NULL, FZ_STORE_UNLIMITED);
	Renard__API__MuPDF__Internal* internal;
	Newx(internal, 1, Renard__API__MuPDF__Internal);
	internal->kind = Context;
	Newx(internal->context, 1, Renard__API__MuPDF__Context);
	internal->context->ctx = ctx;

	if( ! ctx ) {
		croak("Context not created");
	}

	/* Register the default file types to handle. */
	fz_try(ctx) {
		fz_register_document_handlers(ctx);
	}
	fz_catch(ctx) {
		warn("cannot register document handlers: %s\n", fz_caught_message(ctx));
		fz_drop_context(ctx);
		croak("Context not created");
	}

	_mupdf_attach_mg(self, internal);
}
/* }}} */
/* Document {{{ */
void Document_build_path(SV* self, SV* context, const char* path) {
	fz_context*  ctx;
	fz_document* doc;
	Renard__API__MuPDF__Internal* ctx_internal;
	ctx_internal = mupdf_get_object(context);
	ctx = ctx_internal->context->ctx;

	MUPDF_TRY_CATCH_VOID( ctx,
		doc = fz_open_document( ctx, path )
	);

	Renard__API__MuPDF__Internal* doc_internal;
	Newx(doc_internal, 1, Renard__API__MuPDF__Internal);
	doc_internal->kind = Document;
	Newx(doc_internal->document, 1, Renard__API__MuPDF__Document);
	doc_internal->document->ctx = ctx;
	doc_internal->document->doc = doc;

	_mupdf_attach_mg(self, doc_internal);
}

int Document_count_pages(SV* self) {
	fz_context*  ctx;
	fz_document* doc;
	Renard__API__MuPDF__Internal* internal;
	internal = mupdf_get_object(self);
	ctx = internal->document->ctx;
	doc = internal->document->doc;

	int value = -1;
	MUPDF_TRY_CATCH_VOID( ctx,
		value = fz_count_pages( ctx, doc );
	);
	return value;
}
/* }}} */
/* Pixmap {{{ */
int Pixmap_width(SV* self) {
	fz_context* ctx;
	fz_pixmap* pix;
	Renard__API__MuPDF__Internal* internal;
	internal = mupdf_get_object(self);
	ctx = internal->pixmap->ctx;
	pix = internal->pixmap->pix;

	int value = -1;
	MUPDF_TRY_CATCH_VOID( ctx,
		value = fz_pixmap_width(ctx, pix);
	);
	return value;
}

int Pixmap_height(SV* self) {
	fz_context* ctx;
	fz_pixmap* pix;
	Renard__API__MuPDF__Internal* internal;
	internal = mupdf_get_object(self);
	ctx = internal->pixmap->ctx;
	pix = internal->pixmap->pix;

	int value = -1;
	MUPDF_TRY_CATCH_VOID( ctx,
		value = fz_pixmap_height(ctx, pix);
	);
	return value;
}
/* }}} */
/* Matrix {{{ */
fz_matrix Matrix_build(float a, float b, float c, float d, float e, float f) {
	return fz_make_matrix(a,b,c,d,e,f);
}

fz_matrix Matrix_identity() {
	return fz_identity;
}
/* }}} */

#if 0
##define MUPDF_WRAP( \
	#wrapper_fn_name, return_type, failure_value, \
	#real_fn_call, \
	#... \
	#) \
	#\
	#return_type wrapper_fn_name( fz_context *ctx, ##__VA_ARGS__ ) { \
		#return_type ret; \
		#\
		#fz_try( ctx ) { \
			#real_fn_call; \
		#} fz_catch( ctx ) { \
			#ret = failure_value; \
			#croak("%s (%s:%d): %s", __FUNCTION__, __FILE__, __LINE__, fz_caught_message(ctx)); \
		#} \
		#\
		#return ret; \
	#}



#/* fz_pixmap *fz_new_pixmap_from_page_number(
	#fz_context *ctx,
	#fz_document *doc,
	#int number,
	#const fz_matrix *ctm,
	#fz_colorspace *cs,
	#int alpha); */
#MUPDF_WRAP(render, fz_pixmap*, NULL,
	#ret = fz_new_pixmap_from_page_number( ctx, doc, number, ctm, fz_device_rgb(ctx), 0 ),
	#fz_document *doc,
	#int number,
	#fz_matrix ctm )


#/* unsigned char *fz_pixmap_samples(fz_context *ctx, fz_pixmap *pix); */
#MUPDF_WRAP(pixmap_samples_imager, Imager, NULL,
	#Imager img = i_img_8_new(pix->w, pix->h, pix->n);
	#for( int line = 0; line < pix->h; line++ ) {
		#i_psamp(img, 0, pix->w, line,
			#pix->samples + (pix->n*line*pix->w),
			#NULL,
			#pix->n);
	#}
	#ret = img;
	#/*Imager ret = i_img_8_new(pix->w, pix->h, pix->n);
	#printf("%d:%d:%d:%d\n", ret->xsize, ret->ysize, pix->n, ret->bytes);
	#ret->idata = pix->samples*/
	#,
	#fz_pixmap *pix )

#endif
