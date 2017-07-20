DROP FUNCTION gsl_complex_add ( __complex, __complex );
DROP TYPE __complex;

CREATE TYPE __complex AS ( r float, i float );

CREATE OR REPLACE FUNCTION
  gsl_complex_add( __complex, __complex )
RETURNS
  __complex
AS
  'example.so', 'c_complex_add'
LANGUAGE
  C
STRICT
IMMUTABLE;

