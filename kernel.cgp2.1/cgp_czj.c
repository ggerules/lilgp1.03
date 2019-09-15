/* cgp_czj.c version 2.0, for function- anada data type-based constraints */
/* using lil-gp 1.02 */
/* based on cgp1.1, which allows fixed weights for mutation sets */

/* NOTE: function number, which is identical to its index in fset, is used
   as hash index in MST_czj - lats entry (index=NumF) is for the Root */
/* NOTE: TF_czj uses function and terminal hash index identical to its
   index in fset - last entry (index=NumFT) is for the Root */
/* NOTE: types are processed by indexes too; these idexes are those in
   TypeNames; when types are not used, a single type='generic' is used */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "lilgp.h"
#include "cgp2_czj.h"

#define DISPLAY_CONSTRAINTS 1
#define DISPLAY_MST 1
#define DISPLAY_TP 1
#define DISPLAY_NF 1

#define error(str) errorIndir(str,__LINE__,__FILE__)
#define warning(str) warningIndir(str,__LINE__,__FILE__)

#define SMALL 0.000000001                        /* delta for double compare */
#define MINWGHT 0.00001           /* min. maintanble wght for a member of MS */

const int RepeatsSrc_czj=5;    /* max repeats in crossover on infeasible src */
const int RepeatsBad_czj=5;                  /* same on bad (size) offspring */

MST_czj_t MST_czj;                    /* the global table with mutation sets */
TP_czj_t TP_czj;                      /* global dynamic table with type info */

int Function_czj;
        /* the node to be modified has this parent; if the node  is the root
           then this number is the number of type I functions */

int Argument_czj;
        /* the node to be modified is this argument of its parent
           uninitialized if the node is the root */

int Type_czj;
        /* the return type expected by Function_czj on its Argument_czj */

int MinDepth_czj;
        /* if depth=m-n is given in eithe initialization or mutation
           and the corresponding depth_abs=true, this is used to grow only
           trees at least as deep as 'm' (if possible) */

/**************** now local structures */
extern FILE *inputFP;
static int NumF;                                    /* num functions in fset */
static int NumT;                         /* num typeII/III functions in fset */
static int NumFT;                                               /* NumF+NumT */
static int NumTypes;                                      /* number of types */
static float WghtsExt;    /* sum of wghts of cross-feasible leaves of a tree */
static float WghtsInt;                        /* same for the internal nodes */
static char **TypeNames;         /* array of NumTypes ragged dynamic strings */

typedef int *specArr_t; /* dynamic for NumF+NumT; array[i]==1 indicates that
                             function indexed i is present in a set */
typedef struct
{ int numF;                         /* number of F set elements in specArr */
  int numT;
  specArr_t mbs;
} specArrArg_t;
typedef specArrArg_t *specArrs_t;     /* dynamic array of specArrArg_t */
typedef struct
{ int arity;
  specArrs_t Tspecs;    /* dynamic array of ptrs to specArr_t for Tspecs */
  specArrs_t Fspec;                                       /* just one here */
  specArrs_t Fspecs;
} constraint_t;                     /* NOTE: Root will use Tspecs and Fspecs */
typedef constraint_t *constraints_t; /* dynamic array for functions and Root */

static constraints_t Cons;

/****************************************/

/**************** a couple of utility functions */

static void errorIndir(const char *message, int line, char *file)
{ fprintf(stderr,"\nERROR \"%s\":%d : %s\n",file,line,message);
  exit(1);
}

static void warningIndir(const char *message, int line, char *file)
{ fprintf(stdout,"\nWarning \"%s\":%d : %s\n",file,line,message);
}

static void *getVec(size_t numEls, size_t bytesPerEl)
        /* allocate an array from the heap, exit on failure */
{ void *p;
  if (numEls<1 || bytesPerEl<1)
    error("storage allocation missuse");
  p=calloc(numEls,bytesPerEl);
  if (p==NULL)
    error("storage allocation failure");
  return p;
}

static void *getMoreVec(void *oldP, size_t bytes)
        /* reallocate an array from the heap, exit on failure */
{ void *p;
  if (bytes<1)
    error("storage allocation missuse");
  if (oldP == NULL)
    p=malloc(bytes);                 /* some compilers dont handle a NULL */
  else                               /* passed to realloc properly, so  */
    p=realloc(oldP,bytes);           /* malloc is used in those cases   */
  if (p==NULL)
    error("storage allocation failure");
  return p;
}

static int member(int e, int *vec, int start, int stop)
	/* return 1 if e is found in vec between start and stop inclusively */
{ int i;
  for (i=start; i<=stop; i++)
    if (vec[i]==e)
      return(1);
  return(0);
}

/*****************************************/

static int funNumber(const char* funName, int treeNumber)
/* given funName, return its index in fset[treeNumber] or -1 if not found */
{ int i;
  for (i=0; i<fset[treeNumber].size; i++)
    if (!strcmp(funName,fset[treeNumber].cset[i].string))
      return(i);
  return(-1);
}

static int typeNumber(const char *typeName)
/* given typeName, return its index in TypeNames, or -1 if not found */
{ int i;
  for (i=0; i<NumTypes; i++)
    if (!strcmp(typeName,TypeNames[i]))
      return(i);
  return(-1);
}

static void displayHeader(void)
{ printf("\n\n\t\tWELCOME TO cgp-lilgp 2.1/1.02\n");
  printf("\n\t\tdeveloped by\n");
  printf("\tCezary Z. Janikow\n");
  printf("\tUniversity of Missouri - St. Louis\n");
  printf("\temailto:cjanikow@ola.cs.umsl.edu\n");
  printf("\thttp://www.cs.umsl.edu/~janikow\n");
  printf("\n\t\timplementation team:\n");
  printf("\tCezary Z. Janikow, leader\n");
  printf("\tScott DeWeese, UMSL student (cgp interface file)\n");
  printf("\n\n\n\n\tThis is distributed as an addition to lil-gp 1.02\n");
  printf("\n\tNo explicit/implicit warranty\n");
  printf("\n\n\n");
}

static void displayCons(int Ts, int F, int Fs)
	/* for debugging, arguments state which to display */
{ int fun, arg, entry;
  printf("\n\t\tCONSTRAINTS\n");
  for (fun=0; fun<NumF; fun++)
  { printf("Function '%s' [#%d]:\n",fset[0].cset[fun].string,fun);
    if (F)
    { printf("\tF_%s [#Fs=%d:#Ts=%d] =",fset[0].cset[fun].string,
          Cons[fun].Fspec[0].numF,Cons[fun].Fspec[0].numT);
      for (entry=0; entry<NumF; entry++)
        if (Cons[fun].Fspec[0].mbs[entry])
           printf(" '%s'",fset[0].cset[entry].string);
      printf(" ||");
      for (; entry<NumF+NumT; entry++)
        if (Cons[fun].Fspec[0].mbs[entry])
           printf(" '%s'",fset[0].cset[entry].string);
      printf("\n");
    }
    if (Fs)
      for (arg=0; arg<Cons[fun].arity; arg++)
      { printf("\tF_%s_%d [#Fs=%d:#Ts=%d] =",fset[0].cset[fun].string,arg,
          Cons[fun].Fspecs[arg].numF,Cons[fun].Fspecs[arg].numT);
        for (entry=0; entry<NumF; entry++)
          if (Cons[fun].Fspecs[arg].mbs[entry])
            printf(" '%s'",fset[0].cset[entry].string);
        printf(" ||");
        for (; entry<NumF+NumT; entry++)
          if (Cons[fun].Fspecs[arg].mbs[entry])
            printf(" '%s'",fset[0].cset[entry].string);
        printf("\n");
      } 
    if (Ts)
      for (arg=0; arg<Cons[fun].arity; arg++)
      { printf("\tT_%s_%d [#Fs=%d:#Ts=%d] =",fset[0].cset[fun].string,arg,
          Cons[fun].Tspecs[arg].numF,Cons[fun].Tspecs[arg].numT);
        for (entry=0; entry<NumF; entry++)
          if (Cons[fun].Tspecs[arg].mbs[entry])
            printf(" '%s'",fset[0].cset[entry].string);
        printf(" ||");
        for (; entry<NumF+NumT; entry++)
          if (Cons[fun].Tspecs[arg].mbs[entry])
            printf(" '%s'",fset[0].cset[entry].string);
        printf("\n");
      } 
  }
  printf("Root:%d\n",fun);
  if (Fs)
  { printf("\tF_Root [#Fs=%d:#Ts=%d] = ",
          Cons[NumF].Fspecs[0].numF,Cons[NumF].Fspecs[0].numT);
    for (entry=0; entry<NumF; entry++)
      if (Cons[NumF].Fspecs[0].mbs[entry])
        printf(" '%s'",fset[0].cset[entry].string);
    printf(" ||");
    for (; entry<NumF+NumT; entry++)
      if (Cons[NumF].Fspecs[0].mbs[entry])
        printf(" '%s'",fset[0].cset[entry].string);
    printf("\n");
  } 
  if (Ts)
  { printf("\tT_Root [#Fs=%d:#Ts=%d] = ",
          Cons[NumF].Tspecs[0].numF,Cons[NumF].Tspecs[0].numT);
    for (entry=0; entry<NumF; entry++)
      if (Cons[NumF].Tspecs[0].mbs[entry])
        printf(" '%s'",fset[0].cset[entry].string);
    printf(" ||");
    for (; entry<NumF+NumT; entry++)
      if (Cons[NumF].Tspecs[0].mbs[entry])
        printf(" '%s'",fset[0].cset[entry].string);
    printf("\n");
  } 
}

