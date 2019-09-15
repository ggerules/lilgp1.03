/* cgp_czj.c 
 * gwgnote: 20190914 
 * version acgpf2.1 (acgp with adfs and typing from cgp2.1)
 * combines acgp1.1.2 
 * combines cgp2.1
 * adds genramp feature (bloat control)
 * */

/* cgp_czj.c version 1.2 implements CGP preprocessing for lil-gp */
/* using lil-gp 1.02                                             */
/* it also allows weights for mutation set members and adapts    */
/* the weights based on distribution of counted F/T              */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "lilgp.h"
#include "types.h"

/*
//gwgnote: move SAVE_POP to a parameter in input.file
#define SAVE_POP
#define DEBUG_SORT
#define DEBUG_WHEELS
*/

/* acgp1.1.1 parameters:                                         */
/* Note that variables have the same name except that first .    */
/*   is replaced with _                                          */
/*   acgp.use_trees_prct (0..1]                                  */
/*     the effective rate for distribution sampling              */
/*     that is this prct of all trees (all pops) will be taken   */
/*   acgp.select_all  [0,1]                                      */
/*     1 - extract acgp.use_trees_prct best (after sort) out of  */
/*         each population then take them all for sampling       */
/*     0 - extract sqrt(acgp.use_trees_prct) best of each pop    */
/*         then resort and take again sqrt(acgp.use_trees_prct)  */
/*         resulting in acgp.use_trees_prct effective rate       */
/*   acgp.extract_quality_prct [0..1]                            */
/*     two trees with fitness diff by no more than               */
/*     (1-acgp.extract_quality_prct) is considered same fitness  */
/*     and thus compared on size                                 */
/*   acgp.gen_start_prct [0..1]                                  */
/*     start extracting at gen=acgp.gen_start_prct*MaxGen        */
/*   acgp.gen_step [1..MaxGen]                                   */
/*     after starting extracting, extract at this gen interval   */
/*   acgp.gen_slope [0,1,2]                                      */
/*     0 - use extracted heuristics to update and the rate of    */
/*         change is constant at                                 */
/*         sqrt(1/numIterations) if acgp.gen_slope_prct==0       */
/*         else at acgp.gen_slope_prct                           */
/*         note that acgp.gen_slope==0 and acgp.gen_slope_prct=1 */
/*         give complete greedy 100% change of the heuristics    */
/*     1 - use extracted heuristics to update old heuristics     */
/*         and the rate of change increases with iter#           */
/*   acgp.gen_slope_prct [0..1]                                  */
/*     see above                                                 */
/*   acgp.0_threshold_prct [0..1]                                */
/*     if a weight drops to weight such that weight/mutSetSize   */
/*     less than acgp.threshold_prct, then drop weight to 0      */
/*   acgp.what [0,1,2,3]                                         */
/*     0 - CGP run, no adjustments, no *.cnt/.wgt file           */
/*     1 - CGP, but also compute distribution *.cnt/*.wgt files  */
/*     2 - ACGP run, extract and adjust heuristics on this run   */
/*     3 - as 2, but after adjusting heuristics, regrow all pops */
/*   acgp.stop_on_term [0,1]                                     */
/*     0 - continue all generation even on solving (term met)    */
/*     1 - stop generation upon solving                          */
/*   acgp.use_expressed [0,1,2]                                  */
/*     0 - collect distribution from all lnodes in a tree        */
/*     1 - skip over subtress that are not expressed             */
/*     2 - as 0, but use weight proportional to the number of    */
/*         times the node is expressed (and thus skip w/0)       */

/* default values from cgp2.1 */
#define RETERROR -1
#define ENDLIST -2
#define COMMENT -3
#define TYPEDEFAULT  -1
#define WEIGHTDEFAULT  1.0
#define BRANCHLIST "BRANCHLIST"
#define TYPESECTION "TYPE"
#define FTSPECSECTION "FTSPEC"
#define WEIGHTSECTION "WEIGHT"
#define SECTIONEND "ENDSECTION"
#define BRANCHSECTIONBEG "BRANCHENDSECTIONBEGIN"
#define BRANCHSECTIONEND "BRANCHENDSECTIONEND"
#define FILEEND "ENDFILE"
#define VALIDCHARS " \t\nabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ*#0123456789"
#define VALIDNUMS " \t\n+-.0123456789eE"

/* default values for ACGP parameters */
#define ACGP_use_trees_prct_DEFAULT 0.1
#define ACGP_select_all_DEFAULT 1
#define ACGP_extract_quality_prct_DEFAULT 0.99
#define ACGP_gen_start_prct_DEFAULT 0.0    /* from the beginning */
#define ACGP_gen_step_DEFAULT 1
#define ACGP_gen_slope_DEFAULT 0             /* constant changes */
#define ACGP_gen_slope_prct_DEFAULT 0.1      /* change at at 10% */
#define ACGP_0_threshold_prct_DEFAULT 0.025
#define ACGP_what_DEFAULT 0                  /* straight CGP run */
#define ACGP_stop_on_term_DEFAULT 1
#define ACGP_use_expressed_DEFAULT 0            /* use all nodes */

#define DISPLAY_FSET 1
#define DISPLAY_FTP 1
#define DISPLAY_CONSTRAINTS 1
#define DISPLAY_MST 1
#define DISPLAY_TP 1
#define DISPLAY_NF 1

#define SAVE_FSET 1
#define SAVE_FTP 1
#define SAVE_TP 1
#define SAVE_CONSTRAINTS 1
#define SAVE_MST 1

#define funcTermName(tr, i) fset[tr].cset[(i)].string
#define funcArity(tr, i) fset[tr].cset[(i)].arity

static int ggacnt; //gwgdelete later

static int linenum;
static long filePos;
static long savefp;
static char line[BUFSIZ];
static char *interfaceFile;
FILE *inputFP;

static char dbgtext[BUFSIZ];

/* global dependent variables for acgp */
static double Acgp_extract_quality_diff;
/* set on every gen, the actual diff for same quality */
static int Acgp_use_expressed;
/* copy of the acgp.use_expressed parameter           */
int Acgp_adj_regrow;
/* set on every generation:
   0 - no adjusting not regrowing run or simply not
 regrow this generation
   1 - new iteration without regrowing this generation
2 - new iteration and regrowing this generation     */
int Acgp_stop_on_term;
/* copy of the acgp.stop_on_term parameter */

/* local static functions/macros */

static void isort(individual **data,int array_size);

static void acgp_print_counters(int iterNum, const char *basefile, int newIteration);
/* print the counters for root and parent-child distribution czjmmh */

static void acgp_reset_count();
/* resets the counters for count_czj() */

#define ACGP_EXPRESSED_VAL(expressed_node_count) \
(Acgp_use_expressed==0) ? (1) : ((Acgp_use_expressed==1) ?\
!!(expressed_node_count) : (expressed_node_count))

static individual* cur_ind;

static void acgp_count(individual *ind, int toUse);
/* computes the
   distribution of parent-child function(terminal) contexts for
   the single tree 'data'. The individual instances are counted in
   First reset all counters
   Using recursive acgp_count_recurse() to count functions
   Here count the label of Root MS[NumF][0].counters[indexOfRoot]++
   then recurse
   Counters are counted according to the expressed_czj field and
   the parameter ACGP_use_expressed
   If toUse==0 it means that walking through unexpressed subtree
   but must walk due to tree representation */

static void acgp_count_recurse_start (lnode *tree, int toUse, int whichtree);
/* gwg helper function so that memory is traversed correctly
*/

static void acgp_count_recurse (lnode **l, int toUse, int whichtree);
/* the recursive utility
   for countFI() above
   The individual instances are counted in
   the MS structure as follow:
   MS[i][a].counters[j]++ if we encounter parent 'i' with
   child 'j' as argument 'a'.
   Counters are counted according to the expressed_czj field and
   the parameter ACGP_use_expressed
   If toUse==0 it means that walking through unexpressed subtree
   but must walk due to tree representation */


static void acgp_reset_expressed_recurse_start(lnode *tree, int whichtree);
static void acgp_reset_expressed_recurse(lnode **l, int whichtree);
/* recursive utility for acgp_reset_expressed_czj */

static void verify_tree_czj_recurse_start (lnode *tree, int whichtree, int* total);
static void verify_tree_czj_recurse(lnode **l, int whichtree, int* total);

static double acgp_new_weight(double oldW, double prctChnge, double statW,
                              int mutSetSize,double);
/* return new weight
   assume: oldW and statW are normalized to probs in their mut set */

static void acgp_print_wghts(int curGen, FILE *fp, int newIteration);
/* print weights from MS_czj into the open file fp */

static void acgp_normWghtsSetWheels();
/* normalize weights for each mut set to probability and set the wheel */

static int cmpQuality(const individual *p, const individual *q);
//static int cmpSize(const void *p, const void *q);

/* end of local static functions */

/* locally global stuff */

#define SMALL 0.000000001                        /* delta for double compare */
#define MINWGHT 0.00100           /* min. maintanble wght for a member of MS */

//static int NumF;                                    /* num functions in fset */
//static int NumT;                         /* num typeII/III functions in fset */

const int RepeatsSrc_czj=5;    /* max repeats in crossover on infeasible src */
const int RepeatsBad_czj=5;                  /* same on bad (size) offspring */
static double WghtsExt;   /* sum of wghts of cross-feasible leaves of a tree */
static double WghtsInt;                       /* same for the internal nodes */

Spec_t **FTp;                         /* functions and terminals */
MS_czj_t MS_czj;                      /* the global table with mutation sets */
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

typedef int *specArray_t; /* dynamic for NumF+NumT; array[i]==1 indicates that
                             function indexed i is present in a set */
typedef struct
{
  int numF;                         /* number of F set elements in specArray */
  int numT;
  specArray_t members;
} specArrayArg_t;

typedef specArrayArg_t *specArrays_t;     /* dynamic array of specArrayArg_t */

typedef struct
{
  int arity;
  specArrays_t Tspecs;    /* dynamic array of ptrs to specArray_t for Tspecs */
  specArrays_t Fspec;                                       /* just one here */
  specArrays_t Fspecs;
} constraint_t;                     /* NOTE: Root will use Tspecs and Fspecs */

typedef constraint_t** constraints_t; /* dynamic array for functions and Root */

static constraints_t Cons;

void strtoupper(char* pStr)
{
  int sz = 0;
  char ch;
  int i;
  if(pStr == NULL)
    return;
  sz = strlen(pStr);
  for(i = 0; i < sz; i++)
  {
    ch = pStr[i];
    ch = toupper(ch);
    pStr[i] = ch;
  }
}

static void *getVec(size_t numEls, size_t bytesPerEl)
/* allocate an array from the heap, exit on failure */
{
  void *p;
  if (numEls<1 || bytesPerEl<1)
    error(E_FATAL_ERROR, "storage allocation missuse");
  p=calloc(numEls,bytesPerEl);
  if (p==NULL)
    error(E_FATAL_ERROR, "storage allocation failure");
  return p;
}

static void *getMoreVec(void *oldP, size_t bytes)
/* reallocate an array from the heap, exit on failure */
{
  void *p;
  if (bytes<1)
    error(E_FATAL_ERROR, "storage allocation missuse");
  if (oldP == NULL)
    p=malloc(bytes);                 /* some compilers dont handle a NULL */
  else                               /* passed to realloc properly, so  */
    p=realloc(oldP,bytes);           /* malloc is used in those cases   */
  if (p==NULL)
    error(E_FATAL_ERROR, "storage allocation failure");
  return p;
}

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
  printf("\n\n\t\tWELCOME TO acgp/lilgp 1.1/1.02\n");
  printf("\n\t\tdeveloped by\n");
  printf("\tCezary Z. Janikow\n");
  printf("\tUniversity of Missouri - St. Louis\n");
  printf("\temailto:cjanikow@ola.cs.umsl.edu\n");
  printf("\thttp://www.cs.umsl.edu/~janikow\n");
  printf("\n\n\n\n\tThis is distributed as addition to lil-gp\n");
  printf("\n\tNo explicit/implicit warranty\n");
  printf("\n\tPlease send bug reports to above\n");
  printf("\n\n\n");
}

static void savefileConstraints(const char* fname, const char* message, int Ts, int F, int Fs)
/* for debugging, arguments state which to display */
{
  int tr, fun, arg, entry, numF, numT;
  FILE* fh = NULL;

  fh = fopen(fname, "w");
  if(fh == NULL)
    return;

  fprintf(fh, "%s\n",message);
  fprintf(fh, "%s", "\n");

  for(tr = 0; tr < tree_count; tr++)
  {
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    fprintf(fh, "tr=%2d, %s\n",pTS[tr].treeNo, pTS[tr].treeName);
    for (fun=0; fun<numF; fun++)
    {
      fprintf(fh, "Function \"%s\" [#%d]:\n",fset[tr].cset[fun].string,fun);
      if (F)
      {
        fprintf(fh, "\tF_%s [#Fs=%d:#Ts=%d] =",fset[tr].cset[fun].string,
                Cons[tr][fun].Fspec[0].numF,Cons[tr][fun].Fspec[0].numT);
        for (entry=0; entry<numF; entry++)
          if (Cons[tr][fun].Fspec[0].members[entry])
            fprintf(fh, " %s",fset[tr].cset[entry].string);
        printf(" ||");
        for (; entry<numF+numT; entry++)
          if (Cons[tr][fun].Fspec[0].members[entry])
            fprintf(fh, " %s",fset[tr].cset[entry].string);
        fprintf(fh, "%s", "\n");
      }
      if (Fs)
        for (arg=0; arg<Cons[tr][fun].arity; arg++)
        {
          fprintf(fh, "\tF_%s_%d [#Fs=%d:#Ts=%d] =",fset[tr].cset[fun].string,arg,
                  Cons[tr][fun].Fspecs[arg].numF,Cons[tr][fun].Fspecs[arg].numT);
          for (entry=0; entry<numF; entry++)
            if (Cons[tr][fun].Fspecs[arg].members[entry])
              fprintf(fh, " %s",fset[tr].cset[entry].string);
          fprintf(fh, "%s", " ||");
          for (; entry<numF+numT; entry++)
            if (Cons[tr][fun].Fspecs[arg].members[entry])
              fprintf(fh, " %s",fset[tr].cset[entry].string);
          fprintf(fh, "%s", "\n");
        }
      if (Ts)
        for (arg=0; arg<Cons[tr][fun].arity; arg++)
        {
          fprintf(fh, "\tT_%s_%d [#Fs=%d:#Ts=%d] =",fset[tr].cset[fun].string,arg,
                  Cons[tr][fun].Tspecs[arg].numF,Cons[tr][fun].Tspecs[arg].numT);
          for (entry=0; entry<numF; entry++)
            if (Cons[tr][fun].Tspecs[arg].members[entry])
              fprintf(fh, " %s",fset[tr].cset[entry].string);
          fprintf(fh, "%s", " ||");
          for (; entry<numF+numT; entry++)
            if (Cons[tr][fun].Tspecs[arg].members[entry])
              fprintf(fh, " %s",fset[tr].cset[entry].string);
          fprintf(fh, "%s", "\n");
        }
    }
    fprintf(fh, "Root:%d\n",fun);
    if (Fs)
    {
      fprintf(fh, "\tF_Root [#Fs=%d:#Ts=%d] = ",
              Cons[tr][numF].Fspecs[0].numF,Cons[tr][numF].Fspecs[0].numT);
      for (entry=0; entry<numF; entry++)
        if (Cons[tr][numF].Fspecs[0].members[entry])
          fprintf(fh, " %s",fset[tr].cset[entry].string);
      fprintf(fh, "%s", " ||");
      for (; entry<numF+numT; entry++)
        if (Cons[tr][numF].Fspecs[0].members[entry])
          fprintf(fh, " %s",fset[tr].cset[entry].string);
      fprintf(fh, "%s", "\n");
    }
    if (Ts)
    {
      fprintf(fh, "\tT_Root [#Fs=%d:#Ts=%d] = ",
              Cons[tr][numF].Tspecs[0].numF,Cons[tr][numF].Tspecs[0].numT);
      for (entry=0; entry<numF; entry++)
        if (Cons[tr][numF].Tspecs[0].members[entry])
          fprintf(fh, " %s",fset[tr].cset[entry].string);
      fprintf(fh, "%s", " ||");
      for (; entry<numF+numT; entry++)
        if (Cons[tr][numF].Tspecs[0].members[entry])
          fprintf(fh, " %s",fset[tr].cset[entry].string);
      fprintf(fh, "%s", "\n");
    }
  }
  fflush(fh);
  fclose(fh);
}

static void displayConstraints(int Ts, int F, int Fs)
/* for debugging, arguments state which to display */
{
  int tr, fun, arg, entry, numF, numT;
  printf("\n\n\t\tCONSTRAINTS\n");
  for(tr = 0; tr < tree_count; tr++)
  {
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    printf("TREE: name-> %s, number-> %d\n",pTS[tr].treeName, pTS[tr].treeNo);
    for (fun=0; fun<numF; fun++)
    {
      printf("Function \"%s\" [#%d]:\n",fset[tr].cset[fun].string,fun);
      if (F)
      {
        printf("\tF_%s [#Fs=%d:#Ts=%d] =",fset[tr].cset[fun].string,
               Cons[tr][fun].Fspec[0].numF,Cons[tr][fun].Fspec[0].numT);
        for (entry=0; entry<numF; entry++)
          if (Cons[tr][fun].Fspec[0].members[entry])
            printf(" %s",fset[tr].cset[entry].string);
        printf(" ||");
        for (; entry<numF+numT; entry++)
          if (Cons[tr][fun].Fspec[0].members[entry])
            printf(" %s",fset[tr].cset[entry].string);
        printf("\n");
      }
      if (Fs)
        for (arg=0; arg<Cons[tr][fun].arity; arg++)
        {
          printf("\tF_%s_%d [#Fs=%d:#Ts=%d] =",fset[tr].cset[fun].string,arg,
                 Cons[tr][fun].Fspecs[arg].numF,Cons[tr][fun].Fspecs[arg].numT);
          for (entry=0; entry<numF; entry++)
            if (Cons[tr][fun].Fspecs[arg].members[entry])
              printf(" %s",fset[tr].cset[entry].string);
          printf(" ||");
          for (; entry<numF+numT; entry++)
            if (Cons[tr][fun].Fspecs[arg].members[entry])
              printf(" %s",fset[tr].cset[entry].string);
          printf("\n");
        }
      if (Ts)
        for (arg=0; arg<Cons[tr][fun].arity; arg++)
        {
          printf("\tT_%s_%d [#Fs=%d:#Ts=%d] =",fset[tr].cset[fun].string,arg,
                 Cons[tr][fun].Tspecs[arg].numF,Cons[tr][fun].Tspecs[arg].numT);
          for (entry=0; entry<numF; entry++)
            if (Cons[tr][fun].Tspecs[arg].members[entry])
              printf(" %s",fset[tr].cset[entry].string);
          printf(" ||");
          for (; entry<numF+numT; entry++)
            if (Cons[tr][fun].Tspecs[arg].members[entry])
              printf(" %s",fset[tr].cset[entry].string);
          printf("\n");
        }
    }
    printf("Root:%d\n",fun);
    if (Fs)
    {
      printf("\tF_Root [#Fs=%d:#Ts=%d] = ",
             Cons[tr][numF].Fspecs[0].numF,Cons[tr][numF].Fspecs[0].numT);
      for (entry=0; entry<numF; entry++)
        if (Cons[tr][numF].Fspecs[0].members[entry])
          printf(" %s",fset[tr].cset[entry].string);
      printf(" ||");
      for (; entry<numF+numT; entry++)
        if (Cons[tr][numF].Fspecs[0].members[entry])
          printf(" %s",fset[tr].cset[entry].string);
      printf("\n");
    }
    if (Ts)
    {
      printf("\tT_Root [#Fs=%d:#Ts=%d] = ",
             Cons[tr][numF].Tspecs[0].numF,Cons[tr][numF].Tspecs[0].numT);
      for (entry=0; entry<numF; entry++)
        if (Cons[tr][numF].Tspecs[0].members[entry])
          printf(" %s",fset[tr].cset[entry].string);
      printf(" ||");
      for (; entry<numF+numT; entry++)
        if (Cons[tr][numF].Tspecs[0].members[entry])
          printf(" %s",fset[tr].cset[entry].string);
      printf("\n");
    }
  }
  fflush(stdout);
}

