/* cgp2_czj.c for CGP lil-gp v2.0 */
/* This file is the new interface for CGP v2.0  It provides an easy
   to use interface "language" to build the input file for CGP.
Definitions:
funclist = list of applicable functions
termlist = list of applicable terminals
functermlist = list of applicable functions and terminals
arglist = list of applicable argument numbers (0..arity)
weightlist = list of applicable weights (user defined in interface file),
             sizeof(weightlist) <= sizeof(functermlist)
typelist = list of valid types (user defined in interface file)
type = single valid type from typelist
argtypelist = list of valid type for each argument in a particular instance,
              sizeof(argtypelist) = arity
              EX func(angle, int) => argtypelist = angle int
null = empty list
* = wildcard, include all elements from applicable list
# = beginning of comment.  Comments continue until end-of-line or 
    closing grouping marker (i.e. '()', '[]') as defined in the language.
    Comments are allowed in all grouped lists except arglist.

Language:
F/Tspecs:
  FTSPEC
  F_(funclist | *) = funclist | * | null
  F_(funclist | *)[arglist | *] = functermlist | * | null
  T_(funclist | *)[arglist | *] = functermlist | * | null
  F_ROOT = functermlist | * | null
  T_ROOT = functermlist | * | null
  ENDSECTION
Weight:
  WEIGHT
  (funclist | *)[arglist | *](functermlist | *) = weightlist
  ROOT(functermlist | *) = weightlist
  ENDSECTION
Type:
  TYPE
  TYPELIST = typelist
  (funclist)(argtypelist) = type
  (termlist | *) = type
  ROOT = type
  ENDSECTION
EndOfFileMarker
  ENDFILE

Parameters:

  cgp_interface
  cgp_input

cgp_interface = filename of the interface file, if it exists
cgp_input = filename of the input file, to be created from the contents
   of the interface file and/or to be used to specify the constraints
   for the standard interface.

Parameter Usage:
cgp_interface & cgp_input
  The instructions in the interface file are used to create the input file,
  which is then used as the input to CGP

cgp_interface
  The instructions in the interface file are used to create a temporary file,
  which is then used as the input to CGP, and later deleted

cgp_input
  The input file is used as the input to CGP

neither
  The standard interactive interface to CGP is used

*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lilgp.h"

#define RETERROR -1
#define ENDLIST -2
#define COMMENT -3
#define TYPEDEFAULT  -1
#define WEIGHTDEFAULT  1.0
#define FTSPECSECTION "FTSPEC"
#define WEIGHTSECTION "WEIGHT"
#define TYPESECTION "TYPE"
#define SECTIONEND "ENDSECTION"
#define FILEEND "ENDFILE"
#define VALIDCHARS " \t\nabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ*#0123456789"
#define VALIDNUMS " \t\n+-.0123456789eE"

#define error(str) errorIndir(str,linenum,interfaceFile)
#define debugerror(str) errorIndir(str,__LINE__,__FILE__)
#define warning(str) warningIndir(str,__LINE__,__FILE__)

#define funcTermName(i) fset[0].cset[(i)].string
#define funcArity(i) fset[0].cset[(i)].arity

typedef enum {False, True} boolean;
typedef int typ_t;

typedef struct instNode {
  struct instNode *next;
  typ_t *inst;
} inst_t;

typedef struct {
  boolean *F;                         /* F_func[arg] list (F+T)*/
  boolean *T;                         /* T_func[arg] list (F+T)*/
  float   *W;                         /* func[arg] Weight list (F+T)*/
} FuncArgList_t;

typedef struct {
  boolean       *F;                   /* F_func list (F)*/
  FuncArgList_t *Arg;                 /* Pointer to Argument list (arity)*/
  inst_t         *head;               /* Pointer to Type Vec linked list (?)*/
  int            instCount;           /* Count of Type Vectors */
}FuncList_t;

typedef struct {
  boolean DefaultType;
  boolean DefaultFT;
  boolean DefaultWeight;
  FuncList_t *Func;                   /* Pointer to Function list (F)*/
  boolean *FRoot;                     /* F_Root list (F+T)*/
  boolean *TRoot;                     /* T_Root list (F+T)*/
  float   *WRoot;                     /* Root Weight list (F+T)*/
  typ_t   *TypTerm;                   /* Pointer to Terminal Type List (T)*/
  typ_t    TypRoot;                   /* Root Type (1)*/
  char   **TypList;                   /* Array of type strings */
  int      TypCount;                  /* Number of types */
}Spec_t;

static int numF, numT, linenum;
static long filePos;
static long savefp;
static char line[BUFSIZ];
static char *interfaceFile;
Spec_t *FTp;
FILE *inputFP;