static void displayMST(int uncMs, int wheel, int weight)
	/* display mutation sets from MST_czj */
	/* if uncMs the include unconstrained mut set */
	/* if wheel/weight then invclude wheel/weights */
{ int i,j,k,t;
  printf("\n");
  for (i=0; i<NumF; i++)      
  { printf("Function '%s': arity %d \n",
           fset[0].cset[i].string,fset[0].cset[i].arity);
    for (j=0; j<fset[0].cset[i].arity; j++) 
    { printf("\tArgument %d\n",j);
      for (t=0; t<NumTypes; t++)
        if (MST_czj[i][j][t].numFT!=0)             /* mutation set not empty */
        { printf("\t\tType '%s'\n",TypeNames[t]);
          printf("\t\t\tF [%d members] =",MST_czj[i][j][t].numF);
          for (k=0; k<MST_czj[i][j][t].numF; k++)
            printf(" '%s'",fset[0].cset[MST_czj[i][j][t].mbs[k]].string);
          printf("\n\t\t\tT [%d members] =",MST_czj[i][j][t].numT);
          for (k=0; k<MST_czj[i][j][t].numT; k++)
            printf(" '%s'",fset[0].cset[MST_czj[i][j][t].
                                        mbs[MST_czj[i][j][t].numF+k]].string);
          if (wheel)
          { printf("\n\t\t\tWheel: F is %s and T is %s\n\t\t\t",
                   MST_czj[i][j][t].areFs ? "used":"not used", 
                   MST_czj[i][j][t].areTs ? "used":"not used");
            for (k=0; k<MST_czj[i][j][t].numFT; k++)
              printf(" %.6f",MST_czj[i][j][t].wheel[k]);
          }
          if (weight)
          { printf("\n\t\t\tWeights: F is %s and T is %s\n\t\t\t",
                   MST_czj[i][j][t].areFs ? "used":"not used", 
                   MST_czj[i][j][t].areTs ? "used":"not used");
            for (k=0; k<NumFT; k++)
              printf(" %.6f",MST_czj[i][j][t].weights[k]);
          }
          printf("\n");
        }
      if (uncMs)
      { printf("\t\tType unconstrained mutation set\n");
        printf("\t\t\tF [%d members] =",MST_czj[i][j][NumTypes].numF);
        for (k=0; k<MST_czj[i][j][NumTypes].numF; k++)
          printf(" '%s'",fset[0].cset[MST_czj[i][j][NumTypes].mbs[k]].string);
        printf("\n\t\t\tT [%d members] =",MST_czj[i][j][NumTypes].numT);
        for (k=0; k<MST_czj[i][j][NumTypes].numT; k++)
          printf(" '%s'",fset[0].cset[MST_czj[i][j][NumTypes].
                                  mbs[MST_czj[i][j][NumTypes].numF+k]].string);
        if (wheel)
        { printf("\n\t\t\tWheel: F is %s and T is %s\n\t\t\t",
                 MST_czj[i][j][t].areFs ? "used":"not used",
                 MST_czj[i][j][t].areTs ? "used":"not used");
          for (k=0; k<MST_czj[i][j][t].numFT; k++)
            printf(" %.6f",MST_czj[i][j][t].wheel[k]);
        }
        if (weight)
        { printf("\n\t\t\tWeights: F is %s and T is %s\n\t\t\t",
                 MST_czj[i][j][t].areFs ? "used":"not used",
                 MST_czj[i][j][t].areTs ? "used":"not used");
          for (k=0; k<NumFT; k++)
            printf(" %.6f",MST_czj[i][j][t].weights[k]);
        }
        printf("\n");
      }
    }
  }
  printf("Root:\n");
  for (t=0; t<NumTypes; t++)
  if (MST_czj[NumF][0][t].numFT!=0)
  { printf("\t\tType '%s'\n",TypeNames[t]);
    printf("\t\t\tF [%d members] =",MST_czj[NumF][0][t].numF);
    for (k=0; k<MST_czj[NumF][0][t].numF; k++)
      printf(" '%s'",fset[0].cset[MST_czj[NumF][0][t].mbs[k]].string);
    printf("\n\t\t\tT [%d members] =",MST_czj[NumF][0][t].numT);
    for (k=0; k<MST_czj[NumF][0][t].numT; k++)
      printf(" '%s'",fset[0].cset[MST_czj[NumF][0][t].
                                     mbs[MST_czj[NumF][0][t].numF+k]].string);
    if (wheel)
    { printf("\n\t\t\tWheel: F is %s and T is %s\n\t\t\t",
             MST_czj[NumF][0][t].areFs ? "used":"not used",
             MST_czj[NumF][0][t].areTs ? "used":"not used");
      for (k=0; k<MST_czj[NumF][0][t].numFT; k++)
        printf(" %.6f",MST_czj[NumF][0][t].wheel[k]);
    }
    if (weight)
    { printf("\n\t\t\tWeights: F is %s and T is %s\n\t\t\t",
             MST_czj[NumF][0][t].areFs ? "used":"not used", 
             MST_czj[NumF][0][t].areTs ? "used":"not used");
      for (k=0; k<NumFT; k++)
        printf(" %.6f",MST_czj[NumF][0][t].weights[k]);
    }
    printf("\n");
  }
  if (uncMs)
  { printf("\t\tType unconstrained mutation set\n");
    printf("\t\t\tF [%d members] =",MST_czj[NumF][0][NumTypes].numF);
    for (k=0; k<MST_czj[NumF][0][NumTypes].numF; k++)
      printf(" '%s'",fset[0].cset[MST_czj[NumF][0][NumTypes].mbs[k]].string);
    printf("\n\t\t\tT [%d members] =",MST_czj[NumF][0][NumTypes].numT);
    for (k=0; k<MST_czj[NumF][0][NumTypes].numT; k++)
      printf(" '%s'",fset[0].cset[MST_czj[NumF][0][NumTypes].
                               mbs[MST_czj[NumF][0][NumTypes].numF+k]].string);
    if (wheel)
    { printf("\n\t\t\tWheel: F is %s and T is %s\n\t\t\t",
             MST_czj[NumF][0][t].areFs ? "used":"not used",
             MST_czj[NumF][0][t].areTs ? "used":"not used");
      for (k=0; k<MST_czj[NumF][0][t].numFT; k++)
        printf(" %.6f",MST_czj[NumF][0][t].wheel[k]);
    }
    if (weight)
    { printf("\n\t\t\tWeights: F is %s and T is %s\n\t\t\t",
             MST_czj[NumF][0][t].areFs ? "used":"not used",
             MST_czj[NumF][0][t].areTs ? "used":"not used");
      for (k=0; k<NumFT; k++)
        printf(" %.6f",MST_czj[NumF][0][t].weights[k]);
    }
    printf("\n");
  }
}