//static void savefileMS(const char* fname, const char* message,int uncMs, int wheel, int weight)
void savefileMS(const char* fname, const char* message,int uncMs, int wheel, int weight)
/* display the mutation sets from MS_czj */
{
  int tr, f, a, e, k, t, numF, numT, numFT, NumTypes;
  FILE* fh = NULL;

  fh = fopen(fname, "w");
  if(fh == NULL)
    return;

  fprintf(fh, "%s\n",message);
  fprintf(fh, "%s", "\n");

  for(tr = 0; tr < tree_count; tr++)
  {
    numF     = pTS[tr].numF;
    numT     = pTS[tr].numT;
    numFT    = numF+numT;
    NumTypes =FTp[tr]->TypCount;

    fprintf(fh, "tr=%2d, %s\n",pTS[tr].treeNo, pTS[tr].treeName);
    for (f=0; f<numF; f++)
    {
      fprintf(fh, " Function '%s': arity %d \n", fset[tr].cset[f].string,fset[tr].cset[f].arity);
      for (a=0; a<fset[tr].cset[f].arity; a++)
      {
        fprintf(fh, "  Argument %d\n",a);
        for (t=0; t<NumTypes; t++)
        { if (MS_czj[tr][f][a][t].numFT!=0)             /* mutation set not empty */
          {
            fprintf(fh, "   Type '%s'\n",FTp[tr]->TypList[t]);
            fprintf(fh, "    F [%d members] =",MS_czj[tr][f][a][t].numF);
            for (k=0; k<MS_czj[tr][f][a][t].numF; k++)
              fprintf(fh, " %s",fset[tr].cset[MS_czj[tr][f][a][t].members[k]].string);
            fprintf(fh, "%s", "\n");
            fprintf(fh, "    T [%d members] =",MS_czj[tr][f][a][t].numT);
            for (k=0; k<MS_czj[tr][f][a][t].numT; k++)
              fprintf(fh, " %s",fset[tr].cset[MS_czj[tr][f][a][t].members[MS_czj[tr][f][a][t].numF+k]].string);
            fprintf(fh, "%s", "\n");
            fprintf(fh, "    counters_tot = %d",MS_czj[tr][f][a][t].counters_tot);
            fprintf(fh, "%s", "\n");
            fprintf(fh, "    counters [%d members] = ",MS_czj[tr][f][a][t].numFT);
            for (k=0; k<MS_czj[tr][f][a][t].numFT; k++)
              fprintf(fh, " %d",MS_czj[tr][f][a][t].counters[k]);
            if (wheel)
            {
              fprintf(fh, "%s", "\n");
              fprintf(fh, "    Wheel: F is %s and T is %s",
                     MS_czj[tr][f][a][t].areFs ? "used":"not used",
                     MS_czj[tr][f][a][t].areTs ? "used":"not used");
              fprintf(fh, "%s", "\n    ");
              for (k=0; k<MS_czj[tr][f][a][t].numFT; k++)
                fprintf(fh, " %.6f",MS_czj[tr][f][a][t].wheel[k]);
            }
            if (weight)
            {
              fprintf(fh, "%s", "\n");
              fprintf(fh, "    Weights: F is %s and T is %s",
                     MS_czj[tr][f][a][t].areFs ? "used":"not used",
                     MS_czj[tr][f][a][t].areTs ? "used":"not used");
              fprintf(fh, "%s", "\n    ");
              for (k=0; k<numFT; k++)
                fprintf(fh, " %.6f",MS_czj[tr][f][a][t].weights[k]);
            }
            fprintf(fh, "%s", "\n");
          }
        }
        if (uncMs)
        {
          fprintf(fh, "  Type unconstrained mutation set\n");
          fprintf(fh, "   F [%d members] =",MS_czj[tr][f][a][NumTypes].numF);
          for (k=0; k<MS_czj[tr][f][a][NumTypes].numF; k++)
            fprintf(fh, " %s",fset[tr].cset[MS_czj[tr][f][a][NumTypes].members[k]].string);
          fprintf(fh, "%s", "\n");
          fprintf(fh, "   T [%d members] =",MS_czj[tr][f][a][NumTypes].numT);
          for (k=0; k<MS_czj[tr][f][a][NumTypes].numT; k++)
            fprintf(fh, " %s",fset[tr].cset[MS_czj[tr][f][a][NumTypes].members[MS_czj[tr][f][a][NumTypes].numF+k]].string);
          fprintf(fh, "%s", "\n");
          fprintf(fh, "    counters_tot = %d",MS_czj[tr][f][a][NumTypes].counters_tot);
          fprintf(fh, "%s", "\n");
          fprintf(fh, "    counters [%d members] = ",MS_czj[tr][f][a][NumTypes].numFT);
          for (k=0; k<MS_czj[tr][f][a][NumTypes].numFT; k++)
            fprintf(fh, " %d",MS_czj[tr][f][a][NumTypes].counters[k]);
          if (wheel)
          {
            fprintf(fh, "%s", "\n");
            fprintf(fh, "  Wheel: F is %s and T is %s",
                   MS_czj[tr][f][a][t].areFs ? "used":"not used",
                   MS_czj[tr][f][a][t].areTs ? "used":"not used");
            fprintf(fh, "%s", "\n   ");
            for (k=0; k<MS_czj[tr][f][a][t].numFT; k++)
              fprintf(fh, " %.6f",MS_czj[tr][f][a][t].wheel[k]);
          }
          if (weight)
          {
            fprintf(fh, "%s", "\n");
            fprintf(fh, "  Weights: F is %s and T is %s",
                   MS_czj[tr][f][a][t].areFs ? "used":"not used",
                   MS_czj[tr][f][a][t].areTs ? "used":"not used");
            fprintf(fh, "%s", "\n   ");
            for (k=0; k<numFT; k++)
              fprintf(fh, " %.6f",MS_czj[tr][f][a][t].weights[k]);
          }
          fprintf(fh, "%s", "\n");
        }
      }
    }
    fprintf(fh, "%s", " Root:\n");
    for (t=0; t<NumTypes; t++)
    { if (MS_czj[tr][numF][0][t].numFT!=0)
      {
        fprintf(fh, "   Type '%s'\n",funcTermName(tr,t));
        fprintf(fh, "    F [%d members] =",MS_czj[tr][numF][0][t].numF);
        for (k=0; k<MS_czj[tr][numF][0][t].numF; k++)
          fprintf(fh, " %s",fset[tr].cset[MS_czj[tr][numF][0][t].members[k]].string);
        fprintf(fh, "%s", "\n");
        fprintf(fh, "    T [%d members] =",MS_czj[tr][numF][0][t].numT);
        for (k=0; k<MS_czj[tr][numF][0][t].numT; k++)
          fprintf(fh, " %s",fset[tr].cset[MS_czj[tr][numF][0][t].members[MS_czj[tr][numF][0][t].numF+k]].string);
        fprintf(fh, "%s", "\n");
        fprintf(fh, "    counters_tot = %d",MS_czj[tr][numF][0][NumTypes].counters_tot);
        fprintf(fh, "%s", "\n");
        fprintf(fh, "    counters [%d members] = ",MS_czj[tr][numF][0][NumTypes].numFT);
        for (k=0; k<MS_czj[tr][numF][0][NumTypes].numFT; k++)
          fprintf(fh, " %d",MS_czj[tr][numF][0][NumTypes].counters[k]);
        if (wheel)
        {
          fprintf(fh, "%s", "\n");
          fprintf(fh, "   Wheel: F is %s and T is %s",
                 MS_czj[tr][numF][0][t].areFs ? "used":"not used",
                 MS_czj[tr][numF][0][t].areTs ? "used":"not used");
          fprintf(fh, "%s", "\n    ");
          for (k=0; k<MS_czj[tr][numF][0][t].numFT; k++)
            fprintf(fh, " %.6f",MS_czj[tr][numF][0][t].wheel[k]);
        }
        if (weight)
        {
          fprintf(fh, "%s", "\n");
          fprintf(fh, "   Weights: F is %s and T is %s",
                 MS_czj[tr][numF][0][t].areFs ? "used":"not used",
                 MS_czj[tr][numF][0][t].areTs ? "used":"not used");
          fprintf(fh, "%s", "\n    ");
          for (k=0; k<numFT; k++)
            fprintf(fh, " %.6f",MS_czj[tr][numF][0][t].weights[k]);
        }
        fprintf(fh, "%s", "\n");
      }
    }
    if (uncMs)
    {
      fprintf(fh, "  Type unconstrained mutation set\n");
      fprintf(fh, "   F [%d members] =",MS_czj[tr][numF][0][NumTypes].numF);
      for (k=0; k<MS_czj[tr][numF][0][NumTypes].numF; k++)
        fprintf(fh, " %s",fset[tr].cset[MS_czj[tr][numF][0][NumTypes].members[k]].string);
      fprintf(fh, "\n");
      fprintf(fh, "   T [%d members] =",MS_czj[tr][numF][0][NumTypes].numT);
      for (k=0; k<MS_czj[tr][numF][0][NumTypes].numT; k++)
        fprintf(fh, " %s",fset[tr].cset[MS_czj[tr][numF][0][NumTypes].members[MS_czj[tr][numF][0][NumTypes].numF+k]].string);
      fprintf(fh, "%s", "\n");
      fprintf(fh, "    counters_tot = %d",MS_czj[tr][numF][0][NumTypes].counters_tot);
      fprintf(fh, "%s", "\n");
      fprintf(fh, "    counters [%d members] = ",MS_czj[tr][numF][0][NumTypes].numFT);
      for (k=0; k<MS_czj[tr][numF][0][NumTypes].numFT; k++)
        fprintf(fh, " %d",MS_czj[tr][numF][0][NumTypes].counters[k]);
      if (wheel)
      {
        fprintf(fh, "%s", "\n");
        fprintf(fh, "   Wheel: F is %s and T is %s",
               MS_czj[tr][numF][0][t].areFs ? "used":"not used",
               MS_czj[tr][numF][0][t].areTs ? "used":"not used");
        fprintf(fh, "%s", "\n    ");
        for (k=0; k<MS_czj[tr][numF][0][t].numFT; k++)
          fprintf(fh, " %.6f",MS_czj[tr][numF][0][t].wheel[k]);
      }
      if (weight)
      {
        fprintf(fh, "%s", "\n");
        fprintf(fh, "   Weights: F is %s and T is %s",
               MS_czj[tr][numF][0][t].areFs ? "used":"not used",
               MS_czj[tr][numF][0][t].areTs ? "used":"not used");
        fprintf(fh, "%s", "\n    ");
        for (k=0; k<numFT; k++)
          fprintf(fh, " %.6f",MS_czj[tr][numF][0][t].weights[k]);
      }
      fprintf(fh, "%s", "\n");
    }
  }

  fflush(fh);
  fclose(fh);
}

static void displayMS(int uncMs, int wheel, int weight)
/* display mutation sets from MS_czj */
/* if uncMs the include unconstrained mut set */
/* if wheel/weight then invclude wheel/weights */
{
  int tr, f, a, e, k, t, numF, numT, numFT, NumTypes;

  printf("%s", "\n");
  for(tr = 0; tr < tree_count; tr++)
  {
    numF     = pTS[tr].numF;
    numT     = pTS[tr].numT;
    numFT    = numF+numT;
    NumTypes =FTp[tr]->TypCount;
    for (f=0; f<numF; f++)
    {
      printf("Function '%s': arity %d \n", fset[tr].cset[f].string,fset[tr].cset[f].arity);
      for (a=0; a<fset[tr].cset[f].arity; a++)
      {
        printf("\tArgument %d\n",a);
        for (t=0; t<NumTypes; t++)
        { if (MS_czj[tr][f][a][t].numFT!=0)             /* mutation set not empty */
          {
            printf("\t\tType '%s'\n",FTp[tr]->TypList[t]);
            printf("\t\t\tF [%d members] =",MS_czj[tr][f][a][t].numF);
            for (k=0; k<MS_czj[tr][f][a][t].numF; k++)
              printf(" '%s'",fset[tr].cset[MS_czj[tr][f][a][t].members[k]].string);
            printf("\n\t\t\tT [%d members] =",MS_czj[tr][f][a][t].numT);
            for (k=0; k<MS_czj[tr][f][a][t].numT; k++)
              printf(" '%s'",fset[tr].cset[MS_czj[tr][f][a][t].members[MS_czj[tr][f][a][t].numF+k]].string);
            if (wheel)
            {
              printf("\n\t\t\tWheel: F is %s and T is %s\n\t\t\t",
                     MS_czj[tr][f][a][t].areFs ? "used":"not used",
                     MS_czj[tr][f][a][t].areTs ? "used":"not used");
              for (k=0; k<MS_czj[tr][f][a][t].numFT; k++)
                printf(" %.6f",MS_czj[tr][f][a][t].wheel[k]);
            }
            if (weight)
            {
              printf("\n\t\t\tWeights: F is %s and T is %s\n\t\t\t",
                     MS_czj[tr][f][a][t].areFs ? "used":"not used",
                     MS_czj[tr][f][a][t].areTs ? "used":"not used");
              for (k=0; k<numFT; k++)
                printf(" %.6f",MS_czj[tr][f][a][t].weights[k]);
            }
            printf("%s", "\n");
          }
        }
        if (uncMs)
        {
          printf("%s", "\t\tType unconstrained mutation set\n");
          printf("\t\t\tF [%d members] =",MS_czj[tr][f][a][NumTypes].numF);
          for (k=0; k<MS_czj[tr][f][a][NumTypes].numF; k++)
            printf(" '%s'",fset[tr].cset[MS_czj[tr][f][a][NumTypes].members[k]].string);
          printf("\n\t\t\tT [%d members] =",MS_czj[tr][f][a][NumTypes].numT);
          for (k=0; k<MS_czj[tr][f][a][NumTypes].numT; k++)
            printf(" '%s'",fset[tr].cset[MS_czj[tr][f][a][NumTypes].members[MS_czj[tr][f][a][NumTypes].numF+k]].string);
          if (wheel)
          {
            printf("\n\t\t\tWheel: F is %s and T is %s\n\t\t\t",
                   MS_czj[tr][f][a][t].areFs ? "used":"not used",
                   MS_czj[tr][f][a][t].areTs ? "used":"not used");
            for (k=0; k<MS_czj[tr][f][a][t].numFT; k++)
              printf(" %.6f",MS_czj[tr][f][a][t].wheel[k]);
          }
          if (weight)
          {
            printf("\n\t\t\tWeights: F is %s and T is %s\n\t\t\t",
                   MS_czj[tr][f][a][t].areFs ? "used":"not used",
                   MS_czj[tr][f][a][t].areTs ? "used":"not used");
            for (k=0; k<numFT; k++)
              printf(" %.6f",MS_czj[tr][f][a][t].weights[k]);
          }
          printf("%s", "\n");
        }
      }
    }
    printf("%s", "Root:\n");
    for (t=0; t<NumTypes; t++)
    { if (MS_czj[tr][numF][0][t].numFT!=0)
      {
        printf("\t\tType '%s'\n",funcTermName(tr,t));
        printf("\t\t\tF [%d members] =",MS_czj[tr][numF][0][t].numF);
        for (k=0; k<MS_czj[tr][numF][0][t].numF; k++)
          printf(" '%s'",fset[tr].cset[MS_czj[tr][numF][0][t].members[k]].string);
        printf("\n\t\t\tT [%d members] =",MS_czj[tr][numF][0][t].numT);
        for (k=0; k<MS_czj[tr][numF][0][t].numT; k++)
          printf(" '%s'",fset[tr].cset[MS_czj[tr][numF][0][t].members[MS_czj[tr][numF][0][t].numF+k]].string);
        if (wheel)
        {
          printf("\n\t\t\tWheel: F is %s and T is %s\n\t\t\t",
                 MS_czj[tr][numF][0][t].areFs ? "used":"not used",
                 MS_czj[tr][numF][0][t].areTs ? "used":"not used");
          for (k=0; k<MS_czj[tr][numF][0][t].numFT; k++)
            printf(" %.6f",MS_czj[tr][numF][0][t].wheel[k]);
        }
        if (weight)
        {
          printf("\n\t\t\tWeights: F is %s and T is %s\n\t\t\t",
                 MS_czj[tr][numF][0][t].areFs ? "used":"not used",
                 MS_czj[tr][numF][0][t].areTs ? "used":"not used");
          for (k=0; k<numFT; k++)
            printf(" %.6f",MS_czj[tr][numF][0][t].weights[k]);
        }
        printf("%s", "\n");
      }
    }
    if (uncMs)
    {
      printf("%s", "\t\tType unconstrained mutation set\n");
      printf("\t\t\tF [%d members] =",MS_czj[tr][numF][0][NumTypes].numF);
      for (k=0; k<MS_czj[tr][numF][0][NumTypes].numF; k++)
        printf(" '%s'",fset[tr].cset[MS_czj[tr][numF][0][NumTypes].members[k]].string);
      printf("\n\t\t\tT [%d members] =",MS_czj[tr][numF][0][NumTypes].numT);
      for (k=0; k<MS_czj[tr][numF][0][NumTypes].numT; k++)
        printf(" '%s'",fset[tr].cset[MS_czj[tr][numF][0][NumTypes].members[MS_czj[tr][numF][0][NumTypes].numF+k]].string);
      if (wheel)
      {
        printf("\n\t\t\tWheel: F is %s and T is %s\n\t\t\t",
               MS_czj[tr][numF][0][t].areFs ? "used":"not used",
               MS_czj[tr][numF][0][t].areTs ? "used":"not used");
        for (k=0; k<MS_czj[tr][numF][0][t].numFT; k++)
          printf(" %.6f",MS_czj[tr][numF][0][t].wheel[k]);
      }
      if (weight)
      {
        printf("\n\t\t\tWeights: F is %s and T is %s\n\t\t\t",
               MS_czj[tr][numF][0][t].areFs ? "used":"not used",
               MS_czj[tr][numF][0][t].areTs ? "used":"not used");
        for (k=0; k<numFT; k++)
          printf(" %.6f",MS_czj[tr][numF][0][t].weights[k]);
      }
      printf("%s", "\n");
    }
  }
}

/* display weights/wheels from MS_czj */
/* if weights/wheels==0 then do not display weights/wheels */
static void savefileWeightsWheels(const char* fname, const char* message, int weights,int wheels)
{
  int f,a,k, tr, numF, numT, numFT, NumTypes;
  if (weights==0 && wheels==0)
    return;

  FILE* fh = NULL;

  fh = fopen(fname, "w");
  if(fh == NULL)
    return;

  fprintf(fh, "%s\n",message);
  fprintf(fh, "%s", "\n");

  for(tr = 0; tr < tree_count; tr++)
  {
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    numFT    = numF+numT;
    NumTypes = FTp[tr]->TypCount;

    fprintf(fh, "tr=%2d, %s\n",pTS[tr].treeNo, pTS[tr].treeName);
    fprintf(fh, "\n\nThese are %s%s...\n\n",weights ? "weights/" : "", wheels ? "wheels" : "");
    for (f=0; f<numF; f++)
    {
      fprintf(fh, "Function \"%s\" [#%d]: %d arguments\n", fset[tr].cset[f].string,f,fset[tr].cset[f].arity);
      for (a=0; a<fset[tr].cset[f].arity; a++)
      {
        fprintf(fh, "\tArgument %d: ",a);
        fprintf(fh, "F [%d members, %s]  and T [%d members, %s]\n",MS_czj[tr][f][a][NumTypes].numF,
                MS_czj[tr][f][a][NumTypes].areFs ? "used":"not used", MS_czj[tr][f][a][NumTypes].numT,
                MS_czj[tr][f][a][NumTypes].areTs ? "used":"not used");
        if (weights)
        {
          fprintf(fh, "\tWeights:");
          for (k=0; k<numF+numT; k++)
            /* if (MS_czj[tr][f][a][NumTypes].weights[k]>=MINWGHT) */
            fprintf(fh, " %.3f",MS_czj[tr][f][a][NumTypes].weights[k]);
          fprintf(fh, "%s", "\n");
        }
        if (wheels)
        {
          fprintf(fh, "%s", "\tWheels:");
          for (k=0; k<MS_czj[tr][f][a][NumTypes].numFT; k++)
            fprintf(fh, " %.3f",MS_czj[tr][f][a][NumTypes].wheel[k]);
          fprintf(fh, "%s", "\n");
        }
      }
      fprintf(fh, "%s", "\n");
    }
    fprintf(fh, "%s", "Root: ");
    fprintf(fh, "F [%d members, %s] and T [%d members, %s]\n",MS_czj[tr][numF][0][NumTypes].numF,
            MS_czj[tr][numF][0][NumTypes].areFs ? "used":"not used", MS_czj[tr][numF][0][NumTypes].numT,
            MS_czj[tr][numF][0][NumTypes].areTs ? "used":"not used");
    if (weights)
    {
      fprintf(fh, "%s", "\tWeights:");
      for (k=0; k<numF+numT; k++)
        /* if (MS_czj[tr][numF][0][NumTypes].weights[k]>MINWGHT) */
        fprintf(fh, " %.3f",MS_czj[tr][numF][0][NumTypes].weights[k]);
      fprintf(fh, "%s", "\n");
    }
    if (wheels)
    {
      fprintf(fh, "%s", "\tWheels:");
      for (k=0; k<MS_czj[tr][numF][0][NumTypes].numFT; k++)
        fprintf(fh, " %.3f",MS_czj[tr][numF][0][NumTypes].wheel[k]);
      fprintf(fh, "%s", "\n");
    }
    fprintf(fh, "%s", "\n");
  }
  fflush(fh);
  fclose(fh);
}

static void displayWeightsWheels(int weights,int wheels)
/* display weights/wheels from MS_czj */
/* if weights/wheels==0 then do not display weights/wheels */
{
  int f,a,k, tr, numF, numT, numFT, NumTypes;
  if (weights==0 && wheels==0)
    return;

  for(tr = 0; tr < tree_count; tr++)
  {
    numF     = pTS[tr].numF;
    numT     = pTS[tr].numT;
    numFT    = numF+numT;
    NumTypes = FTp[tr]->TypCount;

    printf("TREE: name-> %s, number-> %d\n",pTS[tr].treeName, pTS[tr].treeNo);
    printf("\n\nThese are %s%s...\n\n",weights ? "weights/" : "", wheels ? "wheels" : "");
    for (f=0; f<numF; f++)
    {
      printf("Function \"%s\" [#%d]: %d arguments\n", fset[tr].cset[f].string,f,fset[tr].cset[f].arity);
      for (a=0; a<fset[tr].cset[f].arity; a++)
      {
        printf("\tArgument %d: ",a);
        printf("F [%d members, %s]  and T [%d members, %s]\n",MS_czj[tr][f][a][NumTypes].numF,
               MS_czj[tr][f][a][NumTypes].areFs ? "used":"not used", MS_czj[tr][f][a][NumTypes].numT,
               MS_czj[tr][f][a][NumTypes].areTs ? "used":"not used");
        if (weights)
        {
          printf("\tWeights:");
          for (k=0; k<numF+numT; k++)
            /* if (MS_czj[tr][f][a][NumTypes].weights[k]>=MINWGHT) */
            printf(" %.3f",MS_czj[tr][f][a][NumTypes].weights[k]);
          printf("\n");
        }
        if (wheels)
        {
          printf("\tWheels:");
          for (k=0; k<MS_czj[tr][f][a][NumTypes].numFT; k++)
            printf(" %.3f",MS_czj[tr][f][a][NumTypes].wheel[k]);
          printf("\n");
        }
      }
      printf("\n");
    }
    printf("Root: ");
    printf("F [%d members, %s] and T [%d members, %s]\n",MS_czj[tr][numF][0][NumTypes].numF,
           MS_czj[tr][numF][0][NumTypes].areFs ? "used":"not used", MS_czj[tr][numF][0][NumTypes].numT,
           MS_czj[tr][numF][0][NumTypes].areTs ? "used":"not used");
    if (weights)
    {
      printf("\tWeights:");
      for (k=0; k<numF+numT; k++)
        /* if (MS_czj[tr][numF][0][NumTypes].weights[k]>MINWGHT) */
        printf(" %.3f",MS_czj[tr][numF][0][NumTypes].weights[k]);
      printf("\n");
    }
    if (wheels)
    {
      printf("\tWheels:");
      for (k=0; k<MS_czj[tr][numF][0][NumTypes].numFT; k++)
        printf(" %.3f",MS_czj[tr][numF][0][NumTypes].wheel[k]);
      printf("\n");
    }
    printf("\n");
  }
  fflush(stdout);
}

#if 0 //gwgfix
static double readMinWghtto1(const char *prompt)
/* read (0,1], and if entry < MINWGHT then set it as MINWGHT */
{
  double what;
  int res;
  printf("%s: ",prompt);
  res=scanf("%lf",&what);
  while (res<1 || what >1 || what <0)
  {
    if (res==EOF)
      exit(1);
    fflush(stdin);
    printf("\tInvalid weight: %s: ",prompt);
    res=scanf("%lf",&what);
  }
  if (what<MINWGHT)
    what=MINWGHT;                           /* smaller values become minimal */
  return(what);
}
#endif