static void errorIndir(const char *message, int line, char *file)
{ fprintf(stderr,"\nERROR \"%s\":%d : %s\n",file,line,message);
  exit(1);
}

static void warningIndir(const char *message, int line, char *file)
{ fprintf(stdout,"\nWarning \"%s\":%d : %s\n",file,line,message);
}

/* buildData() will create the data structure and fill with default values
   for creating the input file from the information in the intarface file. */
Spec_t *buildData()
{
  int i, j, k;

  /* creating primary data structure and arrays in it */
  FTp = (Spec_t *)malloc( sizeof(Spec_t) ); /*allocate the space for FTspecs*/
  FTp->Func = (FuncList_t *)calloc( numF, sizeof(FuncList_t) );
  FTp->FRoot = (boolean *)calloc( (numF+numT), sizeof(boolean) );
  FTp->TRoot = (boolean *)calloc( (numF+numT), sizeof(boolean) );
  FTp->WRoot = (float *)calloc( (numF+numT), sizeof(float) );
  FTp->TypTerm = (typ_t *)calloc( numT, sizeof(typ_t) );

  FTp->TypRoot = TYPEDEFAULT;            /* setting default type */
  FTp->DefaultType = True;               /* will be set to false if */
  FTp->DefaultFT = True;                 /* the appropriate section */
  FTp->DefaultWeight = True;             /* appears in the interface file */

  for (i = 0; i < numT; i++)
    FTp->TypTerm[i] = TYPEDEFAULT;       /* setting terminal default type */

  for (i = 0; i < numF + numT; i++)
  {
    FTp->FRoot[i] = False;               /* set default F_Root = empty */
    FTp->TRoot[i] = False;               /* set default T_Root = empty */
    FTp->WRoot[i] = WEIGHTDEFAULT;       /* set default Weight Root = 1 */
  }
  /* fill the array of FT_funcs */
  for (i = 0; i < numF; i++)
  {
    FTp->Func[i].head = (inst_t *)malloc(sizeof(inst_t));
    FTp->Func[i].head->inst = NULL;
    FTp->Func[i].head->next = NULL;
    FTp->Func[i].instCount = 0;
    FTp->Func[i].F = (boolean *)calloc( numF, sizeof(boolean) );

    for (j = 0; j < numF; j++)
      FTp->Func[i].F[j] = False;           /* set default F_func = empty */
    /* allocate the array for FT_func_[args] */
    FTp->Func[i].Arg =
           (FuncArgList_t *)calloc( funcArity(i), sizeof(FuncArgList_t) );

    for (j = 0; j < funcArity(i); j++)
    {
      FTp->Func[i].Arg[j].F = (boolean *)calloc((numF+numT), sizeof(boolean));
      FTp->Func[i].Arg[j].T = (boolean *)calloc((numF+numT), sizeof(boolean));
      FTp->Func[i].Arg[j].W = (float *)calloc( (numF+numT), sizeof(float) );
      for (k = 0; k < numF + numT; k++)
      {
        FTp->Func[i].Arg[j].F[k] = False; /*set default F_func_[arg] = empty*/
        FTp->Func[i].Arg[j].T[k] = False; /*set default T_func_[arg] = empty*/
        FTp->Func[i].Arg[j].W[k] = WEIGHTDEFAULT; /*set def Weight func_[arg]*/
      }
    }
  }
  return FTp;
}

/* getFuncNum returns the function number of f [0..numF) */
int getFuncNum(char *f)
{
  int i;
  for (i=0; i < numF; i++)
    if ( !strcmp( funcTermName(i), f ) )
      return i;
  return RETERROR;
}

/* getTermNum returns the function number of f [numF..numF+numT) */
int getTermNum(char *f)
{
  int i;
  for (i=numF; i < numF+numT; i++)
    if ( !strcmp( funcTermName(i), f ) )
      return i;
  return RETERROR;
}

/* getFuncTermNum returns the function number of f [0..numF+numT) */
int getFuncTermNum(char *f)
{
  int i;
  for (i=0; i < numF+numT; i++)
    if ( !strcmp( funcTermName(i), f ) )
      return i;
  return RETERROR;
}

int getTypeNum(char *t)
{
  int i;
  for ( i = 0; i < FTp->TypCount; i++)
    if ( !strcmp(FTp->TypList[i], t) )
      return i;
  return RETERROR;
}

/* nextFunc returns the next function in the applicable list.  Passing
   NULL, cause it to use the existing string.  Passing a string will it
   cause it to make the new string the existing sting. */
