/*
 *  lp_data.c
 *
 *  Copyright 2008 Aurelian Melinte. 
 *  Released under GPL 3.0 or later. 
 *
 *  Lockpick demo. Mutex & threads accounting. 
 */

#include <signal.h>
#include <execinfo.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <errno.h>
#include <limits.h>
#include <assert.h>

#include <pthread.h>

#include "lp_data.h"
#include "lp_hooks.h"
#include "lp_check.h"
#include "lp_bitset.h"

#define LP_MAX_NUM_THREADS (15)
typedef struct _lp_phtread_info {
    pthread_t             thread;
    lp_bitset             mutexes; /*that the thread owns*/
    const pthread_mutex_t *mutex_to_lock; /*The mutex that the thread tries to acquire.*/
} lp_phtread_info; 

typedef struct _lp_mutex_info {
    /*Its id/order is position in table;*/
    const pthread_mutex_t *mutex; 
    pthread_t             owning_thread; 
    int                   owning_thread_idx; 
} lp_mutex_info; 

/*
 * Note: the arrays are ok for a demo but in real life
 * please use smarter data structures. 
 */
typedef struct _lp_infos {
    pthread_mutex_t mutex; 
    lp_phtread_info threads[LP_MAX_NUM_THREADS+1];
    unsigned        nthreads; 
    lp_mutex_info   mutexes[LP_MAX_NUM_MUTEXES+1]; 
    unsigned        nmutexes; 
} lp_infos; 
static lp_infos lp_info; 


static int lp_data_unlock(void);
static int lp_data_lock(void); 


/* Return index or LP_INVALID_IDX */
static int
lp_thread_insert_or_find(pthread_t thread)
{
    int i;

    assert(thread != LP_INVALID_THREAD); 

    if (lp_info.nthreads >= LP_MAX_NUM_THREADS) {
        lp_report("Max muber of threads reached.\n");
        return LP_INVALID_IDX; 
    }

    for (i=0; i<LP_MAX_NUM_THREADS; i++) {
        /*if (lp_info.threads[i].thread == thread) {*/
        if (0 != pthread_equal(lp_info.threads[i].thread, thread)) {
            return i;
        /*} else if (lp_info.threads[i].thread == LP_INVALID_THREAD) {*/
        } else if (0 != pthread_equal(lp_info.threads[i].thread, LP_INVALID_THREAD)) {
            lp_info.threads[i].thread = thread;
            lp_info.nthreads++; 
            assert(lp_info.threads[i].mutex_to_lock == LP_INVALID_MUTEX); 
            assert(lp_bit_is_empty(&lp_info.threads[i].mutexes) != 0); 
            lp_report("New thread T%lx[%x].\n", thread, i);
            return i;
        }
    }

    assert(0); /*should not reach*/
	return LP_INVALID_IDX;
}


/* Return index or LP_INVALID_IDX */
static int
lp_mutex_insert_or_find(const pthread_mutex_t *mutex)
{
    int i;

    assert(mutex != NULL);

    if (lp_info.nmutexes >= LP_MAX_NUM_MUTEXES) {
        lp_report("Max muber of mutexes reached.\n");
        return LP_INVALID_IDX; 
    }

    for (i=0; i<LP_MAX_NUM_MUTEXES; i++) {
        if (lp_info.mutexes[i].mutex == mutex) {
            return i;
        } else if (lp_info.mutexes[i].mutex == LP_INVALID_MUTEX) {
            lp_info.mutexes[i].mutex = mutex;
            lp_info.nmutexes++; 
            assert(lp_info.mutexes[i].owning_thread_idx == LP_INVALID_IDX); 
            assert(lp_info.mutexes[i].owning_thread == LP_INVALID_THREAD); 
            lp_report("New mutex M%lx[%x].\n", mutex, i);
            return i;
        }
    }

    assert(0); /*should not reach*/
	return LP_INVALID_IDX;
}


static int 
lp_mutex_try_acquire_idx(int midx, int tidx)
{
    assert(midx != LP_INVALID_IDX && midx < LP_MAX_NUM_MUTEXES); 
    assert(tidx != LP_INVALID_IDX && tidx < LP_MAX_NUM_THREADS); 
    
    lp_info.threads[tidx].mutex_to_lock = lp_info.mutexes[midx].mutex;

    return 0;
}


