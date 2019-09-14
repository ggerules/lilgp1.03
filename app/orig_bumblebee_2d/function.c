/*  lil-gp Genetic Programming System, version 1.0, 11 July 1995
 *  Copyright (C) 1995  Michigan State University
 * 
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of version 2 of the GNU General Public License as
 *  published by the Free Software Foundation.
 * 
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 * 
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *  
 *  Douglas Zongker       (zongker@isl.cps.msu.edu)
 *  Dr. Bill Punch        (punch@isl.cps.msu.edu)
 *
 *  Computer Science Department
 *  A-714 Wells Hall
 *  Michigan State University
 *  East Lansing, Michigan  48824
 *  USA
 *  
 */

#include <lilgp.h>

DATATYPE f_bee( int tree, farg *args )
{
  vector bpos;
  bpos.x = g.xpos;
  bpos.y = g.ypos;
  return bpos;
}

DATATYPE f_nextflower( int tree, farg *args )
{
  int fl = random_int(g.nNumFlowers);
  vector v;
  v.x = g.pfl[fl].x;
  v.y = g.pfl[fl].y;
  return v;
}


DATATYPE f_vadd( int tree, farg *args )
{
  vector v;
  v.x = ( args[0].d.x + args[1].d.x );
  v.y = ( args[0].d.y + args[1].d.y );
  return v;
}

DATATYPE f_vsub( int tree, farg *args )
{
  vector v;
  v.x = ( args[0].d.x - args[1].d.x );
  v.y = ( args[0].d.y - args[1].d.y );
  return v;
}

DATATYPE f_gox( int tree, farg *args )
{
  vector v;
  g.xpos += args[0].d.x;
  v.x = 0.0;
  v.y = 0.0;
  // check if bee is near a flower
  for(int i = 0; i < g.nNumFlowers; i++)
  {
    if(fabs(g.xpos - g.pfl[i].x) < 0.02)
    {
      if(fabs(g.ypos - g.pfl[i].y) < 0.02)
      {
        g.pvis[i] = 1;
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
  // check if bee is near a flower
  // check if bee is near a flower
  for(int i = 0; i < g.nNumFlowers; i++)
  {
    if(fabs(g.xpos - g.pfl[i].x) < 0.02)
    {
      if(fabs(g.ypos - g.pfl[i].y) < 0.02)
      {
        g.pvis[i] = 1;
      }
    }
  }
 
  return v;
}

DATATYPE f_prog2 ( int tree, farg *args )
{
     return args[1].d;
}



void f_vecgen ( DATATYPE *r )
{
     r->x = g.lawn_width * random_double();
     r->y = g.lawn_height * random_double();
     r->x = r->x - (g.lawn_width / 2.0);
     r->y = r->y - (g.lawn_height / 2.0);
}

char *f_vecstr ( DATATYPE d )
{
     static char buffer[100];
     sprintf ( buffer, "(make-vec :x %f :y %f )", d.x, d.y);
     return buffer;
}
          
          
          
          
     
