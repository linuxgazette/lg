/*
 *  lp_bitset.h
 *
 *  Copyright 2008 Aurelian Melinte. 
 *  Released under GPL 3.0 or later. 
 *
 *  Lockpick demo. Bitset. 
 */

#ifndef _LP_BITSET_H_
#define _LP_BITSET_H_

#include <limits.h> 

typedef unsigned long lp_bitset; 
#define LP_MAX_NUM_MUTEXES (sizeof(lp_bitset)*CHAR_BIT-1) 

inline void lp_bit_set(lp_bitset *set, unsigned bit)      __attribute__((visibility("hidden")));;
inline void lp_bit_reset(lp_bitset *set, unsigned bit)    __attribute__((visibility("hidden")));;
inline void lp_bit_empty(lp_bitset *set)                  __attribute__((visibility("hidden")));;
inline int  lp_bit_is_set(lp_bitset *set, unsigned bit)   __attribute__((visibility("hidden")));;
inline int  lp_bit_is_empty(lp_bitset *set)               __attribute__((visibility("hidden")));;
char  *lp_bit_string(lp_bitset *set, char *buf, int len)  __attribute__((visibility("hidden")));;

#endif /*_LP_BITSET_H*/
