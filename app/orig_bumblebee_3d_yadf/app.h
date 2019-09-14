
#pragma once

#include <lilgp.h>

typedef struct
{
     vector* pfl;
     int* pvis;
     int nNumFlowers;
     float lawn_width;
     float lawn_height;
     float lawn_depth;
     float xpos;
     float ypos;
     float zpos;
     int movecount;
     int abort;
} globaldata;

extern globaldata g;