static void displayTP(void)
{ int i,j,k,m;
  for (i=0; i<NumF; i++)
  { printf("Function '%s': numArg=%d, numTypeVecs=%d\n",
         fset[0].cset[i].string,TP_czj[i].f.numA,TP_czj[i].f.numTypeVecs); 
    if (TP_czj[i].f.numTypeVecs)
    { for (j=0; j<TP_czj[i].f.numTypeVecs; j++)
      { printf("\tvec%d: ",j);
        for (k=0; k<TP_czj[i].f.numA; k++)
          printf("%d:'%s' ",k,TypeNames[TP_czj[i].f.typeVecs[j][k]]);
        printf("-> '%s'",TypeNames[TP_czj[i].f.typeVecs[j][TP_czj[i].f.numA]]);
        printf("\n");
      }
      for (j=0; j<NumTypes; j++)
      { if (TP_czj[i].f.indexes[j].len>0)
        { printf("\tType '%s' returned from vectors: ",TypeNames[j]);
          for (k=0; k<TP_czj[i].f.indexes[j].len; k++)
            printf("%d ",TP_czj[i].f.indexes[j].indexes[k]);
          printf("\n");
        }
      }
    }
  }
  for (i=NumF; i<NumFT; i++)
    printf("Terminal '%s': -> '%s'\n",fset[0].cset[i].string,
           TypeNames[TP_czj[i].retType]);
  printf("Root: -> '%s'\n",TypeNames[TP_czj[NumFT].retType]);
  printf("\n\n");
}

static double readMinWghtto1(const char *prompt)
/* read (0,1], and if entry < MINWGHT then set it as MINWGHT */
{ double what;
  int res;
  printf("%s: ",prompt);
  res=fscanf(inputFP,"%lf",&what);
  if (res<1 || what >1 || what<0)
    error("failed reading weight");
  if (what<MINWGHT)
    what=MINWGHT;                           /* smaller values become minimal */
  return(what);
}

static void readWeightsSetWheels(void)
/* read weights for mutation set entries and construct wheels for the */
/*   no-type constraints only (MST_czj[*][*][NumTypes] structures */
/* assume weights for non-members are set to -1 */
/* areFs and areTs members of MST_czj are set to true if at least one */
/*   member has weight>MINWGHT */
{ int i,j,k;
  double adjWght;
  int areFs, areTs;
  printf("\n\nSetting initial weights for mutation set members...\n");
  printf("Initial weights are all equal. Do you accept [0 to change]: ");
  fscanf(inputFP,"%d",&i);
  if (i)
    return;                               /* leave inital weights and wheels */
  for (i=0; i<NumF; i++)
  { printf("\n");
    printf("Function '%s': %d mutation set pairs\n",
           fset[0].cset[i].string,fset[0].cset[i].arity);
    for (j=0; j<fset[0].cset[i].arity; j++)
    { areFs=0; areTs=0;
      printf("Argument %d:\n",j);
      printf("\tF [%d members] =",MST_czj[i][j][NumTypes].numF);
      for (k=0; k<MST_czj[i][j][NumTypes].numF; k++)
        printf(" '%s'",fset[0].cset[MST_czj[i][j][NumTypes].mbs[k]].string);
      printf("\n\tT [%d members] =",MST_czj[i][j][NumTypes].numT);
      for (k=0; k<MST_czj[i][j][NumTypes].numT; k++)
        printf(" '%s'",fset[0].cset[MST_czj[i][j][NumTypes].mbs[
                                      MST_czj[i][j][NumTypes].numF+k]].string);
      printf("\n\n\tReading the weights for type I functions...\n");
      for (k=0; k<MST_czj[i][j][NumTypes].numF; k++)
      { printf("\tFunction '%s': ",
               fset[0].cset[MST_czj[i][j][NumTypes].mbs[k]].string);
        writeFuncWeight(i, j, MST_czj[i][j][NumTypes].mbs[k]);
        MST_czj[i][j][NumTypes].weights[MST_czj[i][j][NumTypes].mbs[k]]=
                                            readMinWghtto1("give weight (0,1]");
      }
      printf("\n\tReading the weights for type II/III terminals...\n");
      for (k=0; k<MST_czj[i][j][NumTypes].numT; k++)
      { printf("\tTerminal '%s': ",fset[0].cset[MST_czj[i][j][
                     NumTypes].mbs[MST_czj[i][j][NumTypes].numF+k]].string);
        writeFuncWeight(i, j, 
               MST_czj[i][j][NumTypes].mbs[MST_czj[i][j][NumTypes].numF+k]);
        MST_czj[i][j][NumTypes].weights[MST_czj[i][j][NumTypes].mbs[
          MST_czj[i][j][NumTypes].numF+k]]=readMinWghtto1("give weight (0,1]");
      }
    /* now all non-memb weights are -1, all memb weights are in [MINWGHT..1] */
                   /* now set mut wheel skipping over weights <MINWGHT+SMALL */
      for (k=0; k<MST_czj[i][j][NumTypes].numFT; k++)
      { if (MST_czj[i][j][NumTypes].weights[MST_czj[i][j][NumTypes].mbs[k]]
            <MINWGHT+SMALL)
          adjWght=0;
        else
        { adjWght=
           MST_czj[i][j][NumTypes].weights[MST_czj[i][j][NumTypes].mbs[k]];
          if (k<MST_czj[i][j][NumTypes].numF)
            areFs=1;
          else
            areTs=1;
        }
        MST_czj[i][j][NumTypes].wheel[k]= (k==0) ? adjWght :
                                    MST_czj[i][j][NumTypes].wheel[k-1]+adjWght;
      }
      MST_czj[i][j][NumTypes].areFs=areFs;
      MST_czj[i][j][NumTypes].areTs=areTs;
      if (!areFs && !areTs)
      { fprintf(stderr,
                "\tno member of f=%d arg=%d has any weight >MINWGHT\n",i,j);
        exit(1);
      }
    }
    printf("\n\n");
  }
  printf("Root:\n");
  areFs=0; areTs=0;
  printf("\t\tF [%d members] =",MST_czj[NumF][0][NumTypes].numF);
  for (k=0; k<MST_czj[NumF][0][NumTypes].numF; k++)
    printf(" '%s'",fset[0].cset[MST_czj[NumF][0][NumTypes].mbs[k]].string);
  printf("\n\t\tT [%d members] =",MST_czj[NumF][0][NumTypes].numT);
  for (k=0; k<MST_czj[NumF][0][NumTypes].numT; k++)
    printf(" '%s'",fset[0].cset[MST_czj[NumF][0][NumTypes].mbs[
                                   MST_czj[NumF][0][NumTypes].numF+k]].string);
  printf("\n\tReading the weights for type I functions...\n");
  for (k=0; k<MST_czj[NumF][0][NumTypes].numF; k++)
  { printf("\tFunction '%s': ",
           fset[0].cset[MST_czj[NumF][0][NumTypes].mbs[k]].string);
    writeRootWeight(k);
    MST_czj[NumF][0][NumTypes].weights[MST_czj[NumF][0][NumTypes].mbs[k]]=
                                            readMinWghtto1("give weight (0,1]");
  }
  printf("\n\tReading the weights for type II/III terminals...\n");
  for (k=0; k<MST_czj[NumF][0][NumTypes].numT; k++)
  { printf("\tTerminal '%s': ",fset[0].cset[MST_czj[NumF][0][
                  NumTypes].mbs[MST_czj[NumF][0][NumTypes].numF+k]].string);
    writeRootWeight(k+NumF);
    MST_czj[NumF][0][NumTypes].weights[MST_czj[NumF][0][NumTypes].mbs[
       MST_czj[NumF][0][NumTypes].numF+k]]=readMinWghtto1("give weight (0,1]");
  }
  for (k=0; k<MST_czj[NumF][0][NumTypes].numFT; k++)
  { if (MST_czj[NumF][0][NumTypes].weights[
                          MST_czj[NumF][0][NumTypes].mbs[k]]<MINWGHT+SMALL)
      adjWght=0;
    else
    { adjWght=MST_czj[NumF][0][NumTypes].weights[MST_czj[NumF][0][
                                                         NumTypes].mbs[k]];
      if (k<MST_czj[NumF][0][NumTypes].numF)
        areFs=1;
      else
        areTs=1;
    }
    MST_czj[NumF][0][NumTypes].wheel[k]= (k==0) ? adjWght :
                                 MST_czj[NumF][0][NumTypes].wheel[k-1]+adjWght;
  }
  MST_czj[NumF][0][NumTypes].areFs=areFs;
  MST_czj[NumF][0][NumTypes].areTs=areTs;
  if (!areFs && !areTs)
    error("no member of Root sets has any 'weight>MINWGHT'");
  if (!areFs && areTs)
    warning("Root can only evolve to terminals");
  printf("\n\n");
}

