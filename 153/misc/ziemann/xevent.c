/* xevent.c ************************************************/
/*
 * This file is subject to the terms and conditions of the GNU General Public
 * License.  See the file COPYING in the main directory of this archive for
 * more details.
 *
 * This is heavily based on the xsendkey-0.01.tar.bz2 package
 * augmented by the mouse button features.
 *
 * Author: Volker Ziemann, Date: 080720
 *
 * compile with:
 *   gcc -O -Wall -g -L/usr/X11R6/lib -lX11 -lXtst -o xevent xevent.c
 * 
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <X11/Xlib.h>
#include <X11/extensions/XTest.h>

char *ProgramName;

Display *dpy;
int scr;
Window win;
unsigned int width, height;

int main(int argc, char **argv)
{
    Window ret_win;
    int x, y;
    unsigned int border_width, depth;
    int keycode , is_down=1;

    ProgramName = argv[0];
    if (argc < 2) {
	puts("Usage: xevent keycode [102]");
	puts("   or: xevent -a x y");
	puts("   or: xevent -r dx dy");
	puts("   or: xevent -b <but> [102]");
	return 1;
    }

    dpy = XOpenDisplay("");
    if (!dpy) {
	fprintf(stderr, "%s: Cannot connect to display ...\n", ProgramName);
	return 1;
    }
    scr = DefaultScreen(dpy);
    win = RootWindow(dpy, scr);
    XGetGeometry(dpy, win, &ret_win, &x, &y, &width, &height, &border_width, &depth);

    if (strstr(argv[1],"-r")) {
	if (argc<4) {puts("Usage: xevent -r dx dy"); return 1;}
	x=atoi(argv[2]);
	y=atoi(argv[3]);
	XTestFakeRelativeMotionEvent(dpy, x, y, 0);
    } else if (strstr(argv[1],"-a")) {
	if (argc<4) {puts("Usage: xevent -a x y"); return 1;}
	x=atoi(argv[2]);
	y=atoi(argv[3]);	
	XTestFakeMotionEvent(dpy, scr, x, y, 0);
    } else if (strstr(argv[1],"-b")) {
	if (argc<3) {puts("Usage: xevent -b num [102]"); return 1;}
	x=atoi(argv[2]);  // button number
	is_down = 2;
	if (argc == 4) is_down = atoi(argv[2]);
	if (is_down==1 || is_down==2) XTestFakeButtonEvent(dpy, x, 1, 0);
	if (is_down==0 || is_down==2) XTestFakeButtonEvent(dpy, x, 0, 0);
    } else { // old xsendkey mechanics
	keycode = atoi(argv[1]);
	if (argc == 2) is_down = 2;
	if (argc == 3) is_down = atoi(argv[2]);
	if (is_down==2) {
	    XTestFakeKeyEvent(dpy, keycode, 1, 0);
	    XTestFakeKeyEvent(dpy, keycode, 0, 0);
	} else {
	    XTestFakeKeyEvent(dpy, keycode, is_down, 0);
	}
    }

    XSync(dpy, 1);
    return 0;
}
