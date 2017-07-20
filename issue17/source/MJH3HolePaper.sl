/*
 * Three Holed, lined paper
 * (C) 1997 by Michael J. Hammel
 *
 * hcolor         horizontal line color
 * vcolor         vertical line color
 * hfreq          number of horizontal bars
 * vfreq          number of vertical bars
 * skip           number of horizontal bars to skip (no lines)
 * paper_height   default is 11 (as in inches)
 * paper_width    default is 8.5 (as in inches)
 * density        width of lines on paper
 * holeoffset     percentage of paper_width from left edge for hole centers
 * holeradius     radius of holes relative to paper_width
 * hole1          horizontal line number where hole 1 should be made
 * hole2          horizontal line number where hole 2 should be made
 * hole3          horizontal line number where hole 3 should be made
 */
#include "rmannotes.sl"

surface
MJH3HolePaper(
   color hcolor       = color "rgb" (0, 0, .7);
   color vcolor       = color "rgb" (.7, 0, 0);
   float hfreq        = 34;
   float vfreq        = 6;
   float skip         = 4;
   float paper_height = 11;
   float paper_width  = 8.5;
   float density      = .03525;
   float holeoffset   = .09325;
   float holeradius   = .01975;
   float hole1        = 2.6;
   float hole2        = 18;
   float hole3        = 31.25;
)
{
   color surface_color;
   float hblock = paper_height/hfreq;
   float horiz;
   float tt,ss;
   float min, max, val;
   float thole,shole;
   float vblock = paper_width/vfreq;
   point pos, hpos;


   /* Initialize the surface color to the default surface color */
   surface_color = Cs;

   /*
    * Layer 1 - horizontal stripes.  There is one stripe for every
    * horizontal block.  The stripe is "density" thick and starts at the top of
    * each block, except for the first "skip" blocks.
    */
   tt = t*paper_height;
   for ( horiz=skip; horiz<hfreq; horiz=horiz+1 )
   {
      min = horiz*hblock;
      max = min+density;
      val = smoothstep(min, max, tt);
      if ( val != 0 && val != 1 )
         surface_color = mix(hcolor, Cs, val);
   }

   /* Layer 2 - vertical stripe */
   ss = s*paper_width;
   min = vblock;
   max = min+density;
   val = smoothstep(min, max, ss);
   if ( val != 0 && val != 1 )
      surface_color = mix(vcolor, Cs, val);

   /*
    * The 3 punch holes along the side.  We compute the center for each
    * hole and then the distance the current s,t coordinates are from
    * that center.  If it is less than the holes radius then we set the
    * opacity level for the incident ray to be completely transparent.
    */

   shole = holeoffset*paper_width;
   ss  = s*paper_height;
   tt  = t*paper_height;
   pos = (ss,tt,0);

   /* First Hole */
   thole = hole1*hblock;
   hpos  = (shole, thole, 0);
   Oi    = filterstep (holeradius*paper_width, distance(pos,hpos));

   /* Second Hole */
   thole = hole2*hblock;
   hpos = (shole, thole, 0);
   Oi *= filterstep (holeradius*paper_width, distance(pos,hpos));

   /* Third Hole */
   thole = hole3*hblock;
   hpos = (shole, thole, 0);
   Oi *= filterstep (holeradius*paper_width, distance(pos,hpos));
 
   /*
    * The output values - Ci is the incident ray, the ray leading 
    * to the camera.  We make this a dull surface, with very little
    * reflective qualities.
    */
   Ci = surface_color;
}