static void constrain1Type(int t, mutSet_czj_t ms, mutSet_czj_t *newMs)
/* constrains ms for type t into newMs, allocates storage as needed */
{ int e, f;
  double adjWght;
  for (e=0; e<ms.numF; e++)
  { f=ms.mbs[e];
    if (TP_czj[f].f.indexes[t].len>0)             /* function f gives type t */
    { newMs->numFT++;
      newMs->mbs=(int*)getMoreVec(newMs->mbs,newMs->numFT*sizeof(int));
      newMs->wheel=(double*)getMoreVec(newMs->wheel,newMs->numFT*sizeof(double));
      newMs->mbs[newMs->numFT-1]=f;
      newMs->numF++;
    }
  }
  for (e=ms.numF; e<ms.numFT; e++)                               
  { f=ms.mbs[e];
    if (TP_czj[f].retType==t)                 /* term f gives the right type */
    { newMs->numFT++;
      newMs->mbs=(int*)getMoreVec(newMs->mbs,newMs->numFT*sizeof(int));
      newMs->wheel=(double*)getMoreVec(newMs->wheel,newMs->numFT*sizeof(double));
      newMs->mbs[newMs->numFT-1]=f;
      newMs->numT++;
    }
  }
  if (newMs->numFT>0)
  { newMs->weights=(double*)getVec((size_t)NumFT,sizeof(double));
    for (e=0; e<NumF; e++)  /* copy weights, set to -1 those with wrong type */
    { if (TP_czj[e].f.indexes[t].len>0)
        newMs->weights[e]=ms.weights[e];
      else
        newMs->weights[e]= -1;
    }
    for (e=NumF; e<NumFT; e++)  
    { if (TP_czj[e].retType==t)
        newMs->weights[e]=ms.weights[e];
      else
        newMs->weights[e]= -1;
    }

    newMs->areFs=0;
    newMs->areTs=0;
    for (e=0; e<newMs->numFT; e++)
      { if (newMs->weights[newMs->mbs[e]]<MINWGHT+SMALL)
          adjWght=0;
        else
        { adjWght=newMs->weights[newMs->mbs[e]];
          if (e<newMs->numF)
            newMs->areFs=1;
          else
            newMs->areTs=1;
        }
        newMs->wheel[e]= (e==0) ? adjWght : newMs->wheel[e-1]+adjWght;
      }
  }
}

static void constrainTypes(void)
/* combine type-unconstrained mutation sets in MST_czj[*][*][NumTypes] */
/*   with type info in TPS to create mutation weights for indiv. types */
/*   in MST_czj[*][*][0..NumTypes-1] */
{ int f, a, t, v;
  for (f=0; f<NumF; f++)
  { for (a=0; a<fset[0].cset[f].arity; a++)
      for (t=0; t<NumTypes; t++)
        for (v=0; v<TP_czj[f].f.numTypeVecs; v++)
          if (TP_czj[f].f.typeVecs[v][a]==t)
          { constrain1Type(t,MST_czj[f][a][NumTypes],&MST_czj[f][a][t]);
            break;
          }
  }
  for (t=0; t<NumTypes; t++)
   if (TP_czj[NumFT].retType==t)
     constrain1Type(t,MST_czj[NumF][0][NumTypes],&MST_czj[NumF][0][t]);
}

static void displayFTNames(void)
	/* display function and terminal set */
{ int i;
  printf("\n%d ordinary functions:\n\t",NumF);
  for (i=0; i<NumF; i++)
    printf("%s ",fset[0].cset[i].string); 
  printf("\n%d terminals (ordinary and ephemeral):\n\t",NumT);
  for (; i<NumF+NumT; i++)
    printf("%s ",fset[0].cset[i].string); 
  printf("\nSeparate entries by [ ,;]\nHit <ENTER> for empty set\n");
  printf("Use function names in any order\n\n");
}

static void displayTypeNames(void)
	/* display type names */
{ int i;
  printf("\n%d types: ",NumTypes);
  for (i=0; i<NumTypes; i++)
    printf("%s ",TypeNames[i]);
  printf("Separate entries by [ ,;]  Hit <ENTER> for empty set\n");
  printf("Use type names in any order\n\n");
}

static void read1ConSet(const char*prompt, specArrs_t setP, int max)
	/* read one set from one line; max is the highest index allowed */
{ int entry, status;
  char buf[BUFSIZ];
  char sep[]=" ,;\n";
  char *p;
  for (entry=0; entry<NumF+NumT; entry++)
    setP->mbs[entry]=0;                            /* reset set to empty */
  setP->numF=setP->numT=0;                          /* reset member counters */
  printf("%s [up to %d names] = ",prompt,max+1);
  if (fgets(buf,BUFSIZ,inputFP)==NULL)
  { fprintf(stderr,"ERROR: failed reading constrained\n");
    exit(1);
  }
  p=strtok(buf,sep);
  while (p!=NULL)
  { if ((entry=funNumber(p,0))<0)
      error("invalid function/terminal name");
    else if (entry>max)
           error("function not allowed in this set"); 
         else
         { setP->mbs[entry]=1;
           if (entry<NumF) 
             setP->numF++;
           else 
             setP->numT++;
         }
    p=strtok(NULL,sep);
  }
}

static void set1ConSet(specArrs_t setP, int max)
{ int entry;
  for (entry=0; entry<NumF+NumT; entry++)
    setP->mbs[entry]=0;                            /* reset set to empty */
  setP->numF=setP->numT=0;                          /* reset member counters */
  for (entry = 0; entry <= max; entry++ )
  {
    setP->mbs[entry] = 1;
    if (entry<NumF)
      setP->numF++;
    else
      setP->numT++;
  }
}
 
static void reset1ConSet(specArrs_t setP, int max)
{ int entry;
  for (entry=0; entry<NumF+NumT; entry++)
    setP->mbs[entry]=0;                            /* reset set to empty */
  setP->numF=setP->numT=0;                          /* reset member counters */
}