int nextFunc(char *list)
{
  static char s[BUFSIZ];
  static char *sp;
  static boolean all = False;    
  static int num = 0;    
  char *token;    

  if ( list != NULL )    
  {
    memset(s, '\0', BUFSIZ);
    strcpy(s, list);    
    sp = s;
    num = 0;
    all = False;    
  }    
  if ( !all )    
  { 
    token = strtok(sp, " \t\n");
    if ( token == NULL )    
      return ENDLIST;
    if ( token[0] == '#' )    
      return COMMENT;
    sp = token + strlen(token) + 1;
    if ( token[0] == '*' )
      all = True;
    else
      return getFuncNum(token);
  }    
  if ( num < numF )
    return num++;    
  else    
    return ENDLIST;    
}

/* nextTerm returns the next terminal in the applicable list.  Passing
   NULL, cause it to use the existing string.  Passing a string will it
   cause it to make the new string the existing sting. */
int nextTerm(char *list)
{
  static char s[BUFSIZ];
  static char *sp;
  static boolean all = False;
  static int num = 0;
  char *token;

  if ( list != NULL )
  {
    memset(s, '\0', BUFSIZ);
    strcpy(s, list);
    sp = s;
    num = numF;
    all = False;
  }
  if ( !all )
  {
    token = strtok(sp, " \t\n");
    if ( token == NULL )
      return ENDLIST;
    if ( token[0] == '#' )    
      return COMMENT;
    sp = token + strlen(token) + 1;
    if ( token[0] == '*' )
      all = True;
    else
      return getTermNum(token);
  }
  if ( num < numF + numT )
    return num++;
  else
    return ENDLIST;
}

/* nextArg returns the next argument in the applicable list.  Passing
   NULL, cause it to use the existing string.  Passing a string will it
   cause it to make the new string the existing sting. */
int nextArg(char *list, int arity)
{
  static char s[BUFSIZ];  
  static char *sp;
  static boolean all = False;  
  static int num = 0;  
  char *token;  

  if ( list != NULL )  
  {  
    memset(s, '\0', BUFSIZ);
    strcpy(s, list);  
    sp = s;
    num = 0;
    all = False;  
  }  
  if ( !all )  
  {  
    token = strtok(sp, " \t\n");  
    if ( token == NULL )
      return ENDLIST;
    if ( token[0] == '#' )    
      return COMMENT;
    sp = token + strlen(token) + 1;
    if ( token[0] == '*' )
      all = True;
    else
      return (atoi(token) < arity ? atoi(token) : RETERROR);
  }  
  if ( num < arity )
    return num++;  
  else  
    return ENDLIST;  
}

/* nextFuncTerm returns the next function/terminal in the applicable list.
   Passing NULL, cause it to use the existing string.  Passing a string
   will it cause it to make the new string the existing sting. */
int nextFuncTerm(char *list)
{
  static char s[BUFSIZ];
  static char *sp;
  static boolean all = False;
  static int num = 0;
  char *token;

  if ( list != NULL )
  {
    memset(s, '\0', BUFSIZ);
    strcpy(s, list);
    sp = s;
    num = 0;
    all = False;
  }
  if ( !all )
  {
    token = strtok(sp, " \t\n");
    if ( token == NULL )
      return ENDLIST;
    if ( token[0] == '#' )    
      return COMMENT;
    sp = token + strlen(token) + 1;
    if ( token[0] == '*' )
      all = True;
    else
      return getFuncTermNum(token);
  }
  if ( num < numF + numT )
    return num++;
  else
    return ENDLIST;
}

/* nextFuncSpec acts like nextFunc, but allows two seperate funclists to 
   be processed at the same time. */
int nextFuncSpec(char *list)
{
  static char s[BUFSIZ];
  static char *sp;
  static boolean all = False;
  static int num = 0;
  char *token;

  if ( list != NULL )
  {
    memset(s, '\0', BUFSIZ);
    strcpy(s, list);
    sp = s;
    num = 0;
    all = False;
  }
  if ( !all )
  {
    token = strtok(sp, " \t\n");
    if ( token == NULL )
      return ENDLIST;
    if ( token[0] == '#' )    
      return COMMENT;
    sp = token + strlen(token) + 1;
    if ( token[0] == '*' )
      all = True;
    else
      return getFuncNum(token);
  }
  if ( num < numF )
    return num++;
  else
    return ENDLIST;
}


/* nextFuncTermSpec acts like nextFuncTerm, but allows two seperate
   functermlists to be processed at the same time. */
