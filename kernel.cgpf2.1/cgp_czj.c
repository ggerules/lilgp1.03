/* cgp_czj.c version 2.0, for function- anada data type-based constraints */
/* using lil-gp 1.02 */
/* based on cgp1.1, which allows fixed weights for mutation sets */

/* NOTE: function number, which is identical to its index in fset, is used
   as hash index in MST_czj - lats entry (index=NumF) is for the Root */
/* NOTE: TF_czj uses function and terminal hash index identical to its
   index in fset - last entry (index=NumFT) is for the Root */
/* NOTE: types are processed by indexes too; these idexes are those in
   TypeNames; when types are not used, a single type='generic' is used */
/* gwg: modifications for making this work with ADFS */

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

#define funcTermName(tr, i) fset[tr].cset[(i)].string
#define funcArity(tr, i) fset[tr].cset[(i)].arity

#define SMALL 0.000000001                        /* delta for double compare */
#define MINWGHT 0.00001           /* min. maintanble wght for a member of MS */

char dbgtext[BUFSIZ];

const int RepeatsSrc_czj=5;    /* max repeats in crossover on infeasible src */
const int RepeatsBad_czj=5;                  /* same on bad (size) offspring */

MST_czj_t MST_czj;                    /* the global table with mutation sets */
TP_czj_t TP_czj;                      /* global dynamic table with type info */

extern int quietmode;

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
//static int treeCnt;                                            /* tree count */
//static int NumF;                                    /* num functions in fset */
//static int NumT;                         /* num typeII/III functions in fset */
//static int NumFT;                                               /* NumF+NumT */
//static int NumTypes;                                      /* number of types */
//gwgfix: need to change into an array WghtsExt per tree?
static float WghtsExt;    /* sum of wghts of cross-feasible leaves of a tree */
static float WghtsInt;                        /* same for the internal nodes */
//static char **TypeNames;         /* array of NumTypes ragged dynamic strings */

typedef int *specArr_t; /* dynamic for NumF+NumT; array[i]==1 indicates that
                             function indexed i is present in a set */

extern Spec_t **FTp;

typedef struct
{
  int numF;                         /* number of F set elements in specArr */
  int numT;
  specArr_t mbs;
} specArrArg_t;
typedef specArrArg_t *specArrs_t;     /* dynamic array of specArrArg_t */

typedef struct
{
  int arity;
  specArrs_t Tspecs;    /* dynamic array of ptrs to specArr_t for Tspecs */
  specArrs_t Fspec;                                       /* just one here */
  specArrs_t Fspecs;
} constraint_t;                     /* NOTE: Root will use Tspecs and Fspecs */

static constraint_t** Cons;/* dynamic array for functions and Root */

/****************************************/

/**************** a couple of utility functions */

static void errorIndir(const char *message, int line, char *file)
{
  fprintf(stderr,"\nERROR \"%s\":%d : %s\n",file,line,message);
  exit(1);
}

static void warningIndir(const char *message, int line, char *file)
{
  fprintf(stdout,"\nWarning \"%s\":%d : %s\n",file,line,message);
}

static void *getVec(size_t numEls, size_t bytesPerEl)
/* allocate an array from the heap, exit on failure */
{
  void *p;
  if (numEls<1 || bytesPerEl<1)
    error("storage allocation missuse");
  p=calloc(numEls,bytesPerEl);
  if (p==NULL)
    error("storage allocation failure");
  return p;
}

