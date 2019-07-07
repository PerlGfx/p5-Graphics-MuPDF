# vim: fdm=marker
use Modern::Perl;
use Renard::Incunabula::Common::Setup;
package Renard::API::MuPDF::Bindings;
# ABSTRACT: MuPDF binding functions

use strict;
use warnings;

use Try::Tiny;
use Module::Load;

our $HAS_IMAGER = 0;
our $HAS_CAIRO  = 0;
BEGIN {
	try {
		load 'Imager';
		$HAS_IMAGER = 1;
	} catch {};

	try {
		load 'Cairo';
		load 'Renard::API::Cairo';
		$HAS_CAIRO = 1 unless $^O eq 'MSWin32';
	} catch {};
}

use Alien::MuPDF;
use Dir::Self;
use File::Spec;

use Renard::API::MuPDF::Bindings::Inline C => DATA =>
	ccflagsex => "-std=c99",
	cppflags => join(" ",
			qw( -DHAS_IMAGER ) x !!($HAS_IMAGER),
			qw( -DHAS_CAIRO  ) x !!($HAS_CAIRO),
		),
	enable => autowrap =>
	typemaps => File::Spec->catfile(__DIR__, 'mupdf.map'),
	filters => 'Preprocess',
	with => [
		qw(Alien::MuPDF),
		qw(Imager)             x!!($HAS_IMAGER),
		qw(Renard::API::Cairo) x!!($HAS_CAIRO),
	];

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
	SV* ctx_sv;
} Renard__API__MuPDF__Context;

typedef struct {
	fz_context* ctx;
	fz_document* doc;
	SV* ctx_sv;
} Renard__API__MuPDF__Document;

typedef struct {
	fz_context* ctx;
	fz_pixmap* pix;
	SV* ctx_sv;
} Renard__API__MuPDF__Pixmap;

typedef struct {
	fz_context* ctx;
	fz_colorspace* cs;
	SV* ctx_sv;
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


	Renard__API__MuPDF__Internal* internal;
	Newx(internal, 1, Renard__API__MuPDF__Internal);
	internal->kind = Context;
	Newx(internal->context, 1, Renard__API__MuPDF__Context);
	internal->context->ctx = ctx;

	_mupdf_attach_mg(self, internal);
	internal->context->ctx_sv = self;
}

void Context_DESTROY(SV* self) {
	Renard__API__MuPDF__Internal* internal = mupdf_get_object(self);
	if( Context != internal->kind ) croak("Wrong magic: expected Context");
	fz_drop_context(internal->context->ctx);
	Safefree(internal->context);
	Safefree(internal);
}
/* }}} */
/* Document {{{ */
void Document_build_path(SV* self, Renard__API__MuPDF__Context* context, const char* path) {
	fz_context*  ctx = context->ctx;
	fz_document* doc;

	MUPDF_TRY_CATCH_VOID( ctx,
		doc = fz_open_document( ctx, path )
	);

	Renard__API__MuPDF__Internal* doc_internal;
	Newx(doc_internal, 1, Renard__API__MuPDF__Internal);
	doc_internal->kind = Document;
	Newx(doc_internal->document, 1, Renard__API__MuPDF__Document);
	doc_internal->document->ctx = ctx;
	doc_internal->document->doc = doc;
	doc_internal->document->ctx_sv = SvREFCNT_inc_simple_NN(context->ctx_sv);

	_mupdf_attach_mg(self, doc_internal);
}

void Document_DESTROY(SV* self) {
	Renard__API__MuPDF__Internal* internal = mupdf_get_object(self);
	if( Document != internal->kind ) croak("Wrong magic: expected Document");
	SvREFCNT_dec_NN(internal->document->ctx_sv);
	fz_drop_document(internal->document->ctx, internal->document->doc);
	Safefree(internal->document);
	Safefree(internal);
}

int Document_count_pages(Renard__API__MuPDF__Document* document) {
	fz_context*  ctx = document->ctx;
	fz_document* doc = document->doc;

	int value = -1;
	MUPDF_TRY_CATCH_VOID( ctx,
		value = fz_count_pages( ctx, doc );
	);
	return value;
}

void Document_new_pixmap_from_page_number(Renard__API__MuPDF__Document* document,
	int number,
	fz_matrix ctm,
	Renard__API__MuPDF__ColorSpace* colorspace,
	int alpha,
	SV* pixmap ) {
	fz_context*  ctx = document->ctx;
	fz_document* doc = document->doc;

	fz_pixmap* pix;
	MUPDF_TRY_CATCH_VOID( ctx,
		pix = fz_new_pixmap_from_page_number(
			ctx, doc, number, ctm, colorspace->cs, alpha
		)
	);

	Renard__API__MuPDF__Internal* pix_internal;
	Newx(pix_internal, 1, Renard__API__MuPDF__Internal);
	pix_internal->kind = Pixmap;
	Newx(pix_internal->pixmap, 1, Renard__API__MuPDF__Pixmap);
	pix_internal->pixmap->ctx = ctx;
	pix_internal->pixmap->pix = pix;
	pix_internal->pixmap->ctx_sv = SvREFCNT_inc_simple_NN(document->ctx_sv);

	_mupdf_attach_mg(pixmap, pix_internal);
}
/* }}} */
/* Pixmap {{{ */
void Pixmap_DESTROY(SV* self) {
	Renard__API__MuPDF__Internal* internal = mupdf_get_object(self);
	if( Pixmap != internal->kind ) croak("Wrong magic: expected Pixmap");
	SvREFCNT_dec_NN(internal->pixmap->ctx_sv);
	fz_drop_pixmap(internal->pixmap->ctx, internal->pixmap->pix);
	Safefree(internal->pixmap);
	Safefree(internal);
}
int Pixmap_width(Renard__API__MuPDF__Pixmap* pixmap) {
	fz_context* ctx;
	fz_pixmap* pix;
	ctx = pixmap->ctx;
	pix = pixmap->pix;

	int value = -1;
	MUPDF_TRY_CATCH_VOID( ctx,
		value = fz_pixmap_width(ctx, pix);
	);
	return value;
}