int nextFuncTermSpec(char *list)
{
  static char s[BUFSIZ];
  static char *sp;
  static boolean all = False;
  static int num = 0;
  char *token;
  
  if ( list != NULL )
  {
    memset(s, '\0', BUFSIZ);
    strcpy(s, list);
    sp = s;
    num = 0;
    all = False;
  }
  if ( !all )
  {
    token = strtok(sp, " \t\n");
    if ( token == NULL )
      return ENDLIST;
    if ( token[0] == '#' )    
      return COMMENT;
    sp = token + strlen(token) + 1;
    if ( token[0] == '*' )
      all = True;
    else
      return getFuncTermNum(token);
  }
  if ( num < numF + numT )
    return num++;
  else
    return ENDLIST;
}

/* nextWeight returns the next weight in the applicable list.
   Passing NULL, cause it to use the existing string.  Passing a string
   will it cause it to make the new string the existing sting.  If the
   weight list is exhausted, the last item in the list will continue
   to be returned*/
double nextWeight(char *list)
{
  static char s[BUFSIZ];
  static char *sp;
  static boolean done = False;
  static float num = 0.0;
  char *token;

  if ( list != NULL )
  {
    memset(s, '\0', BUFSIZ);
    strcpy(s, list);
    sp = s;
    num = 0.0;
    done = False;
    return num;
  }
  if ( !done )
  {
    token = strtok(sp, " \t\n");
    if ( (token == NULL) || (token[0] == '#') )
    {
      done = True;
    }
    else
    {
      sp = token + strlen(token) + 1;
      num = atof(token);
      if ( (num < 0.0) || (num > 1.0) )
        error("Illegal weight");
    }
  }
  return num;
}

/* nextType returns the next type in the applicable list.
   Passing NULL, cause it to use the existing string.  Passing a string
   will it cause it to make the new string the existing sting. */
int nextType(char *list)
{
  static char s[BUFSIZ];
  static char *sp;
  int num;
  char *token;

  if ( list != NULL )
  {
    memset(s, '\0', BUFSIZ);
    strcpy(s, list);
    sp = s;
/*    return ENDLIST; */
  }
  token = strtok(sp, " \t\n");
  if ( token == NULL )
    return ENDLIST;
  if ( token[0] == '#' )    
    return COMMENT;
  sp = token + strlen(token) + 1;
  num = getTypeNum(token);
  if ( num >= 0 )
    return num;
  else
    error("Illegal type");
}

/* readFT() reads the F/Tspec section from the interface file, filling
   in the data structure to reflect the user defined F & Tspecs. */
void readFT(FILE *fp)
{
  char spec[BUFSIZ]  = "";                 /* storage for various lists */
  char sList[BUFSIZ] = "";
  char fList[BUFSIZ] = "";
  char aList[BUFSIZ] = "";
  char *token;
  int numfunc, numarg, numspec;
  boolean isF;                             /* flag for style of spec */

  FTp->DefaultFT = False;                  /* not using default values */
  while (True)                             /* keep reading lines */
  {
    memset(line, '\0', BUFSIZ);
    linenum++;
    if ( fgets(line, BUFSIZ, fp) == NULL )
      error("Unexpected EOF");
    if ( sscanf(line, " %[FT_RO]", spec) != 1)
    {
      if ( sscanf(line, " %s", spec) == 0 )
        continue;
      if ( spec[0] == '#' )
        continue;                            /* restart while loop */
      else if ( !strcmp(spec, SECTIONEND) )
        return;
      else
        error("Unknown F/Tspec");
    }
    /* Successfully read in spec */
    if ( sscanf(line, " %[FT_RO]"
                      " (%["VALIDCHARS"])"
                      " [%["VALIDCHARS"]]"
                      " =%["VALIDCHARS"]",
                spec, fList, aList, sList) == 4)
    {
      if ( !strcmp(spec, "F_") )
        isF = True;
      else if ( !strcmp(spec, "T_") )
        isF = False;
      else
        error("Unknown F/Tspec");
      for ( numfunc = nextFunc(fList); numfunc >= 0; numfunc = nextFunc(NULL))
      {
        for (numarg = nextArg(aList, funcArity(numfunc));
             numarg >= 0; numarg = nextArg(NULL, funcArity(numfunc)))
        {
          for (numspec = nextFuncTermSpec(sList);
               numspec >= 0; numspec = nextFuncTermSpec(NULL))
          {
            if (isF)
              FTp->Func[numfunc].Arg[numarg].F[numspec] = True;
            else
              FTp->Func[numfunc].Arg[numarg].T[numspec] = True;
          }
          if ( (numspec != ENDLIST) && (numspec != COMMENT) )
            error("Illegal function/terminal on right of '='");
        }
        if ( numarg == COMMENT )
          error("Comments not allowed in '[]'");
        if ( numarg != ENDLIST )
          error("Illegal argument in ()[arglist]");
      }
      if ( numfunc == COMMENT )
        error("Comments not allowed in '()'");
      if ( numfunc != ENDLIST )
        error("Illegal function in (funclist)[]");

    }
    else if ( sscanf(line, " %[FT_RO]"
                           " (%["VALIDCHARS"])"
                           " =%["VALIDCHARS"]",
                     spec, fList, sList) == 3)
    { /* F_() =, no [arglist] */
      if ( !strcmp(spec, "F_") )
      { /* work on the function list */

        for ( numfunc = nextFunc(fList); numfunc >= 0; numfunc = nextFunc(NULL))
        {
          for (numspec = nextFuncSpec(sList);
               numspec >= 0; numspec = nextFuncSpec(NULL))
            FTp->Func[numfunc].F[numspec] = True;
          if ( numspec != ENDLIST )
            error("Illegal function on right of '='");
        }   
        if ( numfunc == COMMENT )
          error("Comments not allowed in '()'");
        if ( numfunc != ENDLIST )
          error("Illegal function in (funclist)");
      }
      else
        error("Illegal FTspec");
    }
    else if ( sscanf(line, " %[FT_RO]"
                           " =%["VALIDCHARS"]",
                     spec, sList) == 2)
    { /*  F/T_Root =, no (funclist) */
      if ( !strcmp(spec, "F_ROOT") )
        isF = True;
      else if ( !strcmp(spec, "T_ROOT") )
        isF = False;
      else
        error("Unknown F/Tspec");

      for (numspec=nextFuncTermSpec(sList);
           numspec>=0; numspec=nextFuncTermSpec(NULL))
      {
        if ( isF )
          FTp->FRoot[numspec] = True;
        else
          FTp->TRoot[numspec] = True;
      }
      if ( numspec != ENDLIST )
        error("Illegal function/terminal on right of '='");
    }
    else
      error("Illegal FTspec");
  }
}