static void readFTspecs(void)
	/* read FT specs, set up Cons structure */
{ int i, j;
  char buf[BUFSIZ];
  char prompt[BUFSIZ];

  printf("\n\nReading F/Tspec information...\n\n");
  printf("\nDefault is empty Fspecs, full Tspecs. Accept? [0 to change]: ");
  fscanf(inputFP,"%d",&i);
  fgets(buf,BUFSIZ,inputFP);
  if (i)
  {
    Cons=(constraints_t)getVec((size_t)(NumF+1),sizeof(constraint_t));
    for (i=0; i<NumF; i++)
    {
      Cons[i].arity=fset[0].cset[i].arity;
      Cons[i].Fspec=(specArrs_t)getVec((size_t)1,sizeof(specArrArg_t));
      Cons[i].Fspec[0].mbs=(specArr_t)getVec((size_t)(NumF+NumT),sizeof(int));
      reset1ConSet(&(Cons[i].Fspec[0]),NumF-1);
      Cons[i].Tspecs=(specArrs_t)getVec((size_t)Cons[i].arity,sizeof(specArrArg_t));
      Cons[i].Fspecs=(specArrs_t)getVec((size_t)Cons[i].arity,sizeof(specArrArg_t));
      for(j=0; j<Cons[i].arity; j++)
      {
        Cons[i].Tspecs[j].mbs=(specArr_t)getVec((size_t)(NumF+NumT),sizeof(int));
        Cons[i].Fspecs[j].mbs=(specArr_t)getVec((size_t)(NumF+NumT),sizeof(int));
        reset1ConSet(&(Cons[i].Fspecs[j]),NumF+NumT-1);
        set1ConSet(&(Cons[i].Tspecs[j]),NumF+NumT-1);
      }
    }
    Cons[NumF].arity=1;
    Cons[NumF].Fspec=NULL;
    Cons[i].Tspecs=(specArrs_t)getVec((size_t)1,sizeof(specArrArg_t));
    Cons[i].Fspecs=(specArrs_t)getVec((size_t)1,sizeof(specArrArg_t));
    Cons[i].Tspecs[0].mbs=(specArr_t)getVec((size_t)(NumF+NumT),sizeof(int));
    Cons[i].Fspecs[0].mbs=(specArr_t)getVec((size_t)(NumF+NumT),sizeof(int));
    reset1ConSet(&(Cons[NumF].Fspecs[0]), NumF+NumT-1);
    set1ConSet(&(Cons[NumF].Tspecs[0]), NumF+NumT-1);
  }
  else
  {
    Cons=(constraints_t)getVec((size_t)(NumF+1),sizeof(constraint_t));
    for (i=0; i<NumF; i++) 
    { displayFTNames();
      printf("Function '%s':\n",fset[0].cset[i].string);
      Cons[i].arity=fset[0].cset[i].arity;
      Cons[i].Fspec=(specArrs_t)getVec((size_t)1,sizeof(specArrArg_t));
      Cons[i].Fspec[0].mbs=(specArr_t)getVec((size_t)(NumF+NumT),sizeof(int));

      sprintf(prompt,"\tF_%s (exclusions)",fset[0].cset[i].string);
      read1ConSet(prompt,&(Cons[i].Fspec[0]),NumF-1);     /* type I only here */
      Cons[i].Tspecs=(specArrs_t)getVec((size_t)Cons[i].arity,sizeof(specArrArg_t));
      Cons[i].Fspecs=(specArrs_t)getVec((size_t)Cons[i].arity,sizeof(specArrArg_t));
      for (j=0; j<Cons[i].arity; j++)
      { Cons[i].Tspecs[j].mbs=(specArr_t)getVec((size_t)(NumF+NumT),sizeof(int));
        Cons[i].Fspecs[j].mbs=(specArr_t)getVec((size_t)(NumF+NumT),sizeof(int));
        sprintf(prompt,"\tF_%s_%d (exclusions)",fset[0].cset[i].string,j);
        read1ConSet(prompt,&(Cons[i].Fspecs[j]),NumF+NumT-1);
        sprintf(prompt,"\tT_%s_%d (inclusions)",fset[0].cset[i].string,j);
        read1ConSet(prompt,&(Cons[i].Tspecs[j]),NumF+NumT-1);
      }
    }
    Cons[NumF].arity=1;
    Cons[NumF].Fspec=NULL;
    Cons[i].Tspecs=(specArrs_t)getVec((size_t)1,sizeof(specArrArg_t));
    Cons[i].Fspecs=(specArrs_t)getVec((size_t)1,sizeof(specArrArg_t));
    Cons[i].Tspecs[0].mbs=(specArr_t)getVec((size_t)(NumF+NumT),sizeof(int));
    Cons[i].Fspecs[0].mbs=(specArr_t)getVec((size_t)(NumF+NumT),sizeof(int));
    displayFTNames();
    printf("Root:");
    read1ConSet("\tF^Root (exclusions)",&(Cons[NumF].Fspecs[0]),NumF+NumT-1);
    read1ConSet("\tT^Root (inclusions)",&(Cons[NumF].Tspecs[0]),NumF+NumT-1);
  }
}

static void generateNF(void)
	/* from specs of Cons generate NF in Fspecs of Cons */
	/* this involves creating T-extensive Fspecs */
{ int fun, arg, entry;
  for (fun=0; fun<NumF; fun++)           /* first create T-extensive F-specs */
    for (arg=0; arg<Cons[fun].arity; arg++)
      for (entry=0; entry<NumF+NumT; entry++)
        if (Cons[fun].Tspecs[arg].mbs[entry]==0)
          Cons[fun].Fspecs[arg].mbs[entry]=1;
  for (entry=0; entry<NumF+NumT; entry++)               /* same for the Root */
    if (Cons[NumF].Tspecs[0].mbs[entry]==0)
      Cons[NumF].Fspecs[0].mbs[entry]=1;

  for (fun=0; fun<NumF; fun++)              /* now create F-extensive Fspecs */
    for (entry=0; entry<NumF; entry++)
      if (Cons[fun].Fspec[0].mbs[entry]!=0)     /* must extend it */
        for (arg=0; arg<Cons[entry].arity; arg++)
          Cons[entry].Fspecs[arg].mbs[fun]=1;

  for (fun=0; fun<NumF+1; fun++)            /* recount set entries in Fspecs */
    for (arg=0; arg<Cons[fun].arity; arg++)
    { Cons[fun].Fspecs[arg].numF=0;
      Cons[fun].Fspecs[arg].numT=0;
      for (entry=0; entry<NumF; entry++)
        if (Cons[fun].Fspecs[arg].mbs[entry]!=0)
          Cons[fun].Fspecs[arg].numF++;
      for (; entry<NumF+NumT; entry++)
        if (Cons[fun].Fspecs[arg].mbs[entry]!=0)
          Cons[fun].Fspecs[arg].numT++;
    }
}

static void generateMST(void)
	/* create MST_czj from the Fspecs part (ie F-intensive) of Cons */
	/* mbs/wheels/weights are not allocated except for */
	/*   MST_czj[*][*][NumTypes], which represent type-unconstrained */
	/*   mutation sets - here weights/wheels are set to default */
{ int f, a, e, k, t;
  char buf[BUFSIZ];
  MST_czj=(MST_czj_t)getVec((size_t)(NumF+1),sizeof(mutSet_czj_t**)); 
  for (f=0; f<NumF; f++)                         /* set all type I functions */
  { MST_czj[f]=(mutSet_czj_t**)getVec((size_t)fset[0].cset[f].arity,sizeof(mutSet_czj_t*));
    for (a=0; a<fset[0].cset[f].arity; a++)
    { MST_czj[f][a]=(mutSet_czj_t*)getVec((size_t)(NumTypes+1),sizeof(mutSet_czj_t));
      for (t=0; t<NumTypes; t++)
      { MST_czj[f][a][t].numF=0;
        MST_czj[f][a][t].numT=0;
        MST_czj[f][a][t].numFT=0;
        MST_czj[f][a][t].areFs=0;
        MST_czj[f][a][t].areTs=0;
        MST_czj[f][a][t].mbs=NULL;
        MST_czj[f][a][t].wheel=NULL;
        MST_czj[f][a][t].weights=NULL;
      }
      MST_czj[f][a][NumTypes].numF=NumF-Cons[f].Fspecs[a].numF;
      MST_czj[f][a][NumTypes].numT=NumT-Cons[f].Fspecs[a].numT;
      MST_czj[f][a][NumTypes].numFT=MST_czj[f][a][NumTypes].numF+MST_czj[f][a][NumTypes].numT;
      if (MST_czj[f][a][NumTypes].numFT==0)
      { sprintf(buf,"Both sets empty for function '%s' arg %d",
                fset[0].cset[f].string,a);
        error(buf);
      }
      MST_czj[f][a][NumTypes].mbs=(int*)getVec((size_t)(MST_czj[f][a][NumTypes].numFT),sizeof(int));
      MST_czj[f][a][NumTypes].weights=(double*)getVec((size_t)(NumF+NumT),sizeof(double));
      MST_czj[f][a][NumTypes].wheel=(double*)getVec((size_t)(MST_czj[f][a][NumTypes].numFT),sizeof(double));
      for (e=0,k=0; k<NumF+NumT; k++)
        if (Cons[f].Fspecs[a].mbs[k]==0)
        { MST_czj[f][a][NumTypes].weights[k]=1.0;
          MST_czj[f][a][NumTypes].wheel[e]= (e==0) ?
                                           MST_czj[f][a][NumTypes].weights[k] :
                                            MST_czj[f][a][NumTypes].wheel[e-1]+
                                             MST_czj[f][a][NumTypes].weights[k];
          MST_czj[f][a][NumTypes].mbs[e]=k;
          e++;
        }
        else
          MST_czj[f][a][NumTypes].weights[k]= -1.0;
      MST_czj[f][a][NumTypes].areFs= !!MST_czj[f][a][NumTypes].numF;
      MST_czj[f][a][NumTypes].areTs= !!MST_czj[f][a][NumTypes].numT;
    }
  }
  MST_czj[NumF]=(mutSet_czj_t**)getVec((size_t)1,sizeof(mutSet_czj_t*));
  MST_czj[NumF][0]=(mutSet_czj_t*)getVec((size_t)(NumTypes+1),sizeof(mutSet_czj_t));
  for (t=0; t<NumTypes; t++)
  { MST_czj[NumF][0][t].numF=0;
    MST_czj[NumF][0][t].numT=0;
    MST_czj[NumF][0][t].numFT=0;
    MST_czj[NumF][0][t].areFs=0;
    MST_czj[NumF][0][t].areTs=0;
    MST_czj[NumF][0][t].mbs=NULL;
    MST_czj[NumF][0][t].wheel=NULL;
    MST_czj[NumF][0][t].weights=NULL;
  }
  MST_czj[NumF][0][NumTypes].numF=NumF-Cons[NumF].Fspecs[0].numF;
  MST_czj[NumF][0][NumTypes].numT=NumT-Cons[NumF].Fspecs[0].numT;
  MST_czj[NumF][0][NumTypes].numFT=MST_czj[NumF][0][NumTypes].numF+MST_czj[NumF][0][NumTypes].numT;
  if (MST_czj[NumF][0][NumTypes].numFT==0)
    error("Both Root sets empty - no valid programs exist");
  MST_czj[NumF][0][NumTypes].mbs=(int*)getVec((size_t)(MST_czj[NumF][0][NumTypes].numFT),sizeof(int));
  MST_czj[NumF][0][NumTypes].weights=(double*)getVec((size_t)(NumF+NumT),sizeof(double));
  MST_czj[NumF][0][NumTypes].wheel=(double*)getVec((size_t)(MST_czj[NumF][0][NumTypes].numFT),sizeof(double));
  for (e=0,k=0; k<NumF+NumT; k++)
    if (Cons[NumF].Fspecs[0].mbs[k]==0)
    { MST_czj[NumF][0][NumTypes].mbs[e]=k;
      MST_czj[NumF][0][NumTypes].weights[k]=1.0;
      MST_czj[NumF][0][NumTypes].wheel[e]= (e==0) ?
            MST_czj[NumF][0][NumTypes].weights[k] :
            MST_czj[NumF][0][NumTypes].wheel[e-1]+MST_czj[NumF][0][NumTypes].weights[k];
      e++;
    }
    else
      MST_czj[NumF][0][NumTypes].weights[k]= -1.0;
  MST_czj[NumF][0][NumTypes].areFs= !!MST_czj[NumF][0][NumTypes].numF;
  MST_czj[NumF][0][NumTypes].areTs= !!MST_czj[NumF][0][NumTypes].numT;
}

