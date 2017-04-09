use Modern::Perl;
package MuPDFTestHelper;
# ABSTRACT: Helper functions for tests

sub test_data_directory {
	require Path::Tiny;
	Path::Tiny->import();

	if( not defined $ENV{RENARD_TEST_DATA_PATH} ) {
		die "Must set environment variable RENARD_TEST_DATA_PATH to the path for the test-data repository";
	}
	return path( $ENV{RENARD_TEST_DATA_PATH} );
}



1;
