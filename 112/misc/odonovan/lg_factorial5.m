function answer = lg_factorial5( n )

    if( n == 0 )
        answer = 1;
        return;
    else
        answer = n * lg_factorial5( n -1 );
    endif

endfunction
