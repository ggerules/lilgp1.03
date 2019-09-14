
#pragma once 

#include <lilgp.h>


DATATYPE f_add( int tree, farg *args );
DATATYPE f_sub( int tree, farg *args );
DATATYPE f_gox( int tree, farg *args );
DATATYPE f_goy( int tree, farg *args );
DATATYPE f_goz( int tree, farg *args );
DATATYPE f_prog2( int tree, farg *args );
DATATYPE f_bee( int tree, farg *args );
DATATYPE f_nextflower( int tree, farg *args );
void ercvecgen( DATATYPE* );
char* ercvecstr( DATATYPE );