static int read1Type(void)
        /* read one type, a valid name from TypeNames, return its index */
{ int i;
  char buf[BUFSIZ];
  char sep[]=" ,;\n";
  char *p;
  if (fgets(buf,sizeof(buf),inputFP)==NULL)
    error("eof in reading types");
  if ((p=strtok(buf,sep))==NULL)
    error("must have a type name");
  i=typeNumber(p);
  if (i<0)
    error("invalid type name");
  return(i);
} 

static int *read1TypeVec(int fun, int numA)
        /* read one context specification for function fun of numA arguments */
        /* into its allocated storage */
        /* return NULL if no more, else return the allocated storage */
{ int i;
  int *c;
  char buf[BUFSIZ];
  char sep[]=" ,;\n";
  char *p;
  printf("Specs for '%s' [%d arg and one ret types /<ENTER> for no more]\n\t:",
         fset[0].cset[fun].string,numA);
  if (fgets(buf,BUFSIZ,inputFP)==NULL)
    error("eof on type information");
  if ((p=strtok(buf,sep))==NULL)
    return(NULL);
  c=(int*)getVec((size_t)(numA+1),sizeof(int));
  for (i=0; i<numA+1; i++)
  { if (p==NULL)
      error("too few types");
    if ((c[i]=typeNumber(p))<0)
      error("wrong type name");
    p=strtok(NULL,sep);
  }
  return(c);
}

static int verify1TypeVec(int **typeVecs,int numA, int which)
	/* verify that type vector number which is compatible and no repeated*/
	/* with the previous type vectors; return 1 if ok */
/* NOTE: compatibility not checked at the moment */
{ int i, j, diff;
  for (i=0; i<which; i++)
  { diff=0;
    for (j=0; j<numA+1; j++)
      if (typeVecs[i][j]!=typeVecs[which][j])
        diff=1;
    if (diff==0)
      return(0);
  }
  return(1);
}

static void readTypesSetTP(void)
	/* read type info, allocate/init NumTypes, TypeNames, TP_czj */
{ int i,j,k,m;
  char buf[BUFSIZ];
  char sep[]=" ,;\n";
  char *p;
  printf("\n\nReading Type information...\n\n");
  printf("\nDefault is a single 'generic' type. Accept? [0 to change]: ");
  fscanf(inputFP,"%d",&i);
  fgets(buf,BUFSIZ,inputFP);
  if (i)
  { NumTypes=1;
    TypeNames=(char**)getVec((size_t)1,sizeof(char**));
    TypeNames[0]="generic";
  }
  else
  { printf("List type names: ");
    if (fgets(buf,BUFSIZ,inputFP)==NULL)
      error("failed reading types");
    p=strtok(buf,sep);
    if (p==NULL)
      error("failed reading types");
    else
    { while (p!=NULL)
      { for (i=0; i<NumTypes; i++)
          if (!strcmp(TypeNames[i],p))
          { warning("type name repeated (rejected)");
            continue;
          }
        i=strlen(p);
        TypeNames=(char**)getMoreVec(TypeNames,sizeof(char*)*(NumTypes+1));
        TypeNames[NumTypes]=(char*)getVec((size_t)(i+1),sizeof(char));
        strcpy(TypeNames[NumTypes],p);
        p=strtok(NULL,sep);
        NumTypes++;
      }
    }
  }                                 /* TypeNames allocated, NumTypes updated */

  TP_czj=(TP_czj_t)getVec((size_t)(NumFT+1),sizeof(oneTP_czj_t));
  for (i=0; i<NumF; i++)                          /* first process functions */
  { TP_czj[i].f.numA=fset[0].cset[i].arity;
    if (NumTypes==1)             /* the generic case or just one type anyway */
    { TP_czj[i].f.typeVecs=(int**)getVec((size_t)1,sizeof(int*));
      TP_czj[i].f.typeVecs[0]=
                        (int*)getVec((size_t)(TP_czj[i].f.numA+1),sizeof(int));
      TP_czj[i].f.numTypeVecs=1;
      for (j=0; j<TP_czj[i].f.numA+1; j++)
        TP_czj[i].f.typeVecs[0][j]=0;                /* just the only type */
    }
    else 
    { int *vec;
      j=0;
      while(1)
      { if ((vec=read1TypeVec(i,TP_czj[i].f.numA))==NULL)
          if (j==0)
            error("must have at least one valid type vector");
          else
          { TP_czj[i].f.numTypeVecs=j;
            break;                                  /* at least one, no more */
          }
        TP_czj[i].f.typeVecs= (int**)getMoreVec(TP_czj[i].f.typeVecs,sizeof(int*)*(j+1));
        TP_czj[i].f.typeVecs[j]=vec;
        if (verify1TypeVec(TP_czj[i].f.typeVecs,TP_czj[i].f.numA,j))
          j++;
        else
        { free(TP_czj[i].f.typeVecs[j]);
          warning("type vector rejected");
        }
      }
    }
                                       /* now make indexes for this function */
    TP_czj[i].f.indexes= (typesIndexes_t*)getVec((size_t)NumTypes,sizeof(typesIndexes_t));
    for (j=0; j<NumTypes; j++)
    { m=0;
      for (k=0; k<TP_czj[i].f.numTypeVecs; k++)
        if (TP_czj[i].f.typeVecs[k][TP_czj[i].f.numA]==j)
          m++;
      TP_czj[i].f.indexes[j].len=m;
      if (m==0)
        TP_czj[i].f.indexes[j].indexes=NULL;
      else
      { TP_czj[i].f.indexes[j].indexes=(int*)getVec((size_t)m,sizeof(int));
        for (m=0,k=0; k<TP_czj[i].f.numTypeVecs; k++)
          if (TP_czj[i].f.typeVecs[k][TP_czj[i].f.numA]==j)
          { TP_czj[i].f.indexes[j].indexes[m]=k;
            m++;
          }
      }
    }
  }
  //gwgnote: a terminal can only have one type
  for (i=NumF; i<NumFT; i++)                        /* now process terminals */
  { if (NumTypes==1)
      TP_czj[i].retType=0;                                  /* the only type */
    else
    { printf("Give ret type for terminal '%s': ",fset[0].cset[i].string);
      TP_czj[i].retType=read1Type();
    }
  }
  if (NumTypes==1)                                       /* now process Root */
    TP_czj[NumFT].retType=0;                                /* the only type */
  else
  { printf("Give return type for the problem: ");
    TP_czj[NumFT].retType=read1Type();
  }
}