static int 
lp_mutex_acquired_idx(int midx, int tidx)
{
    assert(midx != LP_INVALID_IDX && midx < LP_MAX_NUM_MUTEXES); 
    assert(tidx != LP_INVALID_IDX && tidx < LP_MAX_NUM_THREADS); 
    
    lp_info.mutexes[midx].owning_thread = pthread_self(); /*FIXME: find_or_insert*/
    lp_info.mutexes[midx].owning_thread_idx = tidx; 

    lp_info.threads[tidx].mutex_to_lock = LP_INVALID_MUTEX;
    lp_bit_set(&lp_info.threads[tidx].mutexes, midx); 

    return 0;
}


static int 
lp_mutex_released_idx(int midx, int tidx)
{
    assert(midx != LP_INVALID_IDX && midx < LP_MAX_NUM_MUTEXES); 
    assert(tidx != LP_INVALID_IDX && tidx < LP_MAX_NUM_THREADS); 
    
    lp_info.mutexes[midx].owning_thread_idx = LP_INVALID_IDX; 
    lp_info.mutexes[midx].owning_thread = LP_INVALID_THREAD; 
    lp_bit_reset(&lp_info.threads[tidx].mutexes, midx); 

    return 0;
}


int 
lp_mutex_idx(const pthread_mutex_t *mutex)
{
    int midx = LP_INVALID_IDX;

    assert(mutex != NULL);

    midx = lp_mutex_insert_or_find(mutex);
    assert(midx != LP_INVALID_IDX); 

    return midx; 
}


int 
lp_max_idx_mutex_locked(pthread_t thread)
{
    int tidx = LP_INVALID_IDX, midx = LP_INVALID_IDX;

    tidx = lp_thread_insert_or_find(thread);
    if (tidx != LP_INVALID_IDX) {
        for (midx=LP_MAX_NUM_MUTEXES-1; midx>=0; midx--) {
            if (lp_bit_is_set(&lp_info.threads[tidx].mutexes, midx)) {
                return midx; 
            }
        }
    }

    return LP_INVALID_IDX; 
}


int 
lp_is_mutex_locked(const pthread_mutex_t *mutex, pthread_t thread)
{
    int tidx = LP_INVALID_IDX, midx = LP_INVALID_IDX;
    int rc = 0;

    assert(mutex != NULL);

    tidx = lp_thread_insert_or_find(thread);
    midx = lp_mutex_insert_or_find(mutex);
    if (midx != LP_INVALID_IDX && tidx != LP_INVALID_IDX) {
        rc = lp_bit_is_set(&lp_info.threads[tidx].mutexes, midx); 
    }
    
    return rc; 
}


pthread_t 
lp_thread_owning(const pthread_mutex_t *mutex)
{
    int       midx = LP_INVALID_IDX;
    pthread_t thread = LP_INVALID_THREAD; 

    assert(mutex != NULL);

    midx = lp_mutex_insert_or_find(mutex);
    if (midx != LP_INVALID_IDX) {
        thread = lp_info.mutexes[midx].owning_thread; 
    }

    return thread; 
}


const pthread_mutex_t *
lp_mutex_wanted(pthread_t thread)
{
    int             tidx = LP_INVALID_IDX;
    const pthread_mutex_t *mutex = LP_INVALID_MUTEX; 

    tidx = lp_thread_insert_or_find(thread);
    if (tidx != LP_INVALID_THREAD) {
        mutex = lp_info.threads[tidx].mutex_to_lock;
    }

    return mutex; 
}


int  
lp_data_init(void)
{
    int rc = -1, i = 0; 
    int tidx = LP_INVALID_IDX;

    lp_report("Initialising liblockpick...\n");

    memset(&lp_info, 0, sizeof(lp_info));
    rc = pthread_mutex_init(&lp_info.mutex, NULL); 
    assert(rc == 0);
    
    lp_info.mutexes[0].mutex = &lp_info.mutex;
    lp_info.nmutexes++;

    tidx = lp_thread_insert_or_find(pthread_self());
    assert(tidx != LP_INVALID_IDX); 

    for (i=0; i<LP_MAX_NUM_MUTEXES; i++) {
        lp_mutex_released_idx(i, tidx);
    }
    for (i=0; i<LP_MAX_NUM_THREADS; i++) {
        lp_info.threads[i].mutex_to_lock = LP_INVALID_MUTEX; 
    }

    lp_report("liblockpick initialised.\n");
    return 0;
}


static int 
lp_data_lock(void)
{
    int rc = -1; 
    int tidx = LP_INVALID_IDX, midx = LP_INVALID_IDX;

    tidx = lp_thread_insert_or_find(pthread_self());
    if (tidx != LP_INVALID_IDX) {
        midx = lp_mutex_insert_or_find(&lp_info.mutex);
        assert(midx == 0); 

        rc = lp_mutex_lock(&lp_info.mutex);
        assert(rc == 0);

        lp_mutex_try_acquire_idx(midx, tidx);
        lp_mutex_acquired_idx(midx, tidx);
    }

    return rc;
}


