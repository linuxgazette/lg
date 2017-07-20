/*************************************************************************
 * Copyright (c) 1998 Lexmark International, Inc.
 *
 * $Id: tips_cartutil.c,v 1.1.1.1 2002/08/14 22:27:19 dan Exp $
 *
 * History:
 *   10/19/98	dlane - Created for Optra 40/45 customers using UNIX.
 */

#include <stdio.h>

char *help = {
  "\n"
  "This is a cartridge utility for the Optra Color 40 and 45.\n"
  "It was created for UNIX users who are unable to use the cartridge\n"
  "utilities in our Microsoft drivers. The user is welcome to modify\n"
  "this program to suit their needs. MarkVision and a free utility\n"
  "called lexcart are also available for selected UNIX platforms.\n"
  "\n"
  "This program can be used in at least two ways.\n"
  "\n"
  "1) Commands can be sent to a locally attached printer by typing\n"
  "   'cartutil DEVICE_PORT'. The device port on a Sun would be '/dev/bpp0'.\n"
  "   The port should be '/dev/lp1' on most Linux machines.\n"
  "\n"
  "2) The output of this program can be routed to a local file.\n"
  "   This file of command strings can then be sent to a remote printer\n"
  "   using FTP. Type 'cartutil LOCAL_FILE_NAME' to create a local file.\n"
};

char *menu = {
  "\n"
  "CARTRIDGE UTILITY FOR THE OPTRA COLOR 40 AND 45\n"
  "\n"
  "a) Install or replace a cartridge.\n"
  "b) Park the cartridges.\n"
  "c) Print an alignment page.\n"
  "d) Modify the alignment values.\n"
  "e) Reset the ink level gauges.\n"
  "f) Print a menu page.\n"
  "g) Clean the nozzles.\n"
  "h) Show the help screen.\n"
  "i) Show more information on the menu choices.\n"
  "m) Redisplay this menu.\n"
  "q) QUIT\n"
};

char *menuPrompt = "(a,b,c,d,e,f,g,h,i,m,q):";

char *info ={
  "\n"
  "DETAILED MENU\n"
  "\n"
  "a) Install or replace a cartridge.\n"
  "   This command will cause the cartridge carrier to move \n"
  "   to the extreme left. Once moved to this location, \n"
  "   new cartridges can be installed.\n"
  "   \n"
  "b) Park the cartridges.\n"
  "   This command moves the cartridge carrier back to the \n"
  "   maintenance station. It should always be performed \n"
  "   after installing or replacing a cartridge.\n"
  "   \n"
  "c) Print an alignment page.\n"
  "   This page shows the alignment value choices.\n"
  "   \n"
  "d) Modify the alignment values.\n"
  "   These alignment values compensate for small position variations.\n"
  "   They should be adjusted every time a cartridge is replaced.\n"
  "   \n"
  "e) Reset the ink level gauges.\n"
  "   The menu page contains ink level gauges for the Black, \n"
  "   Color, and Photo cartridges. The appropriate gauge \n"
  "   should be reset to full when a new cartridge is installed.\n"
  "   \n"
  "f) Print a menu page.\n"
  "   This page contains the ink level gauges and system settings.\n"
  "   \n"
  "g) Clean the nozzles.\n"
  "   This prints a test page which should flush any blocked or \n"
  "   partially blocked nozzles.\n"
};

/* The length values are used because strlen is confused by NULLs. */
char *sniff = "\xa5\x00\x10\x80\xa4\x5b\xa4\x5b\x10\xef\xa4\x5b\x11\xee\x00\xff\x13\xec\x2e";
int sniffLength = 19;

char *install = "\xa5\x00\x05\x40\xe0\x0a\x1d\x70";
int installLength = 8;

char *park = "\xa5\x00\x05\x40\xe0\x0a\x01\x00";
int parkLength = 8;

char *palign = "\xa5\x00\x05\x40\xe0\x5c\x81\x03";
int palignLength = 8;

char *pmenu = "\xa5\x00\x05\x40\xe0\x5c\x81\x00";
int pmenuLength = 8;

char *clean = "\xa5\x00\x05\x40\xe0\x5c\x81\x80";
int cleanLength = 8;

int alignCount = 4;
char *alignType[] = {"A", "B", "C", "D"};
int alignMax[] = {30, 15, 30, 30};
char align[][20] = {
  "\xa5\x00\x07\x40\xe0\xe7\x01\x08\x32\xff",
  "\xa5\x00\x07\x40\xe0\xe7\x01\x08\x33\xff",
  "\xa5\x00\x07\x40\xe0\xe7\x01\x08\x34\xff",
  "\xa5\x00\x07\x40\xe0\xe7\x01\x08\x35\xff"
};
int alignLength[] = {10, 10, 10, 10};

int resetCount = 3;
char *resetType[] = {"Black", "Color", "Photo"};
char *reset[] = {
  "\xa5\x00\x04\x40\xe0\x09\x01",
  "\xa5\x00\x04\x40\xe0\x09\x02",
  "\xa5\x00\x04\x40\xe0\x09\x05"
};
int resetLength[] = {7, 7, 7};

char *headLabel[] = {"Left", "Right"};
int headCount[] = {4, 2};
char *headType[][4] = {
  {"Mono", "Mono High Yield", "Photo", "Photo High Yield"},
  {"Color", "Color High Yield"}
};
int headCode[][4] = {
  {0x07, 0x37, 0x0d, 0x3d},
  {0x08, 0x38}
};
char head[] = "\xa5\x00\x05\x40\xe0\x80\xff\xff";
int headLength = 8;
		       