void create_czj(void)
        /* will access global fset function table, and will allocate and
           initialize MST_czj and TF_czj */
        /* will read weights (default is all equal) */
        /* will read types (default is one 'generic') */
        /* Must be called after fset is created and ordered,
           but before initializing the population */
{ int what=0;
  NumF=fset[0].function_count;                                      /* |F_I| */
  NumT=fset[0].terminal_count;                           /* |F_II| + |F_III| */
  NumFT=NumF+NumT;

  buildInterface();                              /* added for new interface */

  displayHeader();
  TypeNames=NULL;
  NumTypes=0;
  readTypesSetTP();
#if DISPLAY_TP
  printf("\nThe following types are used...\n");
  displayTP();
#endif
  readFTspecs();
#if DISPLAY_CONSTRAINTS
  printf("\nRead the following constraints...\n");
  displayCons(1,1,1);
#endif
  generateNF();
#if DISPLAY_NF
  printf("\nThe normal constraints are...\n");
  displayCons(1,1,1);
#endif
  generateMST();
#if DISPLAY_MST
  printf("\nThe following untyped mutation sets are used...\n");
  displayMST(1,1,1); 
#endif
  readWeightsSetWheels();
  finishRootWeight();
  constrainTypes();
#if DISPLAY_MST
  if (NumTypes>1)
  { printf("\nThe following typed mutation sets are used...\n");
    displayMST(1,1,1);
  }
#endif
  printf("Send 1 to continue, anything else to quit cgp-lil-gp: ");
  fscanf(inputFP,"%d",&what);
  if (what!=1)
    exit(1);
  printf("\n\n");
  //closeInterface(); //gwg nonexistent function
}

static int spinWheel(int startI, int stopI, double *wheel)
/* spin the wheel returning an index between startI and stopI inclusively,
   with probability proportional to wheel allocation (roulette) */
{ double mark,begining;
  begining=startI ? wheel[startI-1] : 0;
  mark=begining+random_double()*(wheel[stopI]-begining);
  while (mark > wheel[startI])
      startI++;
  return(startI);
}

int random_F_czj(void)
/* return a random type I index from fset, but which appear in the */
/*    mutation set for Function_czj/Argument_czj/Type_czj */
/* if the set is empty, call random_FT_czj() */
/* NOTE: set is considered empty if numF==0 or each weight is <MINWGHT+SMALL */
/*   (areFs==0) */
{ int randIndex;
  randIndex=MST_czj[Function_czj][Argument_czj][Type_czj].numF;
  if (randIndex==0 || MST_czj[Function_czj][Argument_czj][Type_czj].areFs==0)
    return(random_FT_czj());    
  randIndex=spinWheel(0,randIndex-1,MST_czj[Function_czj][Argument_czj][Type_czj].wheel);
  return MST_czj[Function_czj][Argument_czj][Type_czj].mbs[randIndex];
}
 
int random_T_czj(void)
/* as random_F_czj, except that extract members of T */
{ int randIndex;
  if (MST_czj[Function_czj][Argument_czj][Type_czj].numT==0 ||
      MST_czj[Function_czj][Argument_czj][Type_czj].areTs==0)
    return(random_FT_czj());           
  randIndex=spinWheel(MST_czj[Function_czj][Argument_czj][Type_czj].numF,
                      MST_czj[Function_czj][Argument_czj][Type_czj].numFT-1,
                      MST_czj[Function_czj][Argument_czj][Type_czj].wheel); 
  return MST_czj[Function_czj][Argument_czj][Type_czj].mbs[randIndex]; 
}

int random_FT_czj(void)
        /* return a random type I/II/III index from fset, but which appear in
           the mutation set for Function_czj/Argument_czj/Type_czj */
{ int randIndex;
  if (MST_czj[Function_czj][Argument_czj][Type_czj].numFT==0)
    error("both set empty");
  if (MST_czj[Function_czj][Argument_czj][Type_czj].areFs==0 &&
      MST_czj[Function_czj][Argument_czj][Type_czj].areTs==0)
    error("both sets should not have empty weights");
  randIndex=spinWheel(0,MST_czj[Function_czj][Argument_czj][Type_czj].numFT-1,
                      MST_czj[Function_czj][Argument_czj][Type_czj].wheel);
  return MST_czj[Function_czj][Argument_czj][Type_czj].mbs[randIndex];
} 

static int markXNodes_recurse_czj( lnode **t )
/* assume Function_czj and Argument_czj are set to indicate dest point */
/* mark and count all feasible source nodes for crossover in tree */
/* marking is done with the corresponding weights w/r to dest parent */
/*   and wheel values are accumulated */
/* clear all other marking weights and wheel values to 0 */
/* sum the weights of feasible internal/external nodes in WghtsInt/WghtsWxt */
/* return the number of marked nodes */
/* NOTE: wheel entry may be the same as that of the last node if this node */
/*   is infeasible -> this will ensure that this node is not selected later */
{ function *f = (**t).f;
  float *wheelExt_czj=&((**t).wheelExt_czj);
  float *wheelInt_czj=&((**t).wheelInt_czj);
  int j;
  double wght=0;
  int total;
  int vector=(**t).typeVec_czj;

  ++*t;                              /* step the pointer over the function. */

  if ( f->arity == 0 )                                    /* it is external */
  { if (f->ephem_gen)
      ++*t;                                           /* etra value to skip */
    wght=MST_czj[Function_czj][Argument_czj][Type_czj].weights[f->index];
    if (wght<(MINWGHT+SMALL)  || TP_czj[f->index].retType!=Type_czj)
      total=0;               /* not in this mutation set or do not use */
    else
    { WghtsExt+=wght;
      total=1;
    }
    *wheelInt_czj=WghtsInt;
    *wheelExt_czj=WghtsExt;
    return total;
  }
  switch (f->type)                           /* here only for internal nodes */
  { case FUNC_DATA: case EVAL_DATA:
      wght=MST_czj[Function_czj][Argument_czj][Type_czj].weights[f->index];
      if (wght<(MINWGHT+SMALL) || Type_czj!=
                  TP_czj[f->index].f.typeVecs[vector][TP_czj[f->index].f.numA])
        total=0;  /* not in this mutation set or not the right instance  */
      else
      { WghtsInt+=wght;
        total=1;
      }
      *wheelInt_czj=WghtsInt;
      *wheelExt_czj=WghtsExt;
      for (j=0; j<f->arity; ++j)
        total+=markXNodes_recurse_czj(t);    /* t has already been advanced */
      break;
    case FUNC_EXPR: case EVAL_EXPR:
      wght=MST_czj[Function_czj][Argument_czj][Type_czj].weights[f->index];
      if (wght<(MINWGHT+SMALL) || Type_czj!=
                  TP_czj[f->index].f.typeVecs[vector][TP_czj[f->index].f.numA])
        total=0;
      else
      { WghtsInt+=wght;
        total=1;
      }
      *wheelInt_czj=WghtsInt;
      *wheelExt_czj=WghtsExt;
      for (j=0; j<f->arity; ++j)
      { ++*t;                   /* skip the pointer over the skipsize node. */
        total+=markXNodes_recurse_czj(t);
      }
      break;
  } /* switch */
  return total;
}

