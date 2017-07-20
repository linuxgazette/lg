/*
 *  lp_bitset.c
 *
 *  Copyright 2008 Aurelian Melinte. 
 *  Released under GPL 3.0 or later. 
 *
 *  Lockpick demo. Bitset. 
 */

#include "lp_bitset.h"

void 
lp_bit_set(lp_bitset *set, unsigned bit)
{
    *set |= (1 << bit);
}


void 
lp_bit_reset(lp_bitset *set, unsigned bit)
{
    *set &= ~(1 << bit);
}


void 
lp_bit_empty(lp_bitset *set)
{
    *set = 0L;
}


int 
lp_bit_is_set(lp_bitset *set, unsigned bit)
{
    return (*set & (1 << bit % 32));
}


int 
lp_bit_is_empty(lp_bitset *set)
{
    return (*set == 0L);
}

char*  
lp_bit_string(lp_bitset *set, char *buf, int len)
{
    int i;
    
    for (i=0; i<len; i++) {
        if (lp_bit_is_set(set, i)) {
            buf[i] = '1'; 
        } else {
            buf[i] = '0'; 
        }
    }
    
    if (len < LP_MAX_NUM_MUTEXES) {
        buf[len-1] = '*'; 
    }
    
    return buf; 
}

