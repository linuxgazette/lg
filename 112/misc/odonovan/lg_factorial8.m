function answer = lg_factorial8( n )

    if( nargin != 1 )
        usage( "factorial( n )" );
    elseif( !isscalar( n ) ||  !isreal( n ) )
        error( "n must be a positive integer value" );
    elseif( n < 0 )
        error( "there is no definition for negative factorials" );
    endif
    
    answer = 1;
    
    if( n == 0 )
        return;
    else
        for i = 2:n
            answer = answer * i;
        endfor
    endif

endfunction
