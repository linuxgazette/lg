/*
 *  deadlock.c
 *
 *  Copyright 2008 Aurelian Melinte. 
 *  Released under GPL 3.0 or later. 
 *
 *  Lockpick demo. A few threads to the the lock detector. 
 */
 
#define _GNU_SOURCE  /*strerror_r*/
#include <unistd.h>  /*sleep*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>  /*strerror_r*/
#include <errno.h>
#include <signal.h>
#include <assert.h>
#include <pthread.h>


#define ERRBUF_LEN (255) 

static pthread_mutex_t mutex1 = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t mutex2 = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t mutex3 = PTHREAD_MUTEX_INITIALIZER;

static int  _do_exit = 0;


static char *
wrap_strerror_r(int err, char *buf, int len)
{
    char *src = NULL;
    
    memset(buf, 0, len);
    src = strerror_r(err, buf, len); 

    return src ? src : buf; 
}


void *
thread1(void *threadid)
{
    int tid = (int)threadid;

    printf("Hello World! It's me, thread #%d!\n", tid);
	
	pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, NULL);
	pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS, NULL);
 
    while (!_do_exit) {
        char errbuf[ERRBUF_LEN+1] = {0}; 
        int  mrc; 

        sleep(1);
        printf("T#%d!\n", tid);

        mrc = pthread_mutex_lock(&mutex2);
        if (mrc == 0) {
            printf("T#%d+M2 (%s)\n", tid, 
                    wrap_strerror_r(mrc, errbuf, ERRBUF_LEN));
            sleep(2); 

            if (mrc == 0) {
                mrc = pthread_mutex_lock(&mutex1);
                printf("T#%d+M1 (%s)\n", tid, 
                        wrap_strerror_r(mrc, errbuf, ERRBUF_LEN));
                sleep(1);

                sleep(1); /*Work :)*/

                mrc = pthread_mutex_unlock(&mutex1);
                printf("T#%d-M1 (%s)\n", tid, 
                        wrap_strerror_r(mrc, errbuf, ERRBUF_LEN));
                sleep(1);
            }

            mrc = pthread_mutex_unlock(&mutex2);
            printf("T#%d-M2 (%s)\n", tid, 
                    wrap_strerror_r(mrc, errbuf, ERRBUF_LEN));
        }
    }

    printf("T#%d exit.\n", tid);
    pthread_exit(NULL);
}

void *
thread2(void *threadid)
{
    int tid = (int)threadid;
    printf("Hello World! It's me, thread #%d!\n", tid);
 
	pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, NULL);
	pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS, NULL);
 
    while (!_do_exit) {
        char errbuf[ERRBUF_LEN+1] = {0}; 
        int  mrc; 

        sleep(1);
        printf("T#%d!\n", tid);

        mrc = pthread_mutex_lock(&mutex1);
        if (mrc == 0) {
            printf("T#%d+M1 (%s)\n", tid, 
                    wrap_strerror_r(mrc, errbuf, ERRBUF_LEN));
            sleep(2); 

            mrc  = pthread_mutex_lock(&mutex2);
            if (mrc == 0) {
                printf("T#%d+M2 ()%s\n", tid, 
                        wrap_strerror_r(mrc, errbuf, ERRBUF_LEN));
                sleep(1);

                sleep(1); /*Work :)*/

                mrc = pthread_mutex_unlock(&mutex2);
                printf("T#%d-M2 (%s)\n", tid, 
                        wrap_strerror_r(mrc, errbuf, ERRBUF_LEN));
                sleep(1);

                mrc = pthread_mutex_unlock(&mutex1);
                printf("T#%d-M1 (%s)\n", tid, 
                        wrap_strerror_r(mrc, errbuf, ERRBUF_LEN));
            }
        }
    }

    printf("T#%d exit.\n", tid);
    pthread_exit(NULL);
}

void *
thread3(void *threadid)
{
    int  tid = (int)threadid;
    printf("Hello World! It's me, thread #%d!\n", tid);
 
	pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, NULL);
	pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS, NULL);
 
    while (!_do_exit) {
        int mrc;
        char errbuf[ERRBUF_LEN+1] = {0}; 

        sleep(1);
        printf("T#%d!\n", tid);

        mrc = pthread_mutex_trylock(&mutex3); /*<-- PTHREAD_MUTEX_ERRORCHECK*/
        printf("T#%d+M3=%d (%s)\n", tid, mrc, 
                wrap_strerror_r(mrc, errbuf, ERRBUF_LEN)); 
        sleep(2); 
    }

    printf("T#%d exit.\n", tid);
    pthread_exit(NULL);
}


static void 
sigexit(int signo)
{
    _do_exit = 1;
}

static void 
set_signal(int signo, void (*handler)(int))
{
    struct sigaction sa;

    memset(&sa, 0, sizeof(sa));

    sa.sa_handler = (void (*)(int))handler;
#ifdef SA_INTERRUPT
    sa.sa_flags = SA_INTERRUPT;
#endif
    sigaction(signo, &sa, NULL);
}


int
main(int argc, char *argv[])
{
    #define NUM_THREADS (3) 
    typedef void *(*pthread_func)(void*); 

    pthread_t    threads[NUM_THREADS] = {0};
    pthread_func funcs[NUM_THREADS] = {thread1, thread2, thread3};
    int rc, i;

    /* 
     * This will jam the program solid because of the deadlock. 
     * Needs an alarm set or to signal the thread. 
     */
    set_signal(SIGINT,  sigexit);
    set_signal(SIGQUIT, sigexit);
    
    for (i=0; i<NUM_THREADS; i++) {
        rc = pthread_create(&threads[i], NULL, funcs[i], (void*)(i+1));
        if (rc) {
            printf("Error: return code from pthread_create() is %d\n", rc);
            /*Should stop started threads... */
            exit(EXIT_FAILURE);
        }
    }

    while (!_do_exit) 
        sleep(1); 
        
    for (i=0; i<NUM_THREADS; i++) {
        void *thread_ret = NULL;
		pthread_cancel(threads[i]);
        /*pthread_kill(threads[i]); */
        /*pthread_join(threads[i],  &thread_ret);*/
    }
    
    printf("%s: done.\n", argv[0]);
    return EXIT_SUCCESS; 
}

