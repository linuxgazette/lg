/*
 *  lp_data.h
 *
 *  Copyright 2008 Aurelian Melinte. 
 *  Released under GPL 3.0 or later. 
 *
 *  Lockpick demo. Mutex & threads accounting. 
 */

#ifndef _LP_DATA_H_
#define _LP_DATA_H_

#include <pthread.h> 


void lp_report(const char *fmt, ...)  __attribute__((visibility("hidden"))); 

#define LP_INVALID_IDX     (-1)
#define LP_INVALID_THREAD  ((pthread_t)0)
#define LP_INVALID_MUTEX   ((pthread_mutex_t*)0)

/* Return 0 if successfull. */
int  lp_data_init(void) __attribute__((visibility("hidden"))); 
void lp_dump(void)      __attribute__((visibility("hidden")));
 
/*
 * Hooks 
 */

void lp_lock_precheck(const pthread_mutex_t *mutex)            __attribute__((visibility("hidden"))); 
void lp_lock_postcheck(const pthread_mutex_t *mutex, int rc)   __attribute__((visibility("hidden"))); 
void lp_unlock_precheck(const pthread_mutex_t *mutex)          __attribute__((visibility("hidden"))); 
void lp_unlock_postcheck(const pthread_mutex_t *mutex, int rc) __attribute__((visibility("hidden"))); 

/*
 * Checks
 */

/* Return 1 if locked, 0 otherwise. */
int lp_is_mutex_locked(const pthread_mutex_t *mutex, pthread_t thread) __attribute__((visibility("hidden")));
/* Highest idx of mutexes locked by thread. */
int lp_max_idx_mutex_locked(pthread_t thread)            __attribute__((visibility("hidden")));

/* Idx of this mutex or LP_INVALID_IDX. */
int lp_mutex_idx(const pthread_mutex_t *mutex)           __attribute__((visibility("hidden")));

pthread_t lp_thread_owning(const pthread_mutex_t *mutex) __attribute__((visibility("hidden"))); 
const pthread_mutex_t *lp_mutex_wanted(pthread_t thread) __attribute__((visibility("hidden")));

#endif /*_LP_DATA_H_*/
