/* crosstile.sl
 *
 * creates a single tile with a horizontal yellow bar crossing
 * a vertical white bar on whatever the surface color is.
 *
 */
#include "rmannotes.sl"

surface crosstile()
{
  color surface_color, layer_color;
  color surface_opac, layer_opac;
  float fuzz = 0.05;

  /* background layer */

  surface_color = Cs;
  surface_opac = Os;

  /* vertical bar layer */

  layer_color = color (0.1, 0.5, 0.1);
  layer_opac = pulse(0.35, 0.65, fuzz, s);
  surface_color = blend(surface_color, layer_color, layer_opac);

  /* horizontal bar layer */

  layer_color = color (0.1, 0.1, 0.3);
  layer_opac = pulse(0.35, 0.65, fuzz, t);
  surface_color = blend(surface_color, layer_color, layer_opac);

  /* output */

  Oi = surface_opac;
  Ci = surface_opac * surface_color;
}
