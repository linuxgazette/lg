/*
 *  lp_check.c
 *
 *  Copyright 2008 Aurelian Melinte. 
 *  Released under GPL 3.0 or later. 
 *
 *  Lockpick demo. Detect mutex-related issues. 
 */

#include <assert.h>

#include "lp_check.h"
#include "lp_data.h"



void
lp_lock_precheck_diagnose(const pthread_mutex_t *mutex)
{
    int rc = -1; 
    int maxmidx = LP_INVALID_IDX, midx = LP_INVALID_IDX; 
    pthread_t me = pthread_self(); 

    pthread_t             thr = LP_INVALID_THREAD;
    const pthread_mutex_t *mtx = NULL; 

    assert(mutex != NULL);
    
    /* Thread tries to lock a mutex it has already locked? */
    if ((rc=lp_is_mutex_locked(mutex, me)) != 0) {
        lp_report("Mutex M%lx is already locked by thread.\n", mutex);
        lp_dump(); 
    } 
    
    /* Is mutex order respected? */
    maxmidx = lp_max_idx_mutex_locked(me); 
    midx = lp_mutex_idx(mutex);
    if (midx < maxmidx) {
        lp_report("Mutex M%lx will be locked out of order (idx=%d, crt max=%d).\n", mutex, midx, maxmidx);
        lp_dump(); 
    }

    /* Will deadlock?  */
    lp_report("Checking if it will deadlock...\n");
    thr = me;
    mtx = mutex; 
    while ((thr=lp_thread_owning(mtx)) != LP_INVALID_THREAD) {
        lp_report("  Mutex M%lx is owned by T%lx.\n", mtx, thr);
        mtx = lp_mutex_wanted(thr); 
        lp_report("  Thread T%lx waits for M%lx.\n", thr, mtx);

        if (mtx == LP_INVALID_MUTEX) 
            break; /*no circular dead; */

        if (0 != pthread_equal(thr, me)) {
            lp_report("  Deadlock condition detected.\n");
            lp_dump(); 
            break; 
        }
    }
}


void
lp_lock_postcheck_diagnose(const pthread_mutex_t *mutex, int rc)
{
    assert(mutex != NULL);
}


void
lp_unlock_precheck_diagnose(const pthread_mutex_t *mutex)
{
    int rc = -1; 
    int maxmidx = LP_INVALID_IDX, midx = LP_INVALID_IDX; 
    
    assert(mutex != NULL);

    /* Thread tries to unlock a mutex it does not have? */
    if ((rc=lp_is_mutex_locked(mutex, pthread_self())) == 0) {
        lp_report("Attempt to release M%lx NOT locked by thread.\n", mutex);
        lp_dump(); 
    } 

    /* Are mutexes released in reverse order? */
    maxmidx = lp_max_idx_mutex_locked(pthread_self()); 
    midx = lp_mutex_idx(mutex);
    if (midx < maxmidx) {
        lp_report("Mutex M%lx will be released out of order (idx=%d, crt max=%d).\n", mutex, midx, maxmidx);
        lp_dump(); 
    }
}


void
lp_unlock_postcheck_diagnose(const pthread_mutex_t *mutex, int rc)
{
    assert(mutex != NULL);
}