/* readWeight() reads the Weight spec section from the interface file, filling
   in the data structure to reflect the user defined Weights. All weights
   not specified in interface file are set to 1.0 by buildData().  Weights
   can be specified for all potential mutations sets.  During creation of
   the input file, only weights for valid mutation sets are used. */
void readWeight(FILE *fp)
{
  char fList[BUFSIZ] = "";                    /* storage for various lists */
  char aList[BUFSIZ] = "";
  char sList[BUFSIZ] = "";
  char wList[BUFSIZ] = "";
  int  numfunc, numarg, numspec;
  FTp->DefaultWeight = False;                  /* not using default values */
  while (True)
  {
    memset(line, '\0', BUFSIZ);
    linenum++;
    if ( fgets(line, BUFSIZ, fp) == NULL )
      error("Unexpected EOF");
    if (sscanf(line," ROOT(%["VALIDCHARS"]) =%["VALIDNUMS"]",fList,wList)==2)
    {
      for (numfunc = nextFuncTerm(fList), nextWeight(wList);
           numfunc >= 0; numfunc = nextFuncTerm(NULL))
        FTp->WRoot[numfunc] = nextWeight(NULL);
      if ( numfunc == COMMENT )
         error("Comments not allowed inside '()'");
      if ( numfunc != ENDLIST )
          error("Illegal function/terminal in (functermlist)");
    }
    else if (sscanf(line, " (%["VALIDCHARS"]) [%["VALIDCHARS"]] (%["VALIDCHARS
                        "]) =%["VALIDNUMS"]",fList,aList,sList,wList)==4)
    {
      for (numfunc=nextFunc(fList); numfunc >= 0; numfunc=nextFunc(NULL))
      {
        for (numarg=nextArg(aList,funcArity(numfunc));
             numarg >= 0; numarg=nextArg(NULL,funcArity(numfunc)))
        {
          for (numspec=nextFuncTermSpec(sList), nextWeight(wList);
               numspec>=0;numspec=nextFuncTermSpec(NULL))
            FTp->Func[numfunc].Arg[numarg].W[numspec] = nextWeight(NULL);
          if ( numspec == COMMENT )
             error("Comments not allowed inside '()'");
          if ( numspec != ENDLIST )
              error("Illegal function/terminal in ()[](functermlist)");
        }
        if ( numarg == COMMENT )
           error("Comments not allowed inside '[]'");
        if ( numarg != ENDLIST )
            error("Illegal argument in ()[arglist]()");
      }
      if ( numfunc == COMMENT )
         error("Comments not allowed inside '()'");
      if ( numfunc != ENDLIST )
          error("Illegal function in (funclist)[]()");
    }
    else
    {
      if ( sscanf(line, " %s", fList) == 0)
        continue;
      if ( fList[0] == '#' )
      {
        continue;
      }
      else if ( !strcmp(fList, SECTIONEND) )
        return;
      else
        error("Unknown Weight Spec");
    }
  }
}

