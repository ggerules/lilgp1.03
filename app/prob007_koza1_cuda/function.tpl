[+ AutoGen5 template +]
[+ CASE (suffix) +]
[+ ==  h  +]
#pragma once 

#include <lilgp.h>

[+FOR nadf+][+FOR fset+][+IF (first-for? "fset")+][+FOR func+]
DATATYPE [+name+]( int tree, farg *args );[+ 
   ENDFOR+][+ENDIF+][+ENDFOR+][+ENDFOR+][+ 
   FOR nadf+][+FOR fset+][+IF (first-for? "fset")+][+FOR vars+]
DATATYPE [+name+]( int tree, farg *args );[+ 
   ENDFOR+][+ENDIF+][+ENDFOR+][+ENDFOR+][+
   FOR nadf+][+FOR fset+][+IF (first-for? "fset")+][+FOR const+]
DATATYPE [+name+]( int tree, farg *args );[+ 
   ENDFOR+][+ENDIF+][+ENDFOR+][+ENDFOR+]
void f_erc_gen ( DATATYPE * );
char *f_erc_print ( DATATYPE );
[+ ==  c  +]
#include <math.h>
#include <stdio.h>

#include <lilgp.h>

[+FOR nadf+][+FOR fset+][+IF (first-for? "fset")+][+FOR func+]
DATATYPE [+name+]( int tree, farg *args )
{
     [+oper+]
}
[+ ENDFOR+][+ENDIF+][+ENDFOR+][+ENDFOR+]
[+FOR nadf+][+FOR fset+][+IF (first-for? "fset")+][+FOR vars+]
DATATYPE [+name+]( int tree, farg *args )
{
     return g.[+name+];
}
[+ ENDFOR+][+ENDIF+][+ENDFOR+][+ENDFOR+]
[+FOR nadf+][+FOR fset+][+IF (first-for? "fset")+][+FOR const+]
DATATYPE [+name+]( int tree, farg *args )
{
     [+oper+]
}
[+ ENDFOR+][+ENDIF+][+ENDFOR+][+ENDFOR+]
void f_erc_gen ( DATATYPE *r )
{
     *r = (random_double()*2.0) - 1.0;
}

char *f_erc_print ( DATATYPE d )
{
     static char buffer[20];

     sprintf ( buffer, "%.5f", d );
     return buffer;
}

[+ ESAC +]