static int 
lp_data_unlock(void)
{
    int rc = -1; 
    int tidx = LP_INVALID_IDX;

    tidx = lp_thread_insert_or_find(pthread_self());
    assert(tidx != LP_INVALID_IDX); 

    lp_mutex_released_idx(0, tidx);

    rc = lp_mutex_unlock(&lp_info.mutex);
    assert(rc == 0);

    return rc; 
}


void
lp_unlock_postcheck(const pthread_mutex_t *mutex, int rc)
{
    int tidx = LP_INVALID_IDX, midx = LP_INVALID_IDX;

    if (NULL != mutex && 0 == lp_data_lock()) {

        /* Make sure there is room for thread and mutex info. */
        tidx = lp_thread_insert_or_find(pthread_self());
        midx = lp_mutex_insert_or_find(mutex);
        if (midx != LP_INVALID_IDX && tidx != LP_INVALID_IDX) {
            if (rc == 0) {
                lp_mutex_released_idx(midx, tidx);
            }
            lp_unlock_postcheck_diagnose(mutex, rc);
        }

        lp_data_unlock(); 
    }
}


void
lp_unlock_precheck(const pthread_mutex_t *mutex)
{
    int tidx = LP_INVALID_IDX, midx = LP_INVALID_IDX;

    if (NULL != mutex && 0 == lp_data_lock()) {

        /* Make sure there is room for thread and mutex info. */
        tidx = lp_thread_insert_or_find(pthread_self());
        midx = lp_mutex_insert_or_find(mutex);
        if (midx != LP_INVALID_IDX && tidx != LP_INVALID_IDX) {
            lp_unlock_precheck_diagnose(mutex);
        }
        
        lp_data_unlock(); 
    }
}


void
lp_lock_postcheck(const pthread_mutex_t *mutex, int rc)
{
    int tidx = LP_INVALID_IDX, midx = LP_INVALID_IDX;

    if (NULL != mutex && 0 == lp_data_lock()) {

        /* Make sure there is room for thread and mutex info. */
        tidx = lp_thread_insert_or_find(pthread_self());
        midx = lp_mutex_insert_or_find(mutex);
        if (midx != LP_INVALID_IDX && tidx != LP_INVALID_IDX) {
            if (rc == 0) {
                lp_mutex_acquired_idx(midx, tidx);
            }
            lp_lock_postcheck_diagnose(mutex, rc);
        }
        
        lp_data_unlock(); 
    }
}


void
lp_lock_precheck(const pthread_mutex_t *mutex)
{
    int tidx = LP_INVALID_IDX, midx = LP_INVALID_IDX;

    if (NULL != mutex && 0 == lp_data_lock()) {

        /* Make sure there is room for thread and mutex info. */
        tidx = lp_thread_insert_or_find(pthread_self());
        midx = lp_mutex_insert_or_find(mutex);
        if (midx != LP_INVALID_IDX && tidx != LP_INVALID_IDX) {
            lp_mutex_try_acquire_idx(midx, tidx); 
            lp_lock_precheck_diagnose(mutex);
        }
        
        lp_data_unlock(); 
    }
}


void 
lp_dump(void)
{
    int  i; 
    char bits[LP_MAX_NUM_MUTEXES+1] = {0}; 
    
    lp_report("Mutexes: \n"); 
    for (i=0; i<LP_MAX_NUM_MUTEXES; i++) {
        if (lp_info.mutexes[i].mutex != LP_INVALID_MUTEX) {
            lp_report("  [%02d] M%08lx [T%08lx %02d]\n", 
                    i, lp_info.mutexes[i].mutex, 
                    lp_info.mutexes[i].owning_thread,
                    lp_info.mutexes[i].owning_thread_idx); 
        }
    }
    
    lp_report("Threads: \n"); 
    for (i=0; i<LP_MAX_NUM_THREADS; i++) {
        if (lp_info.threads[i].thread != LP_INVALID_THREAD) {
            lp_report("  [%02d] T%08lx [M%s][M%08lx]\n", 
                    i, lp_info.threads[i].thread, 
                    lp_bit_string(&lp_info.threads[i].mutexes, bits, LP_MAX_NUM_MUTEXES),
                    lp_info.threads[i].mutex_to_lock); 
        }
    }
}


void
lp_report(const char *fmt, ...)
{
    va_list va;

    assert(fmt != NULL);

    fprintf(stderr, "Tx%lx: ", pthread_self());

    va_start(va, fmt); 
    vfprintf(stderr, fmt, va);
    va_end(va); 

    fflush(stderr);
}