static void readWeightsSetWheels(void)
/* read weights for mutation set entries and construct wheels */
/* assume weights/wheels are set for all members equalweighted */
/* assume weights for non-members are set to -1 */
/* areFs and areTs members of MS_czj are set to true if ate least one */
/*   members has weight >MINWGHT */
{
  int tr, f,a,k, dt, numF, NumTypes;
  double adjWght, totWght, what;
  int areFs, areTs;
  printf("\n\nSetting initial weights for mutation set members...\n\n");
  //printf("\nInitial weights are all equal. Do you accept [0 to change]: ");
  //scanf("%d",&i);
  for(tr = 0; tr < tree_count; tr++ )
  {
    numF = pTS[tr].numF;
    NumTypes=FTp[tr]->TypCount;
    dt = FTp[tr]->DefaultType;
    if (dt)
      return;                               /* leave inital weights and wheels */
    printf("TREE: name-> %s, number-> %d\n",pTS[tr].treeName, pTS[tr].treeNo);
    for (f=0; f<numF; f++)
    { printf("\n");
      printf("Function \"%s\" [#%d]: %d mutation set pairs\n", fset[tr].cset[f].string,f,fset[tr].cset[f].arity);
      for (a=0; a<fset[tr].cset[f].arity; a++)
      { areFs=0;
        areTs=0;
        printf("Argument %d:\n",a);
        printf("\tF [%d members] =",MS_czj[tr][f][a][NumTypes].numF);
        for (k=0; k<MS_czj[tr][f][a][NumTypes].numF; k++)
          printf(" %s",fset[tr].cset[MS_czj[tr][f][a][NumTypes].members[k]].string);
        printf("\n\tT [%d members] =",MS_czj[tr][f][a][NumTypes].numT);
        for (k=0; k<MS_czj[tr][f][a][NumTypes].numT; k++)
          printf(" %s", fset[tr].cset[MS_czj[tr][f][a][NumTypes].members[MS_czj[tr][f][a][NumTypes].numF+k]].string);
        printf("\n\n\tReading the weights for type I functions...\n");
        for (k=0; k<MS_czj[tr][f][a][NumTypes].numF; k++)
        {
          printf("\tFunction \"%s\" [%d]: ",
                 fset[tr].cset[MS_czj[tr][f][a][NumTypes].members[k]].string,
                 MS_czj[tr][f][a][NumTypes].members[k]);
          // FTp[tr]->Func[f].Arg[a].W[MS_czj[tr][f][a][NumTypes].members[k]]
          //MS_czj[tr][f][a][NumTypes].weights[MS_czj[tr][f][a][NumTypes].members[k]]= readMinWghtto1("give weight (0,1]");
          what = FTp[tr]->Func[f].Arg[a].W[MS_czj[tr][f][a][NumTypes].members[k]];
          if (what >1 || what<0)
            error(E_FATAL_ERROR, "failed reading weight");
          if (what<MINWGHT)
            what=MINWGHT;                           /* smaller values become minimal */
          MS_czj[tr][f][a][NumTypes].weights[MS_czj[tr][f][a][NumTypes].members[k]] = what;
        }
        printf("\n\tReading the weights for type II/III terminals...\n");
        for (k=0; k<MS_czj[tr][f][a][NumTypes].numT; k++)
        { printf("\tTerminal \"%s\" [%d]: ",
                 fset[tr].cset[MS_czj[tr][f][a][NumTypes].members[MS_czj[tr][f][a][NumTypes].numF+k]].string,
                 MS_czj[tr][f][a][NumTypes].members[MS_czj[tr][f][a][NumTypes].numF+k]);
          // FTp[tr]->Func[f].Arg[a].W[MS_czj[tr][f][a][NumTypes].numF+k]
          //MS_czj[tr][f][a][NumTypes].weights[MS_czj[tr][f][a][NumTypes].members[MS_czj[tr][f][a][NumTypes].numF+k]]= readMinWghtto1("give weight (0,1]");
          what = FTp[tr]->Func[f].Arg[a].W[MS_czj[tr][f][a][NumTypes].numF+k];
          if (what >1 || what<0)
            error(E_FATAL_ERROR, "failed reading weight");
          if (what<MINWGHT)
            what=MINWGHT;                           /* smaller values become minimal */
          MS_czj[tr][f][a][NumTypes].weights[MS_czj[tr][f][a][NumTypes].members[MS_czj[tr][f][a][NumTypes].numF+k]]=what;
        }
        /* now all non-memb weights are -1, all member weights are in [MINWGHT..1] */
        /* now set mut wheel skipping over weights <MINWGHT+SMALL */
        for (k=0,totWght=0; k<MS_czj[tr][f][a][NumTypes].numFT; k++)
          totWght+=MS_czj[tr][f][a][NumTypes].weights[MS_czj[tr][f][a][NumTypes].members[k]];

        for (k=0; k<MS_czj[tr][f][a][NumTypes].numF; k++)
        {
          if (MS_czj[tr][f][a][NumTypes].weights[MS_czj[tr][f][a][NumTypes].members[k]]<MINWGHT+SMALL)
            adjWght=0;
          else
          {
            adjWght=MS_czj[tr][f][a][NumTypes].weights[MS_czj[tr][f][a][NumTypes].members[k]]/totWght;
            areFs=1;
          }
          MS_czj[tr][f][a][NumTypes].wheel[k]= (k==0) ? adjWght:MS_czj[tr][f][a][NumTypes].wheel[k-1]+adjWght;
        }
        for (k=MS_czj[tr][f][a][NumTypes].numF; k<MS_czj[tr][f][a][NumTypes].numFT; k++)
        {
          if (MS_czj[tr][f][a][NumTypes].weights[MS_czj[tr][f][a][NumTypes].members[k]]<MINWGHT+SMALL)
            adjWght=0;
          else
          {
            adjWght=MS_czj[tr][f][a][NumTypes].weights[MS_czj[tr][f][a][NumTypes].members[k]]/totWght;
            areTs=1;
          }
          MS_czj[tr][f][a][NumTypes].wheel[k]= (k==0) ? adjWght:MS_czj[tr][f][a][NumTypes].wheel[k-1]+adjWght;
        }
        MS_czj[tr][f][a][NumTypes].areFs=areFs;
        MS_czj[tr][f][a][NumTypes].areTs=areTs;
        if (!areFs && !areTs)
        {
          fprintf(stderr, "\tno member of f=%d arg=%d has any weight >MINWGHT\n",f,a);
          exit(1);
        }
      }
      printf("\n\n");
    }
    printf("Root:\n");
    areFs=0;
    areTs=0;
    printf("\t\tF [%d members] =",MS_czj[tr][numF][0][NumTypes].numF);
    for (k=0; k<MS_czj[tr][numF][0][NumTypes].numF; k++)
      printf(" %s",fset[tr].cset[MS_czj[tr][numF][0][NumTypes].members[k]].string);
    printf("\n\t\tT [%d members] =",MS_czj[tr][numF][0][NumTypes].numT);
    for (k=0; k<MS_czj[tr][numF][0][NumTypes].numT; k++)
      printf(" %s", fset[tr].cset[MS_czj[tr][numF][0][NumTypes].members[MS_czj[tr][numF][0][NumTypes].numF+k]].string);
    printf("\n\tReading the weights for type I functions...\n");
    for (k=0; k<MS_czj[tr][numF][0][NumTypes].numF; k++)
    {
      printf("\tFunction \"%s\" [%d]: ",
             fset[tr].cset[MS_czj[tr][numF][0][NumTypes].members[k]].string,
             MS_czj[tr][numF][0][NumTypes].members[k]);
      //MS_czj[tr][numF][0][NumTypes].weights[MS_czj[tr][numF][0][NumTypes].members[k]]= readMinWghtto1("give weight (0,1]");
      what = FTp[tr]->WRoot[k];
      if (what >1 || what<0)
        error(E_FATAL_ERROR, "failed reading weight");
      if (what<MINWGHT)
        what=MINWGHT;                           /* smaller values become minimal */
      MS_czj[tr][numF][0][NumTypes].weights[MS_czj[tr][numF][0][NumTypes].members[k]]=what;
    }
    printf("\n\tReading the weights for type II/III terminals...\n");
    for (k=0; k<MS_czj[tr][numF][0][NumTypes].numT; k++)
    {
      printf("\tTerminal \"%s\" [%d]: ",
             fset[tr].cset[MS_czj[tr][numF][0][NumTypes].members[MS_czj[tr][numF][0][NumTypes].numF+k]].string,
             MS_czj[tr][numF][0][NumTypes].members[MS_czj[tr][numF][0][NumTypes].numF+k]);
      //MS_czj[tr][numF][0][NumTypes].weights[MS_czj[tr][numF][0][NumTypes].members[MS_czj[tr][numF][0][NumTypes].numF+k]]= readMinWghtto1("give weight (0,1]");
      what = FTp[tr]->WRoot[k+numF];
      if (what >1 || what<0)
        error(E_FATAL_ERROR, "failed reading weight");
      if (what<MINWGHT)
        what=MINWGHT;                           /* smaller values become minimal */
      MS_czj[tr][numF][0][NumTypes].weights[MS_czj[tr][numF][0][NumTypes].members[MS_czj[tr][numF][0][NumTypes].numF+k]]=what;
    }
    for (k=0,totWght=0; k<MS_czj[tr][numF][0][NumTypes].numFT; k++)
      totWght+=MS_czj[tr][numF][0][NumTypes].weights[MS_czj[tr][numF][0][NumTypes].members[k]];
    for (k=0; k<MS_czj[tr][numF][0][NumTypes].numF; k++)
    {
      if (MS_czj[tr][numF][0][NumTypes].weights[MS_czj[tr][numF][0][NumTypes].members[k]]<MINWGHT+SMALL)
        adjWght=0;
      else
      {
        adjWght=MS_czj[tr][numF][0][NumTypes].weights[MS_czj[tr][numF][0][NumTypes].members[k]]/totWght;
        areFs=1;
      }
      MS_czj[tr][numF][0][NumTypes].wheel[k]= (k==0) ? adjWght :
                                    MS_czj[tr][numF][0][NumTypes].wheel[k-1]+adjWght;
    }
    for (k=MS_czj[tr][numF][0][NumTypes].numF; k<MS_czj[tr][numF][0][NumTypes].numFT; k++)
    {
      if (MS_czj[tr][numF][0][NumTypes].weights[MS_czj[tr][numF][0][NumTypes].members[k]]<MINWGHT+SMALL)
        adjWght=0;
      else
      {
        adjWght=MS_czj[tr][numF][0][NumTypes].weights[MS_czj[tr][numF][0][NumTypes].members[k]]/totWght;
        areTs=1;
      }
      MS_czj[tr][numF][0][NumTypes].wheel[k]= (k==0) ? adjWght :
                                    MS_czj[tr][numF][0][NumTypes].wheel[k-1]+adjWght;
    }
    MS_czj[tr][numF][0][NumTypes].areFs=areFs;
    MS_czj[tr][numF][0][NumTypes].areTs=areTs;
    if (!areFs && !areTs)
    {
      fprintf(stderr,"\tno member of Root sets has any weight >MINWGHT\n");
      exit(1);
    }
    printf("\n\n");
  }
  fflush(stdout);
}

static void constrain1Type(int t, int tr, int numF, int numFT, mutationSet_czj_t ms, mutationSet_czj_t *newMs)
/* constrains ms for type t into newMs, allocates storage as needed */
{
  int e, f;
  double adjWght;

  // need to allocate enough space for counters
  newMs->counters=(int*)getMoreVec(newMs->counters, numFT*sizeof(int));
  newMs->counters_tot = 0;

  //functions from 0 to numF-1 .... functions
  for (e=0; e<ms.numF; e++)
  {
    f=ms.members[e];
    if (TP_czj[tr][f].f.indexes[t].len>0)             /* function f gives type t */
    {
      newMs->numFT++;
      newMs->members=(int*)getMoreVec(newMs->members,newMs->numFT*sizeof(int));
      newMs->wheel=(double*)getMoreVec(newMs->wheel,newMs->numFT*sizeof(double));
      newMs->members[newMs->numFT-1]=f;
      newMs->numF++;
    }
  }
  //functions from numF to numFT-1 .... terminals, erc
  //note: functions can't return functions.  :-(
  for (e=ms.numF; e<ms.numFT; e++)
  {
    f=ms.members[e];
    if (TP_czj[tr][f].retType==t)                 /* term f gives the right type */
    {
      newMs->numFT++;
      newMs->members=(int*)getMoreVec(newMs->members,newMs->numFT*sizeof(int));
      newMs->wheel=(double*)getMoreVec(newMs->wheel,newMs->numFT*sizeof(double));
      newMs->members[newMs->numFT-1]=f;
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
      if (newMs->weights[newMs->members[e]]<MINWGHT+SMALL)
        adjWght=0;
      else
      {
        adjWght=newMs->weights[newMs->members[e]];
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
/*   in MST_czj[*][*][*][0..NumTypes-1] */
/*      MST_czj[tr][f][a][0..NumTypes-1] */
/* tr=tree, f=function, a=arg */
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
            { constrain1Type(t,tr, numF, numFT, MS_czj[tr][f][a][NumTypes],&MS_czj[tr][f][a][t]);
              break;
            }
          }
        }
      }
    }
    for (t=0; t<NumTypes; t++)
    { if (TP_czj[tr][numFT].retType==t)
        constrain1Type(t,tr, numF, numFT, MS_czj[tr][numF][0][NumTypes],&MS_czj[tr][numF][0][t]);
    }
  }
}

static void displayFT(int tr)
{
  int i, numF, numT;

  numF = pTS[tr].numF;
  numT = pTS[tr].numT;
  printf("%d ordinary functions: \n",numF);
  for (i=0; i<numF; i++)
    printf("%5d = %s\n",i,fset[tr].cset[i].string);
  printf("%d terminals (ordinary and ephemeral): \n",numT);
  for (; i<numF+numT; i++)
    printf("%5d = %s\n",i,fset[tr].cset[i].string);
  printf("Separate entries by [ ,;]  Hit <ENTER> for empty set\n");
  printf("Use either function names or numbers, in any order\n\n");
  fflush(stdout);
}


#if 0 //gwg not used for this version
static void readOneConstraintSet(const char*prompt, specArrays_t setP, int max)
/* read one set from one line; max is the highest index allowed */
{
  int entry, status;
  char buf[BUFSIZ];
  char sep[]=" ,;\n";
  char *p;
  for (entry=0; entry<NumF+NumT; entry++)
    setP->members[entry]=0;                            /* reset set to empty */
  setP->numF=setP->numT=0;                          /* reset member counters */
  printf("%s [0..%d] = ",prompt,max);
  if (fgets(buf,BUFSIZ,stdin)==NULL)
  {
    fprintf(stderr,"ERROR: failed reading constrained\n");
    exit(1);
  }
  p=strtok(buf,sep);
  while (p!=NULL)
  {
    if ((entry=funNumber(p,0))>=0 || (sscanf(p,"%d",&entry)>0))
    {
      if (entry<0 || entry >max)
        printf("\a\t\t%d entry out of range\n",entry);
      else                                /* entry is a valid function index */
      {
        setP->members[entry]=1;
        if (entry<NumF)
          setP->numF++;
        else
          setP->numT++;
      }
    }
    else               /* failed reading an integer or invalid function name */
      printf("\t\ainvalid entry\n");
    p=strtok(NULL,sep);
  }
}
#endif

static void print_FTp_names(int tr, int numF, int numT)
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
  fflush(stdout);
}

//note: Tspecs syntactic constraints, Fspecs symantic constraints, in generateNF converted to all Fspecs
static void buildConstraints(void)
{
  int i, j, k, numF, numT, numFT,tr;
  char prompt[BUFSIZ];

  printf("%s\n","Creating Constraints (Cons) array:");
  Cons=(constraint_t**)malloc(tree_count * sizeof(constraint_t*));
  /* last entry for the Root */
  for(tr = 0; tr < tree_count; tr++ )
  {
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    numFT = numF+numT;
    Cons[tr]=(constraint_t*)getVec((size_t)(numF+1),sizeof(constraint_t));
    for (i=0; i<numF; i++)
    {
      print_FTp_names(tr, numF, numT);
      printf("Tree: %s -> Function '%s':\n",FTp[tr]->treeName,fset[tr].cset[i].string);
      fflush(stdout);
      Cons[tr][i].arity=fset[tr].cset[i].arity;
      Cons[tr][i].Fspec=(specArrays_t)getVec((size_t)1,sizeof(specArrayArg_t));
      Cons[tr][i].Fspec[0].members=(specArray_t)getVec((size_t)(numF+numT),sizeof(int));

      sprintf(prompt,"\tF_%s (exclusions)",fset[tr].cset[i].string);
      fflush(stdout);
      //read1ConSet(prompt,&(Cons[tr][i].Fspec[0]),numF-1, numF, numT);     /* type I only here */
      for (k=0; k<numFT; k++)
        Cons[tr][i].Fspec[0].members[k]=0;
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
          Cons[tr][i].Fspec[0].members[k]=1;
          if (k<numF)
            Cons[tr][i].Fspec[0].numF++;
          else
            Cons[tr][i].Fspec[0].numT++;
        }
      }
      Cons[tr][i].Tspecs=(specArrays_t)getVec((size_t)Cons[tr][i].arity,sizeof(specArrayArg_t));
      Cons[tr][i].Fspecs=(specArrays_t)getVec((size_t)Cons[tr][i].arity,sizeof(specArrayArg_t));
      for (j=0; j<Cons[tr][i].arity; j++)
      {
        Cons[tr][i].Tspecs[j].members=(specArray_t)getVec((size_t)(numF+numT),sizeof(int));
        Cons[tr][i].Fspecs[j].members=(specArray_t)getVec((size_t)(numF+numT),sizeof(int));

        sprintf(prompt,"\tF_%s_%d (exclusions)",fset[tr].cset[i].string,j);
        fflush(stdout);
        //read1ConSet(prompt,&(Cons[tr][i].Fspecs[anum]),numFT-1, numF, numT);
        for (k=0; k<numFT; k++)
          Cons[tr][i].Fspecs[j].members[k]=0;
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
            Cons[tr][i].Fspecs[j].members[k]=1;
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
          Cons[tr][i].Tspecs[j].members[k]=0;
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
            Cons[tr][i].Tspecs[j].members[k]=1;
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
    Cons[tr][i].Tspecs=(specArrays_t)getVec((size_t)1,sizeof(specArrayArg_t));
    Cons[tr][i].Fspecs=(specArrays_t)getVec((size_t)1,sizeof(specArrayArg_t));
    Cons[tr][i].Tspecs[0].members=(specArray_t)getVec((size_t)(numF+numT),sizeof(int));
    Cons[tr][i].Fspecs[0].members=(specArray_t)getVec((size_t)(numF+numT),sizeof(int));
    print_FTp_names(tr, numF, numT);
    printf("Root:");
    fflush(stdout);

    //read1ConSet("\tF^Root (exclusions)",&(Cons[tr][numF].Fspecs[0]),numF+numT-1, numF, numT);
    for (k=0; k<numFT; k++)
      Cons[tr][i].Fspecs->members[k]=0;
    Cons[tr][i].Fspecs->numF=0;
    Cons[tr][i].Fspecs->numT=0;
    printf("%s [up to %d names] = ",prompt,numF+1);
    fflush(stdout);
    for ( k = 0; k < numFT; k++ )
    {
      if ( FTp[tr]->FRoot[k] )
      {
        printf("%s ", funcTermName(tr,k));          /* printf T_Root */
        fflush(stdout);
        Cons[tr][i].Fspecs->members[k]=1;
        if (k<numF)
          Cons[tr][i].Fspecs->numF++;
        else
          Cons[tr][i].Fspecs->numT++;
      }
    }

    //read1ConSet("\tT^Root (inclusions)",&(Cons[tr][numF].Tspecs[0]),numF+numT-1, numF, numT);
    for (k=0; k<numFT; k++)
      Cons[tr][i].Tspecs->members[k]=0;
    Cons[tr][i].Tspecs->numF=0;
    Cons[tr][i].Tspecs->numT=0;
    printf("%s [up to %d names] = ",prompt,numF+1);
    fflush(stdout);
    for ( k = 0; k < numFT; k++ )
    {
      if ( FTp[tr]->TRoot[k] )
      {
        printf("%s ", funcTermName(tr,k));          /* printf T_Root */
        fflush(stdout);
        Cons[tr][i].Tspecs->members[k]=1;
        if (k<numF)
          Cons[tr][i].Tspecs->numF++;
        else
          Cons[tr][i].Tspecs->numT++;
      }
    }
  }
}


static void generateNF(void)
/* from specs of Constraints generate NF in Fspecs of Constraints */
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
          if (Cons[tr][fun].Tspecs[arg].members[entry]==0)
            Cons[tr][fun].Fspecs[arg].members[entry]=1;
    for (entry=0; entry<numF+numT; entry++)               /* same for the Root */
      if (Cons[tr][numF].Tspecs[0].members[entry]==0)
        Cons[tr][numF].Fspecs[0].members[entry]=1;

    for (fun=0; fun<numF; fun++)              /* now create F-extensive Fspecs */
      for (entry=0; entry<numF; entry++)
        if (Cons[tr][fun].Fspec[0].members[entry]!=0)     /* must extend it */
          for (arg=0; arg<Cons[tr][entry].arity; arg++)
            Cons[tr][entry].Fspecs[arg].members[fun]=1;

    for (fun=0; fun<numF+1; fun++)            /* recount set entries in Fspecs */
      for (arg=0; arg<Cons[tr][fun].arity; arg++)
      {
        Cons[tr][fun].Fspecs[arg].numF=0;
        Cons[tr][fun].Fspecs[arg].numT=0;
        for (entry=0; entry<numF; entry++)
          if (Cons[tr][fun].Fspecs[arg].members[entry]!=0)
            Cons[tr][fun].Fspecs[arg].numF++;
        for (; entry<numF+numT; entry++)
          if (Cons[tr][fun].Fspecs[arg].members[entry]!=0)
            Cons[tr][fun].Fspecs[arg].numT++;
      }
  }
}

static void generateMS(void)
/* create MS from the Fspecs part (ie F-intensive) of Constraints */
{
  int tr, f, a, e, k, t, v, numF, numT, numFT, NumTypes;
  char buf[BUFSIZ];

  MS_czj=(void*)malloc(tree_count * sizeof(mutationSet_czj_t**));

  for(tr = 0; tr < tree_count; tr++)
  {
    numF     = pTS[tr].numF;
    numT     = pTS[tr].numT;
    numFT    = numF+numT;
    NumTypes = FTp[tr]->TypCount;

    MS_czj[tr]=(void*)malloc((numF+1) * sizeof(mutationSet_czj_t*));  /* one (last) entry for the Root */
    for (f=0; f<numF; f++)                   /* set all type I functions */
    {
      MS_czj[tr][f]=(void*)malloc(fset[tr].cset[f].arity * sizeof(mutationSet_czj_t));
      for (a=0; a<fset[tr].cset[f].arity; a++)
      {
        MS_czj[tr][f][a]=(void*)getVec((size_t)(NumTypes+1),sizeof(mutationSet_czj_t));
        for (t=0; t<NumTypes; t++)
        {
          MS_czj[tr][f][a][t].numF=0;
          MS_czj[tr][f][a][t].numT=0;
          MS_czj[tr][f][a][t].numFT=0;
          MS_czj[tr][f][a][t].areFs=0;
          MS_czj[tr][f][a][t].areTs=0;
          MS_czj[tr][f][a][t].members=NULL;
          //MS_czj[tr][f][a][t].counters=NULL;
          MS_czj[tr][f][a][t].counters=(int*)malloc(numFT * sizeof(int));
          for(v = 0; v < numFT; v++)
          {
            MS_czj[tr][f][a][t].counters[v] = 0;
          }
          MS_czj[tr][f][a][t].counters_tot=0;
          MS_czj[tr][f][a][t].wheel=NULL;
          MS_czj[tr][f][a][t].weights=NULL;
        }

        MS_czj[tr][f][a][NumTypes].numF=numF-Cons[tr][f].Fspecs[a].numF;
        MS_czj[tr][f][a][NumTypes].numT=numT-Cons[tr][f].Fspecs[a].numT;
        MS_czj[tr][f][a][NumTypes].numFT=MS_czj[tr][f][a][NumTypes].numF+MS_czj[tr][f][a][NumTypes].numT;
        if (MS_czj[tr][f][a][NumTypes].numFT==0)
        {
          sprintf(buf,"\n\tBoth sets empty for function %d=%s argument %d\n\a", f,fset[tr].cset[f].string,a);
          error(E_FATAL_ERROR,buf);
        }
        MS_czj[tr][f][a][NumTypes].members= (int*)malloc((MS_czj[tr][f][a][NumTypes].numFT) * sizeof(int));
        MS_czj[tr][f][a][NumTypes].weights= (double*)malloc((size_t)(numFT) * sizeof(double));
        MS_czj[tr][f][a][NumTypes].counters=(int*)malloc((MS_czj[tr][f][a][NumTypes].numFT) * sizeof(int));/* czjmmh */
        MS_czj[tr][f][a][NumTypes].counters_tot=0;
        MS_czj[tr][f][a][NumTypes].wheel=(double*)malloc((MS_czj[tr][f][a][NumTypes].numFT) * sizeof(double));
        for (e=0,k=0; k<numF+numT; k++)
          if (Cons[tr][f].Fspecs[a].members[k]==0)
          {
            MS_czj[tr][f][a][NumTypes].members[e]=k;
            MS_czj[tr][f][a][NumTypes].weights[k]=1.0/MS_czj[tr][f][a][NumTypes].numFT;
            MS_czj[tr][f][a][NumTypes].wheel[e]= (e==0) ?
                                               MS_czj[tr][f][a][NumTypes].weights[k] :
                                               MS_czj[tr][f][a][NumTypes].wheel[e-1]+MS_czj[tr][f][a][NumTypes].weights[k];
            e++;
          }
          else
            MS_czj[tr][f][a][NumTypes].weights[k]= -1.0;

        MS_czj[tr][f][a][NumTypes].areFs= !!MS_czj[tr][f][a][NumTypes].numF;
        MS_czj[tr][f][a][NumTypes].areTs= !!MS_czj[tr][f][a][NumTypes].numT;
      }
    }

    // gwgfix double check [0] part below.  Does that mean left argument and we are ignoring right arg [1]?
    MS_czj[tr][numF]=(void*)malloc(1 *  sizeof(mutationSet_czj_t)); /* for the Root */
    MS_czj[tr][numF][0]=(void*)getVec((size_t)(NumTypes+1),sizeof(mutationSet_czj_t));
    for (t=0; t<NumTypes; t++)
    {
      MS_czj[tr][numF][0][t].numF=0;
      MS_czj[tr][numF][0][t].numT=0;
      MS_czj[tr][numF][0][t].numFT=0;
      MS_czj[tr][numF][0][t].areFs=0;
      MS_czj[tr][numF][0][t].areTs=0;
      MS_czj[tr][numF][0][t].members=NULL;
      //MS_czj[tr][numF][0][t].counters=NULL;
      MS_czj[tr][numF][0][t].counters=(int*)malloc(numFT * sizeof(int));
      for(v = 0; v < numFT; v++)
      {
        MS_czj[tr][numF][0][t].counters[v] = 0;
      }

      MS_czj[tr][numF][0][t].counters_tot=0;
      MS_czj[tr][numF][0][t].wheel=NULL;
      MS_czj[tr][numF][0][t].weights=NULL;
    }
    MS_czj[tr][numF][0][NumTypes].numF=numF-Cons[tr][numF].Fspecs[0].numF;
    MS_czj[tr][numF][0][NumTypes].numT=numT-Cons[tr][numF].Fspecs[0].numT;
    MS_czj[tr][numF][0][NumTypes].numFT=MS_czj[tr][numF][0][NumTypes].numF+MS_czj[tr][numF][0][NumTypes].numT;
    if (MS_czj[tr][numF][0][NumTypes].numFT==0)
    {
      sprintf(buf, "%s", "\n\tBoth Root sets empty - no valid programs exist\n\a");
      error(E_FATAL_ERROR,buf);
    }
    MS_czj[tr][numF][0][NumTypes].members= (int*)malloc((MS_czj[tr][numF][0][NumTypes].numFT) * sizeof(int));
    MS_czj[tr][numF][0][NumTypes].weights= (double*)malloc((size_t)(numFT) * sizeof(double));
    MS_czj[tr][numF][0][NumTypes].counters=(int*)malloc((MS_czj[tr][numF][0][NumTypes].numFT) * sizeof(int));/* czjmmh */
    MS_czj[tr][numF][0][NumTypes].counters_tot=0;
    MS_czj[tr][numF][0][NumTypes].wheel= (double*)malloc((MS_czj[tr][numF][0][NumTypes].numFT) * sizeof(double));
    for (e=0,k=0; k<numF+numT; k++)
      if (Cons[tr][numF].Fspecs[0].members[k]==0)
      {
        MS_czj[tr][numF][0][NumTypes].members[e]=k;
        MS_czj[tr][numF][0][NumTypes].weights[k]=1.0/MS_czj[tr][numF][0][NumTypes].numFT;
        MS_czj[tr][numF][0][NumTypes].wheel[e]=(e==0) ?
                                         MS_czj[tr][numF][0][NumTypes].weights[k] :
                                         MS_czj[tr][numF][0][NumTypes].wheel[e-1]+MS_czj[tr][numF][0][NumTypes].weights[k];
        e++;
      }
      else
      {
        MS_czj[tr][numF][0][NumTypes].weights[k]= -1.0;
      }

    MS_czj[tr][numF][0][NumTypes].areFs= !!MS_czj[tr][numF][0][NumTypes].numF;
    MS_czj[tr][numF][0][NumTypes].areTs= !!MS_czj[tr][numF][0][NumTypes].numT;
  }
  acgp_reset_count();
}

