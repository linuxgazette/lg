/*
 * Winamp .AUD input plug-in for Zoom PS-02
 * Copyright (c) 2002, Randy Gordon (randy@integrand.com)
 * Licensed as LGPL
 *
 */

#include <pthread.h>

#include <math.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* 'Cos the man page says so */
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#include <gtk/gtk.h>
#include "xmms/plugin.h"
#include "xmms/util.h"

#define WM_WA_MPEG_EOF WM_USER+2
#define DEBUG

/* AUD output configuration */
#define NCH           1
#define HI_SAMPLERATE 31250
#define LO_SAMPLERATE 15625
#define BPS           16

InputPlugin mod;		/* The output module (declared near the bottom of this file) */
static char lastfn[512];	/* Currently playing file (used for getting info on the current file) */
static int file_length;		/* File length, in bytes */
static int decode_pos_ms;	/* Current decoding position, in milliseconds */
static int paused;		/* Are we paused? */
static int seek_needed;		/* if != -1, it is the point that the decode thread should seek to, in ms. */
static int samplerate;

static char header[512];	/* The AUD header */
static unsigned char deltas[508];	/* Encoded deltas */
static short samples[509];	/* Rendered samples */

static int get_header (char *buf);
static pthread_t play_thread;

/* Translation table for AUD delta encodings */
static int delta_values[256] = {
  0, 1, 2, 5, 9, 14, 19, 0, 24, 29,
  34, 40, 45, 51, 57, 62, 68, 75, 81, 87,
  94, 100, 107, 114, 120, 127, 134, 141, 148, 155,
  163, 170, 177, 185, 192, 200, 208, 215, 223, 231,
  239, 246, 254, 262, 271, 279, 288, 297, 306, 316,
  325, 336, 346, 357, 368, 380, 391, 404, 416, 429,
  443, 457, 471, 486, 501, 516, 533, 549, 566, 584,
  602, 621, 640, 660, 681, 702, 724, 747, 770, 794,
  819, 845, 871, 898, 926, 955, 985, 1016, 1048, 1081,
  1115, 1151, 1188, 1226, 1266, 1308, 1351, 1397, 1444, 1493,
  1544, 1598, 1653, 1712, 1773, 1836, 1903, 1972, 2045, 2121,
  2204, 2297, 2402, 2520, 2654, 2810, 2991, 3207, 3468, 3792,
  4206, 4732, 5324, 5989, 6738, 7580, 8527, 9551, -9551, -8527,
  -7580, -6738, -5989, -5324, -4732, -4206, -3792, -3468, -3207, -2991,
  -2810, -2654, -2520, -2402, -2297, -2204, -2121, -2045, -1972, -1903,
  -1836, -1773, -1712, -1653, -1598, -1544, -1493, -1444, -1397, -1351,
  -1308, -1266, -1226, -1188, -1151, -1115, -1081, -1048, -1016, -985,
  -955, -926, -898, -871, -845, -819, -794, -770, -747, -724,
  -702, -681, -660, -640, -621, -602, -584, -566, -549, -533,
  -516, -501, -486, -471, -457, -443, -429, -416, -404, -391,
  -380, -368, -357, -346, -336, -325, -316, -306, -297, -288,
  -279, -271, -262, -254, -246, -239, -231, -223, -215, -208,
  -200, -192, -185, -177, -170, -163, -155, -148, -141, -134,
  -127, -120, -114, -107, -100, -94, -87, -81, -75, -68,
  -62, -57, -51, -45, -40, -34, -29, -24, 0, -19,
  -14, -9, -5, -2, -1, 0
};

static FILE *input_file;	/* Input file stream */
int killthread = 0;

static void *decode_thread (void *b);
static int finished ();

static void
about (void)
{
  static GtkWidget *box;
  box = xmms_show_message ("About PS02 AUD Player",
			   "Player for Zoom PS02 AUD files by Randy Gordon\n"
			   "XMMS plugin by Jimmy O'Regan\n",
			   "Ok", FALSE, NULL, NULL);
  gtk_signal_connect (GTK_OBJECT (box), "destroy",
		      gtk_widget_destroyed, &box);
}


int
isourfile (char *filename)
{
  char *ext;

#ifdef DEBUG
  fprintf (stderr, "aud_xmms: isourfile(): %s\n", filename);
#endif

  ext = strrchr (filename, '.');
  if (ext)
    if (!strcasecmp (ext, ".AUD"))
      return TRUE;
  return FALSE;
}

static void
play (char *fn)
{
  int maxlatency;

  struct stat *s;

#ifdef DEBUG
  fprintf (stderr, "aud_xmms: play(): %s\n", fn);
#endif

  input_file = fopen (fn, "r");

  if (!input_file)
    return;

  stat (fn, s);
  file_length = (int) s->st_size;

  if (file_length == 0)
    {
#ifdef DEBUG
      fprintf (stderr, "aud_xmms: play(): Choke! File is empty!\n");
#endif
      exit (1);
    }

  /* Determine sample rate from first byte: 0x00 = HiGrade, 0x01 = LoGrade */
  get_header (header);
  if (header[0] == 0x00)
    samplerate = HI_SAMPLERATE;
  else
    samplerate = LO_SAMPLERATE;

  strcpy (lastfn, fn);
  paused = 0;
  decode_pos_ms = 0;
  seek_needed = -1;

  maxlatency = mod.output->open_audio (FMT_S16_BE, samplerate, NCH);
  if (maxlatency < 0)
    {
      /* Error opening device */
      fclose (input_file);
      return;
    }
  /* Dividing by 1000 for the first parameter of setinfo makes it
     display 'H'... for hundred.. i.e. 14H Kbps. */
  mod.set_info ("", (samplerate * BPS * NCH) / 1000, samplerate / 1000, 1,
		NCH);

  mod.output->set_volume (-1, -1);

  pthread_create (&play_thread, NULL, decode_thread, &killthread);
}

