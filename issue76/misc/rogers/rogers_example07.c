#include <string.h>
#include <stdio.h>
/*
 *
 * 	This program is written to demonstrate the <string.h> library.
 *
 * 	Written by James M. Rogers
 *
 * 	02 Feb 2002
 *
 * 	Released to the Public Domain on this date.
 *
 *
 */




#define  MAX_STRING_LENGTH  17
#define STATIC_STRING "This is a long string that will be copied into a location during runtime"

main (){

    char  aa[10];
    char  ab[100];
    char  ac[1000];
    char  ad[10000];

    char *ba;
    char *bb;
    char *bc;
    char *bd;
    char *be;

    char string_a[17];
    char string_b[MAX_STRING_LENGTH];
    char *string_c;
    int string_length;

    int    x;
    size_t y;

/* Examples */

    /* This reserves room for 16 characters and an end of string marker. */


    strcpy ( string_a, "This is a string" );
    printf("\n strcpy ( string_a, \"This is a string\" ); \n string_a = %s \n", string_a);

  /* the following copies a string in that is too large. */
  /* it shouldn't work, but often does.  */
    strcpy ( string_a, "This is a long string" );
    printf("\n strcpy ( string_a, \"This is a string\" ); \n string_a = %s \n", string_a);


    strncpy ( string_b, "This is a long string", MAX_STRING_LENGTH );
    string_b[MAX_STRING_LENGTH-1] = '\000';
    printf("\n strcpy ( string_b, \"This is a string\" ); \n string_b = %s \n", string_b);
    


    string_length = strlen(STATIC_STRING);
    
    if (!(string_c = (char *) malloc ( string_length ))){
       /* no memory left, die */
       exit (1);
    }

    strncpy( string_c,  STATIC_STRING, string_length);
    string_c[string_length] = '\000';
    printf("\n string_c = %s \n", string_c);

    /* do something with the string */
    free(string_c);


/* Copy */

    printf ("\n* Copy \n");

  /* void  *memcpy(void *dest, const void *src, size_t n); */

    memcpy (aa, "test", 5);
    printf ("\n memcpy (aa, \"test\", 5) \n aa = \"%s\"\n", aa);

  /* void *memmove(void *dest, const void *src, size_t n); */

    memmove (ab, aa, 10);
    printf ("\n memmove (ab, aa, 10) \n ab = \"%s\"\n", ab);

  /* char *strncpy(char *dest, const char *src, size_t n); */

    strncpy (aa, "ghij", 5);
    printf ("\n strncpy (aa, \"ghij\", 5) \n aa = \"%s\"\n", aa);

  /* char  *strcpy(char *dest, const char *src); */

    strcpy (ab, "abcdef");
    printf ("\n strcpy (ab, \"abcdefg\") \n ab = \"%s\"\n", ab);


/* Concat */

    printf ("\n* Concat \n");

  /* char *strcat(char *dest, const char *src); */

    strcat (ab, aa);
    printf ("\n strcat (ab, aa) \n ab = \"%s\"\n", ab);

  /* char *strncat(char *dest, const char *src, size_t n); */

    strncat (ab, aa, 3);
    printf ("\n strncat (ab, aa, 3) \n ab = \"%s\"\n", ab);


/* Compare */

    printf ("\n* Compare \n");

  /* int memcmp(const void *s1, const void *s2, size_t n); */

    x = memcmp("b", "abc", 1);
    printf ("\n x = memcmp(\"b\", \"abc\", 1) \n x = %d \n", x);
    
    x = memcmp("b", "bcd", 1);
    printf ("\n x = memcmp(\"b\", \"bcd\", 1) \n x = %d \n", x);
    
    x = memcmp("b", "cde", 1);
    printf ("\n x = memcmp(\"b\", \"cde\", 1) \n x = %d \n", x);
    
    x = memcmp("b", "b\0cd", 100);
    printf ("\n x = memcmp(\"b\", \"b\\0cd\", 100) \n x = %d \n", x);
    
  /* int strncmp(const char *s1, const char *s2, size_t n); */

    x = strncmp("b", "abc", 1);
    printf ("\n\n x = strncmp(\"b\", \"abc\", 1) \n x = %d \n", x);
    
    x = strncmp("b", "bcd", 1);
    printf ("\n x = strncmp(\"b\", \"bcd\", 1) \n x = %d \n", x);
    
    x = strncmp("b", "cde", 1);
    printf ("\n x = strncmp(\"b\", \"cde\", 1) \n x = %d \n", x);
    
    x = strncmp("b", "b\0cd", 100);
    printf ("\n x = strncmp(\"b\", \"b\\0cd\", 100) \n x = %d \n", x);
    
  /* int strcmp(const char *s1, const char *s2); */

    x = strcmp("b", "abc");
    printf ("\n\n x = strcmp(\"b\", \"abc\") \n x = %d \n", x);
    
    x = strcmp("b", "a");
    printf ("\n x = strcmp(\"b\", \"a\") \n x = %d \n", x);
    
    x = strcmp("b", "bcd");
    printf ("\n x = strcmp(\"b\", \"bcd\") \n x = %d \n", x);
    
    x = strcmp("b", "b");
    printf ("\n x = strcmp(\"b\", \"b\") \n x = %d \n", x);
    
    x = strcmp("b", "cde");
    printf ("\n x = strcmp(\"b\", \"cde\") \n x = %d \n", x);
    
    x = strcmp("b", "c");
    printf ("\n x = strcmp(\"b\", \"c\") \n x = %d \n", x);
    
    x = strcmp("b", "b\0cd");
    printf ("\n x = strcmp(\"b\", \"b\\0cd\") \n x = %d \n", x);
    
  /* int strcoll(const char *s1, const char *s2); */

    x = strcoll("b", "a");
    printf ("\n\n x = strcoll(\"b\", \"abc\") \n x = %d \n", x);
    
    x = strcoll("b", "b");
    printf ("\n x = strcoll(\"b\", \"b\") \n x = %d \n", x);
    
    x = strcoll("b", "c");
    printf ("\n x = strcoll(\"b\", \"cde\") \n x = %d \n", x);
    
    x = strcoll("b", "b\0cd");
    printf ("\n x = strcoll(\"b\", \"b\\0cd\") \n x = %d \n", x);
    
  /* size_t strxfrm(const char *s1, const char *s2, size_t n); */

    strncpy (ac, "abcdefghijklmnopqrstuvwxyz", 27);
    strncpy (aa, "efghijklmonp", 13);

    printf ("\n ac = %s \n", ac);
    printf ("\n aa = %s \n", aa);
    
    y = strxfrm(ac, aa, 27);
    printf ("\n y = strxfrm(ac, aa, 27) \n y = %d \n ac = \"%s\"\n", y, ac);


/* Search */

    printf ("\n* Search \n");

  /* void *memchr(const void *s, int c, size_t n); */

    ba = memchr (ab, 'd', 10);
    printf ("\n ba = memchr(%s, 'd', 10) \n ba = \"%s\" \n ", ab, ba);

  /* size_t *strcspn(const char *s, const char *reject); */

    y = strcspn (ab, "dgh");
    printf ("\n strcspn (\"%s\", \"dgh\")  \n y = %d \n ab[%d] = %s \n", ab, y, y, &ab[y]);
    
  /* size_t *strspn(const char *s, const char *accept); */

    y = strspn (ab, "abcdef");
    printf ("\n strspn (\"%s\", \"abcdef\")  \n y = %d \n ab[%d] = %s \n", ab, y, y, &ab[y]);
    
  /* char *strpbrk(const char *s, const char *accept); */

    ba = strpbrk(ab, "cde");
    printf ("\n strpspn (\"%s\", \"cde\")  \n ba = %s \n", ab, ba);

  /* char *strchr(const char *s, int c); */

    ba = strchr (ab, 'h');
    printf ("\n ba = strchr(%s, 'h') \n ba = \"%s\" \n ", ab, ba);

  /* char *strrchr(const char *s, int c); */

    ba = strrchr (ab, 'h');
    printf ("\n ba = strrchr(%s, 'h') \n ba = \"%s\" \n ", ab, ba);

  /* char *strstr(const char *s, const char *substring); */

    ba = strstr (ab, "hij");
    printf ("\n ba = strchr(%s, 'hij') \n ba = \"%s\" \n ", ab, ba);

    ba = strstr (ab, "ghig");
    printf ("\n ba = strchr(%s, 'ghij') \n ba = \"%s\" \n ", ab, ba);

  /* char *strtok(char *s, const char *delim); */

    strcpy(ad, "This is an example sentence.");
    printf("\n strcpy(ad, \"This is an example sentence.\") \n"); 

    bb = strtok(ad, " ");
    while (bb) {
        printf ("  bb = \"%s\"\n", bb);
        bb = strtok(NULL, " ");
    }
        

/* Misc */

    printf ("\n* Misc \n");

  /* void *memset(void *s, int c, size_t n); */

    memset(ac, 'a', 1000);
    ac[999] = '\0';
    printf ("\n memset(ac, 'a', 1000); \n ac[999] = '\\0'; \n ac = \"%s\" \n", ac);

  /* char *strerror(int errnum); */

    printf ("\n strerror(5) = %s \n", strerror (5));

  /* size_t *strlen(const char *s); */

    y = strlen(ac);
    printf("\n y = strlen(ac); \n y = %d \n", y);

/* Non Portable */

    printf ("\n* Non Portable \n");

  /* int strcasecmp(const char *s1, const char *s2); */

    x = strcasecmp("b", "ABC");
    printf ("\n\n x = strcasecmp(\"b\", \"ABC\") \n x = %d \n", x);

    x = strcasecmp("b", "A");
    printf ("\n x = strcasecmp(\"b\", \"A\") \n x = %d \n", x);

    x = strcasecmp("b", "BCD");
    printf ("\n x = strcasecmp(\"b\", \"BCD\") \n x = %d \n", x);

    x = strcasecmp("b", "B");
    printf ("\n x = strcasecmp(\"b\", \"B\") \n x = %d \n", x);

    x = strcasecmp("b", "CDE");
    printf ("\n x = strcasecmp(\"b\", \"CDE\") \n x = %d \n", x);

    x = strcasecmp("b", "C");
    printf ("\n x = strcasecmp(\"b\", \"C\") \n x = %d \n", x);

    x = strcasecmp("b", "B\0CD");
    printf ("\n x = strcasecmp(\"b\", \"B\\0CD\") \n x = %d \n", x);

  /* int strncasecmp(const char *s1, const char *s2, size_t n); */

    x = strncasecmp("b", "ABC", 1);
    printf ("\n\n x = strncasecmp(\"b\", \"ABC\", 1) \n x = %d \n", x);

    x = strncasecmp("b", "BCD", 1);
    printf ("\n x = strncasecmp(\"b\", \"BCD\", 1) \n x = %d \n", x);

    x = strncasecmp("b", "CDE", 1);
    printf ("\n x = strncasecmp(\"b\", \"CDE\", 1) \n x = %d \n", x);

    x = strncasecmp("b", "B\0CD", 100);
    printf ("\n x = strncasecmp(\"b\", \"B\\0CD\", 100) \n x = %d \n", x);

  /* char *strdup(const char *s); */

    ba = strdup ("Test of strdup");
    printf("\n ba = strdup (\"Test of strdup\"); \n ba = %s \n", ba);

  /* char *strfry(char *string); */

    strfry(ba);
    printf("\n strfry (ba); \n ba = %s \n", ba);
    free (ba);

  /* char *strsep(char **stringp, const char *delim); */

    strcpy(ad, "This is a second example sentence.");
    printf("\n strcpy(ad, \"%s\") \n", ad); 

    ba = ad;

    bb = strsep(&ba, " ");
    while (bb) {
        printf ("  bb = \"%s\"\n", bb);
        bb = strsep(&ba, " ");
    }
    
    printf ("\n ad == %s\n", ad);
    printf ("\n");

  /* char *index(const char *s, int c); */
  /* use strchr instead, it is the same function, only portable */

  /* char *rindex(const char *s, int c); */
  /* use strrchr instead, it is the same function, only portable */

}
