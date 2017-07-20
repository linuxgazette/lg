/*
 *  lp_hooks.c
 *
 *  Copyright 2008 Aurelian Melinte. 
 *  Released under GPL 3.0 or later. 
 *
 *  Lockpick demo. Hook the pthread_* functions. 
 */

#define _GNU_SOURCE
#include <dlfcn.h>

#include <signal.h>
#include <execinfo.h>

#include <errno.h>
#include <stdlib.h>
#include <assert.h>

#include "lp_data.h"
#include "lp_hooks.h"


typedef int (*lp_pthread_mutex_func)(pthread_mutex_t *mutex);
static lp_pthread_mutex_func  next_pthread_mutex_lock = NULL;
static lp_pthread_mutex_func  next_pthread_mutex_trylock = NULL; 
static lp_pthread_mutex_func  next_pthread_mutex_unlock = NULL; 


#if 0
static void 
lp_show_stackframe() {
  void *trace[16];
  char **messages = (char **)NULL;
  int i, trace_size = 0;

  trace_size = backtrace(trace, 16);
  messages = backtrace_symbols(trace, trace_size);
  lp_report("[bt] Execution path:\n");
  for (i=0; i < trace_size; ++i)
      lp_report("[bt] %s\n", messages[i]);
}
#endif


static int
lp_hookfunc(lp_pthread_mutex_func *fptr, const char *fname)
{
    char *msg = NULL;

    assert(fname != NULL);

    if (*fptr == NULL) {
        lp_report("dlsym : wrapping %s\n", fname);
        *fptr = dlsym(RTLD_NEXT, fname);
        lp_report("next_%s = %p\n", fname, *fptr);
        if ((*fptr == NULL) || ((msg = dlerror()) != NULL)) {
            lp_report("dlsym %s failed : %s\n", fname, msg);
            return -1;
        } else {
            lp_report("dlsym: wrapping %s done\n", fname);
            return 0;
        }
    } else {
        return 0;
    }
}


static void
lp_hookfuncs(void)
{
    if (next_pthread_mutex_lock == NULL) {
        lp_hookfunc(&next_pthread_mutex_lock,    "pthread_mutex_lock"); 
        lp_hookfunc(&next_pthread_mutex_trylock, "pthread_mutex_trylock"); 
        lp_hookfunc(&next_pthread_mutex_unlock,  "pthread_mutex_unlock"); 
        if (  NULL == next_pthread_mutex_lock
           || NULL == next_pthread_mutex_trylock
           || NULL == next_pthread_mutex_unlock
           ) {
            lp_report("liblockpick failed to hook.\n");
            exit(EXIT_FAILURE);
        }
        if (0 != lp_data_init()) {
            lp_report("liblockpick initialisation failed.\n");
            exit(EXIT_FAILURE);
        }
    }
}


int 
pthread_mutex_lock(pthread_mutex_t *mutex)
{
    int rc = EINVAL; 

    if (mutex != NULL) {
        lp_lock_precheck(mutex); 
        rc = DL_CALL_FCT(next_pthread_mutex_lock, (mutex));
        lp_lock_postcheck(mutex, rc); 
    } else {
        lp_report("%s(): mutex* is NULL.\n", __FUNCTION__ );
    }

    return rc; 
}

int 
lp_mutex_lock(pthread_mutex_t *mutex)
{
    int rc = EINVAL; 

    rc = next_pthread_mutex_lock(mutex);

    return rc; 
}


int 
pthread_mutex_trylock(pthread_mutex_t *mutex)
{
    int rc = EINVAL; 

    if (mutex != NULL) {
        lp_lock_precheck(mutex); 
        rc = DL_CALL_FCT(next_pthread_mutex_trylock, (mutex));
        lp_lock_postcheck(mutex, rc); 
    } else {
        lp_report("%s(): mutex* is NULL.\n", __FUNCTION__ );
    }

    return rc; 
}

int 
lp_mutex_trylock(pthread_mutex_t *mutex)
{
    int rc = EINVAL; 

    rc = next_pthread_mutex_trylock(mutex);

    return rc; 
}


int 
pthread_mutex_unlock(pthread_mutex_t *mutex)
{
    int rc = EINVAL; 

    if (mutex != NULL) {
        lp_unlock_precheck(mutex); 
        rc = DL_CALL_FCT(next_pthread_mutex_unlock, (mutex));
        lp_unlock_postcheck(mutex, rc); 
    } else {
        lp_report("%s(): mutex* is NULL.\n", __FUNCTION__ );
    }

    return rc; 
}

int 
lp_mutex_unlock(pthread_mutex_t *mutex)
{
    int rc = EINVAL; 

    rc = next_pthread_mutex_unlock(mutex);

    return rc; 
}


void _init()  __attribute__((constructor));
void 
_init()
{
    lp_report("*** liblockpick _init().\n");
    lp_hookfuncs();
}


void  _fini()  __attribute__((destructor)); 
void  
_fini()
{
    lp_report("*** liblockpick _fini().\n");
}

