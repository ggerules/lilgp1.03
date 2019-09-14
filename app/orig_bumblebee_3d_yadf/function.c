
#include <math.h>
#include <stdio.h>

#include <lilgp.h>


DATATYPE f_add( int tree, farg *args )
{
     vector v;
     v.x = ( args[0].d.x + args[1].d.x );
     v.y = ( args[0].d.y + args[1].d.y );
     v.z = ( args[0].d.z + args[1].d.z );
     return v;
}

DATATYPE f_sub( int tree, farg *args )
{
     vector v;
     v.x = ( args[0].d.x - args[1].d.x );
     v.y = ( args[0].d.y - args[1].d.y );
     v.z = ( args[0].d.z - args[1].d.z );
     return v;
}

DATATYPE f_gox( int tree, farg *args )
{
     vector v; 
     g.xpos += args[0].d.x;
     v.x = 0.0;
     v.y = 0.0;
     v.z = 0.0;
     // check if bee is near a flower
     for(int i = 0; i < g.nNumFlowers; i++)
     { 
       if(fabs(g.xpos - g.pfl[i].x) < 0.02)
       {
         if(fabs(g.ypos - g.pfl[i].y) < 0.02)
         { 
           if(fabs(g.zpos - g.pfl[i].z) < 0.02)
           { 
             g.pvis[i] = 1;
	   }
         }
       }
     }
     
     return v;
}

DATATYPE f_goy( int tree, farg *args )
{
     vector v;
     g.ypos += args[0].d.y;
     v.x = 0.0;
     v.y = 0.0;
     v.z = 0.0;
     // check if bee is near a flower
     for(int i = 0; i < g.nNumFlowers; i++)
     {
       if(fabs(g.xpos - g.pfl[i].x) < 0.02)
       {
         if(fabs(g.ypos - g.pfl[i].y) < 0.02)
         {
           if(fabs(g.zpos - g.pfl[i].z) < 0.02)
           { 
             g.pvis[i] = 1;
	   }
         }
       }
     }
   
     return v;
}

DATATYPE f_goz( int tree, farg *args )
{
     vector v;
     g.zpos += args[0].d.z;
     v.x = 0.0;
     v.y = 0.0;
     v.z = 0.0;
     // check if bee is near a flower
     for(int i = 0; i < g.nNumFlowers; i++)
     {
       if(fabs(g.xpos - g.pfl[i].x) < 0.02)
       {
         if(fabs(g.ypos - g.pfl[i].y) < 0.02)
         {
           if(fabs(g.zpos - g.pfl[i].z) < 0.02)
           { 
             g.pvis[i] = 1;
	   }
         }
       }
     }
   
     return v;
}


DATATYPE f_prog2( int tree, farg *args )
{
     return args[1].d;
}


DATATYPE f_bee( int tree, farg *args )
{
     vector bpos;
     bpos.x = g.xpos;
     bpos.y = g.ypos;
     bpos.z = g.zpos;
     return bpos;
}

DATATYPE f_nextflower( int tree, farg *args )
{
     int fl = random_int(g.nNumFlowers);
     vector v;
     v.x = g.pfl[fl].x;
     v.y = g.pfl[fl].y;
     v.z = g.pfl[fl].z;
     return v;
}


void ercvecgen( DATATYPE* r )
{
     r->x = g.lawn_width * random_double();
     r->y = g.lawn_height * random_double();
     r->z = g.lawn_depth * random_double();
     r->x = r->x - (g.lawn_width / 2.0);
     r->y = r->y - (g.lawn_height / 2.0); 
     r->z = r->z - (g.lawn_depth / 2.0); 
}

char* ercvecstr( DATATYPE d )
{
     static char buffer[100];
     sprintf ( buffer, "(make-vec :x %f :y %f :z %f)", d.x, d.y, d.z );
     return buffer;
}



