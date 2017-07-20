function answer = lg_factorial3( n )

    if( nargin != 1 )
        usage( "factorial( n )" );
    elseif( !isscalar( n ) ||  !isreal( n ) )
        error( "n must be a positive integer value" );
    elseif( n < 0 )
        error( "there is no definition for negative factorials" );
    endif
    
    if( n == 0 )
        answer = 1;
        return;
    else
        answer = prod( 1:n );
    endif

endfunction
