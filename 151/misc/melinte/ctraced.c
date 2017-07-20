/*
 *  ctraced.c
 *
 *  Copyright 2008 Aurelian Melinte. 
 *  Released under GPL 3.0 or later. 
 *
 *  Call monitoring demo. 
 */
 
#define _GNU_SOURCE  /*strerror_r*/
#include <unistd.h>  /*sleep*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>  /*strerror_r*/
#include <errno.h>
#include <assert.h>
#include <signal.h>
#include <pthread.h>


#define ERRBUF_LEN (255) 

static pthread_mutex_t mutex1 = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t mutex2 = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t mutex3 = PTHREAD_MUTEX_INITIALIZER;

static int  _do_exit = 0;

void
f4(int id)
{
    printf("%s %d\n", __FUNCTION__, id);
}

static inline int 
f3(int id)
{
    printf("%s %d\n", __FUNCTION__, id);
    f4(id);
    return 80;
}

int 
f2(int id)
{
    printf("%s %d\n", __FUNCTION__, id);
    f3(70+id);
    return 70;
}

static int 
f1(int id)
{
    printf("%s %d\n", __FUNCTION__, id);
    f2(60+id); 
    return 60;
}


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
    int  tid = (int)(*(int*)threadid);

    printf("Hello World! It's me, thread #%d!\n", tid);
 
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
                f1(tid);

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

    pthread_exit(NULL);
}

void *
thread2(void *threadid)
{
    int  tid = (int)(*(int*)threadid);
    printf("Hello World! It's me, thread #%d!\n", tid);
 
    while (!_do_exit) {
        printf("T#%d!\n", tid);
        sleep(1); /*Work :)*/
        f1(tid);
    }

    pthread_exit(NULL);
}

void *
thread3(void *threadid)
{
    int  tid = (int)(*(int*)threadid);
    printf("Hello World! It's me, thread #%d!\n", tid);
 
    while (!_do_exit) {
        int mrc;
        char errbuf[ERRBUF_LEN+1] = {0}; 

        sleep(1);
        printf("T#%d!\n", tid);

        mrc = pthread_mutex_trylock(&mutex3); /*<-- PTHREAD_MUTEX_ERRORCHECK*/
        printf("T#%d+M3=%d (%s)\n", tid, mrc, 
                wrap_strerror_r(mrc, errbuf, ERRBUF_LEN)); 
        sleep(2);
        
        f1(tid); 
    }

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
    sigaction(signo, &sa, NULL);
}


int
main(int argc, char *argv[])
{
    #define NUM_THREADS (3) 
    typedef void *(*pthread_func)(void*); 

    pthread_t    threads[NUM_THREADS] = {0};
    pthread_func funcs[NUM_THREADS] = {thread1, thread2, thread3};
	int          ids[NUM_THREADS] = {1,2,3};
    int          rc, i;

    set_signal(SIGINT,  sigexit);
    set_signal(SIGQUIT, sigexit);
    
    printf("%s: main(argc=%d)\n", argv[0], argc);
    
    for (i=0; i<NUM_THREADS; i++) {
        rc = pthread_create(&threads[i], NULL, funcs[i], (void*)(&ids[i]));
        if (rc) {
            printf("Error: return code from pthread_create() is %d\n", rc);
            exit(EXIT_FAILURE);
        }
    }

    while (!_do_exit) 
        sleep(1); 
        
    printf("%s: done.\n", argv[0]);
    return EXIT_SUCCESS;
}

