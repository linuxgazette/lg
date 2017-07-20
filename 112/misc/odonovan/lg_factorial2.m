function answer = lg_factorial2( n )

    if( n < 0 )
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
