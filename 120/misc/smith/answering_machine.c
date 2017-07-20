/* A Linux-based Telephone Answering Machine
 * Copyright:     Bob Smith, 2005
 * Warranty:      No warranty expressed or implied. USE AT YOUR OWN RISK!
 * License:       GNU General Public License, version 2
 *                See http://www.gnu.org/copyleft/gpl.html for full text
 * Documentation: http://www.linuxtoys.org/answer/answering_machine.html
 * Version:       1.0.0 2005-Sep-20, Initial release

 * REQUIREMENTS:
 *  - Intel 537 based softmodem
 *  - A PCI slot that does not share interrupts
 *  - Linux 2.6 with gcc and sox installed

 * INSTALLATION:
 *  1) Install the zaptel drivers from Asterisk
 *  2) Install the Zapata library from Asterisk
 *  3) Record a greeting asking the caller to press 1 to
 *     leave a message.  Convert the WAV file to mu-law using:
 *     sox leave_a_msg.wav leave_a_msg.ul
 *  4) Compile the program using:
 *     gcc -lzap -o answering_machine answering_machine.c

 * USAGE:
 *  There are no command line options.  Invoke the program with:
 *     ./answering_machine
 *  Voice mail files can be heard using the 'play' utility from
 *  the sox package.  For example:
 *     play 2005_09_22_14_37_03.ul

 * By-the-way:
 *  The zap_xxx() calls in this program are well documented in
 * zap.c in the Zapata source directory.
 */


#include <stdio.h>
#include <zap.h>
#include <errno.h>
#include <time.h>

        /* The number of rings to wait before answering */
#define RINGS   (4)

        /* DTMF digit you ask the caller to press to leave a msg */
#define PLEASE_ENTER '1'

        /* The time (ms) to wait for a "1" from the caller */
#define TM_OUT  (9000)

        /* The maximum size of a string in this program */
#define STRMX   (65)


        /* A generic error collection subroutine */
void err_if(int, char, int, int);

        /* The handle to the open telephone interface */
ZAP     *zp;


main()
{
  int        result;            /* return code from Zapata call */
  char      *pDigits;           /* points to entered DTMF digits */
  char       cidnumber[STRMX];  /* Caller-ID phone number */
  char       cidname[STRMX];    /* Caller-ID name */
  char       date_time[STRMX];  /* date and time from strftime() */
  struct tm *ptm;               /* date and time in tm structure */
  time_t     now;               /* Current time in seconds */


  zp = zap_open("/dev/zap/1", 0);
  if (!zp) {
    printf("Unable to open /dev/zap/1.  Please verify that the\n");
    printf("zaptel and wcfxo modules are installed, and that your\n");
    printf("hardware is installed and working correctly.\n");
    exit(1);
  }

  while (1) {

    /* Wait for a ring and get caller ID info */
    result = zap_clid(zp, cidnumber, cidname);
    err_if(result, '=', -1, __LINE__);   /* error if -1 */
    if (result == -2) {                  /* internal error getting CLID */
      cidnumber[0] = (char) 0;           /* happens on quick user pick-up */
      strncpy(cidname, "(invalid caller ID)", STRMX-1);
    }

    /* Print date, time, and caller ID info */
    date_time[0] = (char) 0;
    now = time((time_t *) 0);
    ptm = localtime(&now);
    err_if((int)ptm, '=', 0, __LINE__);  /* error if zero */

    (void) strftime(date_time, 63, "%T", ptm);
    printf("%s  %s %s  ", date_time, cidnumber, cidname);
    fflush(stdout);

    /* Wait for an additional RINGS-1 rings before answering */
    result = zap_waitcall(zp, (RINGS - 1), ZAP_OFFHOOK, (TM_OUT/1000));
    if (result == -1 && errno == EINTR) {
      printf("\n");                      /* local user picked-up */
      continue;
    }
    err_if(result, '!', 0, __LINE__);    /* error if not zero */

    /* Init the digit buffer and tell Zapata that we want DTMF digits */
    (void) zap_clrdtmfn(zp);
    result = zap_digitmode(zp, ZAP_DTMF) && zap_clrdtmf(zp);
    err_if(result, '!', 0, __LINE__);    /* error if not zero */

    /* Play our outgoing message.  Abort on DTMF or hang-up. */
    result = zap_playf(zp, "leave_a_msg.ul", ZAP_DTMFINT | ZAP_HOOKEXIT);
    err_if(result, '=', -1, __LINE__);   /* error if -1 */
    if (result == -2) {                  /* == -2 on caller hang-up */
      printf("\n");
      zap_sethook(zp, ZAP_ONHOOK);
      continue;
    }

    /* Wait up to TM_OUT ms for the caller to enter a DTMF digit */
    result = zap_getdtmf(zp, 1, (char *)0, 0, 0, TM_OUT, ZAP_HOOKEXIT);
    err_if(result, '=', -1, __LINE__);   /* error if -1 */

    /* Hang-up if time-out and no DTMF digit.  (Bulk dialer?) */
    if (result != 1) {
      printf("\n");
      zap_sethook(zp, ZAP_ONHOOK);
      err_if(result, '=', -1, __LINE__); /* error if -1 */
      continue;
    }

    /* Get the DTMF digit the caller entered.  Hang-up if wrong digit */
    pDigits = zap_dtmfbuf(zp);
    if ((!pDigits) || (*pDigits != PLEASE_ENTER)) {
      printf("\n");
      zap_sethook(zp, ZAP_ONHOOK);
      err_if(result, '=', -1, __LINE__); /* error if -1 */
      continue;
    }
    printf("************\n");  /* Tell local user of voice mail */

    /* Create voice mail file: YYYY_MM_DD_HH_mm_SS.ul */
    (void) strftime(date_time, 63, "%G_%m_%d_%H_%M_%S.ul", ptm);
    result = zap_recf(zp, date_time, 0,
               ZAP_BEEPTONE | ZAP_HOOKEXIT | ZAP_SILENCEINT);
    err_if(result, '=', -1, __LINE__);   /* error if -1 */

    /* Done with message.  Hang-up and wait for next call. */
    result = zap_sethook(zp, ZAP_ONHOOK);
    err_if(result, '=', -1, __LINE__);   /* error if -1 */
  }

  exit(0);  /* not reached */
}



/* err_if() -- Exit the program if the result is not correct.
 * Inputs are the result, the comparison operator, the value
 * to match, and the line number */
void err_if(int result, char operator, int errval, int linenum)
{
  if (((operator == '=') && (result == errval)) ||
      ((operator == '!') && (result != errval))) {
    printf("Error code %d at line = %d, with errno = %d.   Bye...\n",
           result, linenum, errno);

    (void) zap_sethook(zp, ZAP_ONHOOK);
    exit(1);
  }
}
