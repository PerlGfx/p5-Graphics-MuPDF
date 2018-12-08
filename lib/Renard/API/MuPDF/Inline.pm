use Modern::Perl;
package Renard::API::MuPDF::Inline;
# ABSTRACT: MuPDF bindings using Inline::C

use strict;
use warnings;

use Alien::MuPDF;
use Imager;
use Dir::Self;
use File::Spec;

use Inline C => DATA =>
	ccflagsex => "-std=c99",
	enable => autowrap =>
	typemaps => File::Spec->catfile(__DIR__, 'typemaps'),
	filters => 'Preprocess',
	with => [ qw(Alien::MuPDF Imager) ];

1;

=head1 SEE ALSO

L<Repository information|http://project-renard.github.io/doc/development/repo/p5-Renard-API-MuPDF-Inline/>

=cut

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

#define MUPDF_WRAP( \
	wrapper_fn_name, return_type, failure_value, \
	real_fn_call, \
	... \
	) \
	\
	return_type wrapper_fn_name( fz_context *ctx, ##__VA_ARGS__ ) { \
		return_type ret; \
		\
		fz_try( ctx ) { \
			real_fn_call; \
		} fz_catch( ctx ) { \
			ret = failure_value; \
			croak("%s: %s", __FUNCTION__, fz_caught_message(ctx)); \
		} \
		\
		return ret; \
	}

/* fz_document *fz_open_document(fz_context *ctx, const char *filename); */
MUPDF_WRAP(open_document, fz_document*, NULL,
	ret = fz_open_document( ctx, filename ),
	const char* filename )

/* int fz_count_pages(fz_context *ctx, fz_document *doc); */
MUPDF_WRAP(count_pages, int, -1,
	ret = fz_count_pages( ctx, doc ),
	fz_document *doc)

fz_matrix* new_matrix() {
	fz_matrix* ctm;
	Newx(ctm, 1, fz_matrix);
}

fz_matrix* set_as_identity_matrix(fz_matrix* ctm) {
	return fz_copy_matrix(ctm, &fz_identity);
}

/* fz_pixmap *fz_new_pixmap_from_page_number(
	fz_context *ctx,
	fz_document *doc,
	int number,
	const fz_matrix *ctm,
	fz_colorspace *cs,
	int alpha); */
MUPDF_WRAP(render, fz_pixmap*, NULL,
	ret = fz_new_pixmap_from_page_number( ctx, doc, number, ctm, fz_device_rgb(ctx), 0 ),
	fz_document *doc,
	int number,
	fz_matrix *ctm )


/* unsigned char *fz_pixmap_samples(fz_context *ctx, fz_pixmap *pix); */
MUPDF_WRAP(pixmap_samples_imager, Imager, NULL,
	Imager img = i_img_8_new(pix->w, pix->h, pix->n);
	for( int line = 0; line < pix->h; line++ ) {
		i_psamp(img, 0, pix->w, line,
			pix->samples + (pix->n*line*pix->w),
			NULL,
			pix->n);
	}
	ret = img;
	/*Imager ret = i_img_8_new(pix->w, pix->h, pix->n);
	printf("%d:%d:%d:%d\n", ret->xsize, ret->ysize, pix->n, ret->bytes);
	ret->idata = pix->samples*/
	,
	fz_pixmap *pix )

/* int fz_pixmap_width(fz_context *ctx, fz_pixmap *pix); */
MUPDF_WRAP(pixmap_width, int, -1,
	ret = fz_pixmap_width(ctx, pix),
	fz_pixmap *pix )

/* int fz_pixmap_height(fz_context *ctx, fz_pixmap *pix); */
MUPDF_WRAP(pixmap_height, int, -1,
	ret = fz_pixmap_height(ctx, pix),
	fz_pixmap *pix )