/* createTypes() reads the valid types from the interface file, filling
   in the data structure to reflect the user defined Types. */
void createTypes(char *list)
{
  int count;
  char t[BUFSIZ];
  char *token;

  strcpy(t, list);
  token = strtok(t, " \t\n");
  /* count the number of types */
  for ( count = 0; (token != NULL) && (token[0] != '#');
        token = strtok(NULL, " \t\n"), count++ );
  if ( count < 1 )
    error("Must declare at least one type");
  strcpy(t, list);

  /* Create data structure to hold valid type information */
  FTp->TypCount = count;
  FTp->TypList = (char **)calloc( FTp->TypCount, sizeof(char *) );
  for ( count = 0, token = strtok(t, " \t\n"); count < FTp->TypCount; count++ )
  {
    FTp->TypList[count] = (char *)malloc( strlen(token) + 1 );
    strcpy(FTp->TypList[count], token);
    token = strtok(NULL, " \t\n");
  }
}

/* readType() reads the Type spec section from the interface file, filling
   in the data structure to reflect the user defined Types. */
void readType(FILE *fp)
{
  char fList[BUFSIZ] = "";                  /* storage for various lists */
  char sList[BUFSIZ] = "";
  char tList[BUFSIZ] = "";
  int  numterm, numfunc, numarg, numtype;
  inst_t *ip;
  FTp->DefaultType = False;                  /* not using default values */

  memset(line, '\0', BUFSIZ);
  linenum++;
  if ( fgets(line, BUFSIZ, fp) == NULL )
    error("Unexpected EOF");
  if ( sscanf(line, " TYPELIST =%["VALIDCHARS"]", tList) != 1 )
    error("Expected valid type list definition");
  createTypes(tList);

  while (True)
  {
    memset(line, '\0', BUFSIZ);
    linenum++;
    if ( fgets(line, BUFSIZ, fp) == NULL )
      error("Unexpected EOF");
    if (sscanf(line, " ROOT =%["VALIDCHARS"]\n",tList)==1)
    {
      numtype = nextType(tList);
      if ( numtype >= 0 )
        FTp->TypRoot = numtype;
      else if ( numtype == ENDLIST )
        error("No type specified for Root");

      numtype = nextType(NULL);
      if ( (numtype != ENDLIST) && (numtype != COMMENT) )
        error("Too many types specified for Root");
    }
    else if ( sscanf(line, " (%["VALIDCHARS"]) =%["VALIDCHARS"]",
              fList, tList) == 2 )
    {
      for (numterm = nextTerm(fList), numtype = nextType(tList);
           numterm >= 0;
           numterm = nextTerm(NULL))
      {
        if ( numtype >= 0 )
          FTp->TypTerm[numterm-numF] = numtype;
        else if ( numtype == ENDLIST || numtype == COMMENT )
          error("No type specified for terminal");
        else
          error("Illegal type on right of '='");
      }
      if ( numterm == COMMENT )
        error("Comments not allowed inside '()'");
      if ( numterm != ENDLIST )
        error("Illegal terminal in (termlist)");
      numtype = nextType(NULL);
      if ( numtype != ENDLIST && numtype != COMMENT)
        error("Too many types specified for terminal");
    }
    else if ( sscanf(line, 
              " (%["VALIDCHARS"]) (%["VALIDCHARS"]) =%["VALIDCHARS"]",
              fList,sList,tList) == 3 )
    {
      for (numfunc= nextFunc(fList); numfunc>=0; numfunc = nextFunc(NULL))
      {
        FTp->Func[numfunc].instCount++;
                                                      /* find end of list */
        for (ip=FTp->Func[numfunc].head; ip->next != NULL; ip=ip->next );
        ip->next = (inst_t *)malloc(sizeof(inst_t));
        ip = ip->next;
        ip->next = NULL;
        ip->inst = (typ_t *)calloc(funcArity(numfunc)+1, sizeof(typ_t));
        for ( numarg=0, numtype=nextType(sList);
              numarg<funcArity(numfunc) && numtype>=0;
              numarg++, numtype=nextType(NULL))
        { 
          ip->inst[numarg] = numtype;
        }
        if ( numarg < funcArity(numfunc) )
          error("too few argument types");
        if ( numtype == COMMENT )
          error("Comments not allowed inside '()'");
        if ( numtype != ENDLIST )
          error("too many argument types");

        numtype = nextType(tList);                     /* initialize list */
        ip->inst[numarg] = numtype;
        numtype = nextType(NULL);
        if ( numtype != ENDLIST && numtype != COMMENT )
          error("too many return types");
      }
      if ( numfunc == COMMENT )
        error("Comments not allowed inside '()'");
      if ( numfunc != ENDLIST )
        error("Illegal function in (funclist)()");
    }
    else
    {
      if ( sscanf(line, " %s", fList) == 0 )
        continue;
      if ( fList[0] == '#' )
      {
        continue;
      }
      else if ( !strcmp(fList, SECTIONEND) )
      {
        /* before returning from function, check to make sure all data
           structures are filled with type information */
        if ( FTp->TypRoot == TYPEDEFAULT )
          error("No type defined for Root");
        for ( numterm = 0; numterm < numT; numterm++ )
          if ( FTp->TypTerm[numterm] == TYPEDEFAULT )
          {
            sprintf(line, "No type defined for terminal '%s'",
                    funcTermName(numterm+numF));
            error(line);
          }
        for ( numfunc = 0; numfunc < numF; numfunc++ )
          if ( FTp->Func[numfunc].instCount == 0 )
          {
            sprintf(line, "No type defined for function '%s'",
                    funcTermName(numfunc));
            error(line);
          }
        return;
      }
      else
        error("Unknown Type Spec");
    }
  }
}