int markXNodes_czj( lnode *data )
/* assume Function/Argument/Type_czj are set to indicate dest point */
/* mark all nodes in tree which are feasible sources with their wghts */
/*   while contructing the wheels for internal and external nodes */
/* accummulate total wght marked in WghtsInt and WghtsExt */
/*   for the internal and the external nodes, respectively */
/* return the number of marked nodes */
{ lnode *t=data;
  WghtsInt=0;
  WghtsExt=0;
  return markXNodes_recurse_czj (&t);
}

int markXNodesNoRoot_czj( lnode *data )
/* works like markXNodes_czj, except that it ignores the root */
{
  lnode **t=&data;
  function *f;
  float *wheelExt_czj=&((**t).wheelExt_czj);
  float *wheelInt_czj=&((**t).wheelInt_czj);
  int j;
  int total;

  f = (**t).f;
  ++*t;                              /* step the pointer over the function. */
  total=0;
  WghtsInt=0;
  WghtsExt=0;
  *wheelInt_czj=0;
  *wheelExt_czj=0;

  if ( f->arity == 0 )                                    /* it is external */
    return 0;
  switch (f->type)                           /* here only for internal nodes */
  { case FUNC_DATA: case EVAL_DATA:
      for (j=0; j<f->arity; ++j)
        total+=markXNodes_recurse_czj(t);    /* t has already been advanced */
      break;
    case FUNC_EXPR: case EVAL_EXPR:
      for (j=0; j<f->arity; ++j)
      { ++*t;                   /* skip the pointer over the skipsize node. */
        total+=markXNodes_recurse_czj(t);
      }
      break;
  } /* switch */
  return total;
}

static lnode *getSubtreeMarked_recurse_czj(lnode **t, double mark)
/* assume feasible internal and external nodes are marked with wheel values */
/*   and 'mark' determines which wheel entry is used */
/* this function spins the wheel looking for any node */
{ function *f = (**t).f;
  float *wheelExt_czj=&((**t).wheelExt_czj);
  float *wheelInt_czj=&((**t).wheelInt_czj);
  lnode *r;
  int i;

  if (mark < (*wheelExt_czj + *wheelInt_czj))      
    return *t;                 /* this might be either internal or external */
  ++*t;                                              /* move t to next node */
  if (f->arity==0)
  { if (f->ephem_gen)
      ++*t;                                /* skip over the terminal nodes. */
    return NULL;                                          /* not found here */
  }
  switch (f->type)
  { case FUNC_DATA: case EVAL_DATA:
      for (i=0; i<f->arity; i++)
      { r=getSubtreeMarked_recurse_czj(t,mark);
        if (r!=NULL)
          return r;                                      /* subtree found */
      }
      break;
    case FUNC_EXPR: case EVAL_EXPR:
      for (i=0; i<f->arity; i++)
      { ++*t;
        r=getSubtreeMarked_recurse_czj(t,mark);
        if (r!=NULL)
          return r;
      }
      break;
  }
  return NULL;
}

static lnode *getSubtreeMarkedInt_recurse_czj(lnode **t, double mark)
/* same as getSubtreeMarked_recurse_czj except look only internal nodes */
{ function *f = (**t).f;
  float *wheelInt_czj=&((**t).wheelInt_czj);
  lnode *r;
  int i;

  if (f->arity==0)                               /* it is external, skip it */
  { ++*t; 
    if (f->ephem_gen)
      ++*t; 
    return NULL;
  }
  if (mark < *wheelInt_czj)                           /* return this node */
      return *t;
  ++*t;                                              /* move t to next node */
  switch (f->type)
  { case FUNC_DATA: case EVAL_DATA:
      for (i=0; i<f->arity; i++)
      { r=getSubtreeMarkedInt_recurse_czj(t,mark);
        if (r!=NULL)
          return r;                                      /* subtree found */
      }
      break;
    case FUNC_EXPR: case EVAL_EXPR:
      for (i=0; i<f->arity; i++)
      { ++*t;
        r=getSubtreeMarkedInt_recurse_czj(t,mark);
        if (r!=NULL)
          return r;
      }
      break;
  }
  return NULL;
}

static lnode *getSubtreeMarkedExt_recurse_czj(lnode **t, double mark)
/* same as getSubtreeMarked_recurse_czj except look only external nodes */
{ function *f = (**t).f;
  float *wheelExt_czj=&((**t).wheelExt_czj);
  lnode *r;
  int i;

  if (f->arity==0)                           /* it is external, check it out */
  { if (mark<*wheelExt_czj)                            /* return this node */
        return *t;
    ++*t; 
    if (f->ephem_gen)
      ++*t;
    return NULL;
  }
  ++*t;                        /* if here than it is an internal node - skip */
  switch (f->type)
  { case FUNC_DATA: case EVAL_DATA:
      for (i=0; i<f->arity; i++)
      { r=getSubtreeMarkedExt_recurse_czj(t,mark);
        if (r!=NULL)
          return r;                                         /* subtree found */
      }
      break;
    case FUNC_EXPR: case EVAL_EXPR:
      for (i=0; i<f->arity; i++)
      { ++*t;
        r=getSubtreeMarkedExt_recurse_czj(t,mark);
        if (r!=NULL)
          return r;
      }
      break;
  }
  return NULL;
}

lnode *getSubtreeMarked_czj(lnode *data, int intExt)
/* assume tree is filled with both internal and external wheels */
/*   accummulated in WghtsInt and WghtsExt and at least one node is feasible */
/* return a node with selection prob. proportional to its weight */
/* if no nodes found return NULL */
/* if intExt==0 then looking for both internal and external */
/* if intExt==1 then looking for internal, and switch to external only if */
/*   no internal marked */
/* the opposite for intExt==2 */
{ lnode *el = data;
  if (intExt==0 || intExt==1 && WghtsInt<SMALL ||
      intExt==2 && WghtsExt<SMALL)
    return              /* override 'intExt' parameter and look for any node */
      getSubtreeMarked_recurse_czj(&el,(WghtsInt+WghtsExt)*random_double());
  if (intExt==1)
    return
      getSubtreeMarkedInt_recurse_czj(&el,WghtsInt*random_double());
  return 
    getSubtreeMarkedExt_recurse_czj(&el,WghtsExt*random_double());
}

static int verify_tree_czj_recurse ( lnode **t )
/* return #times the tree pointed by t violates MST_czj constraints */
/*   note: *t always points at a function node here: save the function */
{ function *f = (**t).f;
  int i;
  int total=0;
  int vecNum;

  vecNum=(**t).typeVec_czj;
  if (MST_czj[Function_czj][Argument_czj][Type_czj].weights[f->index]<0 ||
      f->index<NumF && Type_czj !=
                  TP_czj[f->index].f.typeVecs[vecNum][TP_czj[f->index].f.numA])
    total++;                                                     /* invalid */
  ++*t;                              /* step the pointer over the function. */
  if (f->arity==0)
  { if (f->ephem_gen)
      ++*t;    /* skip the pointer over the ERC value if this node has one. */
    return total; 
  }
  switch (f->type)
  { case FUNC_DATA: case EVAL_DATA:
      for (i=0; i<f->arity; ++i)
      { Function_czj = f->index;
        Argument_czj = i;
        Type_czj=TP_czj[Function_czj].f.typeVecs[vecNum][Argument_czj];
        total+=verify_tree_czj_recurse (t);
      }
      break;
    case FUNC_EXPR: case EVAL_EXPR:
      for (i=0; i<f->arity; ++i)
      { ++*t;                 /* skip the pointer over the skipsize node. */
        Function_czj = f->index;
        Argument_czj = i;
        Type_czj=TP_czj[Function_czj].f.typeVecs[vecNum][Argument_czj];
        total+=verify_tree_czj_recurse (t);
      }
      break;
  } /* switch */
  return total;
}

int verify_tree_czj ( lnode *tree )
/* return #times the tree pointed by tree violates MS_czj */
{ lnode *t = tree;
  int f_save=Function_czj;
  int a_save=Argument_czj;
  int t_save=Type_czj;
  int total;

  Function_czj = fset[0].function_count;
  Argument_czj = 0;                                  /* start from the Root */
  Type_czj=TP_czj[NumFT].retType;
  total=verify_tree_czj_recurse (&t);
  Function_czj=f_save;
  Argument_czj=a_save;
  Type_czj=t_save;
  return total;
}
