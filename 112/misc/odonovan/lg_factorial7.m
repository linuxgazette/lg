function answer = lg_factorial7( n )

    if( n == 0 )
        answer = 1;
        return;
    else
        answer = prod( 1:n );
    endif

endfunction