/* writeFT() write out to the input file, the FTspecs as specified in the
   interface file. */
void writeFT()
{
  int fnum, anum, snum;
  if ( FTp == NULL )
    return;
  fprintf(inputFP, "%d\n", FTp->DefaultFT);
  if ( FTp->DefaultFT )
    return;
  for ( fnum = 0; fnum < numF; fnum++ )
  {
    for ( snum = 0; snum < numF; snum++ )
      if ( FTp->Func[fnum].F[snum] )
        fprintf(inputFP, "%s ", funcTermName(snum));         /* printf F_func */
    fprintf(inputFP,"\n");
    for ( anum = 0; anum < funcArity(fnum); anum++ )
    {
      for ( snum = 0; snum < numF + numT; snum++ )
        if ( FTp->Func[fnum].Arg[anum].F[snum] )
          fprintf(inputFP, "%s ", funcTermName(snum));      /*printf F_func[arg]*/
      fprintf(inputFP,"\n");
      for ( snum = 0; snum < numF + numT; snum++ )
        if ( FTp->Func[fnum].Arg[anum].T[snum] )
          fprintf(inputFP, "%s ", funcTermName(snum));      /*printf T_func[arg]*/
      fprintf(inputFP,"\n");
    }
  }
  for ( snum = 0; snum < numF + numT; snum++ )
    if ( FTp->FRoot[snum] )
      fprintf(inputFP, "%s ", funcTermName(snum));          /* printf F_Root */
  fprintf(inputFP,"\n");
  for ( snum = 0; snum < numF + numT; snum++ )
    if ( FTp->TRoot[snum] )
      fprintf(inputFP, "%s ", funcTermName(snum));          /* printf T_Root */
  fprintf(inputFP,"\n");
}

/* writeWeightHeader() write out to the input file, just the number
   indicating whetere or not to use the default values. */
void writeWeightHeader()
{ int i, j, k;
  if ( FTp == NULL )
    return;
  fprintf(inputFP, "%d\n", FTp->DefaultWeight);
/*  if ( !FTp->DefaultWeight ) */
    filePos = ftell(inputFP);
  fseek(inputFP,0,SEEK_SET);
}

/* writeFuncWeight() write out to the input file, the weight for a 
   particular func[arg] (func). */
void writeFuncWeight(int f, int a, int s)
{
  static int prevF = -1;            /* for keeping track of where \n's go */
  static int prevA = -1;
  if ( FTp == NULL || FTp->DefaultWeight )
    return;
  savefp = ftell(inputFP);
  if ( fseek(inputFP, filePos, SEEK_SET) != 0 )
    debugerror("Couldn't fseek standard input file");
  if ( (prevF != -1) && ((prevF != f) || (prevA != a)) )
    fprintf(inputFP, "\n");
  prevF = f;
  prevA = a;
  fprintf(inputFP, "%g ", FTp->Func[f].Arg[a].W[s]);
  filePos = ftell(inputFP);
  if ( fseek(inputFP, savefp, SEEK_SET) != 0 )
    debugerror("Couldn't fseek standard input file");
}

/* writeRootWeight() write out to the input file, the weight for a 
   particular func as the root. */
void writeRootWeight(int s)
{
  static boolean first = True;
  if ( FTp == NULL || FTp->DefaultWeight )
    return;
  savefp = ftell(inputFP);
  if ( fseek(inputFP, filePos, SEEK_SET) != 0 )
    debugerror("Couldn't fseek standard input file");
  if ( first )
  {
    first = False;
    fprintf(inputFP, "\n");
  }
  fprintf(inputFP, "%g ", FTp->WRoot[s]);
  filePos = ftell(inputFP);
  if ( fseek(inputFP, savefp, SEEK_SET) != 0 )
    debugerror("Couldn't fseek standard input file");
}

