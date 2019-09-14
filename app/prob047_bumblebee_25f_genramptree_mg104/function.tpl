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
   ENDFOR+][+ENDIF+][+ENDFOR+][+ENDFOR+][+
   FOR nadf+][+FOR fset+][+IF (first-for? "fset")+][+FOR ercs+]
void [+ercfun+]( DATATYPE* );
char* [+ercstr+]( DATATYPE );[+
   ENDFOR+][+ENDIF+][+ENDFOR+][+ENDFOR+]
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
  [+oper+]
}
[+ ENDFOR+][+ENDIF+][+ENDFOR+][+ENDFOR+]
[+FOR nadf+][+FOR fset+][+IF (first-for? "fset")+][+FOR const+]
DATATYPE [+name+]( int tree, farg *args )
{
  [+oper+]
}
[+ ENDFOR+][+ENDIF+][+ENDFOR+][+ENDFOR+][+
FOR nadf+][+FOR fset+][+IF (first-for? "fset")+][+FOR ercs+]
void [+ercfun+]( DATATYPE* r )
{
  [+fercgenbody+]
}

char* [+ercstr+]( DATATYPE d )
{
  [+fercstrbody+]
}
[+ ENDFOR+][+ENDIF+][+ENDFOR+][+ENDFOR+]

[+ ESAC +]