int Pixmap_height(Renard__API__MuPDF__Pixmap* pixmap) {
	fz_context* ctx;
	fz_pixmap* pix;
	ctx = pixmap->ctx;
	pix = pixmap->pix;

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

float Matrix_a(fz_matrix m) { return m.a; }
float Matrix_b(fz_matrix m) { return m.b; }
float Matrix_c(fz_matrix m) { return m.c; }
float Matrix_d(fz_matrix m) { return m.d; }
float Matrix_e(fz_matrix m) { return m.e; }
float Matrix_f(fz_matrix m) { return m.f; }
/* }}} */
/* ColorSpace {{{ */
#define MUPDF_COLORSPACE_BUILD_DEVICE(X) \
	void ColorSpace_build_device_ ## X (SV* self, Renard__API__MuPDF__Context* context) { \
		fz_context*  ctx = context->ctx; \
		fz_colorspace* cs; \
		\
		MUPDF_TRY_CATCH_VOID( ctx, \
			cs = fz_device_ ## X( ctx ) \
		); \
		\
		Renard__API__MuPDF__Internal* cs_internal; \
		Newx(cs_internal, 1, Renard__API__MuPDF__Internal); \
		cs_internal->kind = ColorSpace; \
		Newx(cs_internal->colorspace, 1, Renard__API__MuPDF__ColorSpace); \
		cs_internal->colorspace->ctx = ctx; \
		cs_internal->colorspace->cs = cs; \
		cs_internal->colorspace->ctx_sv = SvREFCNT_inc_simple_NN(context->ctx_sv); \
		\
		_mupdf_attach_mg(self, cs_internal); \
	}

MUPDF_COLORSPACE_BUILD_DEVICE(gray)
MUPDF_COLORSPACE_BUILD_DEVICE(rgb)
MUPDF_COLORSPACE_BUILD_DEVICE(bgr)
MUPDF_COLORSPACE_BUILD_DEVICE(cmyk)
MUPDF_COLORSPACE_BUILD_DEVICE(lab)


void ColorSpace_DESTROY(SV* self) {
	Renard__API__MuPDF__Internal* internal = mupdf_get_object(self);
	if( ColorSpace != internal->kind ) croak("Wrong magic: expected ColorSpace");
	SvREFCNT_dec_NN(internal->colorspace->ctx_sv);
	fz_drop_colorspace(internal->colorspace->ctx, internal->colorspace->cs);
	Safefree(internal->colorspace);
	Safefree(internal);
}


/* }}} */

/* Integration {{{ */
/* Imager {{{ */
bool Integration_Imager_is_enabled() {
#ifdef HAS_IMAGER
	return true;
#else
	return false;
#endif /* HAS_IMAGER */
}

#ifdef HAS_IMAGER
Imager Integration_Imager_pixmap_samples(Renard__API__MuPDF__Pixmap* pixmap) {
	fz_pixmap* pix = pixmap->pix;
	Imager img = i_img_8_new(pix->w, pix->h, pix->n);
	for( int line = 0; line < pix->h; line++ ) {
		i_psamp(img, 0, pix->w, line,
			pix->samples + (pix->n*line*pix->w),
			NULL,
			pix->n);
	}
	return img;
}
#else
/* No Imager support */
#endif /* HAS_IMAGER */
/* }}} */
/* Cairo {{{ */
bool Integration_Cairo_is_enabled() {
#ifdef HAS_CAIRO
	return true;
#else
	return false;
#endif /* HAS_CAIRO */
}

#ifdef HAS_CAIRO
cairo_surface_t* Integration_Cairo_pixmap_samples(Renard__API__MuPDF__Pixmap* pixmap) {
	fz_pixmap* pix = pixmap->pix;

	cairo_format_t format = CAIRO_FORMAT_ARGB32;

	int stride = cairo_format_stride_for_width (format, pix->w);

	cairo_surface_t* surface = cairo_image_surface_create(
		format,
		pix->w,
		pix->h);

	unsigned char* s = pix->samples;
	unsigned char* image_data = cairo_image_surface_get_data(surface);
	for( int y = 0; y < pix->h; y++ ) {
		for( int x = 0; x < pix->w; x++ ) {
			unsigned char* p = image_data + y * stride + x * 4;
			p[0] = s[2];
			p[1] = s[1];
			p[2] = s[0];
			p[3] = 0xFF;
			s += 3;
		}
	}

	cairo_surface_mark_dirty(surface);

	return surface;
}
#else
/* No Cairo support */
#endif /* HAS_CAIRO */
/* }}} */

/* }}} */