void displayFTpV1(const char *message)
{
  int i, j, k, tr, instType, t;
  int nF, nT, nFT; /* nF function, nT terminal, nFT funciton+term count */
  //int inst;
  //int sz;

  for(tr = 0; tr < tree_count; tr++)
  {
    nF = pTS[tr].numF;
    nT = pTS[tr].numT;
    nFT = nF+nT;

    /* printing primary data structure and arrays in it */

    printf("Tree %2d, %s\n",tr, FTp[tr]->treeName);

    /* print default type root, it is an integer */
    printf("tr=%d, TypRoot=%2d\n", tr, FTp[tr]->TypRoot);

    /* next will be set to false if appropriate section appears in the interface file, bool values */
    printf("tr=%2d, DefaultType=%2d\n", tr,   FTp[tr]->DefaultType);
    printf("tr=%2d, DefaultFT=%2d\n", tr,   FTp[tr]->DefaultFT);
    printf("tr=%2d, DefaultWeight=%2d\n", tr,  FTp[tr]->DefaultWeight);
    fflush(stdout);

    /* printing terminal type */
    for (i = 0; i < nT; i++)
      printf("tr=%2d, TypTerm=%2d\n", tr, FTp[tr]->TypTerm[i]);
    fflush(stdout);

    for (i = 0; i < nFT; i++)
    {
      printf("tr=%2d, FRoot[%d]=%2d\n", tr, i, FTp[tr]->FRoot[i]);
      printf("tr=%2d, TRoot[%d]=%2d\n", tr, i, FTp[tr]->TRoot[i]);
      printf("tr=%2d, WRoot[%d]=%f\n" , tr, i,  FTp[tr]->WRoot[i]);
    }
    fflush(stdout);
    /* fill the array of FT_funcs */
    for (i = 0; i < nF; i++)
    {

      // used for checking that we have at least one type and used for multiple type overloading, do a search to see how it is used
      printf("tr=%2d, func[%d].instCount=%2d\n", tr, i, FTp[tr]->Func[i].instCount);

      t=0;
      //print out instruction list, it just holds indexes to types, used in TP_czj for multiple types
      printf("tr=%2d, instruction type list: ",tr);
      inst_t* pi;
      for(pi = FTp[tr]->Func[i].head; pi != NULL; pi = pi->next)
      { printf("[%d]=%s", t, "(");
        if(pi->inst) // calloc in buildData
        { instType = *(pi->inst);
          printf("%d", instType);
        }
        else
        {
          printf("%s","empty");
        }
        printf("%s",") ");
        t++;
      }
      printf("%s","\n");
      fflush(stdout);

      //FTp[tr]->Func[i].F = (boolean *)calloc( nF, sizeof(boolean) );
      // A FxF array of booleans
      for (j = 0; j < nF; j++)
        printf("tr=%2d, Func[%d].F[%d]=%2d\n",tr, i, j, FTp[tr]->Func[i].F[j]);
      fflush(stdout);

      /* allocate the array for FT_func_[args] */
      //FTp[tr]->Func[i].Arg = (FuncArgList_t *)calloc( funcArity(tr,i), sizeof(FuncArgList_t) );
      // a bunch of booleans for T and F, float for W
      for (j = 0; j < funcArity(tr,i); j++)
      {
        for (k = 0; k < nFT; k++)
        {
          printf("tr=%2d, Func[%d].Arg[%d].F[%d]=%2d\n",tr,i,j,k,FTp[tr]->Func[i].Arg[j].F[k]);
          printf("tr=%2d, Func[%d].Arg[%d].T[%d]=%2d\n",tr,i,j,k,FTp[tr]->Func[i].Arg[j].T[k]);
          printf("tr=%2d, Func[%d].Arg[%d].W[%d]=%f\n",tr,i,j,k,FTp[tr]->Func[i].Arg[j].W[k]);
        }
      }
      printf("%s","\n");
      fflush(stdout);
    }
  }
}

void savefileFTpV1(const char* fname, const char *message)
{
  int i, j, k, tr, instType, t;
  int nF, nT, nFT; /* nF function, nT terminal, nFT funciton+term count */
  FILE* fh = NULL;

  fh = fopen(fname, "w");
  if(fh == NULL)
    return;

  fprintf(fh, "FTp ->  %s\n",message);
  fprintf(fh, "%s", "\n");

  for(tr = 0; tr < tree_count; tr++)
  {
    nF = pTS[tr].numF;
    nT = pTS[tr].numT;
    nFT = nF+nT;

    /* printing primary data structure and arrays in it */

    fprintf(fh, "Tree[%d]=%s:\n",tr, FTp[tr]->treeName);

    /* print default type root, it is an integer */
    fprintf(fh, " FTp[%d]:\n", tr);
    fprintf(fh, "  ->TypRoot=%d\n", FTp[tr]->TypRoot);

    /* next will be set to false if appropriate section appears in the interface file, bool values */
    fprintf(fh, "  ->DefaultType=%d\n", FTp[tr]->DefaultType);
    fprintf(fh, "  ->DefaultFT=%d\n", FTp[tr]->DefaultFT);
    fprintf(fh, "  ->DefaultWeight=%d\n", FTp[tr]->DefaultWeight);

    /* printing terminal type */
    fprintf(fh, "%s", "  ->TypeTerm:\n");
    for (i = 0; i < nT; i++)
      fprintf(fh, "   ->TypTerm[%d]=%d\n", i, FTp[tr]->TypTerm[i]);

    fprintf(fh, "%s", "  ->FRoot:\n");
    for (i = 0; i < nFT; i++)
    {
      fprintf(fh, "   ->FRoot[%d]=%2d\n", i, FTp[tr]->FRoot[i]);
    }

    fprintf(fh, "%s", "  ->TRoot:\n");
    for (i = 0; i < nFT; i++)
    {
      fprintf(fh, "   ->TRoot[%d]=%2d\n", i, FTp[tr]->TRoot[i]);
    }

    fprintf(fh, "%s", "  ->WRoot:\n");
    for (i = 0; i < nFT; i++)
    {
      fprintf(fh, "   ->WRoot[%d]=%f\n" , i,  FTp[tr]->WRoot[i]);
    }

    /* fill the array of FT_funcs */
    for (i = 0; i < nF; i++)
    {
      t=0;
      // used for checking that we have at least one type and used for multiple type overloading, do a search to see how it is used
      // gwgnote: the instCount and linked list just used for internal purposes.
      fprintf(fh, "  ->func[%d].instCount=%d\n", i, FTp[tr]->Func[i].instCount);
      //print out instruction list, it just holds indexes to types
      fprintf(fh, "  type list: ");
      inst_t* pi;
      for(pi = FTp[tr]->Func[i].head; pi != NULL; pi = pi->next)
      { fprintf(fh, "[%d]=%s", t, "(");
        if(pi->inst) // calloc in buildData
        { instType = *(pi->inst);
          fprintf(fh, "%d", instType);
        }
        else
        {
          fprintf(fh, "%s","empty");
        }
        fprintf(fh, "%s",") ");
        t++;
      }
      fprintf(fh, "%s","\n");

      // A FxF array of booleans
      for (j = 0; j < nF; j++)
        fprintf(fh, "  ->Func[%d].F[%d]=%2d\n", i, j, FTp[tr]->Func[i].F[j]);

      // a bunch of booleans for T and F, float for W
      for (j = 0; j < funcArity(tr,i); j++)
      { for (k = 0; k < nFT; k++)
        { fprintf(fh, "  ->Func[%d].Arg[%d].F[%d]=%2d\n",i,j,k,FTp[tr]->Func[i].Arg[j].F[k]);
        }
      }
      for (j = 0; j < funcArity(tr,i); j++)
      { for (k = 0; k < nFT; k++)
        {  fprintf(fh, "  ->Func[%d].Arg[%d].T[%d]=%2d\n",i,j,k,FTp[tr]->Func[i].Arg[j].T[k]);
        }
      }
      for (j = 0; j < funcArity(tr,i); j++)
      { for (k = 0; k < nFT; k++)
        {  fprintf(fh, "  ->Func[%d].Arg[%d].W[%d]=%f\n",i,j,k,FTp[tr]->Func[i].Arg[j].W[k]);
        }
      }

    }
    fprintf(fh, "%s", "\n");
  }
  fflush(fh);
  fclose(fh);
}

void displayFTpV2(const char *message)
{
  int i, j, k, numF, numT, numFT, tr;

  for(tr = 0; tr < tree_count; tr++ )
  {
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    numFT = numF+numT;

    printf("Tree[%d]=%s:\n",tr, FTp[tr]->treeName);
    printf(" %s","Types in Tree:");
    for(i = 0; i < FTp[tr]->TypCount; i++)
    {
      printf("%s ", FTp[tr]->TypList[i] );
    }
    printf("%s","\n");
    printf("  %s\n", "Function Info");
    for(i = 0; i < numF; i++)
    {
      //printf("  %s:\n", funcTermName(tr, i));
      // gwgnote: the instCount and linked list just used for internal purposes.
      printf("  Function instCount -> %d \n", FTp[tr]->Func[i].instCount);
      printf("  Func[%d]: %s\n",i ,funcTermName(tr, i));
      printf("  %s\n", "Function Arg Info");
      for (j = 0; j < funcArity(tr,i); j++)
      {
        printf("   Func[%d]: %s -> Arg Num %d:\n",i ,funcTermName(tr, i), j);
        for (k = 0; k < numFT; k++)
        {
          printf("    bool  Func[%d].Arg[%d].F[%d]-> %d \n", i, j,  k, FTp[tr]->Func[i].Arg[j].F[k]);
          printf("    bool  Func[%d].Arg[%d].T[%d]-> %d \n", i, j, k, FTp[tr]->Func[i].Arg[j].T[k]);
          printf("    float Func[%d].Arg[%d].W[%d]-> %f \n", i, j, k, FTp[tr]->Func[i].Arg[j].W[k]);
        }
        printf("%s","\n");
      }
    }
  }
  fflush(stdout);
}

void savefileFTpV2(const char* fname, const char *message)
{
  int i, j, k, tr, numF, numT, numFT;
  FILE* fh = NULL;

  fh = fopen(fname, "w");
  if(fh == NULL)
    return;

  fprintf(fh, "FTp ->  %s\n",message);
  fprintf(fh, "%s", "\n");

  for(tr = 0; tr < tree_count; tr++ )
  {
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    numFT = numF+numT;

    fprintf(fh, "Tree[%d]=%s:\n",tr, FTp[tr]->treeName);
    fprintf(fh, " %s","Types in Tree:");
    for(i = 0; i < FTp[tr]->TypCount; i++)
    {
      fprintf(fh, "%s ", FTp[tr]->TypList[i] );
    }
    fprintf(fh, "%s","\n");
    fprintf(fh, "  %s\n", "Function Info");
    for(i = 0; i < numF; i++)
    {
      //printf("  %s:\n", funcTermName(tr, i));
      // gwgnote: the instCount and linked list just used for internal purposes.
      fprintf(fh, "  Function instCount -> %d \n", FTp[tr]->Func[i].instCount);
      fprintf(fh, "  Func[%d]: %s\n",i ,funcTermName(tr, i));
      fprintf(fh, "  %s\n", "Function Arg Info");
      for (j = 0; j < funcArity(tr,i); j++)
      {
        fprintf(fh, "   Func[%d]: %s -> Arg Num %d:\n",i ,funcTermName(tr, i), j);
        for (k = 0; k < numFT; k++)
        {
          fprintf(fh, "    bool  Func[%d].Arg[%d].F[%d]-> %d \n", i, j,  k, FTp[tr]->Func[i].Arg[j].F[k]);
          fprintf(fh, "    bool  Func[%d].Arg[%d].T[%d]-> %d \n", i, j, k, FTp[tr]->Func[i].Arg[j].T[k]);
          fprintf(fh, "    float Func[%d].Arg[%d].W[%d]-> %f \n", i, j, k, FTp[tr]->Func[i].Arg[j].W[k]);
        }
        fprintf(fh, "%s","\n");
      }
    }
  }

  fflush(fh);
  fclose(fh);
}

void displayFTpV3(const char *message)
{
  int i, j, k, numF, numT, numFT, tr;

  //prints out what was read in
  int fnum, anum, snum;
  for(tr = 0; tr < tree_count; tr++ )
  {
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    numFT = numF+numT;
    printf("Tree[%d]=%s:\n",tr, FTp[tr]->treeName);
    for ( fnum = 0; fnum < numF; fnum++ )
    {
      printf(" Func[%d] (%s): ", fnum, funcTermName(tr, fnum));
      for ( snum = 0; snum < numF; snum++ )
      {
        //printf(" Func[%d].F[%d]: ",fnum, snum);
        if ( FTp[tr]->Func[fnum].F[snum] )
        {
          printf("%s ", funcTermName(tr,snum));         /* printf F_func */
        }
      }
      printf("%s","\n");
      printf("  Func[%d] (%s) args:\n", fnum, funcTermName(tr, fnum));
      for ( anum = 0; anum < funcArity(tr,fnum); anum++ )
      {
        printf("  %s: ","F_func[arg] names ");
        for ( snum = 0; snum < numFT; snum++ )
        {
          //printf("  Func[%d].Arg[%d].F[%d]: ",fnum, anum, snum);
          if ( FTp[tr]->Func[fnum].Arg[anum].F[snum] )
          {
            printf("%s ", funcTermName(tr,snum));      /*printf F_func[arg]*/
          }
        }
        printf("%s","\n");
        printf("  %s: ","T_func[arg] names ");
        for ( snum = 0; snum < numFT; snum++ )
        {
          //printf(" Func[%d].Arg[%d].T[%d]: ",fnum, anum, snum);
          if ( FTp[tr]->Func[fnum].Arg[anum].T[snum] )
          {
            printf("%s ", funcTermName(tr,snum));      /*printf T_func[arg]*/
          }
        }
        printf("%s","\n");
      }
    }
    printf(" %s:","F_Root names");
    for ( snum = 0; snum < numFT; snum++ )
    {
      if ( FTp[tr]->FRoot[snum] )
      {
        printf( "%s ", funcTermName(tr,snum));          /* printf F_Root */
      }
    }
    printf("%s","\n");
    printf(" %s: ","T_Root names");
    for ( snum = 0; snum < numFT; snum++ )
    {
      if ( FTp[tr]->TRoot[snum] )
      {
        printf("%s ", funcTermName(tr,snum));          /* printf T_Root */
      }
    }
    printf("%s","\n");
  }
  fflush(stdout);
}

void savefileFTpV3(const char* fname, const char *message)
{
  int i, j, k, tr, numF, numT, numFT;
  FILE* fh = NULL;

  fh = fopen(fname, "w");
  if(fh == NULL)
    return;

  fprintf(fh, "FTp ->  %s\n",message);
  fprintf(fh, "%s", "\n");

  //prints out what was read in
  int fnum, anum, snum;
  for(tr = 0; tr < tree_count; tr++ )
  {
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    numFT = numF+numT;

    fprintf(fh, "Tree[%d]=%s:\n",tr, FTp[tr]->treeName);
    for ( fnum = 0; fnum < numF; fnum++ )
    {
      fprintf(fh, " Func[%d] (%s): ", fnum, funcTermName(tr, fnum));
      for ( snum = 0; snum < numF; snum++ )
      {
        //printf(" Func[%d].F[%d]: ",fnum, snum);
        if ( FTp[tr]->Func[fnum].F[snum] )
        {
          fprintf(fh, "%s ", funcTermName(tr,snum));         /* printf F_func */
        }
      }
      fprintf(fh, "%s","\n");
      fprintf(fh, "  Func[%d] (%s) args:\n", fnum, funcTermName(tr, fnum));
      for ( anum = 0; anum < funcArity(tr,fnum); anum++ )
      {
        fprintf(fh, "  %s: ","F_func[arg] names ");
        for ( snum = 0; snum < numFT; snum++ )
        {
          //printf("  Func[%d].Arg[%d].F[%d]: ",fnum, anum, snum);
          if ( FTp[tr]->Func[fnum].Arg[anum].F[snum] )
          {
            fprintf(fh, "%s ", funcTermName(tr,snum));      /*printf F_func[arg]*/
          }
        }
        fprintf(fh, "%s","\n");
        fprintf(fh, "  %s: ","T_func[arg] names ");
        for ( snum = 0; snum < numFT; snum++ )
        {
          //printf(" Func[%d].Arg[%d].T[%d]: ",fnum, anum, snum);
          if ( FTp[tr]->Func[fnum].Arg[anum].T[snum] )
          {
            fprintf(fh, "%s ", funcTermName(tr,snum));      /*printf T_func[arg]*/
          }
        }
        fprintf(fh, "%s","\n");
      }
    }
    fprintf(fh, " %s:","F_Root names");
    for ( snum = 0; snum < numFT; snum++ )
    {
      if ( FTp[tr]->FRoot[snum] )
      {
        fprintf(fh,  "%s ", funcTermName(tr,snum));          /* printf F_Root */
      }
    }
    fprintf(fh, "%s","\n");
    fprintf(fh, " %s: ","T_Root names");
    for ( snum = 0; snum < numFT; snum++ )
    {
      if ( FTp[tr]->TRoot[snum] )
      {
        fprintf(fh, "%s ", funcTermName(tr,snum));          /* printf T_Root */
      }
    }
    fprintf(fh, "%s","\n");
  }

  fflush(fh);
  fclose(fh);
}

#if 0 //gwgnote: older version
void savefileFTp(const char* fname, const char *message)
{
  int i, j, k, tr;
  int nF, nT, nFT; /* nF function, nT terminal, nFT funciton+term count */
//  int inst;
//  int sz;
  FILE* fh = NULL;

  fh = fopen(fname, "w");
  if(fh == NULL)
    return;

  fprintf(fh, "%s\n",message);
  fprintf(fh, "%s", "\n");

  for(tr = 0; tr < tree_count; tr++)
  {
    nF = pTS[tr].numF;
    nT = pTS[tr].numT;
    nFT = nF+nT;

    /* printing primary data structure and arrays in it */

    fprintf(fh, "Tree %2d, %s\n",tr, FTp[tr]->treeName);

    /* print default type root, it is an integer */
    fprintf(fh, "tr=%d, TypRoot=%2d\n", tr, FTp[tr]->TypRoot);

    /* next will be set to false if appropriate section appears in the interface file, bool values */
    fprintf(fh, "tr=%2d, DefaultType=%2d\n", tr,   FTp[tr]->DefaultType);
    fprintf(fh, "tr=%2d, DefaultFT=%2d\n", tr,   FTp[tr]->DefaultFT);
    fprintf(fh, "tr=%2d, DefaultWeight=%2d\n", tr,  FTp[tr]->DefaultWeight);

    /* printing terminal type */
    for (i = 0; i < nT; i++)
      fprintf(fh, "tr=%2d, TypTerm=%2d\n", tr, FTp[tr]->TypTerm[i]);

    for (i = 0; i < nFT; i++)
    {
      fprintf(fh, "tr=%2d, FRoot[%d]=%2d\n", tr, i, FTp[tr]->FRoot[i]);
      fprintf(fh, "tr=%2d, TRoot[%d]=%2d\n", tr, i, FTp[tr]->TRoot[i]);
      fprintf(fh, "tr=%2d, WRoot[%d]=%f\n" , tr, i,  FTp[tr]->WRoot[i]);
    }
    /* fill the array of FT_funcs */
    for (i = 0; i < nF; i++)
    {

      // used for checking that we have at least one type and used for multiple type overloading, do a search to see how it is used
      fprintf(fh, "tr=%2d, func[%d].instCount=%2d\n", tr, i, FTp[tr]->Func[i].instCount);

#if 0
      //print out instruction list, it just holds indexes to types
      fprintf(fh, "tr=%2d, Func[%d].head=",tr,i);
      for(inst_t* pi = FTp[tr]->Func[i].head; pi != NULL; pi = pi->next)
      {
        inst = pi->inst;
        fprintf(fh, "%d ", inst);
      }
      fprintf(fh, "%s","\n");
#endif

      //FTp[tr]->Func[i].F = (boolean *)calloc( nF, sizeof(boolean) );
      // A FxF array of booleans
      for (j = 0; j < nF; j++)
        fprintf(fh, "tr=%2d, Func[%d].F[%d]=%2d\n",tr, i, j, FTp[tr]->Func[i].F[j]);

      /* allocate the array for FT_func_[args] */
      //FTp[tr]->Func[i].Arg = (FuncArgList_t *)calloc( funcArity(tr,i), sizeof(FuncArgList_t) );
      // a bunch of booleans for T and F, float for W
      for (j = 0; j < funcArity(tr,i); j++)
      {
        for (k = 0; k < nFT; k++)
        {
          fprintf(fh, "tr=%2d, Func[%d].Arg[%d].F[%d]=%2d\n",tr,i,j,k,FTp[tr]->Func[i].Arg[j].F[k]);
          fprintf(fh, "tr=%2d, Func[%d].Arg[%d].T[%d]=%2d\n",tr,i,j,k,FTp[tr]->Func[i].Arg[j].T[k]);
          fprintf(fh, "tr=%2d, Func[%d].Arg[%d].W[%d]=%f\n",tr,i,j,k,FTp[tr]->Func[i].Arg[j].W[k]);
        }
      }
    }
    fprintf(fh, "%s", "\n");
  }
  fflush(fh);
  fclose(fh);
}
#endif

void savefileFSet(const char* fname, const char *message)
{
  int tr,i;
  FILE* fh = NULL;

  fh = fopen(fname, "w");
  if(fh == NULL)
    return;

  fprintf(fh, "%s\n",message);
  fprintf(fh, "%s", "\n");
  for(tr = 0; tr < fset_count; tr++)
  { fprintf(fh, "evaltree: %d:\n", tr);
    fprintf(fh, " fset[%d]:\n", tr);
    fprintf(fh, "  .function_count=%d\n", fset[tr].function_count);
    fprintf(fh, "  .terminal_count=%d\n", fset[tr].terminal_count);
    fprintf(fh, "  .num_args=%d\n",       fset[tr].num_args);
    fprintf(fh, "  .size=%d\n",           fset[tr].size );
    for (i=0; i<fset[tr].size; i++)
    { fprintf(fh, "   .cset[%d]\n",i);
      fprintf(fh, "    .string=%-6.6s\n", fset[tr].cset[i].string);
      fprintf(fh, "    .arity=%-d\n",     fset[tr].cset[i].arity);
      fprintf(fh, "    .type=%-d ",       fset[tr].cset[i].type);
      switch(fset[tr].cset[i].type)
      {
      case TERM_NORM:
        fprintf(fh, "%s\n", "TERM_NORM");
        break;
      case TERM_ERC:
        fprintf(fh, "%s\n", "TERM_ERC");
        break;
      case FUNC_DATA:
        fprintf(fh, "%s\n", "FUNC_DATA");
        break;
      case EVAL_DATA:
        fprintf(fh, "%s\n", "EVAL_DATA");
        break;
      case FUNC_EXPR:
        fprintf(fh, "%s\n", "FUNC_EXPR");
        break;
      case EVAL_EXPR:
        fprintf(fh, "%s\n", "EVAL_EXPR");
        break;
      case EVAL_TERM:
        fprintf(fh, "%s\n", "EVAL_TERM");
        break;
      case TERM_ARG:
        fprintf(fh, "%s\n", "TERM_ARG");
        break;
      default:
        fprintf(fh, "%s\n", "ERROR!!!!");
        break;
      };

      fprintf(fh, "    .evaltree=%-d\n",  fset[tr].cset[i].evaltree);
      fprintf(fh, "    .index=%-d\n",     fset[tr].cset[i].index);
    }
    fprintf(fh, "%s", "\n");
  }
  fflush(fh);
  fclose(fh);
}