static void
pause_play (short p)
{
  mod.output->pause (p);
}

static void
stop ()
{
  killthread = 1;
  if (input_file)
    fclose (input_file);

  mod.output->close_audio ();
  pthread_exit (NULL);
}

static int
getlength ()
{
  /* Length of AUD in milliseconds */
  int numblocks;
#ifdef DEBUG
  fprintf (stderr, "aud_xmms: getlength():\n");
#endif

  numblocks = file_length / 512 - 1;
  return (numblocks * 509) / samplerate * 1000;
}

static int
getoutputtime ()
{
#ifdef DEBUG
  fprintf (stderr, "aud_xmms: getoutputtime():\n");
#endif

  return decode_pos_ms + (mod.output->output_time () -
			  mod.output->written_time ());
}

static void
setoutputtime (int time_in_ms)
{
#ifdef DEBUG
  fprintf (stderr, "aud_xmms: setoutputtime():\n");
#endif

  seek_needed = time_in_ms;
}

static void
setvolume (int l, int r)
{
  mod.output->set_volume (l, r);
}

static void
getfileinfo (char *filename, char **title, int *length_in_ms)
{
  struct stat *s;
  FILE *hfile;
  int fl;

  if (!filename || !*filename)
    {
      /* Currently playing file */
      if (length_in_ms)
	*length_in_ms = getlength ();
      if (*title)
	{
	  char *p = lastfn + strlen (lastfn);
	  while (*p != '/' && p >= lastfn)
	    p--;
	  strcpy (*title, ++p);
	}
    }
  else
    {
      /* Some other file */
      if (length_in_ms)
	{
	  *length_in_ms = -1000;
	  hfile = fopen (filename, "r");
	  if (!hfile)
	    {
	      stat (filename, s);
	      fl = (int) s->st_size;

	      *length_in_ms = fl * 10 / (samplerate / 100 * NCH * (BPS / 8));
	    }
	  fclose (hfile);
	}
      if (*title)
	{
	  char *p = filename + strlen (filename);
	  while (*p != '/' && p >= filename)
	    p--;
	  strcpy (*title, ++p);
	}
    }
}

static int
get_short_big_endian (short *value)
{
  int len;
  unsigned char bytes[2];
  short result;

  fread ((unsigned char *) bytes, 2, len, input_file);

  result = bytes[0] << 8 | bytes[1];
  *value = result;

  return len;
}

static int
get_header (char *buf)
{
  int len;

#ifdef DEBUG
  fprintf (stderr, "aud_xmms: get_header(): %s\n", buf);
#endif
  /*  ReadFile (input_file, buf, 512, &len, NULL); */
  fread (buf, 512, len, input_file);
  return len;
}

static int
get_deltas (char *buf)
{
  int len;
#ifdef DEBUG
  fprintf (stderr, "aud_xmms: get_deltas(): %s\n", buf);
#endif

  fread (buf, 508, len, input_file);
  return len;
}

static void *
decode_thread (void *b)
{
  int done = 0;
  int i = 0;
  int offs;
  int offsblock;
  int offsfile;
  short sample = 0;
  short terminator = 0;
  int len;
  unsigned int delta_index;
  int delta;

#ifdef DEBUG
  fprintf (stderr, "aud_xmms: DecodeThread()\n");
#endif

  while (!*((int *) b))
    {
      if (seek_needed != -1)
	{
	  decode_pos_ms = seek_needed - (seek_needed % 1000);
	  seek_needed = -1;
	  done = 0;
	  mod.output->flush (decode_pos_ms);
	  offs = (decode_pos_ms / 1000) * samplerate;

	  offsblock = offs / 509;
	  offsfile = (offsblock + 1) * 512;

	  fseek (input_file, offsfile, SEEK_SET);
	}

      /* Decode an AUD 512-byte block */
      len = get_short_big_endian (&sample);
      if (!len)
	{
	  finished ();
	  return 0;
	}

      /* Get the deltas */
      len = get_deltas ((char *) deltas);
      if (!len)
	{
	  finished ();
	  return 0;
	}

      /* Get the terminator (ignored) */
      len = get_short_big_endian (&terminator);
      if (!len)
	{
	  finished ();
	  return 0;
	}

      /* Construct samples */
      samples[0] = sample;
      for (i = 0; i < 508; i++)
	{
	  delta_index = (unsigned int) deltas[i];
	  delta = delta_values[delta_index];
	  sample += delta;
	  samples[i + 1] = sample;
	}

      
      decode_pos_ms += (509 * 1000) / samplerate;

      mod.output->write_audio ((char *) samples, 509 * NCH * (BPS / 8));
    }
  return 0;
}

static int
finished ()
{
  if (!mod.output->buffer_playing ())
    return 0;
  sleep (10);
  return 0;
}

InputPlugin mod = {
  NULL,
  NULL,
  "AUD Player v1.1 for Zoom PS-02",
  NULL,
  about,
  NULL,
  isourfile,
  NULL,
  play,
  stop,
  pause_play,
  NULL,				/*seek */
  NULL,
  NULL,				/*gettime */
  NULL,
  setvolume,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,				/* setinfo */
  getfileinfo,
  NULL,
  NULL
};

InputPlugin *
get_iplugin_info ()
{
  return &mod;
}
