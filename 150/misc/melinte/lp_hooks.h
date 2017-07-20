/*
 *  lp_hooks.h
 *
 *  Copyright 2008 Aurelian Melinte. 
 *  Released under GPL 3.0 or later. 
 *
 *  Lockpick demo. Hook the pthread_* functions. 
 */

#ifndef _LP_HOOKS_H_
#define _LP_HOOKS_H_

#include <pthread.h>

/* Wrappers */
int lp_mutex_lock(pthread_mutex_t *mutex)     __attribute__((visibility("hidden")));
int lp_mutex_trylock(pthread_mutex_t *mutex)  __attribute__((visibility("hidden"))); 
int lp_mutex_unlock(pthread_mutex_t *mutex)   __attribute__((visibility("hidden"))); 

#endif /*_LP_HOOKS_H*/
