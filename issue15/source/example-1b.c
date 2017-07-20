/*
 * Example 1b.c - Sample source from The RenderMan Companion
 * by Steve Upstill
 *
 */
#include <ri.h>
#define NFRAMES    10    /* number of frames in the animation */
#define NCUBES     5     /* # of minicubes on a side of the color cube */
#define FRAMEROT   5.0   /* # of degress to rotate cube between frames */

main()
{
   int frame;
   float scale;
   char   filename[20];

   RiBegin(RI_NULL);      /* Start the renderer */

      RiLightSource("distantlight", RI_NULL);

      /* Viewing transformation */
      RiProjection("perspective", RI_NULL);
      RiTranslate(0.0, 0.0, 1.5);
      RiRotate(40.0, -1.0, 1.0, 0.0);

      for (frame = 1; frame <= NFRAMES; frame++)
      {
			sprintf(filename, "anim%d.pic", frame);
         RiFrameBegin(frame);
            RiDisplay(filename, RI_FILE, RI_RGBA, RI_NULL);
            RiWorldBegin();
               scale=(float)(NFRAMES-(frame-1))/(float)NFRAMES;
               RiRotate(FRAMEROT * frame, 0.0, 0.0, 1.0);
               RiSurface("matte", RI_NULL);

               /* Define the cube */
               ColorCube(NCUBES,scale);
            RiWorldEnd();
         RiFrameEnd();
      }
   RiEnd();
}

