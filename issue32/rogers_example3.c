#include <stdio.h>

/*
   this program reads in a data file consisting of
   multiple lines, each line contains a floating 
   point number and a single character label.
   This simulates multiple accounts with charges
   and credits.  The program will add up all charges
   and credits and print a total for each.
 */

main ()
{

  float value, add[255];
  char label[1024];
  int i;
  FILE *stream;

  /* initialize the array to zero */
  for (i = 0; i < 255; i++)
    add[i] = 0;

  /* open the input file for reading, quit if it doesn't open */
  if ((stream = fopen ("example3.dat", "r")) == (FILE *) 0)
    {
      fprintf (stderr, "Couldn't open example3.dat file.");
      return 1;
    }				/* end if */

  /* read from the file until you reach the end of the file */
  while (fscanf (stream, "%e%s", &value, label) != EOF)
    {
      add[*label] = add[*label] + value;
    }				/* end while */


  /* print out the totals for the files by label */
  for (i = 0; i < 255; i++)
    {
      if (add[i] != 0)
	printf ("%c	%6.2f\n", i, add[i]);
    }

  /* we are done and successful */
  return 0;

}				/* end main */
