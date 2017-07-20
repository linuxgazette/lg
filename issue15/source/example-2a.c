#include <stdio.h>
#include <ri.h>

/*
 * BMRT Introduction - Michael J. Hammel
 * Example 2a - a sphere over a plane
 */
main()
{
   /* The angle of the field of view of this image */
   RtFloat fov = 35.0;

   /* The color we'll use for the sphere */
   RtColor blue = { 0.2,0.3,0.9 };

   /* The color we'll use for the plane under the sphere */
   RtColor gray = { 0.9, 0.9, 0.9 };

   /* The intensity level of the distant light */
   RtFloat intensity = 1.0;

   /*
    * Coordinates for the distant light.
    */
   RtPoint from = {0.0, 10.5, -6.0};
   RtPoint to = {0.0, 0.0, 0.0};

   /* The coordinates of the corners of our plane */
   RtPoint points[4] = { 
         -3.0, 0.0, 0.0,
          3.0, 0.0, 0.0,  
          3.0, 3.0, 0.0,
         -3.0, 3.0, 0.0
         };

   /*
    * RI_NULL means send RIB output to standard out; this could be 
    * changed to a filename to force the RIB to a specific file.  You can
    * also specify the name of the one of the BMRT renderers which will
    * cause the output to be piped directly to that renderer.
    */
   RiBegin(RI_NULL);

      /*
       * The filename of the rendered image is specfified in the RiDisplay
       * command.  This is not where the RIB output goes, this is where
       * the output from the renderer goes.
       */
      RiDisplay ("example-2a.tif", RI_FILE, RI_RGB, RI_NULL);

      /*
       * Image size - the "1" is the ratio of width to height for pixels.
       * Unless you're using non-square pixels this should always be 1.
       */
      RiFormat (480, 360, 1);

      /*
       * Set the samples per pixel to be 1 in each direction.
       */
      RiPixelSamples ( 1, 1 );

      /*
       * Perspective views give a more realistic sense of depth to
       * the image.  
       */
      RiProjection ( RI_PERSPECTIVE, RI_FOV, (RtPointer)&fov, RI_NULL );

      /*
       * Set our initial position for World objects.  Basically this 
		 * is just setting our initial camera position to 8 units in 
		 * the positive Z direction.  Any changes we would make to the
		 * cameras postion would be relative to this.
       */
      RiTranslate (0, 0, 8);

      /*
       * Now we start to define the objects in our scene.
		 * All our rendering options are frozen inside the World commands.
       */
      RiWorldBegin();

         /*
          * Set up a distant light source.  Distant lights have parallel
			 * rays which follow a line parallel to the line defined by
			 * "from" and "to" below.
          */
         RiLightSource(RI_DISTANTLIGHT, RI_INTENSITY, &intensity, 
               RI_FROM, (RtPointer)from, RI_TO, (RtPointer)to, RI_NULL);

         /*
          * Each object has its own set of attributes.  Putting them
          * inside the Attribute commands prevents us from accidently
          * forgetting to reset the attributes, such as a colors,
          * for a later object.
          */
         RiAttributeBegin();

            /*
             * We need to set the surface texture of the sphere first.  Here
             * we use a simple matte surface shader which is provided
             * in the BMRT distribution.  The surface will have a blue
				 * color.
             */
            RiColor(blue);
            RiSurface("matte", RI_NULL);

            /*
             * Next we define our sphere.  We'll move it up a little from
				 * the XZ plane.
             */
            RiTranslate ( 0, 0.75, 0.0 );
            RiSphere(0.8,-0.8, 0.8, 360.0, RI_NULL);

         RiAttributeEnd();

         /*
          * Now a shiny, metal plane below the sphere.
          */
         RiAttributeBegin();
            RiColor(gray);
            RiSurface("shinymetal", RI_NULL);
            RiTranslate ( 0, -1.0, 2.0 );
            RiRotate ( 80, 1, 0, 0 );
            RiPolygon(4, RI_P, (RtPointer)points, RI_NULL);
         RiAttributeEnd();

		/*
		 * Don't forget:  RiWorldEnd() causes the current scene to be 
		 * written to the output file (or standard out if no file is
		 * defined).
		 */
      RiWorldEnd();
}