/*
 * Put a string to the output file and check for errors.
 * I can't use 'fputs' because my strings contain NULLs.
 */
int myputs(char *s, int count, FILE *fp, char *prog)
{
  while (count--){
    fputc(*s++, fp);
  }
  fflush(fp);

  if (ferror(fp)){
    fprintf(stderr, "%s: Error during output to file.\n", prog);
    return(EOF);
  }
  else {
    return(0);
  }
}

/*
 * Convert an ASCII string of numerals to a decimal value.
 */
int convert2dec(char *pStr)
{
   int ArgValue = 0;
   char digit;

   if((*pStr < '0') || (*pStr > '9')) return(-1);
   
   while (1)
   {
      digit = (*pStr) ;
      if ((digit < '0') || (digit > '9')) return(ArgValue);
      digit = digit - '0' ;
      ArgValue = ArgValue * 10 ;
      ArgValue += digit ;
      pStr++ ;
   }
}

void main(int argc, char *argv[])
{
  FILE *fp;
  char *prog = argv[0]; /* program name called */
  char inchars[80];
  char selection;
  int i,j;

  
  /* test for exactly one arguement */
  if (argc != 2){
    fprintf(stderr, "%s: Please supply an output file. (ex. /dev/bpp0)\n", prog);
    printf("%s",help);
    exit(2);
  }
  
  /* open the output file */
  if ((fp = fopen(argv[1], "w")) == NULL){
    fprintf(stderr, "%s: Can't open %s\n", prog, *argv[1]);
    exit(2);
  }

  printf("%s",menu);
  
  do {
    printf("\n%s", menuPrompt);
    fgets(inchars, sizeof(inchars), stdin);
    switch(inchars[0]){
    case 'a':
      printf("Sending the install command.\n");
      if (myputs(sniff, sniffLength, fp, prog)) exit(2);
      if (myputs(install, installLength, fp, prog)) exit(2);
      printf("\nAfter you have installed the cartridges,\n"
	     "please inform the printer of your selections.\n");
      for (i=0; i<2; i++){
	printf("\nSelect the %s cartridge.\n",headLabel[i]);
	for (j=0; j<headCount[i]; j++){
	  printf("%d) %s\n",j+1,headType[i][j]);
	}
	do{
	  printf("(1-%d):",headCount[i]);
	  fgets(inchars, sizeof(inchars), stdin);
	  selection = convert2dec(inchars);
	} while ((selection < 1) || (selection > headCount[i]));
	head[headLength - 2 + i] = headCode[i][selection - 1];
      }
      if (myputs(sniff, sniffLength, fp, prog)) exit(2);
      if (myputs(head, headLength, fp, prog)) exit(2);
      printf("\nDo you wish to park the cartridges?\n"
	     "This step should only be skipped when creating\n"
	     "command scripts for a remote printer.\n");
      do{
	printf("(y,n):");
	fgets(inchars, sizeof(inchars), stdin);
      } while ((inchars[0] != 'y') && (inchars[0] != 'n'));
      if (inchars[0] == 'y'){
	if (myputs(sniff, sniffLength, fp, prog)) exit(2);
	if (myputs(park, parkLength, fp, prog)) exit(2);
      }
      break;
    case 'b':
      printf("Sending the park command.\n");
      if (myputs(sniff, sniffLength, fp, prog)) exit(2);
      if (myputs(park, parkLength, fp, prog)) exit(2);
      break;
    case 'c':
      printf("Sending the print alignment command.\n");
      if (myputs(sniff, sniffLength, fp, prog)) exit(2);
      if (myputs(palign, palignLength, fp, prog)) exit(2);
      break;
    case 'd':
      printf("Please select your values from the alignment page.\n"
	     "Note that the C and D values are not used when a Photo\n"
	     "cartridge is installed.\n\n");
      for (i=0; i<alignCount; i++){
	printf("Select the best alignment number for %s.\n",alignType[i]);
	do{
	  printf("(0-%d):",alignMax[i]);
	  fgets(inchars, sizeof(inchars), stdin);
	  selection = convert2dec(inchars);
	} while ((selection < 0) || (selection > alignMax[i]));
	if (myputs(sniff, sniffLength, fp, prog)) exit(2);
	align[i][alignLength[i] - 1] = selection;
	if (myputs(align[i], alignLength[i], fp, prog)) exit(2);
      }
      break;
    case 'e':
      for (i=0; i<resetCount; i++){
	printf("Do you wish to reset the %s ink level gauge?\n",resetType[i]);
	do{
	  printf("(y,n):");
	  fgets(inchars, sizeof(inchars), stdin);
	} while ((inchars[0] != 'y') && (inchars[0] != 'n'));
	if (inchars[0] == 'y'){
	  if (myputs(sniff, sniffLength, fp, prog)) exit(2);
	  if (myputs(reset[i], resetLength[i], fp, prog)) exit(2);
	}
      }
      break;
    case 'f':
      printf("Sending the print menu command.\n");
      if (myputs(sniff, sniffLength, fp, prog)) exit(2);
      if (myputs(pmenu, pmenuLength, fp, prog)) exit(2);
      break;
    case 'g':
      printf("Sending the clean command.\n");
      if (myputs(sniff, sniffLength, fp, prog)) exit(2);
      if (myputs(clean, cleanLength, fp, prog)) exit(2);
      break;
    case 'h':
      printf("%s",help);
      break;
    case 'i':
      printf("%s",info);
      break;
    case 'm':
      printf("%s",menu);
      break;
    case 'q':
      printf("Good Bye.\n");
      break;
    default:
      printf("Invalid selection.\n");
    }
  } while (inchars[0] != 'q');

  fclose(fp);
  exit(0);
}
