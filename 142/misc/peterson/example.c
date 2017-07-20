// PostgreSQL includes
#include "postgres.h"
#include "fmgr.h"
// Tuple building functions and macros
#include "access/heapam.h"
#include "funcapi.h"

#include <string.h>

// GNU Scientific Library headers
#include <gsl/gsl_complex.h>
#include <gsl/gsl_complex_math.h>

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

typedef char pg_bool;

// forward declaration to keep compiler happy
Datum c_complex_add( PG_FUNCTION_ARGS );

PG_FUNCTION_INFO_V1( c_complex_add );
Datum
c_complex_add( PG_FUNCTION_ARGS )
{
   // input variables
   HeapTupleHeader   lt, rt;

   pg_bool           isNull;

   // things we need to deal with constructing our composite type
   TupleDesc         tupdesc;
   Datum             values[2];
   HeapTuple         tuple;

   // See PostgreSQL Manual section 33.9.2 for base types in C language
   // functions, which tells us that our sql 'float' (aka 'double
   // precision') is a 'float8 *' in PostgreSQL C code.
   float8                *tmp;

   // defined by GSL library
   gsl_complex           l, r, ret;

   // Get arguments.  If we declare our function as STRICT, then
   // this check is superfluous.
   if( PG_ARGISNULL(0) ||
       PG_ARGISNULL(1) )
   {
      PG_RETURN_NULL();
   }

   // Get components of first complex number
   //// get the tuple
   lt = PG_GETARG_HEAPTUPLEHEADER(0);
   ////// get the first element of the tuple
   tmp = (float8*)GetAttributeByNum( lt, 1, &isNull );
   if( isNull ) { PG_RETURN_NULL(); }
   GSL_SET_REAL( &l, *tmp );
   ////// get the second element of the tuple
   tmp = (float8*)GetAttributeByNum( lt, 2, &isNull );
   if( isNull ) { PG_RETURN_NULL(); }
   GSL_SET_IMAG( &l, *tmp );

   // Get components of second complex number
   rt = PG_GETARG_HEAPTUPLEHEADER(1);
   tmp = (float8*)GetAttributeByNum( rt, 1, &isNull );
   if( isNull ) { PG_RETURN_NULL(); }
   GSL_SET_REAL( &r, *tmp );
   tmp = (float8*)GetAttributeByNum( rt, 2, &isNull );
   if( isNull ) { PG_RETURN_NULL(); }
   GSL_SET_IMAG( &r, *tmp );

   // Example of how to print informational debugging statements from
   // your PostgreSQL module.  Remember to set minimum log error
   // levels appropriately in postgresql.conf, or you might not
   // see any output.
   ereport( INFO,
            ( errcode( ERRCODE_SUCCESSFUL_COMPLETION ),
              errmsg( "tmp: %e\n", *tmp )));

   // call our GSL library function
   ret = gsl_complex_add( l, r );

   // Now we need to convert this value into a PostgreSQL composite
   // type.

   if( get_call_result_type( fcinfo, NULL, &tupdesc ) != TYPEFUNC_COMPOSITE )
      ereport( ERROR,
              ( errcode( ERRCODE_FEATURE_NOT_SUPPORTED ),
                errmsg( "function returning record called in context "
                      "that cannot accept type record" )));

   // Use BlessTupleDesc if working with Datums.  Use
   // TupleDescGetAttInMetadata if working with C strings (official
   // 8.2 docs section 33.9.9 shows usage)
   BlessTupleDesc( tupdesc );

   // WARNING: Architecture specific code!
   // GSL uses double representation of complex numbers, which
   // on x86 is eight bytes.  
   // Float8GetDatum defined in postgres.h.
   values[0] = Float8GetDatum( GSL_REAL( ret ) );
   values[1] = Float8GetDatum( GSL_IMAG( ret ) );

   // build tuple from datum array
   tuple = heap_formtuple( tupdesc, values, &isNull );

   // A float8 datum palloc's space, so if we free them too soon,
   // their values will be corrupted (so don't pfree here, let
   // PostgreSQL take care of it.)
   // pfree(values);
   
   PG_RETURN_DATUM( HeapTupleGetDatum( tuple ) );
}
