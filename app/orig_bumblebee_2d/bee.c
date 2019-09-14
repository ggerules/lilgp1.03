#include<stdio.h>
#include<stdlib.h>
#include "appdef.h"
#include "app.h"
#include "function.h"

/*
koza gp2 ch9 p275 
- location of each flower specified by two dimensional vector of floating point coordinates
- bee starts at origin 0,0
- flower x location randomly chosen from -5.0 - 5.0
- flower y location randomly chosen from -5.0 - 5.0
- no flower can be within 0.2 of flower location, a square 
- 10 15 20 and 25 are numbers of flowers for each size problem 

without adfs:
- terminals:
  bee - current location of the bee
  next-flower - terminal that who's value is randomly set to the next unvisited flower for the current fitness case. 
  erc - a random constant who's vector value is between -5.0 and 5.0.  This is like an erc
- functions:
  v+ - vector addition     2 args takes two vectors adds them, returns the resulting vector 
  v- - vector subtraction  2 args takes two vectors subtracts them, returns the resulting vector 
  go-x - 1 arg takes a vector, moves the bee in the x direction 
  go-y - 1 arg takes a vector, moves the bee in the y direction 
  progn - evaluates each item from list begin to end 
- fitness cases:
  2 fitness cases
  raw fitness is the number of flowers visited across fitness cases
    if there are 25 flowers, raw fitness would be between 0 and 50
  a hit is when the bee is within 0.02 distance of the flower, not circular distance, just square sides
  bee is limited to 100 movements per fitness case
  standardized fitness - twice the number of flowers (ie 50 for 25 flower case) minus raw fitness
  wrapper none
  population 4000
  generations 50
  sucecess predicate - a program scores the maximum number of hits.

with adfs:
adf0:
- terminals:
  arg0, bee, erc
- functions:
  v+, v- go-x, go-y progn
rpb:
- terminals:
  bee, next-flower, erc
- functions:
  adf0, v+, v- go-x, go-y progn


*/

globaldata g;

void init_rand( int seed )
{
  random_seed ( seed );

  return; 
}

int main()
{
  int nFlws = 10;
  int rs = 1; // seed number for random number generator
  int nTryCnt = 200;
  vector v1;
  vector v2;
  vector v3;
  farg arg;

  init_rand(rs); 

  g.pfl = NULL;
  g.nNumFlowers   = nFlws;
  g.nCurFlower    = 0;;
  g.lawn_width    = 10.0;
  g.lawn_height   = 10.0;
  g.xpos          = 0.0;
  g.ypos          = 0.0;
  g.dir           = APP_NORTH;
  g.movecount     = 200;
  g.abort         = 0;

  // generate flowers
  g.pfl = (vector*)malloc(nFlws * sizeof(vector));
  if(!g.pfl)
    return 1; // out of memory 

  // assign flower locations based on lawn dimmensions
  // no two flowers can be with-in 0.02 of another flower
  for(int f = 0; f < nFlws; f++)
  {
    g.pfl[f].x = g.lawn_width * random_double();
    g.pfl[f].y = g.lawn_height * random_double();
    //g.pfl[f].visited = 0;

    #if 0
    // code to test what happens if points are the same.  
    // for this purpose artificially set points
    if(f == 4)
    {
      g.pfl[f].x = 1.0; 
      g.pfl[f].y = 1.0; 
      g.pfl[f-2].x = 1.01; 
      g.pfl[f-2].y = 1.01; 
    }
    #endif 

    //check to see if any previous points are the same
    if(f > 0)
    {
      for(int i = f - 1; i >= 0; i--)
      {
        if(fabs(g.pfl[f].x - g.pfl[i].x) < 0.02)
        {
          //printf("%s\n", "match x");
          if(fabs(g.pfl[f].y - g.pfl[i].y) < 0.02)
          {
            //printf("%s\n", "match y");
            g.pfl[f].x = g.lawn_width * random_double();
            g.pfl[f].y = g.lawn_height * random_double();
            //g.pfl[f].visited = 0;
            i = f;  // restart check
          }
        }
      }
    }
  }

  printf("%s\n", "memory alloc worked");

  for(int f = 0; f < nFlws; f++)
  {
    //printf("(%.6f %.6f %d)\n", g.pfl[f].x, g.pfl[f].y, g.pfl[f].visited); 
    printf("(%.6f %.6f)\n", g.pfl[f].x, g.pfl[f].y); 
  }

  char* pStr = NULL;
  f_vecgen ( &v1 );
  pStr = f_vecstr ( v1 );
  printf("%s\n", pStr);

  #if 0
  for(int i = 0; i < 100; i++)
  {
    printf("ri=%d\n", random_int(g.nNumFlowers));
  }
  #endif

  v2 = f_nextflower(0, &arg);

  printf("next flower location (%.6f %.6f)\n", v2.x, v2.y );

  free(g.pfl);
  g.pfl = NULL;

  return 0;
}