/* finishRootWeight() write out to the input file, the \n as needed
   to close out the weight section.  (only for astetics) */
void finishRootWeight()
{
  if (FTp == NULL )
    return;
  savefp = ftell(inputFP);
  if ( fseek(inputFP, filePos, SEEK_SET) != 0 )
    debugerror("Couldn't fseek standard input file");
  if ( !FTp->DefaultWeight )
    fprintf(inputFP, "\n");
  fprintf(inputFP, "1\n");                  /* flag to continue running cgp */
  filePos = ftell(inputFP);
  if ( fseek(inputFP, savefp, SEEK_SET) != 0 )
    debugerror("Couldn't fseek standard input file");
}

/* writeType() write out to the input file, every type instance of each
   function, along with the types of the terminals and root. */
void writeType()
{
  int numfunc, numarg, numterm, numtype;
  inst_t *ip;
  if ( FTp == NULL )
    return;
  fprintf(inputFP, "%d\n", FTp->DefaultType);
  if ( FTp->DefaultType )
    return;
  for (numtype = 0; numtype < FTp->TypCount; numtype++)
    fprintf(inputFP, "%s ", FTp->TypList[numtype]);
  fprintf(inputFP, "\n");
  if ( numtype <= 1 )
    return;
  for (numfunc=0; numfunc < numF; numfunc++)
  {
    for ( ip = FTp->Func[numfunc].head->next;
         (ip != NULL) && (ip->inst != NULL); ip = ip->next )
    {
      for (numarg = 0; numarg < funcArity(numfunc)+1; numarg++)
        fprintf(inputFP, "%s ", FTp->TypList[ip->inst[numarg]]);
      fprintf(inputFP, "\n");
    }
    fprintf(inputFP, "\n");
  }
  for (numterm = 0; numterm < numT; numterm++)
    fprintf(inputFP, "%s\n", FTp->TypList[FTp->TypTerm[numterm]]);
  fprintf(inputFP, "%s\n", FTp->TypList[FTp->TypRoot]);
}

/* readInterfaceFile() start reading the interface file, determining which
   section is being defined */
void readInterfaceFile(FILE *fp)
{
  char section[BUFSIZ];

  while ( True  )
  {
    memset(line, '\0', BUFSIZ);
    linenum++;
    if ( fgets(line, BUFSIZ, fp) == NULL )
      break;
    if ( sscanf(line, "%s", section) != 1 )
      continue;

    if ( !strcmp(FTSPECSECTION, section) )
      readFT(fp);
    else if ( !strcmp(WEIGHTSECTION, section) )
      readWeight(fp);
    else if ( !strcmp(TYPESECTION, section) )
      readType(fp);
    else if ( !strcmp(FILEEND, section) )
      return;
    else if ( section[0] == '#' )
      continue;
    else
      error("Unknown section header");
  }
  error("Section header not found (unexpected EOF without '"FILEEND"')");
}

/* closeInterface() closes the input file after all reading and writing
   is completed */
void closeInterface()
{
/*  if ( stdin_bu != NULL )
    stdin = stdin_bu; */
  if ( inputFP != NULL )
    fclose(inputFP);
}

/* buildInterface() determines which files need to be used for the 
   interface and input files, if any, creates them and then sets up
   the building of the needed data structures. */
void buildInterface()
{
  FILE *interfaceFP;
  char *inputFile;

  inputFP = stdin;
  interfaceFile = get_parameter("cgp_interface");
  inputFile = get_parameter("cgp_input");

  if ( interfaceFile == NULL )
  {
    if ( inputFile == NULL )
      return;
    if ( (inputFP = fopen(inputFile, "r")) == NULL )
      error("unable to open input file for reading");
    return;
  }

  if ( interfaceFile != NULL  )
  {
    numF = fset[0].function_count;
    numT = fset[0].terminal_count;
    linenum = 0;
    buildData();

    if ( (interfaceFP = fopen(interfaceFile, "r")) == NULL )
      error("unable to open interface file");

    readInterfaceFile(interfaceFP);
    fclose(interfaceFP);

    if ( inputFile == NULL )
    {
      if ( (inputFP = tmpfile()) == NULL )
        error("unable to open temporary input file for r/w");
    }
    else if ( (inputFP = fopen(inputFile, "w+")) == NULL )
      error("unable to open input file for r/w");

    writeType();
    writeFT();
    /* just write the weight header right now.  The rest is taken care
       of after creation of the mutations sets in cgp_czj.c */
    writeWeightHeader();
  }
}

