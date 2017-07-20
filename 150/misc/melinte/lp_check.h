/*
 *  lp_check.h
 *
 *  Copyright 2008 Aurelian Melinte. 
 *  Released under GPL 3.0 or later. 
 *
 *  Lockpick demo. Detect mutex-related issues. 
 */

#ifndef _LP_CHECK_H_
#define _LP_CHECK_H_

#include <pthread.h>

void lp_lock_precheck_diagnose(const pthread_mutex_t *mutex)            __attribute__((visibility("hidden")));; 
void lp_lock_postcheck_diagnose(const pthread_mutex_t *mutex, int rc)   __attribute__((visibility("hidden")));; 
void lp_unlock_precheck_diagnose(const pthread_mutex_t *mutex)          __attribute__((visibility("hidden")));; 
void lp_unlock_postcheck_diagnose(const pthread_mutex_t *mutex, int rc) __attribute__((visibility("hidden")));; 

#endif /*_LP_CHECK_H_*/
