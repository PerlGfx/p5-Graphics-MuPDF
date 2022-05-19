package inc::MuPDFMaker;
use Moose;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

override _build_WriteMakefile_args => sub { +{
		# Add LIBS => to WriteMakefile() args
		%{ super() },
} };

override _build_WriteMakefile_dump => sub {
	my $str = super();
	$str .= <<'END';
$WriteMakefileArgs{CONFIGURE} = sub {
	require Alien::MuPDF;
	require Config;
	require Module::Load;
	require Hash::Merge;

	my $merge = Hash::Merge->new('RETAINMENT_PRECEDENT');
	my @inlines;
	my @defines;
	push @inlines, Alien::MuPDF->Inline('C');
	push @defines, '-DHAS_MUPDF';

	my $HAS_IMAGER = 0;
	my $HAS_CAIRO  = 0;
	eval {
		Module::Load::load('Imager');
		$HAS_IMAGER = 1;
		push @inlines, Imager->Inline('C');
		push @defines, '-DHAS_IMAGER';
		warn "Imager integration: Yes\n";
		1;
	} or warn "Imager integration: No\n";

	eval {
		die "Skip Cairo integration on MSWin32" if $^O eq 'MSWin32';
		Module::Load::load('Cairo');
		Module::Load::load('Intertangle::API::Cairo');
		$HAS_CAIRO = 1;
		my $cairo = Intertangle::API::Cairo->Inline('C');
		$cairo->{INC} = delete $cairo->{CCFLAGSEX};
		push @inlines, $cairo;
		push @defines, '-DHAS_CAIRO';
		warn "Cairo integration: Yes\n";
		1;
	} or warn "Cairo integration: No\n";

	my $merged = { INC => "", LIBS => "", TYPEMAPS => [] };
	$merged = $merge->merge( $merged, $_ ) for @inlines;
	+{
		CCFLAGS => join(" ",
			$Config::Config{ccflags},
			@{ $merged->{INC} },
			@defines,
		),
		LIBS => join(" ",
			@{ $merged->{LIBS} }
		),
		MYEXTLIB => $merged->{MYEXTLIB},
		TYPEMAPS => [
			'lib/Graphics/MuPDF/mupdf.map',
			@{ $merged->{TYPEMAPS} }
		],
		postamble => {
			defines => \@defines,
		}
	};
};
END
	$str;
};

override _build_footer => sub {
	my $str = super();
	$str .= <<'END';
package MY;
sub postamble {
	my $self = shift;
	my %args = @_;
	my @defines = @{ $args{defines} };
	return $self->SUPER::postamble . <<"POSTAMBLE";

%.xsi : %.xsi.in; cpp @defines \$< > \$@

IntegrationImager.xsi :: IntegrationImager_real.xsi

IntegrationCairo.xsi :: IntegrationCairo_real.xsi

MuPDF.xs :: \\
	IntegrationImager.xsi \\
	IntegrationCairo.xsi

POSTAMBLE

}

END
};

__PACKAGE__->meta->make_immutable;
