function answer = lg_factorial6( n )

    answer = 1;
    
    if( n == 0 )
        return;
    else
        for i = 2:n
            answer = answer * i;
        endfor
    endif

endfunction
