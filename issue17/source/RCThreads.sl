
/*
 * threads(): wrap threads around a cylinder 
 */
displacement 
RCThreads ( 
   float   Km   =  .1,
      frequency = 5.0,
      phase     =  .0,
      offset    =  .0,
      dampzone  =  .05 )
{
   float magnitude;
 
   /* Calculate the undamped displacement */
   magnitude = (sin( PI*2*(t*frequency + s + phase))+offset) * Km;

   /* Damp the displacement to 0 at each end */
   if( t > (1-dampzone)) 
      magnitude *= (1.0-t) / dampzone;
   else if( t < dampzone )
      magnitude *= t / dampzone;

   /* Do the displacement */
   P += normalize(N) * magnitude;
   N = calculatenormal(P);
}