static void *getMoreVec(void *oldP, size_t bytes)
/* reallocate an array from the heap, exit on failure */
{
  void *p;
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

#if 0 // gwgnote: function never used
static int member(int e, int *vec, int start, int stop)
/* return 1 if e is found in vec between start and stop inclusively */
{
  int i;
  for (i=start; i<=stop; i++)
    if (vec[i]==e)
      return(1);
  return(0);
}
#endif

/*****************************************/
static int funNumber(const char* funName, int treeNumber)
/* given funName, return its index in fset[treeNumber] or -1 if not found */
{
  int i;
  for (i=0; i<fset[treeNumber].size; i++)
    if (!strcmp(funName,fset[treeNumber].cset[i].string))
      return(i);
  return(-1);
}

static void displayHeader(void)
{
  printf("\n\n\t\tWELCOME TO cgp-lilgp 3.1/1.02\n");
  printf("\n\t\tdeveloped and implemented by\n");
  printf("\tGeorge Gerules as part of Ph.D work\n");
  printf("\temailto:gwgkt2@mail.umsl.edu\n");
  printf("\tAdvisor: Cezary Z. Janikow\n");
  printf("\n\t\tBased on CGP2.1 developed by\n");
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
{
  int tr, fun, arg, entry, numF, numT, numFT;
  printf("\n\t\tCONSTRAINTS\n");
  for(tr = 0; tr < tree_count; tr++)
  {
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    numFT = numF+numT;
    for (fun=0; fun<numF; fun++)
    {
      printf("Function '%s' [#%d]:\n",fset[tr].cset[fun].string,fun);
      if (F)
      {
        printf("\tF_%s [#Fs=%d:#Ts=%d] =",fset[tr].cset[fun].string,
               Cons[tr][fun].Fspec[0].numF,Cons[tr][fun].Fspec[0].numT);
        for (entry=0; entry<numF; entry++)
          if (Cons[tr][fun].Fspec[0].mbs[entry])
            printf(" '%s'",fset[tr].cset[entry].string);
        printf(" ||");
        for (; entry<numFT; entry++)
          if (Cons[tr][fun].Fspec[0].mbs[entry])
            printf(" '%s'",fset[tr].cset[entry].string);
        printf("\n");
      }
      if (Fs)
      {
        for (arg=0; arg<Cons[tr][fun].arity; arg++)
        {
          printf("\tF_%s_%d [#Fs=%d:#Ts=%d] =",fset[tr].cset[fun].string,arg,
                 Cons[tr][fun].Fspecs[arg].numF,Cons[tr][fun].Fspecs[arg].numT);
          for (entry=0; entry<numF; entry++)
            if (Cons[tr][fun].Fspecs[arg].mbs[entry])
              printf(" '%s'",fset[tr].cset[entry].string);
          printf(" ||");
          for (; entry<numFT; entry++)
            if (Cons[tr][fun].Fspecs[arg].mbs[entry])
              printf(" '%s'",fset[tr].cset[entry].string);
          printf("\n");
        }
      }
      if (Ts)
      {
        for (arg=0; arg<Cons[tr][fun].arity; arg++)
        {
          printf("\tT_%s_%d [#Fs=%d:#Ts=%d] =",fset[tr].cset[fun].string,arg,
                 Cons[tr][fun].Tspecs[arg].numF,Cons[tr][fun].Tspecs[arg].numT);
          for (entry=0; entry<numF; entry++)
            if (Cons[tr][fun].Tspecs[arg].mbs[entry])
              printf(" '%s'",fset[tr].cset[entry].string);
          printf(" ||");
          for (; entry<numFT; entry++)
            if (Cons[tr][fun].Tspecs[arg].mbs[entry])
              printf(" '%s'",fset[tr].cset[entry].string);
          printf("\n");
        }
      }
    }
    printf("Root:%d\n",fun);
    if (Fs)
    {
      printf("\tF_Root [#Fs=%d:#Ts=%d] = ",
             Cons[tr][numF].Fspecs[0].numF,Cons[tr][numF].Fspecs[0].numT);
      for (entry=0; entry<numF; entry++)
        if (Cons[tr][numF].Fspecs[0].mbs[entry])
          printf(" '%s'",fset[tr].cset[entry].string);
      printf(" ||");
      for (; entry<numFT; entry++)
        if (Cons[tr][numF].Fspecs[0].mbs[entry])
          printf(" '%s'",fset[tr].cset[entry].string);
      printf("\n");
    }
    if (Ts)
    {
      printf("\tT_Root [#Fs=%d:#Ts=%d] = ",
             Cons[tr][numF].Tspecs[0].numF,Cons[tr][numF].Tspecs[0].numT);
      for (entry=0; entry<numF; entry++)
        if (Cons[tr][numF].Tspecs[0].mbs[entry])
          printf(" '%s'",fset[tr].cset[entry].string);
      printf(" ||");
      for (; entry<numFT; entry++)
        if (Cons[tr][numF].Tspecs[0].mbs[entry])
          printf(" '%s'",fset[tr].cset[entry].string);
      printf("\n");
    }
  }
}

static void displayMST(int uncMs, int wheel, int weight)
/* display mutation sets from MST_czj */
/* if uncMs the include unconstrained mut set */
/* if wheel/weight then invclude wheel/weights */
{
  int tr, i,j,k,t, numF, numT, numFT, NumTypes;
  printf("\n");
  for(tr = 0; tr < tree_count; tr++)
  {
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    numFT = numF+numT;
    NumTypes=FTp[tr]->TypCount;
    for (i=0; i<numF; i++)
    {
      printf("Function '%s': arity %d \n",
             fset[tr].cset[i].string,fset[tr].cset[i].arity);
      for (j=0; j<fset[tr].cset[i].arity; j++)
      {
        printf("\tArgument %d\n",j);
        for (t=0; t<NumTypes; t++)
          if (MST_czj[tr][i][j][t].numFT!=0)             /* mutation set not empty */
          {
            printf("\t\tType '%s'\n",funcTermName(tr,t));
            printf("\t\t\tF [%d members] =",MST_czj[tr][i][j][t].numF);
            for (k=0; k<MST_czj[tr][i][j][t].numF; k++)
              printf(" '%s'",fset[tr].cset[MST_czj[tr][i][j][t].mbs[k]].string);
            printf("\n\t\t\tT [%d members] =",MST_czj[tr][i][j][t].numT);
            for (k=0; k<MST_czj[tr][i][j][t].numT; k++)
              printf(" '%s'",fset[tr].cset[MST_czj[tr][i][j][t].
                                           mbs[MST_czj[tr][i][j][t].numF+k]].string);
            if (wheel)
            {
              printf("\n\t\t\tWheel: F is %s and T is %s\n\t\t\t",
                     MST_czj[tr][i][j][t].areFs ? "used":"not used",
                     MST_czj[tr][i][j][t].areTs ? "used":"not used");
              for (k=0; k<MST_czj[tr][i][j][t].numFT; k++)
                printf(" %.6f",MST_czj[tr][i][j][t].wheel[k]);
            }
            if (weight)
            {
              printf("\n\t\t\tWeights: F is %s and T is %s\n\t\t\t",
                     MST_czj[tr][i][j][t].areFs ? "used":"not used",
                     MST_czj[tr][i][j][t].areTs ? "used":"not used");
              for (k=0; k<numFT; k++)
                printf(" %.6f",MST_czj[tr][i][j][t].weights[k]);
            }
            printf("\n");
          }
        if (uncMs)
        {
          printf("\t\tType unconstrained mutation set\n");
          printf("\t\t\tF [%d members] =",MST_czj[tr][i][j][NumTypes].numF);
          for (k=0; k<MST_czj[tr][i][j][NumTypes].numF; k++)
            printf(" '%s'",fset[tr].cset[MST_czj[tr][i][j][NumTypes].mbs[k]].string);
          printf("\n\t\t\tT [%d members] =",MST_czj[tr][i][j][NumTypes].numT);
          for (k=0; k<MST_czj[tr][i][j][NumTypes].numT; k++)
            printf(" '%s'",fset[tr].cset[MST_czj[tr][i][j][NumTypes].
                                         mbs[MST_czj[tr][i][j][NumTypes].numF+k]].string);
          if (wheel)
          {
            printf("\n\t\t\tWheel: F is %s and T is %s\n\t\t\t",
                   MST_czj[tr][i][j][t].areFs ? "used":"not used",
                   MST_czj[tr][i][j][t].areTs ? "used":"not used");
            for (k=0; k<MST_czj[tr][i][j][t].numFT; k++)
              printf(" %.6f",MST_czj[tr][i][j][t].wheel[k]);
          }
          if (weight)
          {
            printf("\n\t\t\tWeights: F is %s and T is %s\n\t\t\t",
                   MST_czj[tr][i][j][t].areFs ? "used":"not used",
                   MST_czj[tr][i][j][t].areTs ? "used":"not used");
            for (k=0; k<numFT; k++)
              printf(" %.6f",MST_czj[tr][i][j][t].weights[k]);
          }
          printf("\n");
        }
      }
    }
    printf("Root:\n");
    for (t=0; t<NumTypes; t++)
      if (MST_czj[tr][numF][0][t].numFT!=0)
      {
        printf("\t\tType '%s'\n",funcTermName(tr,t));
        printf("\t\t\tF [%d members] =",MST_czj[tr][numF][0][t].numF);
        for (k=0; k<MST_czj[tr][numF][0][t].numF; k++)
          printf(" '%s'",fset[tr].cset[MST_czj[tr][numF][0][t].mbs[k]].string);
        printf("\n\t\t\tT [%d members] =",MST_czj[tr][numF][0][t].numT);
        for (k=0; k<MST_czj[tr][numF][0][t].numT; k++)
          printf(" '%s'",fset[tr].cset[MST_czj[tr][numF][0][t].
                                       mbs[MST_czj[tr][numF][0][t].numF+k]].string);
        if (wheel)
        {
          printf("\n\t\t\tWheel: F is %s and T is %s\n\t\t\t",
                 MST_czj[tr][numF][0][t].areFs ? "used":"not used",
                 MST_czj[tr][numF][0][t].areTs ? "used":"not used");
          for (k=0; k<MST_czj[tr][numF][0][t].numFT; k++)
            printf(" %.6f",MST_czj[tr][numF][0][t].wheel[k]);
        }
        if (weight)
        {
          printf("\n\t\t\tWeights: F is %s and T is %s\n\t\t\t",
                 MST_czj[tr][numF][0][t].areFs ? "used":"not used",
                 MST_czj[tr][numF][0][t].areTs ? "used":"not used");
          for (k=0; k<numFT; k++)
            printf(" %.6f",MST_czj[tr][numF][0][t].weights[k]);
        }
        printf("\n");
      }
    if (uncMs)
    {
      printf("\t\tType unconstrained mutation set\n");
      printf("\t\t\tF [%d members] =",MST_czj[tr][numF][0][NumTypes].numF);
      for (k=0; k<MST_czj[tr][numF][0][NumTypes].numF; k++)
        printf(" '%s'",fset[tr].cset[MST_czj[tr][numF][0][NumTypes].mbs[k]].string);
      printf("\n\t\t\tT [%d members] =",MST_czj[tr][numF][0][NumTypes].numT);
      for (k=0; k<MST_czj[tr][numF][0][NumTypes].numT; k++)
        printf(" '%s'",fset[tr].cset[MST_czj[tr][numF][0][NumTypes].
                                     mbs[MST_czj[tr][numF][0][NumTypes].numF+k]].string);
      if (wheel)
      {
        printf("\n\t\t\tWheel: F is %s and T is %s\n\t\t\t",
               MST_czj[tr][numF][0][t].areFs ? "used":"not used",
               MST_czj[tr][numF][0][t].areTs ? "used":"not used");
        for (k=0; k<MST_czj[tr][numF][0][t].numFT; k++)
          printf(" %.6f",MST_czj[tr][numF][0][t].wheel[k]);
      }
      if (weight)
      {
        printf("\n\t\t\tWeights: F is %s and T is %s\n\t\t\t",
               MST_czj[tr][numF][0][t].areFs ? "used":"not used",
               MST_czj[tr][numF][0][t].areTs ? "used":"not used");
        for (k=0; k<numFT; k++)
          printf(" %.6f",MST_czj[tr][numF][0][t].weights[k]);
      }
      printf("\n");
    }
  }
}


static void displayTP(void)
{
  int i,j,k,tr, numFT, numF, numT;
  for(tr = 0; tr < tree_count; tr++)
  {
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    numFT = numF+numT;
    for (i=0; i<numF; i++)
    {
      printf("Function '%s': numArg=%d, numTypeVecs=%d\n", fset[tr].cset[i].string, TP_czj[tr][i].f.numA,TP_czj[tr][i].f.numTypeVecs);
      if (TP_czj[tr][i].f.numTypeVecs)
      {
        for (j=0; j<TP_czj[tr][i].f.numTypeVecs; j++)
        {
          printf("\tvec%d: ",j);
          for (k=0; k<TP_czj[tr][i].f.numA; k++)
            printf("%d:'%s' ",k,FTp[tr]->TypList[TP_czj[tr][i].f.typeVecs[j][k]]);
          printf("-> '%s'",FTp[tr]->TypList[TP_czj[tr][i].f.typeVecs[j][TP_czj[tr][i].f.numA]]);
          printf("\n");
        }
        for (j=0; j<FTp[tr]->TypCount; j++)
        {
          if (TP_czj[tr][i].f.indexes[j].len>0)
          {
            printf("\tType '%s' returned from vectors: ",FTp[tr]->TypList[j]);
            for (k=0; k<TP_czj[tr][i].f.indexes[j].len; k++)
              printf("%d ",TP_czj[tr][i].f.indexes[j].indexes[k]);
            printf("\n");
          }
        }
      }
    }
    for (i=numF; i<numFT; i++)
      printf("Terminal '%s': -> '%s'\n",fset[tr].cset[i].string, FTp[tr]->TypList[TP_czj[tr][i].retType]);
    printf("Root: -> '%s'\n",FTp[tr]->TypList[TP_czj[tr][numFT].retType]);
    printf("\n\n");
  }
}
#if 0
static double readMinWghtto1(const char *prompt)
/* read (0,1], and if entry < MINWGHT then set it as MINWGHT */
{
  double what;
  int res;
  printf("%s: ",prompt);
  res=fscanf(inputFP,"%lf",&what);
  if (res<1 || what >1 || what<0)
    error("failed reading weight");
  if (what<MINWGHT)
    what=MINWGHT;                           /* smaller values become minimal */
  return(what);
}
#endif

static void readWeightsSetWheels(void)
/* read weights for mutation set entries and construct wheels for the */
/*   no-type constraints only (MST_czj[*][*][NumTypes] structures */
/* assume weights for non-members are set to -1 */
/* areFs and areTs members of MST_czj are set to true if at least one */
/*   member has weight>MINWGHT */
{
  int tr, i,j,k, numF, NumTypes;
  double adjWght, what;
  int areFs, areTs;
  printf("\n\nSetting initial weights for mutation set members...\n");
  //  printf("Initial weights are all equal. Do you accept [0 to change]: ");
  //  fscanf(inputFP,"%d",&i);
  for(tr = 0; tr < tree_count; tr++ )
  {
    numF = pTS[tr].numF;
    NumTypes=FTp[tr]->TypCount;
    i = FTp[tr]->DefaultType;
    if (i)
      continue;                               /* leave inital weights and wheels */
    for (i=0; i<numF; i++)
    {
      printf("\n");
      printf("Function '%s': %d mutation set pairs\n",
             fset[tr].cset[i].string,fset[tr].cset[i].arity);
      for (j=0; j<fset[tr].cset[i].arity; j++)
      {
        areFs=0;
        areTs=0;
        printf("Argument %d:\n",j);
        //gwgfix!!!! if there are more than one type put in a for loop and increment where NumTypes is at......
        printf("\tF [%d members] =",MST_czj[tr][i][j][NumTypes].numF);
        for (k=0; k<MST_czj[tr][i][j][NumTypes].numF; k++)
          printf(" '%s'",fset[tr].cset[MST_czj[tr][i][j][NumTypes].mbs[k]].string);
        printf("\n\tT [%d members] =",MST_czj[tr][i][j][NumTypes].numT);
        for (k=0; k<MST_czj[tr][i][j][NumTypes].numT; k++)
          printf(" '%s'",fset[tr].cset[MST_czj[tr][i][j][NumTypes].mbs[
                                         MST_czj[tr][i][j][NumTypes].numF+k]].string);
        printf("\n\n\tReading the weights for type I functions...\n");
        for (k=0; k<MST_czj[tr][i][j][NumTypes].numF; k++)
        {
          printf("\tFunction '%s': ", fset[tr].cset[MST_czj[tr][i][j][NumTypes].mbs[k]].string);
          //writeFuncWeight(i, j, MST_czj[tr][i][j][NumTypes].mbs[k]);
          // FTp[tr]->Func[i].Arg[j].W[MST_czj[tr][i][j][NumTypes].mbs[k]]
          //MST_czj[tr][i][j][NumTypes].weights[MST_czj[tr][i][j][NumTypes].mbs[k]]= readMinWghtto1("give weight (0,1]");
          what = FTp[tr]->Func[i].Arg[j].W[MST_czj[tr][i][j][NumTypes].mbs[k]];
          if (what >1 || what<0)
            error("failed reading weight");
          if (what<MINWGHT)
            what=MINWGHT;                           /* smaller values become minimal */
          MST_czj[tr][i][j][NumTypes].weights[MST_czj[tr][i][j][NumTypes].mbs[k]] = what;
        }
        printf("\n\tReading the weights for type II/III terminals...\n");
        for (k=0; k<MST_czj[tr][i][j][NumTypes].numT; k++)
        {
          printf("\tTerminal '%s': ",fset[tr].cset[MST_czj[tr][i][j][ NumTypes].mbs[MST_czj[tr][i][j][NumTypes].numF+k]].string);
          //writeFuncWeight(i, j, MST_czj[tr][i][j][NumTypes].mbs[MST_czj[tr][i][j][NumTypes].numF+k]);
          // FTp[tr]->Func[i].Arg[j].W[MST_czj[tr][i][j][NumTypes].numF+k]
          //MST_czj[tr][i][j][NumTypes].weights[MST_czj[tr][i][j][NumTypes].mbs[MST_czj[tr][i][j][NumTypes].numF+k]]=readMinWghtto1("give weight (0,1]");
          what = FTp[tr]->Func[i].Arg[j].W[MST_czj[tr][i][j][NumTypes].numF+k];
          if (what >1 || what<0)
            error("failed reading weight");
          if (what<MINWGHT)
            what=MINWGHT;                           /* smaller values become minimal */
          MST_czj[tr][i][j][NumTypes].weights[MST_czj[tr][i][j][NumTypes].mbs[MST_czj[tr][i][j][NumTypes].numF+k]]=what;
        }
        /* now all non-memb weights are -1, all member weighth are in [MINWGHT..1] */
        /* now set mut wheel skipping over weights <MINWGHT+SMALL */
        for (k=0; k<MST_czj[tr][i][j][NumTypes].numFT; k++)
        {
          if (MST_czj[tr][i][j][NumTypes].weights[MST_czj[tr][i][j][NumTypes].mbs[k]] <MINWGHT+SMALL)
            adjWght=0;
          else
          {
            adjWght=
              MST_czj[tr][i][j][NumTypes].weights[MST_czj[tr][i][j][NumTypes].mbs[k]];
            if (k<MST_czj[tr][i][j][NumTypes].numF)
              areFs=1;
            else
              areTs=1;
          }
          MST_czj[tr][i][j][NumTypes].wheel[k]= (k==0) ? adjWght :
                                                MST_czj[tr][i][j][NumTypes].wheel[k-1]+adjWght;
        }
        MST_czj[tr][i][j][NumTypes].areFs=areFs;
        MST_czj[tr][i][j][NumTypes].areTs=areTs;
        if (!areFs && !areTs)
        {
          fprintf(stderr, "\tno member of f=%d arg=%d has any weight >MINWGHT\n",i,j);
          exit(1);
        }
      }
      printf("\n\n");
    }
    printf("Root:\n");
    areFs=0;
    areTs=0;
    printf("\t\tF [%d members] =",MST_czj[tr][numF][0][NumTypes].numF);
    for (k=0; k<MST_czj[tr][numF][0][NumTypes].numF; k++)
      printf(" '%s'",fset[tr].cset[MST_czj[tr][numF][0][NumTypes].mbs[k]].string);
    printf("\n\t\tT [%d members] =",MST_czj[tr][numF][0][NumTypes].numT);
    for (k=0; k<MST_czj[tr][numF][0][NumTypes].numT; k++)
      printf(" '%s'",fset[tr].cset[MST_czj[tr][numF][0][NumTypes].mbs[
                                     MST_czj[tr][numF][0][NumTypes].numF+k]].string);
    printf("\n\tReading the weights for type I functions...\n");
    for (k=0; k<MST_czj[tr][numF][0][NumTypes].numF; k++)
    {
      printf("\tFunction '%s': ", fset[tr].cset[MST_czj[tr][numF][0][NumTypes].mbs[k]].string);
      //writeRootWeight(k);
      //MST_czj[tr][numF][0][NumTypes].weights[MST_czj[tr][numF][0][NumTypes].mbs[k]]= readMinWghtto1("give weight (0,1]");
      what = FTp[tr]->WRoot[k];
      if (what >1 || what<0)
        error("failed reading weight");
      if (what<MINWGHT)
        what=MINWGHT;                           /* smaller values become minimal */
      MST_czj[tr][numF][0][NumTypes].weights[MST_czj[tr][numF][0][NumTypes].mbs[k]]=what;
    }
    printf("\n\tReading the weights for type II/III terminals...\n");
    for (k=0; k<MST_czj[tr][numF][0][NumTypes].numT; k++)
    {
      printf("\tTerminal '%s': ",fset[tr].cset[MST_czj[tr][numF][0][ NumTypes].mbs[MST_czj[tr][numF][0][NumTypes].numF+k]].string);
      //writeRootWeight(k+numF);
      //MST_czj[tr][numF][0][NumTypes].weights[MST_czj[tr][numF][0][NumTypes].mbs[MST_czj[tr][numF][0][NumTypes].numF+k]]=readMinWghtto1("give weight (0,1]");
      what = FTp[tr]->WRoot[k+numF];
      if (what >1 || what<0)
        error("failed reading weight");
      if (what<MINWGHT)
        what=MINWGHT;                           /* smaller values become minimal */
      MST_czj[tr][numF][0][NumTypes].weights[MST_czj[tr][numF][0][NumTypes].mbs[MST_czj[tr][numF][0][NumTypes].numF+k]]=what;
    }
    for (k=0; k<MST_czj[tr][numF][0][NumTypes].numFT; k++)
    {
      if (MST_czj[tr][numF][0][NumTypes].weights[
            MST_czj[tr][numF][0][NumTypes].mbs[k]]<MINWGHT+SMALL)
        adjWght=0;
      else
      {
        adjWght=MST_czj[tr][numF][0][NumTypes].weights[MST_czj[tr][numF][0][NumTypes].mbs[k]];
        if (k<MST_czj[tr][numF][0][NumTypes].numF)
          areFs=1;
        else
          areTs=1;
      }
      MST_czj[tr][numF][0][NumTypes].wheel[k]= (k==0) ? adjWght :
          MST_czj[tr][numF][0][NumTypes].wheel[k-1]+adjWght;
    }
    MST_czj[tr][numF][0][NumTypes].areFs=areFs;
    MST_czj[tr][numF][0][NumTypes].areTs=areTs;
    if (!areFs && !areTs)
      error("no member of Root sets has any 'weight>MINWGHT'");
    if (!areFs && areTs)
      warning("Root can only evolve to terminals");
    printf("\n\n");
  }
}

static void constrain1Type(int t, int tr, int numF, int numFT, mutSet_czj_t ms, mutSet_czj_t *newMs)
/* constrains ms for type t into newMs, allocates storage as needed */
{
  int e, f;
  double adjWght;
  for (e=0; e<ms.numF; e++)
  {
    f=ms.mbs[e];
    if (TP_czj[tr][f].f.indexes[t].len>0)             /* function f gives type t */
    {
      newMs->numFT++;
      newMs->mbs=(int*)getMoreVec(newMs->mbs,newMs->numFT*sizeof(int));
      newMs->wheel=(double*)getMoreVec(newMs->wheel,newMs->numFT*sizeof(double));
      newMs->mbs[newMs->numFT-1]=f;
      newMs->numF++;
    }
  }
  for (e=ms.numF; e<ms.numFT; e++)
  {
    f=ms.mbs[e];
    if (TP_czj[tr][f].retType==t)                 /* term f gives the right type */
    {
      newMs->numFT++;
      newMs->mbs=(int*)getMoreVec(newMs->mbs,newMs->numFT*sizeof(int));
      newMs->wheel=(double*)getMoreVec(newMs->wheel,newMs->numFT*sizeof(double));
      newMs->mbs[newMs->numFT-1]=f;
      newMs->numT++;
    }
  }
  if (newMs->numFT>0)
  {
    newMs->weights=(double*)getVec((size_t)numFT,sizeof(double));
    for (e=0; e<numF; e++)  /* copy weights, set to -1 those with wrong type */
    {
      if (TP_czj[tr][e].f.indexes[t].len>0)
        newMs->weights[e]=ms.weights[e];
      else
        newMs->weights[e]= -1;
    }
    for (e=numF; e<numFT; e++)
    {
      if (TP_czj[tr][e].retType==t)
        newMs->weights[e]=ms.weights[e];
      else
        newMs->weights[e]= -1;
    }

    newMs->areFs=0;
    newMs->areTs=0;
    for (e=0; e<newMs->numFT; e++)
    {
      if (newMs->weights[newMs->mbs[e]]<MINWGHT+SMALL)
        adjWght=0;
      else
      {
        adjWght=newMs->weights[newMs->mbs[e]];
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
{
  int tr, f, a, t, v, numF, numT, numFT, NumTypes;
  for(tr = 0; tr < tree_count; tr++)
  {
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    numFT = numF+numT;
    NumTypes = FTp[tr]->TypCount;
    for (f=0; f<numF; f++)
    { for (a=0; a<fset[tr].cset[f].arity; a++)
      { for (t=0; t<NumTypes; t++)
        { for (v=0; v<TP_czj[tr][f].f.numTypeVecs; v++)
          { if (TP_czj[tr][f].f.typeVecs[v][a]==t)
            { constrain1Type(t,tr, numF, numFT, MST_czj[tr][f][a][NumTypes],&MST_czj[tr][f][a][t]);
              break;
            }
          }
        }
      }
    }
    for (t=0; t<NumTypes; t++)
      if (TP_czj[tr][numFT].retType==t)
        constrain1Type(t,tr, numF, numFT, MST_czj[tr][numF][0][NumTypes],&MST_czj[tr][numF][0][t]);
  }
}

static void displayFTNames(int tr, int numF, int numT)
/* display function and terminal set */
{
  int i;
  printf("TREE: %s",FTp[tr]->treeName);
  printf("\n%d ordinary functions:\n\t",numF);
  for (i=0; i<numF; i++)
    printf("%s ",fset[tr].cset[i].string);
  printf("\n%d terminals (ordinary and ephemeral):\n\t",numT);
  for (; i<numF+numT; i++)
    printf("%s ",fset[tr].cset[i].string);
  printf("\nSeparate entries by [ ,;]\nHit <ENTER> for empty set\n");
  printf("Use function names in any order\n\n");
}

#if 0
static void displayTypeNames(void)
/* display type names */
{
  int i;
  printf("\n%d types: ",NumTypes);
  for (i=0; i<NumTypes; i++)
    printf("%s ",TypeNames[i]);
  printf("Separate entries by [ ,;]  Hit <ENTER> for empty set\n");
  printf("Use type names in any order\n\n");
}
#endif

static void read1ConSet(const char*prompt, specArrs_t setP, int max, int numF, int numT)
/* read one set from one line; max is the highest index allowed */
{
  int entry;
  char buf[BUFSIZ];
  char sep[]=" ,;\n";
  char *p;
  for (entry=0; entry<numF+numT; entry++)
    setP->mbs[entry]=0;                            /* reset set to empty */
  setP->numF=setP->numT=0;                          /* reset member counters */
  printf("%s [up to %d names] = ",prompt,max+1);
  if (fgets(buf,BUFSIZ,inputFP)==NULL)
  {
    fprintf(stderr,"ERROR: failed reading constrained\n");
    exit(1);
  }
  p=strtok(buf,sep);
  while (p!=NULL)
  {
    if ((entry=funNumber(p,0))<0)
      error("invalid function/terminal name");
    else if (entry>max)
      error("function not allowed in this set");
    else
    {
      setP->mbs[entry]=1;
      if (entry<numF)
        setP->numF++;
      else
        setP->numT++;
    }
    p=strtok(NULL,sep);
  }
}

static void set1ConSet(specArrs_t setP, int max, int numF, int numT)
{
  int entry;
  for (entry=0; entry<numF+numT; entry++)
    setP->mbs[entry]=0;                            /* reset set to empty */
  setP->numF=setP->numT=0;                          /* reset member counters */
  for (entry = 0; entry <= max; entry++ )
  {
    setP->mbs[entry] = 1;
    if (entry<numF)
      setP->numF++;
    else
      setP->numT++;
  }
}

static void reset1ConSet(specArrs_t setP, int max, int numF, int numT)
{
  int entry;
  for (entry=0; entry<numF+numT; entry++)
    setP->mbs[entry]=0;                            /* reset set to empty */
  setP->numF=setP->numT=0;                          /* reset member counters */
}

static void readFTspecs(void)
/* read FT specs, set up Cons structure */
{
  int i, j, k, numF, numT, numFT,tr;
  char prompt[BUFSIZ];

  for(tr = 0; tr < tree_count; tr++ )
  {
    printf("Treename: %s\n", FTp[tr]->treeName);
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    numFT = numF+numT;
    printf("%s","Types in Tree:");
    for(i = 0; i < FTp[tr]->TypCount; i++)
    {
      printf(" %s", FTp[tr]->TypList[i] );
    }
    printf("%s","\n");
    printf("%s\n", "Function Info");
    for(i = 0; i < numF; i++)
    {
      // gwgnote: the instCount and linked list just used for internal purposes.
      printf("Function instCount -> %d \n",FTp[tr]->Func[i].instCount);
      printf("%s\n", "Function Arg Info");
      for (j = 0; j < funcArity(tr,i); j++)
      {
        printf("Func %d -> Arg Num %d:\n",i,j );
        for (k = 0; k < numFT; k++)
        {
          printf("  bool  F[%d]-> %d \n", k, FTp[tr]->Func[i].Arg[j].F[k]);
          printf("  bool  T[%d]-> %d \n", k, FTp[tr]->Func[i].Arg[j].T[k]);
          printf("  float W[%d]-> %f \n", k, FTp[tr]->Func[i].Arg[j].W[k]);
        }
        printf("%s","\n");
      }
    }
  }
  fflush(stdout);

  //prints out what was read in
  int fnum, anum, snum;
  for(tr = 0; tr < tree_count; tr++ )
  {
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    numFT = numF+numT;
    for ( fnum = 0; fnum < numF; fnum++ )
    {
      printf("%s\n","F_func data");
      for ( snum = 0; snum < numF; snum++ )
      {
        if ( FTp[tr]->Func[fnum].F[snum] )
        {
          printf("%s ", funcTermName(tr,snum));         /* printf F_func */
        }
      }
      printf("%s","\n");
      for ( anum = 0; anum < funcArity(tr,fnum); anum++ )
      {
        printf("%s\n","F_func[arg] data");
        for ( snum = 0; snum < numFT; snum++ )
        {
          if ( FTp[tr]->Func[fnum].Arg[anum].F[snum] )
          {
            printf("%s ", funcTermName(tr,snum));      /*printf F_func[arg]*/
          }
        }
        printf("%s","\n");
        printf("%s\n","T_func[arg] data");
        for ( snum = 0; snum < numFT; snum++ )
        {
          if ( FTp[tr]->Func[fnum].Arg[anum].T[snum] )
          {
            printf("%s ", funcTermName(tr,snum));      /*printf T_func[arg]*/
          }
        }
        printf("%s","\n");
      }
    }
    printf("%s\n","F_Root data");
    for ( snum = 0; snum < numFT; snum++ )
    {
      if ( FTp[tr]->FRoot[snum] )
      {
        printf( "%s ", funcTermName(tr,snum));          /* printf F_Root */
      }
    }
    printf("%s","\n");
    printf("%s\n","T_Root data");
    for ( snum = 0; snum < numFT; snum++ )
    {
      if ( FTp[tr]->TRoot[snum] )
      {
        printf("%s ", funcTermName(tr,snum));          /* printf T_Root */
      }
    }
  }
  fflush(stdout);

  //  printf("\n\nReading F/Tspec information...\n\n");
  //  printf("\nDefault is empty Fspecs, full Tspecs. Accept? [0 to change]: ");
  //  fscanf(inputFP,"%d",&i);
  //  fgets(buf,BUFSIZ,inputFP);

  Cons = (constraint_t**)malloc( tree_count * sizeof(constraint_t*));
  for(tr = 0; tr < tree_count; tr++ )
  {
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    numFT = numF+numT;
    i = FTp[tr]->DefaultType;
    if (i)
    {
      Cons[tr]=(constraint_t*)getVec((size_t)(numF+1),sizeof(constraint_t));
      for (i=0; i<numF; i++)
      {
        Cons[tr][i].arity=fset[tr].cset[i].arity;
        Cons[tr][i].Fspec=(specArrs_t)getVec((size_t)1,sizeof(specArrArg_t));
        Cons[tr][i].Fspec[0].mbs=(specArr_t)getVec((size_t)(numF+numT),sizeof(int));

        //reset1ConSet(&(Cons[tr][i].Fspec[0]),numF-1, numF, numT);
        /* reset set to empty */
        for (k=0; k<numFT; k++)
          Cons[tr][i].Fspec->mbs[k]=0;
        Cons[tr][i].Fspec->numF=0;
        Cons[tr][i].Fspec->numT=0;

        Cons[tr][i].Tspecs=(specArrs_t)getVec((size_t)Cons[tr][i].arity,sizeof(specArrArg_t));
        Cons[tr][i].Fspecs=(specArrs_t)getVec((size_t)Cons[tr][i].arity,sizeof(specArrArg_t));
        for(j=0; j<Cons[tr][i].arity; j++)
        {
          Cons[tr][i].Tspecs[j].mbs=(specArr_t)getVec((size_t)(numF+numT),sizeof(int));
          Cons[tr][i].Fspecs[j].mbs=(specArr_t)getVec((size_t)(numF+numT),sizeof(int));

          //reset1ConSet(&(Cons[tr][i].Fspecs[j]),numFT-1, numF, numT);
          /* reset set to empty */
          for (k=0; k<numFT; k++)
            Cons[tr][i].Fspecs[j].mbs[k]=0;
          Cons[tr][i].Fspecs[j].numF=0;
          Cons[tr][i].Fspecs[j].numT=0;
          for(k= 0; k <= numFT-1; k++ )
          {
            Cons[tr][i].Fspecs[j].mbs[k] = 1;
            if (k<numF)
              Cons[tr][i].Fspecs[j].numF++;
            else
              Cons[tr][i].Fspecs[j].numT++;
          }

          //set1ConSet(&(Cons[tr][i].Tspecs[j]),numFT-1, numF, numT);
          for(k=0; k<numFT; k++)
            Cons[tr][i].Tspecs[j].mbs[k]=0;    /* reset set to empty */
          Cons[tr][i].Tspecs[j].numF=0;
          Cons[tr][i].Tspecs[j].numT=0;        /* reset member counters */
          for(k= 0; k <= numFT-1; k++ )
          {
            Cons[tr][i].Tspecs[j].mbs[k] = 1;
            if (k<numF)
              Cons[tr][i].Tspecs[j].numF++;
            else
              Cons[tr][i].Tspecs[j].numT++;
          }
        }
      }
      Cons[tr][numF].arity=1;
      Cons[tr][numF].Fspec=NULL;
      Cons[tr][i].Tspecs=(specArrs_t)getVec((size_t)1,sizeof(specArrArg_t));
      Cons[tr][i].Fspecs=(specArrs_t)getVec((size_t)1,sizeof(specArrArg_t));
      Cons[tr][i].Tspecs[0].mbs=(specArr_t)getVec((size_t)(numFT),sizeof(int));
      Cons[tr][i].Fspecs[0].mbs=(specArr_t)getVec((size_t)(numFT),sizeof(int));

      //reset1ConSet(&(Cons[tr][numF].Fspecs[0]), numF+numT-1, numF, numT);
      /* reset set to empty */
      for (k=0; k<numFT; k++)
        Cons[tr][i].Fspecs[0].mbs[k]=0;
      Cons[tr][i].Fspecs[0].numF=0;
      Cons[tr][i].Fspecs[0].numT=0;

      //set1ConSet(&(Cons[tr][numF].Tspecs[0]), numF+numT-1, numF, numT);
      for(k=0; k<numFT; k++)
        Cons[tr][i].Tspecs[0].mbs[k]=0;   /* reset set to empty */
      Cons[tr][i].Tspecs[0].numF=0;
      Cons[tr][i].Tspecs[0].numT=0;        /* reset member counters */
      for(k= 0; k <= numFT-1; k++ )
      {
        Cons[tr][i].Tspecs[0].mbs[k] = 1;
        if (k<numF)
          Cons[tr][i].Tspecs[0].numF++;
        else
          Cons[tr][i].Tspecs[0].numT++;
      }
    }
    else
    {
      Cons[tr]=(constraint_t*)getVec((size_t)(numF+1),sizeof(constraint_t));
      for (i=0; i<numF; i++)
      {
        displayFTNames(tr, numF, numT);
        printf("Tree: %s -> Function '%s':\n",FTp[tr]->treeName,fset[tr].cset[i].string);
        fflush(stdout);
        Cons[tr][i].arity=fset[tr].cset[i].arity;
        Cons[tr][i].Fspec=(specArrs_t)getVec((size_t)1,sizeof(specArrArg_t));
        Cons[tr][i].Fspec[0].mbs=(specArr_t)getVec((size_t)(numF+numT),sizeof(int));

        sprintf(prompt,"\tF_%s (exclusions)",fset[tr].cset[i].string);
        fflush(stdout);
        //read1ConSet(prompt,&(Cons[tr][i].Fspec[0]),numF-1, numF, numT);     /* type I only here */
        for (k=0; k<numFT; k++)
          Cons[tr][i].Fspec[0].mbs[k]=0;
        Cons[tr][i].Fspec[0].numF=0;
        Cons[tr][i].Fspec[0].numT=0;
        printf("%s [up to %d names] = ",prompt,numF+1);
        fflush(stdout);
        // numF is max parameter in read1ConSet
        for ( k = 0; k < numF; k++ )
        {
          if ( FTp[tr]->Func[i].F[k] )
          {
            printf("%s ", funcTermName(tr,k));
            fflush(stdout);
            sprintf(dbgtext, "%s", funcTermName(tr,k));  //gwgdbg
            Cons[tr][i].Fspec[0].mbs[k]=1;
            if (k<numF)
              Cons[tr][i].Fspec[0].numF++;
            else
              Cons[tr][i].Fspec[0].numT++;
          }
        }
        Cons[tr][i].Tspecs=(specArrs_t)getVec((size_t)Cons[tr][i].arity,sizeof(specArrArg_t));
        Cons[tr][i].Fspecs=(specArrs_t)getVec((size_t)Cons[tr][i].arity,sizeof(specArrArg_t));
        for (j=0; j<Cons[tr][i].arity; j++)
        {
          Cons[tr][i].Tspecs[j].mbs=(specArr_t)getVec((size_t)(numF+numT),sizeof(int));
          Cons[tr][i].Fspecs[j].mbs=(specArr_t)getVec((size_t)(numF+numT),sizeof(int));

          sprintf(prompt,"\tF_%s_%d (exclusions)",fset[tr].cset[i].string,j);
          fflush(stdout);
          //read1ConSet(prompt,&(Cons[tr][i].Fspecs[anum]),numFT-1, numF, numT);
          for (k=0; k<numFT; k++)
            Cons[tr][i].Fspecs[j].mbs[k]=0;
          Cons[tr][i].Fspecs[j].numF=0;
          Cons[tr][i].Fspecs[j].numT=0;
          printf("%s [up to %d names] = ",prompt,numFT+1);
          fflush(stdout);
          for ( k= 0; k< numFT; k++ )
          {
            if ( FTp[tr]->Func[i].Arg[j].F[k] )
            {
              printf("%s ", funcTermName(tr,k));
              fflush(stdout);
              sprintf(dbgtext, "%s", funcTermName(tr,k));  //gwgdbg
              Cons[tr][i].Fspecs[j].mbs[k]=1;
              if (k<numF)
                Cons[tr][i].Fspecs[j].numF++;
              else
                Cons[tr][i].Fspec[j].numT++;
            }
          }

          sprintf(prompt,"\tT_%s_%d (inclusions)",fset[tr].cset[i].string,j);
          fflush(stdout);
          //read1ConSet(prompt,&(Cons[tr][i].Tspecs[anum]),numFT-1, numF, numT);
          for (k=0; k<numFT; k++)
            Cons[tr][i].Tspecs[j].mbs[k]=0;
          Cons[tr][i].Tspecs[j].numF=0;
          Cons[tr][i].Tspecs[j].numT=0;
          printf("%s [up to %d names] = ",prompt,numFT+1);
          fflush(stdout);
          for ( k= 0; k< numFT; k++ )
          {
            if ( FTp[tr]->Func[i].Arg[j].T[k] )
            {
              printf("%s ", funcTermName(tr,k));
              fflush(stdout);
              sprintf(dbgtext, "%s", funcTermName(tr,k));  //gwgdbg
              Cons[tr][i].Tspecs[j].mbs[k]=1;
              if (k<numF)
                Cons[tr][i].Tspecs[j].numF++;
              else
                Cons[tr][i].Tspecs[j].numT++;
            }
          }
        }
      }
      Cons[tr][numF].arity=1;
      Cons[tr][numF].Fspec=NULL;
      Cons[tr][i].Tspecs=(specArrs_t)getVec((size_t)1,sizeof(specArrArg_t));
      Cons[tr][i].Fspecs=(specArrs_t)getVec((size_t)1,sizeof(specArrArg_t));
      Cons[tr][i].Tspecs[0].mbs=(specArr_t)getVec((size_t)(numF+numT),sizeof(int));
      Cons[tr][i].Fspecs[0].mbs=(specArr_t)getVec((size_t)(numF+numT),sizeof(int));
      displayFTNames(tr, numF, numT);
      printf("Root:");
      fflush(stdout);

      //read1ConSet("\tF^Root (exclusions)",&(Cons[tr][numF].Fspecs[0]),numF+numT-1, numF, numT);
      for (k=0; k<numFT; k++)
        Cons[tr][i].Fspecs->mbs[k]=0;
      Cons[tr][i].Fspecs->numF=0;
      Cons[tr][i].Fspecs->numT=0;
      printf("%s [up to %d names] = ",prompt,numF+1);
      fflush(stdout);
      for ( k = 0; k < numFT; k++ )
      {
        if ( FTp[tr]->FRoot[k] )
        {
          printf("%s ", funcTermName(tr,k));          /* printf T_Root */
          sprintf(dbgtext, "%s", funcTermName(tr,k));  //gwgdbg
          fflush(stdout);
          Cons[tr][i].Fspecs->mbs[k]=1;
          if (k<numF)
            Cons[tr][i].Fspecs->numF++;
          else
            Cons[tr][i].Fspecs->numT++;
        }
      }

      //read1ConSet("\tT^Root (inclusions)",&(Cons[tr][numF].Tspecs[0]),numF+numT-1, numF, numT);
      for (k=0; k<numFT; k++)
        Cons[tr][i].Tspecs->mbs[k]=0;
      Cons[tr][i].Tspecs->numF=0;
      Cons[tr][i].Tspecs->numT=0;
      printf("%s [up to %d names] = ",prompt,numF+1);
      fflush(stdout);
      for ( k = 0; k < numFT; k++ )
      {
        if ( FTp[tr]->TRoot[k] )
        {
          printf("%s ", funcTermName(tr,k));          /* printf T_Root */
          sprintf(dbgtext, "%s", funcTermName(tr,k));  //gwgdbg
          fflush(stdout);
          Cons[tr][i].Tspecs->mbs[k]=1;
          if (k<numF)
            Cons[tr][i].Tspecs->numF++;
          else
            Cons[tr][i].Tspecs->numT++;
        }
      }
    }
  }
}

static void generateNF(void)
/* from specs of Cons generate NF in Fspecs of Cons */
/* this involves creating T-extensive Fspecs */
{
  int tr, fun, arg, entry, numF, numT;

  for(tr = 0; tr < tree_count; tr++)
  {
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    for (fun=0; fun<numF; fun++)           /* first create T-extensive F-specs */
      for (arg=0; arg<Cons[tr][fun].arity; arg++)
        for (entry=0; entry<numF+numT; entry++)
          if (Cons[tr][fun].Tspecs[arg].mbs[entry]==0)
            Cons[tr][fun].Fspecs[arg].mbs[entry]=1;
    for (entry=0; entry<numF+numT; entry++)               /* same for the Root */
      if (Cons[tr][numF].Tspecs[0].mbs[entry]==0)
        Cons[tr][numF].Fspecs[0].mbs[entry]=1;

    for (fun=0; fun<numF; fun++)              /* now create F-extensive Fspecs */
      for (entry=0; entry<numF; entry++)
        if (Cons[tr][fun].Fspec[0].mbs[entry]!=0)     /* must extend it */
          for (arg=0; arg<Cons[tr][entry].arity; arg++)
            Cons[tr][entry].Fspecs[arg].mbs[fun]=1;

    for (fun=0; fun<numF+1; fun++)            /* recount set entries in Fspecs */
      for (arg=0; arg<Cons[tr][fun].arity; arg++)
      {
        Cons[tr][fun].Fspecs[arg].numF=0;
        Cons[tr][fun].Fspecs[arg].numT=0;
        for (entry=0; entry<numF; entry++)
          if (Cons[tr][fun].Fspecs[arg].mbs[entry]!=0)
            Cons[tr][fun].Fspecs[arg].numF++;
        for (; entry<numF+numT; entry++)
          if (Cons[tr][fun].Fspecs[arg].mbs[entry]!=0)
            Cons[tr][fun].Fspecs[arg].numT++;
      }
  }
}

static void generateMST(void)
/* create MST_czj from the Fspecs part (ie F-intensive) of Cons */
/* mbs/wheels/weights are not allocated except for */
/*   MST_czj[*][*][NumTypes], which represent type-unconstrained */
/*   mutation sets - here weights/wheels are set to default */
{
  int tr, f, a, e, k, t, numF, numT, numFT, NumTypes;
  char buf[BUFSIZ];

  MST_czj=(void*)malloc(tree_count * sizeof(mutSet_czj_t***));
  for(tr = 0; tr < tree_count; tr++)
  {
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    numFT = numF+numT;
    NumTypes= FTp[tr]->TypCount;
    MST_czj[tr]=(void*)getVec((size_t)(numF+1),sizeof(mutSet_czj_t**));
    for (f=0; f<numF; f++)                         /* set all type I functions */
    {
      MST_czj[tr][f]=(mutSet_czj_t**)getVec((size_t)fset[tr].cset[f].arity,sizeof(mutSet_czj_t*));
      for (a=0; a<fset[tr].cset[f].arity; a++)
      {
        MST_czj[tr][f][a]=(mutSet_czj_t*)getVec((size_t)(NumTypes+1),sizeof(mutSet_czj_t));
        for (t=0; t<NumTypes; t++)
        {
          MST_czj[tr][f][a][t].numF=0;
          MST_czj[tr][f][a][t].numT=0;
          MST_czj[tr][f][a][t].numFT=0;
          MST_czj[tr][f][a][t].areFs=0;
          MST_czj[tr][f][a][t].areTs=0;
          MST_czj[tr][f][a][t].mbs=NULL;
          MST_czj[tr][f][a][t].wheel=NULL;
          MST_czj[tr][f][a][t].weights=NULL;
        }
        MST_czj[tr][f][a][NumTypes].numF=numF-Cons[tr][f].Fspecs[a].numF;
        MST_czj[tr][f][a][NumTypes].numT=numT-Cons[tr][f].Fspecs[a].numT;
        MST_czj[tr][f][a][NumTypes].numFT=MST_czj[tr][f][a][NumTypes].numF+MST_czj[tr][f][a][NumTypes].numT;
        if (MST_czj[tr][f][a][NumTypes].numFT==0)
        {
          sprintf(buf,"Both sets empty for function '%s' arg %d",
                  fset[tr].cset[f].string,a);
          error(buf);
        }
        MST_czj[tr][f][a][NumTypes].mbs=(int*)getVec((size_t)(MST_czj[tr][f][a][NumTypes].numFT),sizeof(int));
        MST_czj[tr][f][a][NumTypes].weights=(double*)getVec((size_t)(numFT),sizeof(double));
        MST_czj[tr][f][a][NumTypes].wheel=(double*)getVec((size_t)(MST_czj[tr][f][a][NumTypes].numFT),sizeof(double));
        for (e=0,k=0; k<numFT; k++)
          if (Cons[tr][f].Fspecs[a].mbs[k]==0)
          {
            MST_czj[tr][f][a][NumTypes].weights[k]=1.0;
            MST_czj[tr][f][a][NumTypes].wheel[e]= (e==0) ?
                                                  MST_czj[tr][f][a][NumTypes].weights[k] :
                                                  MST_czj[tr][f][a][NumTypes].wheel[e-1]+
                                                  MST_czj[tr][f][a][NumTypes].weights[k];
            MST_czj[tr][f][a][NumTypes].mbs[e]=k;
            e++;
          }
          else
            MST_czj[tr][f][a][NumTypes].weights[k]= -1.0;
        MST_czj[tr][f][a][NumTypes].areFs= !!MST_czj[tr][f][a][NumTypes].numF;
        MST_czj[tr][f][a][NumTypes].areTs= !!MST_czj[tr][f][a][NumTypes].numT;
      }
    }
    MST_czj[tr][numF]=(mutSet_czj_t**)getVec((size_t)1,sizeof(mutSet_czj_t*));
    MST_czj[tr][numF][0]=(mutSet_czj_t*)getVec((size_t)(NumTypes+1),sizeof(mutSet_czj_t));
    for (t=0; t<NumTypes; t++)
    {
      MST_czj[tr][numF][0][t].numF=0;
      MST_czj[tr][numF][0][t].numT=0;
      MST_czj[tr][numF][0][t].numFT=0;
      MST_czj[tr][numF][0][t].areFs=0;
      MST_czj[tr][numF][0][t].areTs=0;
      MST_czj[tr][numF][0][t].mbs=NULL;
      MST_czj[tr][numF][0][t].wheel=NULL;
      MST_czj[tr][numF][0][t].weights=NULL;
    }
    MST_czj[tr][numF][0][NumTypes].numF=numF-Cons[tr][numF].Fspecs[0].numF;
    MST_czj[tr][numF][0][NumTypes].numT=numT-Cons[tr][numF].Fspecs[0].numT;
    MST_czj[tr][numF][0][NumTypes].numFT=MST_czj[tr][numF][0][NumTypes].numF+MST_czj[tr][numF][0][NumTypes].numT;
    if (MST_czj[tr][numF][0][NumTypes].numFT==0)
      error("Both Root sets empty - no valid programs exist");
    MST_czj[tr][numF][0][NumTypes].mbs=(int*)getVec((size_t)(MST_czj[tr][numF][0][NumTypes].numFT),sizeof(int));
    MST_czj[tr][numF][0][NumTypes].weights=(double*)getVec((size_t)(numFT),sizeof(double));
    MST_czj[tr][numF][0][NumTypes].wheel=(double*)getVec((size_t)(MST_czj[tr][numF][0][NumTypes].numFT),sizeof(double));
    for (e=0,k=0; k<numFT; k++)
      if (Cons[tr][numF].Fspecs[0].mbs[k]==0)
      {
        MST_czj[tr][numF][0][NumTypes].mbs[e]=k;
        MST_czj[tr][numF][0][NumTypes].weights[k]=1.0;
        MST_czj[tr][numF][0][NumTypes].wheel[e]= (e==0) ?
            MST_czj[tr][numF][0][NumTypes].weights[k] :
            MST_czj[tr][numF][0][NumTypes].wheel[e-1]+MST_czj[tr][numF][0][NumTypes].weights[k];
        e++;
      }
      else
        MST_czj[tr][numF][0][NumTypes].weights[k]= -1.0;
    MST_czj[tr][numF][0][NumTypes].areFs= !!MST_czj[tr][numF][0][NumTypes].numF;
    MST_czj[tr][numF][0][NumTypes].areTs= !!MST_czj[tr][numF][0][NumTypes].numT;
  }
}

#if 0
static int typeNumber(const char *typeName)
/* given typeName, return its index in TypeNames, or -1 if not found */
{
  int i;
  for (i=0; i<NumTypes; i++)
    if (!strcmp(typeName,TypeNames[i]))
      return(i);
  return(-1);
}
#endif

static int read1Type(int tr, int fun)
/* read one type, a valid name from TypeNames, return its index */
{
  int i = 0;
#if 0
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
#endif
  int numfunc, numarg, numterm, numtype;
  inst_t *ip;
  return(i);
}

static int *read1TypeVec(int tr, int fun, int numA)
/* read one context specification for function fun of numA arguments */
/* into its allocated storage */
/* return NULL if no more, else return the allocated storage */
{
  int i;
  int *c;
  char buf[200];
#if 0 /* old code */
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
  {
    if (p==NULL)
      error("too few types");
    if ((c[i]=typeNumber(p))<0)
      error("wrong type name");
    p=strtok(NULL,sep);
  }
#endif
  int numfunc, numarg;
  inst_t *ip;
  sprintf(buf, "Specs for '%s' [%d arg and one ret types /<ENTER> for no more]\n\t:",
         fset[tr].cset[fun].string,numA); // debugging
  c=(int*)getVec((size_t)(numA+1),sizeof(int));
  if(c == NULL)
  { error("Out of memory, allocation in read1TypeVec");
  }
  for (numfunc=0; numfunc < pTS[tr].numF; numfunc++)
  {
    if(fun == numfunc)
    {
      for ( ip = FTp[tr]->Func[numfunc].head->next; (ip != NULL) && (ip->inst != NULL); ip = ip->next )
      { for (numarg = 0; numarg < funcArity(tr,numfunc)+1; numarg++)
        { //fprintf(inputFP, "%s ", FTp[tr]->TypList[ip->inst[numarg]]);
          sprintf(buf, "fun-> %s, argNo=%d, argType->%s ", fset[tr].cset[fun].string, numarg, FTp[tr]->TypList[ip->inst[numarg]]);
          c[numarg] = ip->inst[numarg]; // get the type
        }
      }
      /*found it, now return result*/
      break;
    }
  }
#if 0 // gwg delete later
  for (numterm = 0; numterm < pTS[tr].numT; numterm++)
    sprintf(buf, "%s\n", FTp[tr]->TypList[FTp[tr]->TypTerm[numterm]]);
  sprintf(buf, "%s\n", FTp[tr]->TypList[FTp[tr]->TypRoot]);
#endif

  return(c);
}


static int verify1TypeVec(int **typeVecs,int numA, int which)
/* verify that type vector number which is compatible and no repeated*/
/* with the previous type vectors; return 1 if ok */
/* NOTE: compatibility not checked at the moment */
{
  int i, j, diff;
  for (i=0; i<which; i++)
  {
    diff=0;
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
{
  int i,j,k,m,tr;
  //char buf[BUFSIZ];
  //char sep[]=" ,;\n";
  //char *p;
  int numFT;
  char buf[200];

  /* gwgnote: Not reading in intermediate file , it is alread read in with readType function*/
#if 0
  printf("\n\nReading Type information...\n\n");
  printf("\nDefault is a single 'generic' type. Accept? [0 to change]: ");
  fscanf(inputFP,"%d",&i);
  fgets(buf,BUFSIZ,inputFP);
  if (i)
  {
    NumTypes=1;
    TypeNames=(char**)getVec((size_t)1,sizeof(char**));
    TypeNames[0]="generic";
  }
  else
  {
    printf("List type names: ");
    if (fgets(buf,BUFSIZ,inputFP)==NULL)
      error("failed reading types");
    p=strtok(buf,sep);
    if (p==NULL)
      error("failed reading types");
    else
    {
      while (p!=NULL)
      {
        for (i=0; i<NumTypes; i++)
          if (!strcmp(TypeNames[i],p))
          {
            warning("type name repeated (rejected)");
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

#endif /* gwg intermediate file */

  //TP_czj=(TP_czj_t*)getVec((size_t)(tree_count), sizeof(oneTP_czj_t*));
  TP_czj=(void*)getVec((size_t)(tree_count), sizeof(oneTP_czj_t*));
  for(tr = 0; tr < tree_count; tr++)
  {
    numFT = pTS[tr].numF+pTS[tr].numT;
    TP_czj[tr]=(void*)getVec((size_t)(numFT+1),sizeof(oneTP_czj_t));
    for (i=0; i<pTS[tr].numF; i++)                          /* first process functions */
    {
      TP_czj[tr][i].f.numA=fset[tr].cset[i].arity;
      sprintf(buf, "%s", fset[tr].cset[i].string); //gwgdbg
      if(FTp[tr]->TypCount==1)             /* the generic case or just one type anyway */
      {
        TP_czj[tr][i].f.typeVecs=(int**)getVec((size_t)1,sizeof(int*));
        TP_czj[tr][i].f.typeVecs[0]= (int*)getVec((size_t)(TP_czj[tr][i].f.numA+1),sizeof(int));
        TP_czj[tr][i].f.numTypeVecs=1;
        for (j=0; j<TP_czj[tr][i].f.numA+1; j++)
          TP_czj[tr][i].f.typeVecs[0][j]=0;                /* just the only type */
      }
      else
      {
        /* does overloaded functions with multiple types */
        int* vec = NULL;
        j = 0;
        int arg = 0;
        inst_t *ip = NULL;
        int ic = 0;
        char buf[200];
        sprintf(buf, "Specs for '%s' [%d arg and one ret types /<ENTER> for no more]\n\t:",
               fset[tr].cset[i].string,TP_czj[tr][i].f.numA); // debugging

        ic = FTp[tr]->Func[i].instCount;
        for ( ip = FTp[tr]->Func[i].head->next; (ip != NULL) && (ip->inst != NULL); ip = ip->next )
        {
          vec=(int*)getVec((size_t)(fset[tr].cset[i].string,TP_czj[tr][i].f.numA+1),sizeof(int));
          if(vec == NULL)
          { error("Out of memory, allocation in read1TypeVec");
          }
          for (arg = 0; arg < funcArity(tr,i)+1; arg++)
          { sprintf(buf, "fun-> %s, argNo=%d, argType->%s ", fset[tr].cset[i].string, arg, FTp[tr]->TypList[ip->inst[arg]]);
            vec[arg] = ip->inst[arg]; // get the type
          }
          TP_czj[tr][i].f.numTypeVecs=j+1;
          TP_czj[tr][i].f.typeVecs= (int**)getMoreVec(TP_czj[tr][i].f.typeVecs,sizeof(int*)*(j+1));
          TP_czj[tr][i].f.typeVecs[j]=vec;
          if (!verify1TypeVec(TP_czj[tr][i].f.typeVecs,TP_czj[tr][i].f.numA,j))
          {
            free(TP_czj[tr][i].f.typeVecs[j]);
            error("must have at least one valid type vector");
          }
          j++;
        }
      }
      /* now make indexes for this function */
      TP_czj[tr][i].f.indexes= (typesIndexes_t*)getVec((size_t)FTp[tr]->TypCount,sizeof(typesIndexes_t));
      for (j=0; j<FTp[tr]->TypCount; j++)
      {
        m=0;
        for (k=0; k<TP_czj[tr][i].f.numTypeVecs; k++)
          if (TP_czj[tr][i].f.typeVecs[k][TP_czj[tr][i].f.numA]==j)
            m++;
        TP_czj[tr][i].f.indexes[j].len=m;
        if (m==0)
          TP_czj[tr][i].f.indexes[j].indexes=NULL;
        else
        {
          TP_czj[tr][i].f.indexes[j].indexes=(int*)getVec((size_t)m,sizeof(int));
          for (m=0,k=0; k<TP_czj[tr][i].f.numTypeVecs; k++)
            if (TP_czj[tr][i].f.typeVecs[k][TP_czj[tr][i].f.numA]==j)
            {
              TP_czj[tr][i].f.indexes[j].indexes[m]=k;
              m++;
            }
        }
      }
    }

    //gwgnote: a terminal can only have one type
    for (i=pTS[tr].numF; i<numFT; i++)                        /* now process terminals */
    {
      if (FTp[tr]->TypCount==1)
        TP_czj[tr][i].retType=0;                                  /* the only type */
      else
      {
        //gwgrevisit: make two type example
        sprintf(buf, "Give ret type for terminal '%s': ",fset[tr].cset[i].string); /*debug info*/
        /*TP_czj[tr][i].retType=read1Type(tr, i); */
        TP_czj[tr][i].retType=FTp[tr]->TypTerm[i-pTS[tr].numF];
      }
    }

    if (FTp[tr]->TypCount==1)                                       /* now process Root */
      TP_czj[tr][pTS[tr].numF+pTS[tr].numT].retType=0;                                /* the only type */
    else
    {
      //gwgrevisit: make two type example
      sprintf(buf, "Give return type for the problem: "); /*debug info*/
      /*TP_czj[tr][pTS[tr].numF+pTS[tr].numT].retType=read1Type(tr,pTS[tr].numF+pTS[tr].numT);*/
      TP_czj[tr][pTS[tr].numF+pTS[tr].numT].retType=FTp[tr]->TypRoot;
    }
  }
}

void create_czj(void)
/* will access global fset function table, and will allocate and
   initialize MST_czj and TF_czj */
/* will read weights (default is all equal) */
/* will read types (default is one 'generic') */
/* Must be called after fset is created and ordered,
   but before initializing the population */
{
  //int what=0;

  buildInterface();                              /* added for new interface */
  displayHeader();
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
  printf("\n##1 The following untyped mutation sets are used...\n");
  displayMST(1,1,1);
#endif
  readWeightsSetWheels();
  //finishRootWeight();
#if DISPLAY_MST // gwg added next display code
  printf("\n ##2 After finishRootWeight and readWeightsSetWheels The following untyped mutation sets are used...\n");
  displayMST(1,1,1);
#endif
  constrainTypes();
#if DISPLAY_MST
  //  if (NumTypes>1)
  //  {
  printf("\n##3 After constrainTypes The following typed mutation sets are used...\n");
  displayMST(1,1,1);
  //  }
#endif
  //  printf("Send 1 to continue, anything else to quit cgp-lil-gp: ");
  //  fscanf(inputFP,"%d",&what);
  //  if (what!=1)
  //    exit(1);
  printf("\n\n");
}

static int spinWheel(int startI, int stopI, double *wheel)
/* spin the wheel returning an index between startI and stopI inclusively,
   with probability proportional to wheel allocation (roulette) */
{
  double mark,begining;
  begining=startI ? wheel[startI-1] : 0;
  mark=begining+random_double()*(wheel[stopI]-begining);
  while (mark > wheel[startI])
    startI++;
  return(startI);
}

int random_F_czj(int tr)
/* return a random type I index from fset, but which appear in the */
/*    mutation set for Function_czj/Argument_czj/Type_czj */
/* if the set is empty, call random_FT_czj() */
/* NOTE: set is considered empty if numF==0 or each weight is <MINWGHT+SMALL */
/*   (areFs==0) */
{
  int randIndex;
  randIndex=MST_czj[tr][Function_czj][Argument_czj][Type_czj].numF;
  if (randIndex==0 || MST_czj[tr][Function_czj][Argument_czj][Type_czj].areFs==0)
    return(random_FT_czj(tr));
  randIndex=spinWheel(0,randIndex-1,MST_czj[tr][Function_czj][Argument_czj][Type_czj].wheel);
  return MST_czj[tr][Function_czj][Argument_czj][Type_czj].mbs[randIndex];
}

int random_T_czj(int tr)
/* as random_F_czj, except that extract members of T */
{
  int randIndex;
  if (MST_czj[tr][Function_czj][Argument_czj][Type_czj].numT==0 ||
      MST_czj[tr][Function_czj][Argument_czj][Type_czj].areTs==0)
    return(random_FT_czj(tr));
  randIndex=spinWheel(MST_czj[tr][Function_czj][Argument_czj][Type_czj].numF,
                      MST_czj[tr][Function_czj][Argument_czj][Type_czj].numFT-1,
                      MST_czj[tr][Function_czj][Argument_czj][Type_czj].wheel);
  return MST_czj[tr][Function_czj][Argument_czj][Type_czj].mbs[randIndex];
}

int random_FT_czj(int tr)
/* return a random type I/II/III index from fset, but which appear in
   the mutation set for Function_czj/Argument_czj/Type_czj */
{
  int randIndex;
  if (MST_czj[tr][Function_czj][Argument_czj][Type_czj].numFT==0)
    error("both set empty");
  if (MST_czj[tr][Function_czj][Argument_czj][Type_czj].areFs==0 &&
      MST_czj[tr][Function_czj][Argument_czj][Type_czj].areTs==0)
    error("both sets should not have empty weights");
  randIndex=spinWheel(0,MST_czj[tr][Function_czj][Argument_czj][Type_czj].numFT-1,
                      MST_czj[tr][Function_czj][Argument_czj][Type_czj].wheel);
  return MST_czj[tr][Function_czj][Argument_czj][Type_czj].mbs[randIndex];
}

static int markXNodes_recurse_czj(int tr, lnode **t )
/* assume Function_czj and Argument_czj are set to indicate dest point */
/* mark and count all feasible source nodes for crossover in tree */
/* marking is done with the corresponding weights w/r to dest parent */
/*   and wheel values are accumulated */
/* clear all other marking weights and wheel values to 0 */
/* sum the weights of feasible internal/external nodes in WghtsInt/WghtsWxt */
/* return the number of marked nodes */
/* NOTE: wheel entry may be the same as that of the last node if this node */
/*   is infeasible -> this will ensure that this node is not selected later */
{
  function *f = (**t).f;
  float *wheelExt_czj=&((**t).wheelExt_czj);
  float *wheelInt_czj=&((**t).wheelInt_czj);
  int j;
  double wght=0;
  int total;
  int vector=(**t).typeVec_czj;

  ++*t;                              /* step the pointer over the function. */

  if ( f->arity == 0 )                                    /* it is external */
  {
    if (f->ephem_gen)
      ++*t;                                           /* etra value to skip */
    wght=MST_czj[tr][Function_czj][Argument_czj][Type_czj].weights[f->index];
    if (wght<(MINWGHT+SMALL)  || TP_czj[tr][f->index].retType!=Type_czj)
      total=0;               /* not in this mutation set or do not use */
    else
    {
      WghtsExt+=wght;
      total=1;
    }
    *wheelInt_czj=WghtsInt;
    *wheelExt_czj=WghtsExt;
    return total;
  }
  switch (f->type)                           /* here only for internal nodes */
  {
  case FUNC_DATA:
  case EVAL_DATA:
    wght=MST_czj[tr][Function_czj][Argument_czj][Type_czj].weights[f->index];
    if (wght<(MINWGHT+SMALL) || Type_czj!=
        TP_czj[tr][f->index].f.typeVecs[vector][TP_czj[tr][f->index].f.numA])
      total=0;  /* not in this mutation set or not the right instance  */
    else
    {
      WghtsInt+=wght;
      total=1;
    }
    *wheelInt_czj=WghtsInt;
    *wheelExt_czj=WghtsExt;
    for (j=0; j<f->arity; ++j)
      total+=markXNodes_recurse_czj(tr, t);    /* t has already been advanced */
    break;
  case FUNC_EXPR:
  case EVAL_EXPR:
    wght=MST_czj[tr][Function_czj][Argument_czj][Type_czj].weights[f->index];
    if (wght<(MINWGHT+SMALL) || Type_czj!=
        TP_czj[tr][f->index].f.typeVecs[vector][TP_czj[tr][f->index].f.numA])
      total=0;
    else
    {
      WghtsInt+=wght;
      total=1;
    }
    *wheelInt_czj=WghtsInt;
    *wheelExt_czj=WghtsExt;
    for (j=0; j<f->arity; ++j)
    {
      ++*t;                   /* skip the pointer over the skipsize node. */
      total+=markXNodes_recurse_czj(tr,t);
    }
    break;
  } /* switch */
  return total;
}

int markXNodes_czj(int tr, lnode *data )
/* assume Function/Argument/Type_czj are set to indicate dest point */
/* mark all nodes in tree which are feasible sources with their wghts */
/*   while contructing the wheels for internal and external nodes */
/* accummulate total wght marked in WghtsInt and WghtsExt */
/*   for the internal and the external nodes, respectively */
/* return the number of marked nodes */
{
  lnode *t=data;
  WghtsInt=0;
  WghtsExt=0;
  return markXNodes_recurse_czj (tr, &t);
}

int markXNodesNoRoot_czj(int tr, lnode *data )
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
  {
  case FUNC_DATA:
  case EVAL_DATA:
    for (j=0; j<f->arity; ++j)
      total+=markXNodes_recurse_czj(tr, t);    /* t has already been advanced */
    break;
  case FUNC_EXPR:
  case EVAL_EXPR:
    for (j=0; j<f->arity; ++j)
    {
      ++*t;                   /* skip the pointer over the skipsize node. */
      total+=markXNodes_recurse_czj(tr,t);
    }
    break;
  } /* switch */
  return total;
}

static lnode *getSubtreeMarked_recurse_czj(int tr, lnode **t, double mark)
/* assume feasible internal and external nodes are marked with wheel values */
/*   and 'mark' determines which wheel entry is used */
/* this function spins the wheel looking for any node */
{
  function *f = (**t).f;
  float *wheelExt_czj=&((**t).wheelExt_czj);
  float *wheelInt_czj=&((**t).wheelInt_czj);
  lnode *r;
  int i;

  if (mark < (*wheelExt_czj + *wheelInt_czj))
    return *t;                 /* this might be either internal or external */
  ++*t;                                              /* move t to next node */
  if (f->arity==0)
  {
    if (f->ephem_gen)
      ++*t;                                /* skip over the terminal nodes. */
    return NULL;                                          /* not found here */
  }
  switch (f->type)
  {
  case FUNC_DATA:
  case EVAL_DATA:
    for (i=0; i<f->arity; i++)
    {
      r=getSubtreeMarked_recurse_czj(tr, t,mark);
      if (r!=NULL)
        return r;                                      /* subtree found */
    }
    break;
  case FUNC_EXPR:
  case EVAL_EXPR:
    for (i=0; i<f->arity; i++)
    {
      ++*t;
      r=getSubtreeMarked_recurse_czj(tr, t,mark);
      if (r!=NULL)
        return r;
    }
    break;
  }
  return NULL;
}

static lnode *getSubtreeMarkedInt_recurse_czj(int tr, lnode **t, double mark)
/* same as getSubtreeMarked_recurse_czj except look only internal nodes */
{
  function *f = (**t).f;
  float *wheelInt_czj=&((**t).wheelInt_czj);
  lnode *r;
  int i;

  if (f->arity==0)                               /* it is external, skip it */
  {
    ++*t;
    if (f->ephem_gen)
      ++*t;
    return NULL;
  }
  if (mark < *wheelInt_czj)                           /* return this node */
    return *t;
  ++*t;                                              /* move t to next node */
  switch (f->type)
  {
  case FUNC_DATA:
  case EVAL_DATA:
    for (i=0; i<f->arity; i++)
    {
      r=getSubtreeMarkedInt_recurse_czj(tr, t,mark);
      if (r!=NULL)
        return r;                                      /* subtree found */
    }
    break;
  case FUNC_EXPR:
  case EVAL_EXPR:
    for (i=0; i<f->arity; i++)
    {
      ++*t;
      r=getSubtreeMarkedInt_recurse_czj(tr, t,mark);
      if (r!=NULL)
        return r;
    }
    break;
  }
  return NULL;
}

static lnode *getSubtreeMarkedExt_recurse_czj(int tr, lnode **t, double mark)
/* same as getSubtreeMarked_recurse_czj except look only external nodes */
{
  function *f = (**t).f;
  float *wheelExt_czj=&((**t).wheelExt_czj);
  lnode *r;
  int i;

  if (f->arity==0)                           /* it is external, check it out */
  {
    if (mark<*wheelExt_czj)                            /* return this node */
      return *t;
    ++*t;
    if (f->ephem_gen)
      ++*t;
    return NULL;
  }
  ++*t;                        /* if here than it is an internal node - skip */
  switch (f->type)
  {
  case FUNC_DATA:
  case EVAL_DATA:
    for (i=0; i<f->arity; i++)
    {
      r=getSubtreeMarkedExt_recurse_czj(tr,t,mark);
      if (r!=NULL)
        return r;                                         /* subtree found */
    }
    break;
  case FUNC_EXPR:
  case EVAL_EXPR:
    for (i=0; i<f->arity; i++)
    {
      ++*t;
      r=getSubtreeMarkedExt_recurse_czj(tr,t,mark);
      if (r!=NULL)
        return r;
    }
    break;
  }
  return NULL;
}

lnode *getSubtreeMarked_czj(int tr, lnode *data, int intExt)
/* assume tree is filled with both internal and external wheels */
/*   accummulated in WghtsInt and WghtsExt and at least one node is feasible */
/* return a node with selection prob. proportional to its weight */
/* if no nodes found return NULL */
/* if intExt==0 then looking for both internal and external */
/* if intExt==1 then looking for internal, and switch to external only if */
/*   no internal marked */
/* the opposite for intExt==2 */
{
  lnode *el = data;
  if (intExt==0 || intExt==1 && WghtsInt<SMALL || intExt==2 && WghtsExt<SMALL)
    return              /* override 'intExt' parameter and look for any node */
      getSubtreeMarked_recurse_czj(tr,&el,(WghtsInt+WghtsExt)*random_double());
  if (intExt==1)
    return
      getSubtreeMarkedInt_recurse_czj(tr,&el,WghtsInt*random_double());
  return
    getSubtreeMarkedExt_recurse_czj(tr,&el,WghtsExt*random_double());
}

static int verify_tree_czj_recurse (int tr, lnode **t )
/* return #times the tree pointed by t violates MST_czj constraints */
/*   note: *t always points at a function node here: save the function */
{
  function *f = (**t).f;
  int i;
  int total=0;
  int vecNum;
  int numF = 0;

  numF = pTS[tr].numF;

  vecNum=(**t).typeVec_czj;
  if (MST_czj[tr][Function_czj][Argument_czj][Type_czj].weights[f->index]<0 ||
      f->index<numF && Type_czj !=
      TP_czj[tr][f->index].f.typeVecs[vecNum][TP_czj[tr][f->index].f.numA])
    total++;                                                     /* invalid */
  ++*t;                              /* step the pointer over the function. */
  if (f->arity==0)
  {
    if (f->ephem_gen)
      ++*t;    /* skip the pointer over the ERC value if this node has one. */
    return total;
  }
  switch (f->type)
  {
  case FUNC_DATA:
  case EVAL_DATA:
    for (i=0; i<f->arity; ++i)
    {
      Function_czj = f->index;
      Argument_czj = i;
      Type_czj=TP_czj[tr][Function_czj].f.typeVecs[vecNum][Argument_czj];
      total+=verify_tree_czj_recurse (tr,t);
    }
    break;
  case FUNC_EXPR:
  case EVAL_EXPR:
    for (i=0; i<f->arity; ++i)
    {
      ++*t;                 /* skip the pointer over the skipsize node. */
      Function_czj = f->index;
      Argument_czj = i;
      Type_czj=TP_czj[tr][Function_czj].f.typeVecs[vecNum][Argument_czj];
      total+=verify_tree_czj_recurse (tr,t);
    }
    break;
  } /* switch */
  return total;
}

int verify_tree_czj (int tr, lnode *tree )
/* return #times the tree pointed by tree violates MS_czj */
{
  lnode *t = tree;
  int f_save=Function_czj;
  int a_save=Argument_czj;
  int t_save=Type_czj;
  int total;
  int numFT = 0;

  numFT = pTS[tr].numF+pTS[tr].numT;

  Function_czj = fset[tr].function_count;
  Argument_czj = 0;                                  /* start from the Root */
  Type_czj=TP_czj[tr][numFT].retType;
  total=verify_tree_czj_recurse (tr,&t);
  Function_czj=f_save;
  Argument_czj=a_save;
  Type_czj=t_save;
  return total;
}
