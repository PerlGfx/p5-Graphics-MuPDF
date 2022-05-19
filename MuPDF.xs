#if defined(_MSC_VER) || defined(__MINGW32__)
#  define NO_XSLOCKS /* To avoid PerlProc_setjmp/PerlProc_longjmp unresolved symbols */
#endif

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "mupdf/fitz.h"

#include "TryCatch.xsi"
#include "MuPDFWrapper.xsi"

#ifdef HAS_IMAGER

#include "imext.h"
#include "imperl.h"
DEFINE_IMAGER_CALLBACKS;

#endif


#ifdef HAS_CAIRO
#include <cairo-perl.h>
#endif



MODULE = Graphics::MuPDF                PACKAGE = Graphics::MuPDF
PROTOTYPES: DISABLE

char* version(klass)
	SV* klass
CODE:
	RETVAL = FZ_VERSION;
OUTPUT:
	RETVAL


INCLUDE: Context.xsi

INCLUDE: Document.xsi

INCLUDE: Matrix.xsi

INCLUDE: Pixmap.xsi

INCLUDE: ColorSpace.xsi


INCLUDE: IntegrationCairo.xsi

INCLUDE: IntegrationImager.xsi