void displayFSet(const char *message)
{
  int tr,i;
  printf("%s\n",message);
  printf("%s", "\n");
  for(tr = 0; tr < fset_count; tr++)
  {
    for (i=0; i<fset[tr].size; i++)
      printf("Tree %2d: Position %2d: fset[%d].cset[%2d].%-6.6s index=%-2d arity=%-2d \n",tr, i,tr,i, fset[tr].cset[i].string, fset[tr].cset[i].index, fset[tr].cset[i].arity);
    printf("%s","\n");
    fflush(stdout);
  }
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

#if 0 //gwgnote: delete later
typedef union
{
  struct
  {
    int numA;                                         /* number of arguments */
    int numTypeVecs;
    int **typeVecs;                           /* info about TypeArgs -> Type */
    typesIndexes_t *indexes;                            /* array of NumTypes */
  } f;
  int retType;                                     /* for terminals and Root */
} oneTP_czj_t;

    TP_czj[tr]->
#endif
static void displayTP(const char* message)
{
  int i,j,k,m,tr,b,a;
  char buf[BUFSIZ];
  int numFT;

  printf("TP_czj ->  %s\n",message);
  printf("%s", "\n");

  for(tr = 0; tr < tree_count; tr++)
  {
    numFT = pTS[tr].numF+pTS[tr].numT;

    printf("Tree[%d]=%s:\n",tr, FTp[tr]->treeName);
    printf(" TP_czj[%d] numFT+1 = %d\n", tr, numFT+1);

    /* gwgnote: Types are used elsewhere in the program like this in tree traversal
               see verify_tree_czj, eval_tree others....
         Type_czj=TP_czj[tr][Function_czj].f.typeVecs[vecNum][Argument_czj];
    */

    //TP_czj[tr]=(void*)getVec((size_t)(numFT+1),sizeof(oneTP_czj_t));
    printf("%s", " process functions:\n");
    printf("   pTS[%d].numF=%d\n", tr, pTS[tr].numF);
    for (i=0; i<pTS[tr].numF; i++)                          /* first process functions */
    {
      printf("    %s:\n", funcTermName(tr, i));
      //TP_czj[tr][i].f.numA=fset[tr].cset[i].arity;
      printf("    TP_czj[%d][%d].f.numA=%d (function arguments)\n",tr, i, TP_czj[tr][i].f.numA);
      printf("    FTp[%d]->TypeCount=%d\n",tr, FTp[tr]->TypCount);
      b = (FTp[tr]->TypCount==1);
      printf("    if(FTp[%d]->TypCount==1) -> %d (", tr, b);
      if(FTp[tr]->TypCount==1)             /* the generic case or just one type anyway */
      {
        printf("%s\n", "True)");
        printf("%s","    One Type:\n");
        //TP_czj[tr][i].f.typeVecs=(int**)getVec((size_t)1,sizeof(int*));
        //TP_czj[tr][i].f.typeVecs[0]= (int*)getVec((size_t)(TP_czj[tr][i].f.numA+1),sizeof(int));
        //TP_czj[tr][i].f.numTypeVecs=1;
        printf("     TP_czj[%d][%d].f.numTypeVecs=%d\n", tr,i,TP_czj[tr][i].f.numTypeVecs);
        printf("     TP_czj[%d][%d].f.numA+1=%d \n", tr, i, TP_czj[tr][i].f.numA+1);
        for (j=0; j<TP_czj[tr][i].f.numA+1; j++)
        {
          //function args types and return type
          //TP_czj[tr][i].f.typeVecs[0][j]=0;                /* just the only type */
          printf("      TP_czj[%d][%d].f.typeVecs[0][%d]=%d\n", tr, i, j, TP_czj[tr][i].f.typeVecs[0][j]);
        }
      }
      else
      {
        printf("%s\n", "False)");
        printf("%s","   Multiple Types:\n");
        /* does overloaded functions with multiple types */

        //int* vec = NULL;
        j = 0;
        int arg = 0;
        inst_t *ip = NULL;
        //sprintf(buf, "Specs for '%s' [%d arg and one ret types /<ENTER> for no more]\n\t:",
        //        fset[tr].cset[i].string,TP_czj[tr][i].f.numA); // debugging
        printf("   fset[%d].cset[%d].string=%s, TP_czj[%d][%d].f.numA=%d\n", tr, i, fset[tr].cset[i].string, tr, i, TP_czj[tr][i].f.numA );
        printf("   FTp[%d]->Func[%d].instCount=%d\n",tr, i, FTp[tr]->Func[i].instCount);
        for ( ip = FTp[tr]->Func[i].head->next; (ip != NULL) && (ip->inst != NULL); ip = ip->next )
        {
          //vec=(int*)getVec((size_t)(fset[tr].cset[i].string,TP_czj[tr][i].f.numA+1),sizeof(int));
          //if(vec == NULL)
          //{
          //  error(E_FATAL_ERROR, "Out of memory, allocation in read1TypeVec");
          //}
          for (arg = 0; arg < funcArity(tr,i)+1; arg++)
          {
            //sprintf(buf, "fun-> %s, argNo=%d, argType->%s ", fset[tr].cset[i].string, arg, FTp[tr]->TypList[ip->inst[arg]]);
            printf("    arg=%d ip->inst[arg]=%d\n", arg, ip->inst[arg]);
            printf("    fset[%d].cset[%d].string=%s, arg=%d, FTp[%d]->TypList[ip->inst[arg]]=%s", tr, i, fset[tr].cset[i].string, arg, tr, FTp[tr]->TypList[ip->inst[arg]]);
            //vec[arg] = ip->inst[arg]; // get the types for the arg
          }

          //TP_czj[tr][i].f.numTypeVecs=j+1;
          printf("   TP_czj[%d][%d].f.numTypeVecs=%d\n", tr, i, TP_czj[tr][i].f.numTypeVecs);

          //TP_czj[tr][i].f.typeVecs= (int**)getMoreVec(TP_czj[tr][i].f.typeVecs,sizeof(int*)*(j+1));
          //TP_czj[tr][i].f.typeVecs[j]=vec;
          for (a=0; a<TP_czj[tr][i].f.numA+1; a++)
          {
            //function args types and return type
            printf("      TP_czj[%d][%d].f.typeVecs[%d][%d]=%d\n", tr, i, j, a, TP_czj[tr][i].f.typeVecs[j][a]);
          }
          //gwgnote: double check this
          if (!verify1TypeVec(TP_czj[tr][i].f.typeVecs,TP_czj[tr][i].f.numA,j))
          {
            free(TP_czj[tr][i].f.typeVecs[j]);
            printf("ERROR ON VALIDATE FOR: TP_czj[%d][%d].f.typeVecs,TP_czj[%d][%d].f.numA=%d,%d\n", tr,i,tr,i,TP_czj[tr][i].f.numA,j);
            error(E_FATAL_ERROR, "must have at least one valid type vector");
          }
          j++; //increments function in typeVecs
        }
      }

      /* now make indexes for this function */
      printf("%s\n", "   Index(s) for Function:");
      printf("    FTp[%d]->TypeCount=%d\n",tr, FTp[tr]->TypCount);
      for (j=0; j<FTp[tr]->TypCount; j++)
      {
        m=0;
        for (k=0; k<TP_czj[tr][i].f.numTypeVecs; k++)
          if (TP_czj[tr][i].f.typeVecs[k][TP_czj[tr][i].f.numA]==j)
            m++;
        printf("     TP_czj[%d][%d].f.indexes[%d].len=%d\n", tr, i, j, TP_czj[tr][i].f.indexes[j].len);
        if(TP_czj[tr][i].f.indexes[j].len > 0)
        {

          for (m=0,k=0; k<TP_czj[tr][i].f.numTypeVecs; k++)
          { if (TP_czj[tr][i].f.typeVecs[k][TP_czj[tr][i].f.numA]==j)
            {
              //TP_czj[tr][i].f.indexes[j].indexes[m]=k;
              printf("     TP_czj[%d][%d].f.indexes[%d].indexes[%d]=%d\n", tr, i, j, m,  TP_czj[tr][i].f.indexes[j].indexes[m]);
              m++;
            }
          }
        }
      }
    }

    //gwgnote: a terminal can only have one type
    printf("%s", " process terminals:\n");
    for (i=pTS[tr].numF; i<numFT; i++)                        /* now process terminals */
    {
      printf(" %s:\n", funcTermName(tr, i));
      if (FTp[tr]->TypCount==1)
      {
        printf("%s","  One Type:\n");
        //TP_czj[tr][i].retType=0;                                  /* the only one type */
        printf("   TP_czj[%d][%d].retType=%d\n", tr, i,  TP_czj[tr][i].retType);
      }
      else
      {
        //sprintf(buf, "Give ret type for terminal '%s': ",fset[tr].cset[i].string); /*debug info*/
        /*TP_czj[tr][i].retType=read1Type(tr, i); */
        printf("%s","   Multiple Types:\n");
        //TP_czj[tr][i].retType=FTp[tr]->TypTerm[i];
        printf("   TP_czj[%d][%d].retType=%d\n", tr, i,  TP_czj[tr][i].retType);
      }
    }

    printf("%s", " process root:\n");
    //printf(" %s:\n", funcTermName(tr, i)); //gwgfix
    if (FTp[tr]->TypCount==1)                                       /* now process Root */
    {
      printf("%s","  One Type:\n");
      //TP_czj[tr][pTS[tr].numF+pTS[tr].numT].retType=0;                                /* the only type */
      printf("   TP_czj[%d][pTS[%d].numF+pTS[%d].numT].retType=%d\n", tr, tr, tr, TP_czj[tr][pTS[tr].numF+pTS[tr].numT].retType);
    }
    else
    {
      //gwgrevisit: make two type example
      //sprintf(buf, "Give return type for the problem: "); /*debug info*/
      /*TP_czj[tr][pTS[tr].numF+pTS[tr].numT].retType=read1Type(tr,pTS[tr].numF+pTS[tr].numT);*/
      printf("%s","   Multiple Types:\n");
      //TP_czj[tr][pTS[tr].numF+pTS[tr].numT].retType=FTp[tr]->TypRoot;
      printf("   TP_czj[%d][pTS[%d].numF+pTS[%d].numT].retType=%d\n", tr, tr, tr, TP_czj[tr][pTS[tr].numF+pTS[tr].numT].retType);
    }
  }
  fflush(stdout);
}

static void savefileTP(const char* fname, const char* message)
{
  FILE* fh = NULL;

  fh = fopen(fname, "w");
  if(fh == NULL)
    return;

  fprintf(fh, "%s\n",message);
  fprintf(fh, "%s", "\n");

  int i,j,k,m,tr,b,a;
  char buf[BUFSIZ];
  int numFT;

  fprintf(fh, "TP_czj ->  %s\n",message);
  fprintf(fh, "%s", "\n");

  for(tr = 0; tr < tree_count; tr++)
  {
    numFT = pTS[tr].numF+pTS[tr].numT;

    fprintf(fh, "Tree[%d]=%s:\n",tr, FTp[tr]->treeName);
    fprintf(fh, " TP_czj[%d] numFT+1 = %d\n", tr, numFT+1);

    /* gwgnote: Types are used elsewhere in the program like this in tree traversal
               see verify_tree_czj, eval_tree others....
         Type_czj=TP_czj[tr][Function_czj].f.typeVecs[vecNum][Argument_czj];
    */

    //TP_czj[tr]=(void*)getVec((size_t)(numFT+1),sizeof(oneTP_czj_t));
    fprintf(fh, "%s", " process functions:\n");
    fprintf(fh, "   pTS[%d].numF=%d\n", tr, pTS[tr].numF);
    for (i=0; i<pTS[tr].numF; i++)                          /* first process functions */
    {
      fprintf(fh, "    %s:\n", funcTermName(tr, i));
      //TP_czj[tr][i].f.numA=fset[tr].cset[i].arity;
      fprintf(fh, "     TP_czj[%d][%d].f.numA=%d (function arguments)\n",tr, i, TP_czj[tr][i].f.numA);
      fprintf(fh, "     FTp[%d]->TypeCount=%d\n",tr, FTp[tr]->TypCount);
      b = (FTp[tr]->TypCount==1);
      fprintf(fh, "     if(FTp[%d]->TypCount==1) -> %d (", tr, b);
      if(FTp[tr]->TypCount==1)             /* the generic case or just one type anyway */
      {
        fprintf(fh, "%s\n", "True)");
        fprintf(fh, "%s","    One Type:\n");
        //TP_czj[tr][i].f.typeVecs=(int**)getVec((size_t)1,sizeof(int*));
        //TP_czj[tr][i].f.typeVecs[0]= (int*)getVec((size_t)(TP_czj[tr][i].f.numA+1),sizeof(int));
        //TP_czj[tr][i].f.numTypeVecs=1;
        fprintf(fh, "     TP_czj[%d][%d].f.numTypeVecs=%d\n", tr,i,TP_czj[tr][i].f.numTypeVecs);
        fprintf(fh, "     TP_czj[%d][%d].f.numA+1=%d \n", tr, i, TP_czj[tr][i].f.numA+1);
        for (j=0; j<TP_czj[tr][i].f.numA+1; j++)
        {
          //function args types and return type
          //TP_czj[tr][i].f.typeVecs[0][j]=0;                /* just the only type */
          fprintf(fh, "      TP_czj[%d][%d].f.typeVecs[0][%d]=%d\n", tr, i, j, TP_czj[tr][i].f.typeVecs[0][j]);
        }
      }
      else
      {
        fprintf(fh, "%s\n", "False)");
        fprintf(fh, "%s","     Multiple Types:\n");
        /* does overloaded functions with multiple types */

        //int* vec = NULL;
        j = 0;
        int arg = 0;
        inst_t *ip = NULL;
        //sprintf(buf, "Specs for '%s' [%d arg and one ret types /<ENTER> for no more]\n\t:",
        //        fset[tr].cset[i].string,TP_czj[tr][i].f.numA); // debugging
        fprintf(fh, "     fset[%d].cset[%d].string=%s, TP_czj[%d][%d].f.numA=%d\n", tr, i, fset[tr].cset[i].string, tr, i, TP_czj[tr][i].f.numA );
        fprintf(fh, "     FTp[%d]->Func[%d].instCount=%d\n",tr, i, FTp[tr]->Func[i].instCount);
        for ( ip = FTp[tr]->Func[i].head->next; (ip != NULL) && (ip->inst != NULL); ip = ip->next )
        {
          //vec=(int*)getVec((size_t)(fset[tr].cset[i].string,TP_czj[tr][i].f.numA+1),sizeof(int));
          //if(vec == NULL)
          //{
          //  error(E_FATAL_ERROR, "Out of memory, allocation in read1TypeVec");
          //}
          for (arg = 0; arg < funcArity(tr,i)+1; arg++)
          {
            //sprintf(buf, "fun-> %s, argNo=%d, argType->%s ", fset[tr].cset[i].string, arg, FTp[tr]->TypList[ip->inst[arg]]);
            fprintf(fh, "      arg=%d ip->inst[arg]=%d\n", arg, ip->inst[arg]);
            fprintf(fh, "      fset[%d].cset[%d].string=%s, arg=%d, FTp[%d]->TypList[ip->inst[arg]]=%s", tr, i, fset[tr].cset[i].string, arg, tr, FTp[tr]->TypList[ip->inst[arg]]);
            //vec[arg] = ip->inst[arg]; // get the types for the arg
          }

          //TP_czj[tr][i].f.numTypeVecs=j+1;
          fprintf(fh, "     TP_czj[%d][%d].f.numTypeVecs=%d\n", tr, i, TP_czj[tr][i].f.numTypeVecs);

          //TP_czj[tr][i].f.typeVecs= (int**)getMoreVec(TP_czj[tr][i].f.typeVecs,sizeof(int*)*(j+1));
          //TP_czj[tr][i].f.typeVecs[j]=vec;
          for (a=0; a<TP_czj[tr][i].f.numA+1; a++)
          {
            //function args types and return type
            fprintf(fh, "        TP_czj[%d][%d].f.typeVecs[%d][%d]=%d\n", tr, i, j, a, TP_czj[tr][i].f.typeVecs[j][a]);
          }
          //gwgnote: double check this
          if (!verify1TypeVec(TP_czj[tr][i].f.typeVecs,TP_czj[tr][i].f.numA,j))
          {
            free(TP_czj[tr][i].f.typeVecs[j]);
            printf("ERROR ON VALIDATE FOR: TP_czj[%d][%d].f.typeVecs,TP_czj[%d][%d].f.numA=%d,%d\n", tr,i,tr,i,TP_czj[tr][i].f.numA,j);
            error(E_FATAL_ERROR, "must have at least one valid type vector");
          }
          j++; //increments function in typeVecs
        }
      }

      /* now make indexes for this function */
      fprintf(fh, "%s\n", "     Index(s) for Function:");
      fprintf(fh, "      FTp[%d]->TypeCount=%d\n",tr, FTp[tr]->TypCount);
      for (j=0; j<FTp[tr]->TypCount; j++)
      {
        m=0;
        for (k=0; k<TP_czj[tr][i].f.numTypeVecs; k++)
          if (TP_czj[tr][i].f.typeVecs[k][TP_czj[tr][i].f.numA]==j)
            m++;
        fprintf(fh, "       TP_czj[%d][%d].f.indexes[%d].len=%d\n", tr, i, j, TP_czj[tr][i].f.indexes[j].len);
        if(TP_czj[tr][i].f.indexes[j].len > 0)
        {
          for (m=0,k=0; k<TP_czj[tr][i].f.numTypeVecs; k++)
          { if (TP_czj[tr][i].f.typeVecs[k][TP_czj[tr][i].f.numA]==j)
            {
              //TP_czj[tr][i].f.indexes[j].indexes[m]=k;
              fprintf(fh, "        TP_czj[%d][%d].f.indexes[%d].indexes[%d]=%d\n", tr, i, j, m,  TP_czj[tr][i].f.indexes[j].indexes[m]);
              m++;
            }
          }
        }
      }
    }

    //gwgnote: a terminal can only have one type
    fprintf(fh, "%s", " process terminals:\n");
    for (i=pTS[tr].numF; i<numFT; i++)                        /* now process terminals */
    {
      fprintf(fh, " %s:\n", funcTermName(tr, i));
      if (FTp[tr]->TypCount==1)
      {
        fprintf(fh, "%s","  One Type:\n");
        //TP_czj[tr][i].retType=0;                                  /* the only one type */
        fprintf(fh, "   TP_czj[%d][%d].retType=%d\n", tr, i,  TP_czj[tr][i].retType);
      }
      else
      {
        //sprintf(buf, "Give ret type for terminal '%s': ",fset[tr].cset[i].string); /*debug info*/
        /*TP_czj[tr][i].retType=read1Type(tr, i); */
        fprintf(fh, "%s","   Multiple Types:\n");
        //TP_czj[tr][i].retType=FTp[tr]->TypTerm[i];
        fprintf(fh, "   TP_czj[%d][%d].retType=%d\n", tr, i,  TP_czj[tr][i].retType);
      }
    }

    fprintf(fh, "%s", " process root:\n");
    if (FTp[tr]->TypCount==1)                                       /* now process Root */
    {
      fprintf(fh, "%s","  One Type:\n");
      //TP_czj[tr][pTS[tr].numF+pTS[tr].numT].retType=0;                                /* the only type */
      fprintf(fh, "   TP_czj[%d][pTS[%d].numF+pTS[%d].numT].retType=%d\n", tr, tr, tr, TP_czj[tr][pTS[tr].numF+pTS[tr].numT].retType);
    }
    else
    {
      //gwgrevisit: make two type example
      //sprintf(buf, "Give return type for the problem: "); /*debug info*/
      /*TP_czj[tr][pTS[tr].numF+pTS[tr].numT].retType=read1Type(tr,pTS[tr].numF+pTS[tr].numT);*/
      fprintf(fh, "%s","   Multiple Types:\n");
      //TP_czj[tr][pTS[tr].numF+pTS[tr].numT].retType=FTp[tr]->TypRoot;
      fprintf(fh, "   TP_czj[%d][pTS[%d].numF+pTS[%d].numT].retType=%d\n", tr, tr, tr, TP_czj[tr][pTS[tr].numF+pTS[tr].numT].retType);
    }
  }

  fflush(fh);
  fclose(fh);
}

//static void readTypesSetTP(void)
static void buildTP(void)
/* read type info, allocate/init NumTypes, TypeNames, TP_czj */
{
  int i,j,k,m,tr;
  char buf[BUFSIZ];
  int numFT;

  //TP_czj=(TP_czj_t*)getVec((size_t)(tree_count), sizeof(oneTP_czj_t*));
  TP_czj=(void*)getVec((size_t)(tree_count), sizeof(oneTP_czj_t*));
  for(tr = 0; tr < tree_count; tr++)
  {
    if(pTS == NULL)
    {
      error( E_FATAL_ERROR, "Interface file not found, put cgp_interface=interface.file in input.file");
      exit(1);
    }
    numFT = pTS[tr].numF+pTS[tr].numT;
    //TP_czj[tr]=(TP_czj_t*)getVec((size_t)(numFT+1),sizeof(oneTP_czj_t));
    TP_czj[tr]=(void*)getVec((size_t)(numFT+1),sizeof(oneTP_czj_t));
    for (i=0; i<pTS[tr].numF; i++)                          /* first process functions */
    {
      TP_czj[tr][i].f.numA=fset[tr].cset[i].arity;
      //if(FTp[tr][i].TypCount==1)             /* the generic case or just one type anyway */
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
        sprintf(buf, "Specs for '%s' [%d arg and one ret types /<ENTER> for no more]\n\t:",
                fset[tr].cset[i].string,TP_czj[tr][i].f.numA); // debugging

        ic = FTp[tr]->Func[i].instCount;
        for ( ip = FTp[tr]->Func[i].head->next; (ip != NULL) && (ip->inst != NULL); ip = ip->next )
        {
          vec=(int*)getVec((size_t)(fset[tr].cset[i].string,TP_czj[tr][i].f.numA+1),sizeof(int));
          if(vec == NULL)
          {
            error(E_FATAL_ERROR, "Out of memory, allocation in read1TypeVec");
          }
          for (arg = 0; arg < funcArity(tr,i)+1; arg++)
          {
            sprintf(buf, "fun-> %s, argNo=%d, argType->%s ", fset[tr].cset[i].string, arg, FTp[tr]->TypList[ip->inst[arg]]);
            vec[arg] = ip->inst[arg]; // get the type
          }
          TP_czj[tr][i].f.numTypeVecs=j+1;
          TP_czj[tr][i].f.typeVecs= (int**)getMoreVec(TP_czj[tr][i].f.typeVecs,sizeof(int*)*(j+1));
          TP_czj[tr][i].f.typeVecs[j]=vec;
          if (!verify1TypeVec(TP_czj[tr][i].f.typeVecs,TP_czj[tr][i].f.numA,j))
          {
            free(TP_czj[tr][i].f.typeVecs[j]);
            error(E_FATAL_ERROR, "must have at least one valid type vector");
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

void create_MS_czj(void)
/* will access global fset function table, and will allocate and
   initialize MS_czj; check that no pair is completely empty */
/* Must be called after fset is created and ordered,
         but before initializing the population */
{
  //int what=0;
#if 1
#if DISPLAY_FSET
  displayFSet("beginning of create_MS_czj");
#endif
#if SAVE_FSET
  savefileFSet("sf_a_fset.txt", "fset -> beginning of create_MS_czj");
#endif

  /* creates pTS: pointerTreeStructure dependent on fset numF, numT
   * creates FTp: : FTspecs from interface.file dependent on fset numF, numT
  */
  buildInterface();
  //  displayHeader();  gwgfix: put back in after testing

#if DISPLAY_FTP
  displayFTpV1("display FTp V1");
#endif
#if SAVE_FTP
  savefileFTpV1("sf_b_FTpV1.txt", "FTp -> created V1");
#endif

  /* creates TP_czj: Type dependent on pTS, FTp, fset
  */
  //readTypesSetTP();
  buildTP();
#if DISPLAY_TP
  printf("\nTypes are... \n");
  displayTP("displayTP");
#endif
#if SAVE_TP
  savefileTP("sf_c_TP.txt", "TP -> created");
#endif

#if DISPLAY_FTP
  displayFTpV2("display FTp V2");
  displayFTpV3("display FTp V3");
#endif
#if SAVE_FTP
  savefileFTpV2("sf_d_FTpV2.txt", "FTp -> created V2");
  savefileFTpV3("sf_e_FTpV3.txt", "FTp -> created V3");
#endif

  /* creates Constraints: dependent on pTS, FTp
  */
  buildConstraints();

#if DISPLAY_CONSTRAINTS
  printf("\nRead the following constraints...\n");
  displayConstraints(1,1,1);
#endif
#if SAVE_CONSTRAINTS
  savefileConstraints("sf_f_Constraints_1.txt", "Constraints -> Before generateNF", 1, 1, 1);
#endif

  /* Constraints array used: T-extensive F-specs */
  generateNF(); // NF stands for Normal Form
#if DISPLAY_CONSTRAINTS
  printf("\nThe normal constraints are...\n");
  //displayConstraints(0,0,1);
  displayConstraints(1,1,1);
#endif
#if SAVE_CONSTRAINTS
  savefileConstraints("sf_g_Constraints_2.txt", "Constraints -> After generateNF", 1, 1, 1);
#endif

 /* creates MS_czj: dependent on pTS, fset, Constraints, untyped
  * Fspecs part (ie F-intensive) of Constraints
  */
  generateMS();
#if DISPLAY_MST
  printf("\n##1 The following untyped mutation sets are used...\n");
  displayMS(1,1,1);
#endif
#if SAVE_MST
  savefileMS("sf_h_MS_before_weights_wheels.txt", "MS -> generateMS", 0, 1, 1);
#endif

  /* pTS, MS_czj used here,
  */
  readWeightsSetWheels();
#if DISPLAY_MST // gwg added next display code
  printf("\nWheels are...\n");
  displayWeightsWheels(1,1);
#endif
#if SAVE_MST
  savefileWeightsWheels("sf_i_WW_before_types.txt", "Weights Wheels -> After call to readWeightsSetWheels", 1,1);
#endif

  /* pTS, fset, FTp, TP_czj, MS_czj used here,
  */
#if SAVE_MST
  savefileMS("sf_j_MS_before_constrain_types.txt", "MS -> generateMS before types constrained", 0, 1, 1);
#endif
  constrainTypes();
#if DISPLAY_MST
  //  if (NumTypes>1)
  //  {
  printf("\n##3 After constrainTypes The following typed mutation sets are used...\n");
  displayMS(1,1,1);
  //  }
#endif
#if SAVE_MST
  savefileMS("sf_k_MS_after_constrain_types.txt", "MS -> generateMS after types constrained", 0, 1, 1);
#endif

  //printf("Send 1 to continue, anything else to quit cgp-lil-gp: ");
  //scanf("%d",&what);
  //if (what!=1)
  //  exit(1);
  //printf("\n\n");
#endif
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
/*    mutation set for Function_czj/Argument_czj */
/* if the set is empty, call random_FT_czj() */
/* NOTE: set is considered empty if numF==0 or each weight is <MINWGHT+SMALL */
{
  int randIndex;
  randIndex=MS_czj[tr][Function_czj][Argument_czj][Type_czj].numF;
  if (randIndex==0 || MS_czj[tr][Function_czj][Argument_czj][Type_czj].areFs==0)
    return(random_FT_czj(tr));
  randIndex=spinWheel(0,randIndex-1,MS_czj[tr][Function_czj][Argument_czj][Type_czj].wheel);
  return MS_czj[tr][Function_czj][Argument_czj][Type_czj].members[randIndex];
}

int random_T_czj(int tr)
/* as random_F_czj, except that extract members of T */
{
  int randIndex;
  if (MS_czj[tr][Function_czj][Argument_czj][Type_czj].numT==0 ||
      MS_czj[tr][Function_czj][Argument_czj][Type_czj].areTs==0)
    return(random_FT_czj(tr));
  randIndex=spinWheel(MS_czj[tr][Function_czj][Argument_czj][Type_czj].numF,
                      MS_czj[tr][Function_czj][Argument_czj][Type_czj].numFT-1,
                      MS_czj[tr][Function_czj][Argument_czj][Type_czj].wheel);
  return MS_czj[tr][Function_czj][Argument_czj][Type_czj].members[randIndex];
}

int random_FT_czj(int tr)
/* return a random type I/II/III index from fset, but which appear in
   the mutation set for Function_czj/Argument_czj */
/* assume both sets (F and T) are not empty */
{
  int randIndex;
  if (MS_czj[tr][Function_czj][Argument_czj][Type_czj].numFT==0)
  {
    fprintf(stderr,"\nERROR: both sets should not be empty\n");
    exit(1);
  }
  if (MS_czj[tr][Function_czj][Argument_czj][Type_czj].areFs==0 &&
      MS_czj[tr][Function_czj][Argument_czj][Type_czj].areTs==0)
  {
    fprintf(stderr,"\nERROR: both sets should not have empty weights\n");
    exit(1);
  }
  randIndex=spinWheel(0,MS_czj[tr][Function_czj][Argument_czj][Type_czj].numFT-1,
                      MS_czj[tr][Function_czj][Argument_czj][Type_czj].wheel);
  return MS_czj[tr][Function_czj][Argument_czj][Type_czj].members[randIndex];
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
  double *wheelExt_czj=&((**t).wheelExt_czj);
  double *wheelInt_czj=&((**t).wheelInt_czj);
  int j;
  double wght=0;
  int total;

  ++*t;                              /* step the pointer over the function. */

  if ( f->arity == 0 )                                    /* it is external */
  {
    if (f->ephem_gen)
      ++*t;                                  /* etra value to skip */
    wght=MS_czj[tr][Function_czj][Argument_czj][Type_czj].weights[f->index];
    if (wght<(MINWGHT+SMALL))     /* not in this mutation set or do not use */
      total=0;
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
    wght=MS_czj[tr][Function_czj][Argument_czj][Type_czj].weights[f->index];
    if (wght<(MINWGHT+SMALL))    /* not in this mutation set or do not use */
      total=0;
    else
    {
      WghtsInt+=wght;
      total=1;
    }
    *wheelInt_czj=WghtsInt;
    *wheelExt_czj=WghtsExt;
    for (j=0; j<f->arity; ++j)
      total+=markXNodes_recurse_czj(tr,t);    /* t has already been advanced */
    break;
  case FUNC_EXPR:
  case EVAL_EXPR:
    wght=MS_czj[tr][Function_czj][Argument_czj][Type_czj].weights[f->index];
    if (wght<(MINWGHT+SMALL))    /* not in this mutation set or do not use */
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
/* assume Function_czj and Argument_czj are set to indicate dest point */
/* mark all nodes in tree which are feasible sources with their wghts */
/*   while contructing the wheels for internal and external nodes */
/* accummulate total wght marked in WghtsInt and WghtsExt */
/*   for the internal and the external nodes, respectively */
/* return the number of marked nodes */
{
  lnode *t=data;
  WghtsInt=0;
  WghtsExt=0;
  return markXNodes_recurse_czj(tr, &t);
}

static lnode *getSubtreeMarked_recurse_czj(lnode **t, double mark)
/* assume feasible internal and external nodes are marked with wheel values */
/*   and 'mark' determines which wheel entry is used */
/* this function spins the wheel looking for any node */
{
  function *f = (**t).f;
  double *wheelExt_czj=&((**t).wheelExt_czj);
  double *wheelInt_czj=&((**t).wheelInt_czj);
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
      r=getSubtreeMarked_recurse_czj(t,mark);
      if (r!=NULL)
        return r;                                      /* subtree found */
    }
    break;
  case FUNC_EXPR:
  case EVAL_EXPR:
    for (i=0; i<f->arity; i++)
    {
      ++*t;
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
{
  function *f = (**t).f;
  double *wheelInt_czj=&((**t).wheelInt_czj);
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
      r=getSubtreeMarkedInt_recurse_czj(t,mark);
      if (r!=NULL)
        return r;                                      /* subtree found */
    }
    break;
  case FUNC_EXPR:
  case EVAL_EXPR:
    for (i=0; i<f->arity; i++)
    {
      ++*t;
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
{
  function *f = (**t).f;
  double *wheelExt_czj=&((**t).wheelExt_czj);
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
      r=getSubtreeMarkedExt_recurse_czj(t,mark);
      if (r!=NULL)
        return r;                                         /* subtree found */
    }
    break;
  case FUNC_EXPR:
  case EVAL_EXPR:
    for (i=0; i<f->arity; i++)
    {
      ++*t;
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
{
  lnode *el = data;
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

#if 0
static int verify_tree_czj_recurse (int tr,  lnode **t )
/* return #times the tree pointed by t violates MS_czj */
/*   note: *t always points at a function node here: save the function */
{
  function *f = (**t).f;
  int i;
  int total=0;
  int vecNum;
  int numF = 0;

  numF = pTS[tr].numF;

  vecNum=(**t).typeVec_czj;
  if (MS_czj[tr][Function_czj][Argument_czj][Type_czj].weights[f->index]<0 ||
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
      total+=verify_tree_czj_recurse (tr, t);
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
#endif

#if 0 //gwg delete later
int verify_tree_czj (int tr, lnode *tree )
/* return #times the tree pointed by tree violates MS_czj */
{
  lnode *t = tree;
  int f_save=Function_czj;
  int a_save=Argument_czj;
  int t_save=Type_czj;
  int total;

  Function_czj = fset[tr].function_count;
  Argument_czj = 0;                                  /* start from the Root */
  Type_czj = 0;
  total=verify_tree_czj_recurse (tr,&t);
  Function_czj=f_save;
  Argument_czj=a_save;
  Type_czj = t_save;
  return total;
}
#endif

int verify_tree_czj(individual *ind)
{
  int total=0;
  cur_ind = ind; // set the current individual like eval_tree and eval_tree_recurse

  verify_tree_czj_recurse_start(ind->tr[0].data, 0 , &total);
  return total;
}

static void verify_tree_czj_recurse_start (lnode *tree, int whichtree, int* total)
{
  lnode *t = tree;
  int f_save=Function_czj;
  int a_save=Argument_czj;
  int t_save=Type_czj;

  int numFT = pTS[whichtree].numF+pTS[whichtree].numT;

  Function_czj = fset[whichtree].function_count;
  Argument_czj = 0;                                  /* start from the Root */
  Type_czj = TP_czj[whichtree][numFT].retType;
  verify_tree_czj_recurse (&t, whichtree, total);
  Function_czj=f_save;
  Argument_czj=a_save;
  Type_czj = t_save;
}

/* return #times the tree pointed by t violates MS_czj */
/*   note: *t always points at a function node here: save the function */
static void verify_tree_czj_recurse (lnode **l, int whichtree, int *total)
{
  function *f = (**l).f;
  int i;
  int vecNum;
  int numF = 0;

  numF = pTS[whichtree].numF;

  vecNum=(**l).typeVec_czj;
  if (MS_czj[whichtree][Function_czj][Argument_czj][Type_czj].weights[f->index]<0 || f->index<numF && Type_czj !=
        TP_czj[whichtree][f->index].f.typeVecs[vecNum][TP_czj[whichtree][f->index].f.numA])
    (*total)++;                                                     /* invalid */

  ++*l;                              /* step the pointer over the function. */
  if (f->arity==0)
  {
    if (f->ephem_gen)
      ++*l;    /* skip the pointer over the ERC value if this node has one. */
    //return total;
  }
  switch (f->type)
  {
  case FUNC_DATA:
  case EVAL_DATA:
    for (i=0; i<f->arity; ++i)
    {
      Function_czj = f->index;
      Argument_czj = i;
      Type_czj=TP_czj[whichtree][Function_czj].f.typeVecs[vecNum][Argument_czj];
      //total+=verify_tree_czj_recurse (l, whichtree);
      verify_tree_czj_recurse (l, whichtree, total);
    }
    break;
  case FUNC_EXPR:
  case EVAL_EXPR:
    for (i=0; i<f->arity; ++i)
    {
      ++*l;                 /* skip the pointer over the skipsize node. */
      Function_czj = f->index;
      Argument_czj = i;
      Type_czj=TP_czj[whichtree][Function_czj].f.typeVecs[vecNum][Argument_czj];
      //total+=verify_tree_czj_recurse (l, whichtree);
      verify_tree_czj_recurse (l, whichtree, total);
    }
    break;
  } /* switch */

  //return total;
}

/* print the counters for root and parent-child distribution czj */
/* NOTE: relying on implicit file close */
static void acgp_print_counters(int curGen, const char *basefile, int newIteration)
{
  int i, a, t, tr, e, numF, numT, NumTypes;
  char fname[BUFSIZ];
  static FILE *fpczj=0;

  strcpy(fname,basefile);
  strcat(fname,".cnt");

  if (!fpczj)
  {
    if ((fpczj=fopen(fname,"w"))==0)
    {
      fprintf(stderr,"Couldnt open Counter.txt\n");
      exit(1);
    }
  }

  for(tr = 0; tr < tree_count; tr++)
  {
    numF     = pTS[tr].numF;
    numT     = pTS[tr].numT;
    NumTypes = FTp[tr]->TypCount;

    fprintf(fpczj,"tr=%2d, %s, F=%d T=%d ",tr, pTS[tr].treeName, numF, numT);
    for (i=0; i<numF+numT; i++)
      fprintf(fpczj,"%s %d ",fset[tr].cset[i].string,fset[tr].cset[i].arity);
    fprintf(fpczj,"\n");

    for(t=0;t<NumTypes;t++)
    {
      fprintf(fpczj, "DType: %s\n",FTp[tr]->TypList[t]);
      fprintf(fpczj,"  Gen %3d : %6d",curGen,MS_czj[tr][numF][0][t].counters_tot);
      for (i=0; i<numF+numT; i++)
        fprintf(fpczj,"%6.5s",fset[tr].cset[i].string);
      fprintf(fpczj,"\n ");
      for(i=0; i<numF; i++)        /* function counters */
      { for(a=0; a<fset[tr].cset[i].arity; a++)
        {
          fprintf(fpczj," %5.5s %1d : %6d ",fset[tr].cset[i].string,a, MS_czj[tr][i][a][t].counters_tot);
          for (e=0; e<numF+numT; e++)
            fprintf(fpczj,"%5d ",MS_czj[tr][i][a][t].counters[e]);
          fprintf(fpczj,"\n ");
        }
      }
      fprintf(fpczj," %5s   : %6d ","Root",MS_czj[tr][numF][0][t].counters_tot);
      for (e=0; e<numF+numT; e++)             /* Root counters */
        fprintf(fpczj,"%5d ",MS_czj[tr][numF][0][t].counters[e]);
      fprintf(fpczj,"\n");
    }
  }
  if (newIteration)
    fprintf(fpczj,"*New iteration\n");

  fprintf(fpczj,"\n");
  fflush(fpczj);
}

static void acgp_reset_count()
/* Added 5/30/03 by czjmmh.
   This function resets the counters for count_czj() */
{
  int f, a, t, ft, j, tr, numF, numT, numFT, NumTypes;

  for(tr = 0; tr < tree_count; tr++)
  {
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    numFT = numF+numT;
    NumTypes= FTp[tr]->TypCount;

    for (ft=0; ft < MS_czj[tr][numF][0][NumTypes].numFT; ft++)   /* reset Root counters */
    { MS_czj[tr][numF][0][NumTypes].counters[ft]=0;
      MS_czj[tr][numF][0][NumTypes].counters_tot=0;
    }
    for (f=0; f<numF; f++)        /* reset function counters */
    { for (a=0; a<fset[tr].cset[f].arity; a++)
      { for (ft=0; ft<MS_czj[tr][f][a][NumTypes].numFT; ft++)
        { MS_czj[tr][f][a][NumTypes].counters[ft]=0;
        }

        MS_czj[tr][f][a][NumTypes].counters_tot=0;
      }
    }
  }
}

static void acgp_count (individual *ind, int toUse)
/* This function computes the
   distribution of parent-child function(terminal) contexts for
   the single tree 'data'. The individual instances are counted in
   First reset all counters
   Using recursive acgp_count_recurse() to count functions
   Here count the label of Root MS[NumF][0].counters[indexOfRoot]++
   then recurse
   Counters are counted according to the expressed_czj field and
   the parameter ACGP_use_expressed
   If toUse==0 it means that walking through unexpressed subtree
   but must walk due to tree representation
   Last parameter 0 means start with root tree, we might be going to another tree
   */
{
  cur_ind = ind; // set the current individual like eval_tree and eval_tree_recurse
  acgp_count_recurse_start(ind->tr[0].data, toUse, 0 );
}

static void acgp_count_recurse_start (lnode *tree, int toUse, int whichtree)
{
  lnode *l = tree;
  int numF, t;
  int parIndex=(*l).f->index;
  int expressed_count=ACGP_EXPRESSED_VAL((*l).expressed_czj);
  toUse = toUse && expressed_count;
  if (toUse)
  {
    t = (*l).typeVec_czj; // get the type of this node
    numF = pTS[whichtree].numF;
    MS_czj[whichtree][numF][0][t].counters[parIndex]+=expressed_count;
    MS_czj[whichtree][numF][0][t].counters_tot+=expressed_count;
  }
  acgp_count_recurse (&l, toUse, whichtree);
}

// gwgnote: original acgp_count_recurse
static void acgp_count_recurse (lnode **l, int toUse, int whichtree)
/* This is the recursive utility
   for countFI() above
   The individual instances are counted in
   the MS structure as follow:
   MS[i][a].counters[j]++ if we encounter parent 'i' with
   child 'j' as argument 'a'
   Counters are counted according to the expressed_czj field and
   the parameter ACGP_use_expressed
   If toUse==0 it means that walking through unexpressed subtree
   but must walk due to tree representation */
/* NOTE: redo for proper # of trees, gwgnote this is fixed 20170920 */
/* NOTE: a child cannot be expressed more than its parent
   because each evaluation starts with resetting the expressed
   field */
{
  //function *parent;
  lnode* p = (*l);// parent
  lnode* ch = NULL;
  int a,t;
  int parIndex, chIndex;
  int expressed_count=ACGP_EXPRESSED_VAL((**l).expressed_czj);

  t = p->typeVec_czj; // get the type of the parent, needed for counting

  toUse = toUse && expressed_count;
  //parent = (**l).f;
  //parIndex=parent->index;
  parIndex=p->f->index;
  ++*l;                      /* l is now first child */

  ggacnt++;

  /* added to fix ERC issue - jja **************************************/
  if (p->f->arity==0)
  {
    if (p->f->ephem_gen)
      ++*l;  /* skip the pointer over the ERC value if this node has one. */
  } /* end of ERC fix code - jja **************************************/

  switch ( p->f->type )
  {
  case FUNC_DATA:
    for ( a = 0; a < p->f->arity; ++a )
    {
      chIndex=(**l).f->index;
      expressed_count=ACGP_EXPRESSED_VAL((**l).expressed_czj);
      /* expressed subtree && child */
      if (toUse && expressed_count)
      { MS_czj[whichtree][parIndex][a][t].counters[chIndex]+=expressed_count;
        MS_czj[whichtree][parIndex][a][t].counters_tot+=expressed_count;
      }
      acgp_count_recurse(l,toUse, whichtree);
    }
    break;

  case EVAL_DATA:
    for ( a = 0; a < p->f->arity; ++a )
    {
      chIndex=(**l).f->index;
      expressed_count=ACGP_EXPRESSED_VAL((**l).expressed_czj);
      /* expressed subtree && child */
      if (toUse && expressed_count)
      {
        MS_czj[whichtree][parIndex][a][t].counters[chIndex]+=expressed_count;
        MS_czj[whichtree][parIndex][a][t].counters_tot+=expressed_count;
      }
      acgp_count_recurse(l,toUse, whichtree);
    }
    ch = cur_ind->tr[p->f->evaltree].data;
    acgp_count_recurse_start(ch, toUse,  p->f->evaltree);
    break;

  case FUNC_EXPR:
    for ( a = 0; a < p->f->arity; ++a )
    {
      ++*l;           /* l was skipnode, now its the child */
      chIndex=(**l).f->index;
      expressed_count=ACGP_EXPRESSED_VAL((**l).expressed_czj);
      /* expressed subtree && child */
      if (toUse && expressed_count)
      { MS_czj[whichtree][parIndex][a][t].counters[chIndex]+=expressed_count;
        MS_czj[whichtree][parIndex][a][t].counters_tot+=expressed_count;
      }
      acgp_count_recurse(l,toUse, whichtree);
    }
    break;

  case EVAL_EXPR:
    for ( a = 0; a < p->f->arity; ++a )
    {
      ++*l;           /* l was skipnode, now its the child */
      chIndex=(**l).f->index;
      expressed_count=ACGP_EXPRESSED_VAL((**l).expressed_czj);
      if (toUse && expressed_count)
      { /* expressed subtree && child */
        MS_czj[whichtree][parIndex][a][t].counters[chIndex]+=expressed_count;
        MS_czj[whichtree][parIndex][a][t].counters_tot+=expressed_count;
      }
      acgp_count_recurse(l,toUse, whichtree);
    }
    ch = cur_ind->tr[p->f->evaltree].data;
    acgp_count_recurse_start(ch, toUse,  p->f->evaltree);
    break;
  }
}

// gwgnote: this call structure is based on how eval_tree and eval_tree_recurse works.
//          it gets memory in call stack set up correctly to traverse
void acgp_reset_expressed_czj(individual* ind)
/* resets the field expressed_czj in every node
   even in unexpressed subtrees (possible doe to crossover)
   NOTE: when resetting a node can be expressed even if parent wasn't
   due to crossover */
{
  cur_ind = ind; // set the current individual like eval tree
  acgp_reset_expressed_recurse_start(ind->tr[0].data,0);
}

// support function to mimic calls like eval_tree and eval_tree_recurse
static void acgp_reset_expressed_recurse_start(lnode *tree, int whichtree)
{
  lnode *l = tree;
  acgp_reset_expressed_recurse(&l,0);
}

static void acgp_reset_expressed_recurse(lnode **l, int whichtree)
/* recursive utility for above */
{
  function *parent;
  lnode* ch;
  int a;
  int parIndex, chIndex;
  (**l).expressed_czj=0;

  parent = (**l).f;
  parIndex=parent->index;
  ++*l;                      /* l is now first child */

  /* added to fix ERC issue - jja ****************************************/
  if (parent->arity==0)
  {
    if (parent->ephem_gen)
      ++*l;  /* skip the pointer over the ERC value if this node has one. */
  } /* end of ERC fix code - jja ****************************************/
  switch ( parent->type )
  {
  case TERM_NORM:
  case TERM_ERC:
  case EVAL_TERM:
  case TERM_ARG:
    a = 0;
    a++; // gwgnote: so I can put a breakpoint for debugging
    break;

  case FUNC_DATA:
    for ( a = 0; a < parent->arity; ++a )
      acgp_reset_expressed_recurse(l, whichtree);
    break;
  case EVAL_DATA:
    for ( a = 0; a < parent->arity; ++a )
      acgp_reset_expressed_recurse(l, whichtree);

    ch = cur_ind->tr[parent->evaltree].data;
    acgp_reset_expressed_recurse_start( ch, parent->evaltree);
    break;

  case FUNC_EXPR:
    for ( a = 0; a < parent->arity; ++a )
    {
      ++*l;           /* l was skipnode, now its the child */
      acgp_reset_expressed_recurse(l, whichtree);
    }
    break;

  case EVAL_EXPR:
    for ( a = 0; a < parent->arity; ++a )
    {
      ++*l;           /* l was skipnode, now its the child */
      acgp_reset_expressed_recurse(l, whichtree);
    }
    ch = cur_ind->tr[parent->evaltree].data;
    acgp_reset_expressed_recurse_start( ch, parent->evaltree);
    break;
  }
}

static double acgp_new_weight(double oldW, double prctChnge, double statW,
                              int mutSetSize, double thresholdPrct)
/* return new weight
   assume: oldW and statW are normalized to probs in their mut set */
{
  double newW;
  newW=oldW*(1-prctChnge)+statW*prctChnge;
  if (newW<thresholdPrct/mutSetSize || newW<MINWGHT)
    return MINWGHT;
  else
    return newW;
}

void acgp_adjustWeights(popstats *popStat, population **pops, int numPops, int curGen, int maxGen, const char *basefile)
/* called after every gp generation
   if acgp.what==0 then do nothing, plain CGP run
   first count statistics and print to *.cnt file for distribution information
   - compute counters statistics for all trees in all pops and print
   - extract (int)ceil(popSize*acgp_internal_use_trees_prct) from each pop
     onto the common extracted list
   - sort
   - if acgp.select_all==1 select all extracted
   - else select (int)ceil(popSize*acgp_internal_use_trees_prct)
   - count statistics and print to *.cnt file
   adjust weights if appropriate
   - adjusting is done every acgp_gen_step generations after
     acgp_gen_start=ceil(maxGen*acgp.gen_start_prct)
     if acgp.what > 1
   on adjusting generations
   - use the counters to adjust weights, then normalize then
     recompute the wheels and print weights into *.wgt
     (initial weights always printed up front)
   numPops is the number of populations
   popStat[0] is accumulative best from all populations */
{
  int i,a,j;
  static FILE *fp=NULL;
  static FILE* fptr=NULL;
  /* local vars for remaining acgp parameters with their default values */
  static double acgp_use_trees_prct=ACGP_use_trees_prct_DEFAULT;
  static int acgp_select_all=ACGP_select_all_DEFAULT;
  static double acgp_gen_start_prct=ACGP_gen_start_prct_DEFAULT;
  static int acgp_gen_step=ACGP_gen_step_DEFAULT;
  static int acgp_gen_slope=ACGP_gen_slope_DEFAULT;
  static double acgp_gen_slope_prct=ACGP_gen_slope_prct_DEFAULT;
  static double acgp_0_threshold_prct=ACGP_0_threshold_prct_DEFAULT;
  /* falling below this threshold/mutSetSize will be reset to MINWGHT */
  static double acgp_extract_quality_prct=ACGP_extract_quality_prct_DEFAULT;
  /* 0..1, 1-this number times the diff between best and worst
  fitness are considered same fitness for comparison (sort on size) */
  static int acgp_what=ACGP_what_DEFAULT;          /* def is no adjustments */

  /* now computed acgp parameter */
  static int acgp_gen_start;                /* generation to start adapting */
  static int popSize;
  static individual **acgp_pop_list;        /* this for sorting a whole pop */
  static int acgp_extract_from_pop;
  /* size to extract from each pop */
  static int acgp_extract_list_len;
  /* acgp_extract_from_pop*numPops */
  static individual **acgp_extract_list;
  /* constructd, list of pointers to extracted individuals */
  static double acgp_internal_use_trees_prct;
  /* acgp_use_trees_prct if numPops==1 || acgp_select_all==1 */
  /* sqrt(acgp_use_trees_prct) otherwise                     */
  static double acgp_prctChnge;             /* use this prct new of weights */
  double lowFit, highFit;
  char fname[BUFSIZ];
  char *p;
  int tn = 0; // total node count used for DEBUG_SORT
  int t = 0;
  int numF = 0;
  int numT = 0;
  int NumTypes=0;

  Acgp_adj_regrow=0;
  if (curGen==0)
  {
    /* first get acgp params and set dependent params and structures */
    Acgp_stop_on_term=ACGP_stop_on_term_DEFAULT;
    Acgp_use_expressed=ACGP_use_expressed_DEFAULT;
    if (p=get_parameter( "acgp.what" ))
      acgp_what = atoi(p);
    if (acgp_what<0 || acgp_what>3)
    {
      error ( E_WARNING, "acgp.what reset to default" );
      acgp_what=ACGP_what_DEFAULT;
    }
    if (!acgp_what)
      return;

    popSize=atoi(get_parameter("pop_size"));
    if (p=get_parameter( "acgp.use_trees_prct" ))
      acgp_use_trees_prct = atof(p);
    if (acgp_use_trees_prct<=0 || acgp_use_trees_prct>1)
      error ( E_FATAL_ERROR, "acgp_use_trees_prct must be (0..1>" );
    binary_parameter( "acgp.select_all",  ACGP_select_all_DEFAULT );
    if (p=get_parameter( "acgp.select_all" ))
      acgp_select_all = atoi(p);
    if (numPops==1 || acgp_select_all)
      acgp_internal_use_trees_prct=acgp_use_trees_prct;
    else
      acgp_internal_use_trees_prct=sqrt(acgp_use_trees_prct);
    acgp_extract_from_pop=(int)ceil(popSize*acgp_internal_use_trees_prct);
    acgp_extract_list_len=acgp_extract_from_pop*numPops;
    acgp_pop_list= (individual**)MALLOC (popSize*sizeof(individual*));
    acgp_extract_list= (individual**)MALLOC (acgp_extract_list_len*sizeof(individual*));
    if (p=get_parameter( "acgp.extract_quality_prct" ))
      acgp_extract_quality_prct = atof(p);
    if (acgp_extract_quality_prct<0 || acgp_extract_quality_prct>1)
    {
      error ( E_WARNING, "acgp.extract_quality_prct reset to default" );
      acgp_extract_quality_prct=ACGP_extract_quality_prct_DEFAULT;
    }
    if (acgp_what>1)
    {
      if (p=get_parameter( "acgp.gen_start_prct" ))
        acgp_gen_start_prct = atof(p);
      if (acgp_gen_start_prct<0 || acgp_gen_start_prct>1)
      {
        error ( E_WARNING, "acgp.gen_base_prct reset to default" );
        acgp_gen_start_prct=ACGP_gen_start_prct_DEFAULT;
      }
      acgp_gen_start=acgp_gen_start_prct*1000000;
      acgp_gen_start=maxGen*acgp_gen_start/1000000;
      if (p=get_parameter( "acgp.gen_step" ))
        acgp_gen_step = atoi(p);
      if (acgp_gen_step<1)
      {
        error ( E_WARNING, "acgp.gen_step reset to default" );
        acgp_gen_step=ACGP_gen_step_DEFAULT;
      }
      binary_parameter( "acgp.gen_slope",  ACGP_gen_slope_DEFAULT );
      if (p=get_parameter( "acgp.gen_slope" ))
        acgp_gen_slope = atoi(p);
      if (p=get_parameter( "acgp.gen_slope_prct" ))
        acgp_gen_slope_prct = atof(p);
      if (acgp_gen_slope_prct<0 || acgp_gen_slope_prct>1)
      {
        error ( E_WARNING, "acgp.gen_slope_prct reset to default" );
        acgp_gen_slope_prct=ACGP_gen_slope_prct_DEFAULT;
      }
      if (p=get_parameter( "acgp.0_threshold_prct" ))
        acgp_0_threshold_prct = atof(p);
      if (acgp_0_threshold_prct<0 || acgp_0_threshold_prct>1)
      {
        error ( E_WARNING, "acgp.0_threshold_prct reset to default" );
        acgp_0_threshold_prct=ACGP_0_threshold_prct_DEFAULT;
      }
      binary_parameter( "acgp.stop_on_term",  ACGP_stop_on_term_DEFAULT );
      if (p=get_parameter( "acgp.stop_on_term" ))
        Acgp_stop_on_term = atoi(p);
      if (p=get_parameter( "acgp.use_expressed" ))
        Acgp_use_expressed = atoi(p);
      if (Acgp_use_expressed<0 || Acgp_use_expressed>2)
      {
        error ( E_WARNING, "acgp.use_expressed reset to default" );
        Acgp_use_expressed=ACGP_use_expressed_DEFAULT;
      }
      if (acgp_gen_slope==0)             /* constant heuristics change rate */
        if (acgp_gen_slope_prct<SMALL)
          acgp_prctChnge=sqrt((double)acgp_gen_step/(maxGen-acgp_gen_start+1));
        else
          acgp_prctChnge=acgp_gen_slope_prct;
    }

    /* open weight file and print parameters and initial weights */
    strcpy(fname,basefile);
    strcat(fname,".wgt");
    if ((fp=fopen(fname,"w"))==0)
    {
      fprintf(stderr,"Could not open %s to write weights\n",fname);
      exit(1);
    }

    fprintf(fp,"Parameters:\n");
    fprintf(fp,"\trandom_seed=%d\n",
            !(get_parameter("random_seed")) ? 1 : (atoi(get_parameter("random_seed"))));
    fprintf(fp,"\tmax_generations=%d\n",maxGen);
    fprintf(fp,"\tpop_size=%d\n",popSize);
    fprintf(fp,"\tmultiple_subpops=%d\n",numPops);
    fprintf(fp,"\tacgp.use_trees_prct=%.5f\n",acgp_use_trees_prct);
    fprintf(fp,"\tacgp_internal_use_trees_prct=%.5f\n",
            acgp_internal_use_trees_prct);
    fprintf(fp,"\tacgp.extract_quality_prct=%.5f\n",acgp_extract_quality_prct);
    fprintf(fp,"\tacgp.select_all=%d\n",acgp_select_all);
    fprintf(fp,"\tacgp.what=%d\n",acgp_what);
    fprintf(fp,"\tacgp.stop_on_term=%d\n",Acgp_stop_on_term);
    fprintf(fp,"\tacgp.use_expressed=%d\n",Acgp_use_expressed);
    if (acgp_what>1)
    {
      fprintf(fp,"\tacgp.gen_start_prct=%.3f\n",acgp_gen_start_prct);
      fprintf(fp,"\tacgp_gen_start=%d\n",acgp_gen_start);
      fprintf(fp,"\tacgp.gen_step=%d\n",acgp_gen_step);
      fprintf(fp,"\tacgp.gen_slope=%d\n",acgp_gen_slope);
      if (acgp_gen_slope==0)
      {
        fprintf(fp,"\tacgp.gen_slope_prct=%.5f\n",acgp_gen_slope_prct);
        fprintf(fp,"\tconstant change rate at =%.5f\n",acgp_prctChnge);
      }
      fprintf(fp,"\tacgp.0_threshold_prct=%.3f\n",acgp_0_threshold_prct);
    }
    fprintf(fp,"\n");
    acgp_print_wghts(-1,fp,Acgp_adj_regrow>0);
    /* dumping the original weights */
  }                                   /* end of extra work on genereation 0 */

  /* here now on on every generation */
  if (!acgp_what)
    return;

  if (acgp_what>1 && curGen>=acgp_gen_start)
  {
    if (!((curGen-acgp_gen_start)%acgp_gen_step))
    {
      Acgp_adj_regrow=1;
      if (acgp_gen_slope==1)
        acgp_prctChnge= (double)(curGen-acgp_gen_start+1)/
                        (maxGen-acgp_gen_start+1);
      if (acgp_what==3)
        Acgp_adj_regrow=2;
    }
  }

#if 0
  /* this is for debugging counters  ****************/
  acgp_reset_count();
  for (i=0; i<numPops; i++)
  { for (j=0; j<popSize; j++)
    {
      acgp_count((pops[i]->ind)+j,1);
      acgp_print_counters(curGen,basefile,0);
    }
  }
  //acgp_print_counters(curGen,basefile,0);
  /***************************************** end remove **********************/
  return;
#endif

  lowFit=1;
  highFit=0;
  for (i=0; i<numPops; i++)
  { for (j=0; j<popSize; j++)     /* first extract from each pop after sort */
      acgp_pop_list[j] = pops[i]->ind + j;
    if (popStat[i+1].worstfit<lowFit)
      lowFit=popStat[i+1].worstfit;
    if (popStat[i+1].bestfit>highFit)
      highFit=popStat[i+1].bestfit;
#ifdef DEBUG_SORT
    printf("Pop %d list before sort. Bestfit=%.5f worstfit=%.5f\n",i,
           popStat[i+1].bestfit,popStat[i+1].worstfit);
    tn = 0;
    for (a=0; a<popSize; a++)
    { for(t = 0; t < tree_count; t++)
        tn += acgp_pop_list[a]->tr[t].nodes;
      printf("%3d%8.5f%4d\n",a,acgp_pop_list[a]->a_fitness, tn);
    }
#endif
    Acgp_extract_quality_diff=(popStat[i+1].bestfit-popStat[i+1].worstfit) * (1-acgp_extract_quality_prct);
    isort(acgp_pop_list,popSize);
#ifdef DEBUG_SORT
    printf("Pop %d list after sort based on q_diff=%.5f\n",i, Acgp_extract_quality_diff);

    tn = 0;
    for (a=0; a<popSize; a++)
    { for(t = 0; t < tree_count; t++)
        tn += acgp_pop_list[a]->tr[t].nodes;
      printf("%3d%8.5f%4d\n",a,acgp_pop_list[a]->a_fitness, tn);
    }
#endif
    for (j=0; j<acgp_extract_from_pop; j++)  /* and put best on extract list */
      acgp_extract_list[i*acgp_extract_from_pop+j]=acgp_pop_list[j];
  }

  acgp_reset_count();                                 /* now count and print */
#ifdef DEBUG_SORT
  printf("Extract list as constructed. Bestfit=%.5f=%.5f worstfit=%.5f=%.5f\n",
         highFit,popStat[0].bestfit,lowFit,popStat[0].worstfit);
  //for (i=0; i<acgp_extract_list_len; i++) // gwgdelete later
  //  printf("%3d%8.5f%4d\n",i,acgp_extract_list[i]->a_fitness, acgp_extract_list[i]->tr->nodes); // gwgdelete later

  tn = 0;
  for (i=0; i<acgp_extract_list_len; i++)
  { for(t = 0; t < tree_count; t++)
        tn += acgp_pop_list[i]->tr[t].nodes;
    printf("%3d%8.5f%4d\n",i,acgp_extract_list[i]->a_fitness, tn);
  }
#endif

  /* if numPops==1 || acgp_select_all then take all extracted */
  if (numPops==1 || acgp_select_all)
  { for (i=0; i<acgp_extract_list_len; i++)
      acgp_count(acgp_extract_list[i],1);
  }
  else                           /* resort and select acgp_internal_use_prct */
  {
    Acgp_extract_quality_diff=(highFit-lowFit)*(1-acgp_extract_quality_prct);
    isort(acgp_extract_list,acgp_extract_list_len);
#ifdef DEBUG_SORT
    printf("Extract list after additional sort\n");
    tn = 0;
    for (i=0; i<acgp_extract_list_len; i++)
    { for(t = 0; t < tree_count; t++)
        tn += acgp_extract_list[i]->tr[t].nodes;
      printf("%3d%8.5f%4d\n",i,acgp_extract_list[i]->a_fitness, tn);
    }
#endif
    for (i=0; i<acgp_internal_use_trees_prct*acgp_extract_list_len; i++)
      acgp_count(acgp_extract_list[i],1);
  }

  acgp_print_counters(curGen,basefile, Acgp_adj_regrow>0);
  /* on every generation */

  if (Acgp_adj_regrow<1)                   /* no adjustments this generation */
  {
    acgp_print_wghts(curGen,fp,Acgp_adj_regrow>0);
    return;                                   /* just print weights and done */
  }

  /* Note: we get here only on adjusting generation */
  int tr = 0;
  for(tr = 0; tr < tree_count; tr++)
  {
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    NumTypes=FTp[tr]->TypCount;
    for (i=0; i<numF; i++)                      /* work on functions in MS_czj */
    { for (a=0; a<fset[tr].cset[i].arity; a++)
        if (MS_czj[tr][i][a][NumTypes].counters_tot)
          for (j=0; j<numF+numT; j++)
            if (MS_czj[tr][i][a][NumTypes].weights[j]>0)                  /* if weight used */
              MS_czj[tr][i][a][NumTypes].weights[j]=
                acgp_new_weight(MS_czj[tr][i][a][NumTypes].weights[j],acgp_prctChnge,
                                (double)MS_czj[tr][i][a][NumTypes].counters[j]/MS_czj[tr][i][a][NumTypes].counters_tot,
                                MS_czj[tr][i][a][NumTypes].numFT,acgp_0_threshold_prct);
    }
    if (MS_czj[tr][numF][0][NumTypes].counters_tot)                   /* change Root weights */
      for (j=0; j<numF+numT; j++ )
        if (MS_czj[tr][numF][0][NumTypes].weights[j]>0)
          MS_czj[tr][numF][0][NumTypes].weights[j]=
            acgp_new_weight(MS_czj[tr][numF][0][NumTypes].weights[j],acgp_prctChnge,
                            (double)MS_czj[tr][numF][0][NumTypes].counters[j]/MS_czj[tr][numF][0][NumTypes].counters_tot,
                            MS_czj[tr][numF][0][NumTypes].numFT,acgp_0_threshold_prct);
  }

  acgp_normWghtsSetWheels();
#ifdef DEBUG_WHEELS
  printf("Generation %d\n",curGen);
  displayWeightsWheels(1,1);
#endif
  acgp_print_wghts(curGen,fp,Acgp_adj_regrow>0);

}

/* print weights from MS_czj into the open file fp */
static void acgp_print_wghts(int curGen, FILE *fp, int newIteration)
{
  int i, f, a, k, tr, numF, numT, NumTypes;
  for(tr = 0; tr < tree_count; tr++)
  {
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    NumTypes =FTp[tr]->TypCount;

    fprintf(fp, "tr=%2d, %s\n",pTS[tr].treeNo, pTS[tr].treeName);
    fprintf(fp,"%-4s%5.5s%4s%6s","It#","Func","Arg","TotCt");
    for (i=0; i<numF+numT; i++)
      fprintf(fp,"%6.5s",fset[tr].cset[i].string);
    fprintf(fp,"\n");

    for (f=0; f<numF; f++)
    { for (a=0; a<fset[tr].cset[f].arity; a++)
      {
        if (curGen<0) /* initial weights */
          fprintf(fp,"%4s","");
        else
          fprintf(fp,"%-4d",curGen);
        fprintf(fp,"%5.5s%4d %6d",fset[tr].cset[f].string,a, MS_czj[tr][f][a][NumTypes].counters_tot);
        for (k=0; k<numF+numT; k++)
          fprintf(fp,"%6.3f",MS_czj[tr][f][a][NumTypes].weights[k]);
        fprintf(fp, "\n");
      }
    }
    if (curGen<0) /* initial weights */
      fprintf(fp,"%4s","");
    else
      fprintf(fp,"%-4d",curGen);
    fprintf(fp,"%5.5s%4d %6d","Root",0,MS_czj[tr][numF][0][NumTypes].counters_tot);
    for (k=0; k<numF+numT; k++)
      fprintf(fp,"%6.3f",MS_czj[tr][numF][0][NumTypes].weights[k]);
    fprintf(fp,"\n");
  }
  if (newIteration)
    fprintf(fp,"*New iteration\n");
}

static void acgp_normWghtsSetWheels()
/* normalize weights for each mut set then set the wheel */
/* skip over those with counters_tot=0 (no change) */
/* set areTs/areFs same as in readWeightsSetWheels() */
{
  int i,a,k,tr,numF,numT, NumTypes;
  double adjWght, totWght;
  int areFs, areTs;

  for(tr = 0; tr < tree_count; tr++)
  {
    numF = pTS[tr].numF;
    numT = pTS[tr].numT;
    NumTypes =FTp[tr]->TypCount;

    for (i=0; i<numF; i++)
    {
      for (a=0; a<fset[tr].cset[i].arity; a++)
      {
        areFs=0;
        areTs=0;
        totWght=0;
        if (!MS_czj[tr][i][a][NumTypes].counters_tot)
          break;
        for (k=0; k<MS_czj[tr][i][a][NumTypes].numFT; k++)
          totWght+=MS_czj[tr][i][a][NumTypes].weights[MS_czj[tr][i][a][NumTypes].members[k]];
        /* now set mut wheel skipping over weights <MINWGHT+SMALL */
        for (k=0; k<MS_czj[tr][i][a][NumTypes].numF; k++)
        {
          if (MS_czj[tr][i][a][NumTypes].weights[MS_czj[tr][i][a][NumTypes].members[k]]<MINWGHT+SMALL)
            adjWght=0;
          else
          {
            adjWght=MS_czj[tr][i][a][NumTypes].weights[MS_czj[tr][i][a][NumTypes].members[k]]/totWght;
            areFs=1;
          }
          MS_czj[tr][i][a][NumTypes].wheel[k]= (k==0) ? adjWght:MS_czj[tr][i][a][NumTypes].wheel[k-1]+adjWght;
        }
        for (k=MS_czj[tr][i][a][NumTypes].numF; k<MS_czj[tr][i][a][NumTypes].numFT; k++)
        {
          if (MS_czj[tr][i][a][NumTypes].weights[MS_czj[tr][i][a][NumTypes].members[k]]<MINWGHT+SMALL)
            adjWght=0;
          else
          {
            adjWght=MS_czj[tr][i][a][NumTypes].weights[MS_czj[tr][i][a][NumTypes].members[k]]/totWght;
            areTs=1;
          }
          MS_czj[tr][i][a][NumTypes].wheel[k]= (k==0) ? adjWght:MS_czj[tr][i][a][NumTypes].wheel[k-1]+adjWght;
        }
        MS_czj[tr][i][a][NumTypes].areFs=areFs;
        MS_czj[tr][i][a][NumTypes].areTs=areTs;
        if (!areFs && !areTs)
        {
          fprintf(stderr,
                  "\tno member of f=%d arg=%d has any weight >MINWGHT\n",i,a);
          exit(1);
        }
      }
    }
    areFs=0;
    areTs=0;
    totWght=0;
    if (MS_czj[tr][numF][0][NumTypes].counters_tot)
    {
      for (k=0; k<MS_czj[tr][numF][0][NumTypes].numFT; k++)
        totWght+=MS_czj[tr][numF][0][NumTypes].weights[MS_czj[tr][numF][0][NumTypes].members[k]];
      for (k=0; k<MS_czj[tr][numF][0][NumTypes].numF; k++)
      {
        if (MS_czj[tr][numF][0][NumTypes].weights[MS_czj[tr][numF][0][NumTypes].members[k]]<MINWGHT+SMALL)
          adjWght=0;
        else
        {
          adjWght=MS_czj[tr][numF][0][NumTypes].weights[MS_czj[tr][numF][0][NumTypes].members[k]]/totWght;
          areFs=1;
        }
        MS_czj[tr][numF][0][NumTypes].wheel[k]= (k==0) ? adjWght :
                                      MS_czj[tr][numF][0][NumTypes].wheel[k-1]+adjWght;
      }
      for (k=MS_czj[tr][numF][0][NumTypes].numF; k<MS_czj[tr][numF][0][NumTypes].numFT; k++)
      {
        if (MS_czj[tr][numF][0][NumTypes].weights[MS_czj[tr][numF][0][NumTypes].members[k]]<MINWGHT+SMALL)
          adjWght=0;
        else
        {
          adjWght=MS_czj[tr][numF][0][NumTypes].weights[MS_czj[tr][numF][0][NumTypes].members[k]]/totWght;
          areTs=1;
        }
        MS_czj[tr][numF][0][NumTypes].wheel[k]= (k==0) ? adjWght :
                                      MS_czj[tr][numF][0][NumTypes].wheel[k-1]+adjWght;
      }
      MS_czj[tr][numF][0][NumTypes].areFs=areFs;
      MS_czj[tr][numF][0][NumTypes].areTs=areTs;
      if (!areFs && !areTs)
      {
        fprintf(stderr,"\ttr=%2d, no member of Root sets has any weight >MINWGHT\n", tr);
        exit(1);
      }
    }
  }
}

static int cmpQuality(const individual *p, const individual *q)
/* Compare quality for decreasing order, but if difference less than
   Acgp_extract_quality_diff then compare sizes
   Could extend the last 'else' to check if size diff is more
   significant than quality diff or not */
{
  int tr = 0;
  int tnp = 0; //total nodes p
  int tnq = 0; //total nodes q
  if ((p->a_fitness - q->a_fitness)>Acgp_extract_quality_diff)
    return -1;
  else if ((q->a_fitness - p->a_fitness)>Acgp_extract_quality_diff)
    return 1;
  else
  { /* original note.... considered same quality, take smaller size as secondary key */
    //return (p->tr->nodes - q->tr->nodes); //gwgnote: originally this does only tree 0 not any other trees

    // modified note.... considered same quality, take total smaller size as secondary key
    for(tr = 0; tr < tree_count; tr++)
    {
      tnp += p->tr[tr].nodes;
      tnq += q->tr[tr].nodes;
    }
    return (tnp - tnq);
  }
}

void isort(individual ** data, int array_size)
/* insertion sort redone for a list of individual*  */
{
  int i, j;
  individual *indexp;
  for (i=1; i < array_size; i++)
  {
    indexp = data[i];
    j = i;
    while ((j > 0) && (cmpQuality(data[j-1],indexp)>0))
    {
      data[j] = data[j-1];
      j--;
    }
    data[j] = indexp;
  }
}

/* buildData() will create the data structure and fill with default values
   for creating the input file from the information in the intarface file. */
Spec_t** buildData()
{
  int i, j, k, tr;
  int nF, nT, nFT; /* nF function, nT terminal, nFT funciton+term count */
  int sz;

  pTS = (treeStats*) malloc( tree_count * sizeof(treeStats));
  if(!pTS)
    return NULL;

  for(tr = 0; tr < tree_count; tr++)
  {
    pTS[tr].treeNo = tr;
    sz = strlen(tree_map[tr].name);
    pTS[tr].treeName = (char*)calloc(sz+1, sizeof(char) );
    strcpy(pTS[tr].treeName, tree_map[tr].name);
    strtoupper(pTS[tr].treeName);
    pTS[tr].numF = fset[tr].function_count;
    pTS[tr].numT = fset[tr].terminal_count;
  }

  FTp = (Spec_t**)malloc( tree_count * sizeof(Spec_t*));
  for(tr = 0; tr < tree_count; tr++)
  {
    nF = pTS[tr].numF;
    nT = pTS[tr].numT;
    nFT = nF+nT;

    /* creating primary data structure and arrays in it */
    FTp[tr] = (Spec_t *)malloc( sizeof(Spec_t) ); /*allocate the space for FTspecs*/

    sz = strlen(tree_map[tr].name);
    FTp[tr]->treeName = (char*)calloc(sz+1, sizeof(char) );
    strcpy(FTp[tr]->treeName, tree_map[tr].name);
    strtoupper(FTp[tr]->treeName);
    FTp[tr]->Func = (FuncList_t *)calloc( nF, sizeof(FuncList_t) );
    FTp[tr]->FRoot = (boolean *)calloc( ( nFT ), sizeof(boolean) );
    FTp[tr]->TRoot = (boolean *)calloc( ( nFT ), sizeof(boolean) );
    FTp[tr]->WRoot = (float *)calloc( ( nFT ), sizeof(float) );
    FTp[tr]->TypTerm = (typ_t *)calloc( nT, sizeof(typ_t) );

    FTp[tr]->TypRoot = TYPEDEFAULT;            /* setting default type */
    FTp[tr]->DefaultType = True;               /* will be set to false if */
    FTp[tr]->DefaultFT = True;                 /* the appropriate section */
    FTp[tr]->DefaultWeight = True;             /* appears in the interface file */

    for (i = 0; i < nT; i++)
      FTp[tr]->TypTerm[i] = TYPEDEFAULT;       /* setting terminal default type */

    for (i = 0; i < nFT; i++)
    {
      FTp[tr]->FRoot[i] = False;               /* set default F_Root = empty */
      FTp[tr]->TRoot[i] = False;               /* set default T_Root = empty */
      FTp[tr]->WRoot[i] = WEIGHTDEFAULT;       /* set default Weight Root = 1 */
    }
    /* fill the array of FT_funcs */
    for (i = 0; i < nF; i++)
    {
      FTp[tr]->Func[i].head = (inst_t *)malloc(sizeof(inst_t));
      FTp[tr]->Func[i].head->inst = NULL;
      FTp[tr]->Func[i].head->next = NULL;
      FTp[tr]->Func[i].instCount = 0;
      FTp[tr]->Func[i].F = (boolean *)calloc( nF, sizeof(boolean) );

      for (j = 0; j < nF; j++)
        FTp[tr]->Func[i].F[j] = False;           /* set default F_func = empty */
      /* allocate the array for FT_func_[args] */
      FTp[tr]->Func[i].Arg = (FuncArgList_t *)calloc( funcArity(tr,i), sizeof(FuncArgList_t) );

      for (j = 0; j < funcArity(tr,i); j++)
      {
        FTp[tr]->Func[i].Arg[j].F = (boolean *)calloc((nFT), sizeof(boolean));
        FTp[tr]->Func[i].Arg[j].T = (boolean *)calloc((nFT), sizeof(boolean));
        FTp[tr]->Func[i].Arg[j].W = (float *)calloc( (nFT), sizeof(float) );
        for (k = 0; k < nFT; k++)
        {
          FTp[tr]->Func[i].Arg[j].F[k] = False; /*set default F_func_[arg] = empty*/
          FTp[tr]->Func[i].Arg[j].T[k] = False; /*set default T_func_[arg] = empty*/
          FTp[tr]->Func[i].Arg[j].W[k] = WEIGHTDEFAULT; /*set def Weight func_[arg]*/
        }
      }
    }
  }
  return FTp;
}

/* getFuncNum returns the function number of f [0..numF) */
int getFuncNum(int tr, char *f)
{
  int i;
  for (i=0; i < pTS[tr].numF; i++)
    if ( !strcmp( funcTermName(tr,i), f ) )
      return i;
  return RETERROR;
}

/* getTermNum returns the function number of f [numF..numF+numT) */
int getTermNum(int tr, char *f)
{
  int i;
  for (i=pTS[tr].numF; i < pTS[tr].numF+pTS[tr].numT; i++)
    if ( !strcmp( funcTermName(tr, i), f ) )
      return i;
  return RETERROR;
}

/* getFuncTermNum returns the function number of f [0..numF+numT) */
int getFuncTermNum(int tr, char *f)
{
  int i;
  for (i=0; i < pTS[tr].numF+pTS[tr].numT; i++)
    if ( !strcmp( funcTermName(tr,i), f ) )
      return i;
  return RETERROR;
}

int getTypeNum(int tr, char *t)
{
  int i;
  for ( i = 0; i < FTp[tr]->TypCount; i++)
    if ( !strcmp(FTp[tr]->TypList[i], t) )
      return i;
  return RETERROR;
}

/* nextFunc returns the next function in the applicable list.  Passing
   NULL, cause it to use the existing string.  Passing a string will it
   cause it to make the new string the existing sting.
   t is the tree number */
int nextFunc(int tr, char *list)
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
      return getFuncNum(tr,token);
  }
  if ( num < pTS[tr].numF  )
    return num++;
  else
    return ENDLIST;
}

/* nextTerm returns the next terminal in the applicable list.  Passing
   NULL, cause it to use the existing string.  Passing a string will it
   cause it to make the new string the existing sting. */
int nextTerm(int tr, char *list)
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
    num = pTS[tr].numF;
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
      return getTermNum(tr, token);
  }
  if ( num < pTS[tr].numF + pTS[tr].numT )
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
   will it cause it to make the new string the existing sting.
   t is tree number */
int nextFuncTerm(int tr, char *list)
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
      return getFuncTermNum(tr,token);
  }
  if ( num < pTS[tr].numF + pTS[tr].numT )
    return num++;
  else
    return ENDLIST;
}

/* nextFuncSpec acts like nextFunc, but allows two seperate funclists to
   be processed at the same time.
   t is tree number */
int nextFuncSpec(int tr, char *list)
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
      return getFuncNum(tr,token);
  }
  if ( num < pTS[tr].numF )
    return num++;
  else
    return ENDLIST;
}


/* nextFuncTermSpec acts like nextFuncTerm, but allows two seperate
   functermlists to be processed at the same time.
   t is tree number. */
int nextFuncTermSpec(int tr, char *list)
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
      return getFuncTermNum(tr,token);
  }
  if ( num < pTS[tr].numF + pTS[tr].numT )
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
        error(E_FATAL_ERROR, "Illegal weight");
    }
  }
  return num;
}

/* nextType returns the next type in the applicable list.
   Passing NULL, cause it to use the existing string.  Passing a string
   will it cause it to make the new string the existing sting. */
int nextType(int tr, char *list)
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
  num = getTypeNum(tr,token);
  if ( num >= 0 )
    return num;
  else
  {
    error(E_FATAL_ERROR, "Illegal type");
    return RETERROR; // should never get here
  }
}

/* readFT() reads the F/Tspec section from the interface file, filling
   in the data structure to reflect the user defined F & Tspecs. */
void readFT(FILE *fp, char* brname)
{
  char spec[BUFSIZ]  = "";                 /* storage for various lists */
  char sList[BUFSIZ] = "";
  char fList[BUFSIZ] = "";
  char aList[BUFSIZ] = "";
  char errstr[BUFSIZ] = "";
  int  tr, numfunc, numarg, numspec;
  boolean isF;                             /* flag for style of spec */

  /* Need to have information for each tree */
  for(tr = 0; tr < tree_count; tr++)
  {
    if(strcmp(FTp[tr]->treeName,brname))
      continue;
    FTp[tr]->DefaultFT = False;                  /* not using default values */
    while (True)                             /* keep reading lines */
    {
      memset(line, '\0', BUFSIZ);
      linenum++;
      if ( fgets(line, BUFSIZ, fp) == NULL )
      {
        sprintf(errstr, "Unexpected EOF: line-> %d", linenum);
        error(E_FATAL_ERROR, errstr);
      }
      if ( sscanf(line, " %[FT_RO]", spec) != 1)
      {
        if ( sscanf(line, " %s", spec) == 0 )
          continue;
        if ( spec[0] == '#' )
          continue;                            /* restart while loop */
        else if ( !strcmp(spec, SECTIONEND) )
          break;
        else
        {
          sprintf(errstr, "Unknown F/Tspec: line-> %d", linenum);
          error(E_FATAL_ERROR, errstr);
        }
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
        {
          sprintf(errstr, "Unknown F/Tspec: line-> %d", linenum);
          error(E_FATAL_ERROR, errstr);
        }
        for ( numfunc = nextFunc(tr, fList); numfunc >= 0; numfunc = nextFunc(tr, NULL))
        {
          sprintf(dbgtext, "%s", funcTermName(tr,numfunc));  //gwgdbg
          for (numarg = nextArg(aList, funcArity(tr,numfunc)); numarg >= 0; numarg = nextArg(NULL, funcArity(tr,numfunc)))
          {
            for (numspec = nextFuncTermSpec(tr, sList); numspec >= 0; numspec = nextFuncTermSpec(tr, NULL))
            {
              if (isF)
                FTp[tr]->Func[numfunc].Arg[numarg].F[numspec] = True;
              else
                FTp[tr]->Func[numfunc].Arg[numarg].T[numspec] = True;
            }
            if ( (numspec != ENDLIST) && (numspec != COMMENT) )
            {
              sprintf(errstr, "Illegal function/terminal on right of '=': line-> %d", linenum);
              error(E_FATAL_ERROR, errstr);
            }
          }
          if ( numarg == COMMENT )
          {
            sprintf(errstr, "Comments not allowed in '[]': line-> %d", linenum);
            error(E_FATAL_ERROR, errstr);
          }
          if ( numarg != ENDLIST )
          {
            sprintf(errstr, "Illegal argument in ()[arglist]: line-> %d", linenum);
            error(E_FATAL_ERROR, errstr);
          }
        }
        if ( numfunc == COMMENT )
        {
          sprintf(errstr, "Comments not allowed in '()': line-> %d", linenum);
          error(E_FATAL_ERROR, errstr);
        }
        if ( numfunc != ENDLIST )
        {
          sprintf(errstr, "Illegal function in (funclist)[]: line-> %d", linenum);
          error(E_FATAL_ERROR, errstr);
        }
      }
      else if ( sscanf(line, " %[FT_RO]"
                       " (%["VALIDCHARS"])"
                       " =%["VALIDCHARS"]",
                       spec, fList, sList) == 3)
      {
        /* F_() =, no [arglist] */
        if ( !strcmp(spec, "F_") )
        {
          /* work on the function list */
          for ( numfunc = nextFunc(tr, fList); numfunc >= 0; numfunc = nextFunc(tr, NULL))
          {
            sprintf(dbgtext, "%s", funcTermName(tr,numfunc)); //gwgdbg
            for (numspec = nextFuncSpec(tr,sList); numspec >= 0; numspec = nextFuncSpec(tr,NULL))
              FTp[tr]->Func[numfunc].F[numspec] = True;
            if ( numspec != ENDLIST )
            {
              sprintf(errstr, "Illegal function on right of '=': line-> %d", linenum);
              error(E_FATAL_ERROR, errstr);
            }
          }
          if ( numfunc == COMMENT )
          {
            sprintf(errstr, "Comments not allowed in '()': line-> %d", linenum);
            error(E_FATAL_ERROR, errstr);
          }
          if ( numfunc != ENDLIST )
          {
            sprintf(errstr, "Illegal function in (funclist): line-> %d", linenum);
            error(E_FATAL_ERROR, errstr);
          }
        }
        else
        {
          sprintf(errstr, "Illegal FTspec: line-> %d", linenum);
          error(E_FATAL_ERROR, errstr);
        }
      }
      else if ( sscanf(line, " %[FT_RO]"
                       " =%["VALIDCHARS"]",
                       spec, sList) == 2)
      {
        /*  F/T_Root =, no (funclist) */
        if ( !strcmp(spec, "F_ROOT") )
          isF = True;
        else if ( !strcmp(spec, "T_ROOT") )
          isF = False;
        else
        {
          sprintf(errstr, "Unknown F/Tspec: line-> %d", linenum);
          error(E_FATAL_ERROR, errstr);
        }

        for (numspec=nextFuncTermSpec(tr, sList); numspec>=0; numspec=nextFuncTermSpec(tr, NULL))
        {
          if ( isF )
            FTp[tr]->FRoot[numspec] = True;
          else
            FTp[tr]->TRoot[numspec] = True;
        }
        if ( numspec != ENDLIST )
        {
          sprintf(errstr, "Illegal function/terminal on right of '=': line-> %d", linenum);
          error(E_FATAL_ERROR, errstr);
        }
      }
      else
      {
        sprintf(errstr, "Illegal FTspec: line-> %d", linenum);
        error(E_FATAL_ERROR, errstr);
      }
    }
  }
}

/* readWeight() reads the Weight spec section from the interface file, filling
   in the data structure to reflect the user defined Weights. All weights
   not specified in interface file are set to 1.0 by buildData().  Weights
   can be specified for all potential mutations sets.  During creation of
   the input file, only weights for valid mutation sets are used. */
void readWeight(FILE *fp, char* brname)
{
  char fList[BUFSIZ] = "";                    /* storage for various lists */
  char aList[BUFSIZ] = "";
  char sList[BUFSIZ] = "";
  char wList[BUFSIZ] = "";
  char errstr[BUFSIZ] = "";
  int  tr, numfunc, numarg, numspec;

  for(tr = 0; tr < tree_count; tr++)
  {
    if(strcmp(FTp[tr]->treeName,brname))
      continue;
    FTp[tr]->DefaultWeight = False;                  /* not using default values */
    while (True)
    {
      memset(line, '\0', BUFSIZ);
      linenum++;
      if ( fgets(line, BUFSIZ, fp) == NULL )
      {
        sprintf(errstr, "Unexpected EOF: line-> %d", linenum);
        error(E_FATAL_ERROR, errstr);
      }
      if (sscanf(line," ROOT(%["VALIDCHARS"]) =%["VALIDNUMS"]",fList,wList)==2)
      {
        for (numfunc = nextFuncTerm(tr, fList), nextWeight(wList);
             numfunc >= 0; numfunc = nextFuncTerm(tr, NULL))
          FTp[tr]->WRoot[numfunc] = nextWeight(NULL);
        if ( numfunc == COMMENT )
        {
          sprintf(errstr, "Comments not allowed inside '()': line-> %d", linenum);
          error(E_FATAL_ERROR, errstr);
        }
        if ( numfunc != ENDLIST )
        {
          sprintf(errstr, "Illegal function/terminal in (functermlist): line-> %d", linenum);
          error(E_FATAL_ERROR, errstr);
        }
      }
      else if (sscanf(line, " (%["VALIDCHARS"]) [%["VALIDCHARS"]] (%["VALIDCHARS
                      "]) =%["VALIDNUMS"]",fList,aList,sList,wList)==4)
      {
        for (numfunc=nextFunc(tr, fList); numfunc >= 0; numfunc=nextFunc(tr, NULL))
        {
          for (numarg=nextArg(aList,funcArity(tr,numfunc));
               numarg >= 0; numarg=nextArg(NULL,funcArity(tr,numfunc)))
          {
            for (numspec=nextFuncTermSpec(tr, sList), nextWeight(wList);
                 numspec>=0; numspec=nextFuncTermSpec(tr, NULL))
              FTp[tr]->Func[numfunc].Arg[numarg].W[numspec] = nextWeight(NULL);
            if ( numspec == COMMENT )
            {
              sprintf(errstr, "Comments not allowed inside '()': line-> %d", linenum);
              error(E_FATAL_ERROR, errstr);
            }
            if ( numspec != ENDLIST )
            {
              sprintf(errstr, "Illegal function/terminal in ()[](functermlist): line-> %d", linenum);
              error(E_FATAL_ERROR, errstr);
            }
          }
          if ( numarg == COMMENT )
          {
            sprintf(errstr, "Comments not allowed inside '[]': line-> %d", linenum);
            error(E_FATAL_ERROR, errstr);
          }
          if ( numarg != ENDLIST )
          {
            sprintf(errstr, "Illegal argument in ()[arglist](): line-> %d", linenum);
            error(E_FATAL_ERROR, errstr);
          }
        }
        if ( numfunc == COMMENT )
        {
          sprintf(errstr, "Comments not allowed inside '()': line-> %d", linenum);
          error(E_FATAL_ERROR, errstr);
        }
        if ( numfunc != ENDLIST )
        {
          sprintf(errstr, "Illegal function in (funclist)[](): line-> %d", linenum);
          error(E_FATAL_ERROR, errstr);
        }
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
          break;
        else
        {
          sprintf(errstr, "Unknown Weight Spec: line-> %d", linenum);
          error(E_FATAL_ERROR, errstr);
        }
      }
    }
  }
}

/* createTypes() reads the valid types from the interface file, filling
   in the data structure to reflect the user defined Types.
   t is tree number */
void createTypes(int tr, char *list)
{
  int count;
  char st[BUFSIZ];
  char *token;

  strcpy(st, list);
  token = strtok(st, " \t\n");
  /* count the number of types */
  for ( count = 0; (token != NULL) && (token[0] != '#');
        token = strtok(NULL, " \t\n"), count++ );
  if ( count < 1 )
    error(E_FATAL_ERROR, "Must declare at least one type");
  strcpy(st, list);

  /* Create data structure to hold valid type information */
  //gwgrevisit: see if it needs to be FTp[tr][somenumber]
  FTp[tr]->TypCount = count;
  FTp[tr]->TypList = (char **)calloc( FTp[tr]->TypCount, sizeof(char *) );
  for ( count = 0, token = strtok(st, " \t\n"); count < FTp[tr]->TypCount; count++ )
  {
    FTp[tr]->TypList[count] = (char *)malloc( strlen(token) + 1 );
    strcpy(FTp[tr]->TypList[count], token);
    token = strtok(NULL, " \t\n");
  }
}

/* readType() reads the Type spec section from the interface file, filling
   in the data structure to reflect the user defined Types. */
void readType(FILE *fp, char* brname)
{
  char fList[BUFSIZ] = "";                  /* storage for various lists */
  char sList[BUFSIZ] = "";
  char tList[BUFSIZ] = "";
  char errstr[BUFSIZ] = "";
  int  tr, numterm, numfunc, numarg, numtype;
  inst_t *ip; // gwgfix: free is never called on this

  for(tr = 0; tr < tree_count; tr++)
  {
    if(strcmp(FTp[tr]->treeName,brname))
      continue;
    FTp[tr]->DefaultType = False;                  /* not using default values */
    memset(line, '\0', BUFSIZ);
    linenum++;
    if ( fgets(line, BUFSIZ, fp) == NULL )
    {
      sprintf(errstr, "Unexpected EOF: line-> %d", linenum);
      error(E_FATAL_ERROR, errstr);
    }
    if ( sscanf(line, " TYPELIST =%["VALIDCHARS"]", tList) != 1 )
    {
      sprintf(errstr, "Expected valid type list definition: line-> %d", linenum);
      error(E_FATAL_ERROR, errstr);
    }
    createTypes(tr, tList);

    while (True)
    {
      memset(line, '\0', BUFSIZ);
      linenum++;
      if ( fgets(line, BUFSIZ, fp) == NULL )
      {
        sprintf(errstr, "Unexpected EOF: line-> %d", linenum);
        error(E_FATAL_ERROR, errstr);
      }
      if (sscanf(line, " ROOT =%["VALIDCHARS"]\n",tList)==1)
      {
        numtype = nextType(tr, tList);
        if ( numtype >= 0 )
          FTp[tr]->TypRoot = numtype;
        else if ( numtype == ENDLIST )
        {
          sprintf(errstr, "No type specified for Root: line-> %d", linenum);
          error(E_FATAL_ERROR, errstr);
        }

        numtype = nextType(tr,NULL);
        if ( (numtype != ENDLIST) && (numtype != COMMENT) )
        {
          sprintf(errstr, "Too many types specified for Root: line-> %d", linenum);
          error(E_FATAL_ERROR, errstr);
        }
      }
      else if ( sscanf(line, " (%["VALIDCHARS"]) =%["VALIDCHARS"]", fList, tList) == 2 )
      {
        for (numterm = nextTerm(tr,fList), numtype = nextType(tr,tList);
             numterm >= 0;
             numterm = nextTerm(tr,NULL))
        {
          if ( numtype >= 0 )
            FTp[tr]->TypTerm[numterm-pTS[tr].numF] = numtype;
          else if ( numtype == ENDLIST || numtype == COMMENT )
          {
            sprintf(errstr, "No type specified for terminal:line->  %d", linenum);
            error(E_FATAL_ERROR, errstr);
          }
          else
          {
            sprintf(errstr, "Illegal type on right of '=': line-> %d", linenum);
            error(E_FATAL_ERROR, errstr);
          }
        }
        if ( numterm == COMMENT )
        {
          sprintf(errstr, "Comments not allowed inside '()': line-> %d", linenum);
          error(E_FATAL_ERROR, errstr);
        }
        if ( numterm != ENDLIST )
        {
          sprintf(errstr, "Illegal terminal in (termlist): line-> %d", linenum);
          error(E_FATAL_ERROR, errstr);
        }
        numtype = nextType(tr,NULL);
        if ( numtype != ENDLIST && numtype != COMMENT)
        {
          sprintf(errstr, "Too many types specified for terminal: line-> %d", linenum);
          error(E_FATAL_ERROR, errstr);
        }
      }
      else if ( sscanf(line,
                       " (%["VALIDCHARS"]) (%["VALIDCHARS"]) =%["VALIDCHARS"]",
                       fList,sList,tList) == 3 )
      {
        for (numfunc= nextFunc(tr, fList); numfunc>=0; numfunc = nextFunc(tr, NULL))
        {
          FTp[tr]->Func[numfunc].instCount++;
          /* find end of list */
          for (ip=FTp[tr]->Func[numfunc].head; ip->next != NULL; ip=ip->next );
          ip->next = (inst_t *)malloc(sizeof(inst_t));
          ip = ip->next;
          ip->next = NULL;
          ip->inst = (typ_t *)calloc(funcArity(tr,numfunc)+1, sizeof(typ_t));
          for ( numarg=0, numtype=nextType(tr,sList);
                numarg<funcArity(tr,numfunc) && numtype>=0;
                numarg++, numtype=nextType(tr,NULL))
          {
            ip->inst[numarg] = numtype;
          }
          if ( numarg < funcArity(tr,numfunc) )
          {
            sprintf(errstr, "Too few argument types: line-> %d", linenum);
            error(E_FATAL_ERROR, errstr);
          }
          if ( numtype == COMMENT )
          {
            sprintf(errstr, "Comments not allowed inside '()': line-> %d", linenum);
            error(E_FATAL_ERROR, errstr);
          }
          if ( numtype != ENDLIST )
          {
            sprintf(errstr, "Too many argument types: line-> %d", linenum);
            error(E_FATAL_ERROR, errstr);
          }

          numtype = nextType(tr,tList);                     /* initialize list */
          ip->inst[numarg] = numtype;
          numtype = nextType(tr,NULL);
          if ( numtype != ENDLIST && numtype != COMMENT )
          {
            sprintf(errstr, "Too many return types: line-> %d", linenum);
            error(E_FATAL_ERROR, errstr);
          }
        }
        if ( numfunc == COMMENT )
        {
          sprintf(errstr, "Comments not allowed inside '()': line-> %d", linenum);
          error(E_FATAL_ERROR, errstr);
        }
        if ( numfunc != ENDLIST )
        {
          sprintf(errstr, "Illegal function in (funclist)(): line-> %d", linenum);
          error(E_FATAL_ERROR, errstr);
        }
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
          if ( FTp[tr]->TypRoot == TYPEDEFAULT )
          {
            sprintf(errstr, "No type defined for Root: line-> %d", linenum);
            error(E_FATAL_ERROR, errstr);
          }
          for ( numterm = 0; numterm < pTS[tr].numT; numterm++ )
            if ( FTp[tr]->TypTerm[numterm] == TYPEDEFAULT )
            {
              sprintf(errstr, "No type defined for terminal '%s'",
                      funcTermName(tr,numterm+pTS[tr].numF));
              error(E_FATAL_ERROR, errstr);
            }
          for ( numfunc = 0; numfunc < pTS[tr].numF; numfunc++ )
            if ( FTp[tr]->Func[numfunc].instCount == 0 )
            {
              sprintf(errstr, "No type defined for function '%s'",
                      funcTermName(tr,numfunc));
              error(E_FATAL_ERROR, errstr);
            }
          break;
        }
        else
        {
          sprintf(errstr, "Unknown Type Spec: line-> %d", linenum);
          error(E_FATAL_ERROR, errstr);
        }
      }
    }
  }
}

/* readInterfaceFile() start reading the interface file, determining which
   section is being defined */
void readInterfaceFile(FILE *fp)
{
  char section[BUFSIZ];
  char brname[BUFSIZ];
  char errstr[BUFSIZ] = "";

  while ( True  )
  {
    memset(line, '\0', BUFSIZ);
    linenum++;
    if ( fgets(line, BUFSIZ, fp) == NULL )
      break;
    if ( sscanf(line, "%s", section) != 1 )
      continue;

    if ( sscanf(section, "FTSPEC=%["VALIDCHARS"]", brname) == 1)
    {
      strtoupper(brname);
      readFT(fp, brname);
    }
    else if ( sscanf(section, "WEIGHT=%["VALIDCHARS"]", brname) == 1)
    {
      strtoupper(brname);
      readWeight(fp,brname);
    }
    else if ( sscanf(section, "TYPE=%["VALIDCHARS"]", brname) == 1)
    {
      strtoupper(brname);
      readType(fp,brname);
    }
    else if ( !strcmp(FILEEND, section) )
    {
      return;
    }
    else if ( section[0] == '#' )
    {
      continue;
    }
    else
    {
      sprintf(errstr, "Unknown section header: line-> %d", linenum);
      error(E_FATAL_ERROR, errstr);
    }
  }
  sprintf(errstr, "Section header not found (unexpected EOF without '"FILEEND"'): line-> %d", linenum);
  error(E_FATAL_ERROR, errstr);
}

/* buildInterface() determines which files need to be used for the
   interface and input files, if any, creates them and then sets up
   the building of the needed data structures. */
void buildInterface()
{
  FILE *interfaceFP;
  //char *inputFile;

  inputFP = stdin;
  interfaceFile = get_parameter("cgp_interface");
  //inputFile = get_parameter("cgp_input");

  if ( interfaceFile == NULL )
  {
    return;
  }

  if ( interfaceFile != NULL  )
  {
    linenum = 0;
    buildData();

    if ( (interfaceFP = fopen(interfaceFile, "r")) == NULL )
      error(E_FATAL_ERROR, "unable to open interface file");

    readInterfaceFile(interfaceFP);
    fclose(interfaceFP);

  }
}
