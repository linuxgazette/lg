/*  AutoShade v2.0 default Surface shader for TCOORD option of C:RMPROP.  */

/*  decal.sl     1.0     Larry Knott     06/04/90    */

/*  Modified, 10/22/90, KDM
        Changed the default value of one or more parameters to make the
        shader easy to use with the Pushpins filmroll.  */
            

/*----------------------------------------------------------------------------
 * decal - texture-map shader
 *
 * Puts a texture map onto a surface using texture coordinates (s, t).
 *
 * texname - the name of the texture file
 * Ka, Kd, Ks, roughness, specularcolor - the usual meaning
 *---------------------------------------------------------------------------*/

surface
PXDecal(
      float  Ka = 0.2,            /* Previously = 1 */
             Kd = 0.5,            /* Previously = 1 */
             Ks = 0.4,            /* Previously = 0 */
             roughness = 0.25;
      color  specularcolor = 1;
      string texturename = "";
     )

{
    varying vector Nf, NI;

    Nf = faceforward( normalize(N), I);

    Ci = (Ka*ambient() + Kd*diffuse(Nf)) * color texture(texturename, s, t);
    if (Ks != 0.0)
    {
        NI = normalize(-I);
        Ci += Ks*specularcolor*specular(Nf,NI,roughness);
    }
    Oi = Os;
    Ci = Ci * Oi;
}
