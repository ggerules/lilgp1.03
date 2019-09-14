/* cgp_czj.h provides prototypes for cgp_czj.c */
/* gwg: modifications for making this work with ADFS */
#pragma once

#define VERIFY_CROSSOVER_czj 0
#define VERIFY_MUTATION_czj 0
#define VERIFY_POPULATE_czj 1

typedef struct
{
  int   treeNo;                    /* Tree Number */
  char* treeName;                  /* Tree Name */
  int   numF;                      /* Number of functions for this tree */
  int   numT;                      /* Numebr of Terminals for this tree */
} treeStats;
treeStats* pTS;

typedef enum {False, True} boolean;
typedef int typ_t;

typedef struct instNode
{
  struct instNode *next;
  typ_t *inst;
} inst_t;

typedef struct
{
  boolean *F;                         /* F_func[arg] list (F+T)*/
  boolean *T;                         /* T_func[arg] list (F+T)*/
  float   *W;                         /* func[arg] Weight list (F+T)*/
} FuncArgList_t;

typedef struct
{
  boolean       *F;                   /* F_func list (F)*/
  FuncArgList_t *Arg;                 /* Pointer to Argument list (arity)*/
  inst_t         *head;               /* Pointer to Type Vec linked list (?)*/
  int            instCount;           /* Count of Type Vectors */
} FuncList_t;

typedef struct
{
  int     treeNo;                    /* Tree Number */
  char*   treeName;                  /* Tree Name */
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
} Spec_t;
//Spec_t **FTp;

typedef struct
{ int treeNo;                    /* Tree Number */
  int numF;                                                        /* type I */
  int areFs;                          /* 0 if all F weights <(MINWGHT+SMALL) */
  int numT;                                               /* type II and III */
  int areTs;                          /* 0 if all T weights <(MINWGHT+SMALL) */
  int numFT;                                                    /* numF+numT */
  int *members;                 /* lists numF F members, then numT T members */
                                            /* listing the indexes from fset */
  double *weights;           /* weights -1 or [MINWGHT..1] for all NumF+NumT */
                           /* -1 means corresponding element not in mut. set */
  double *wheel;             /* same size as 'members', accumulating weights */
                                         /* wheel[i+1]=wheel[i]+weights[i+1] */
  int *counters;             /* one counter per every element of NumFT czjmmh*/
  int counters_tot;
} mutationSet_czj_t; /* a type to store info about one mutation pair F and T */


typedef mutationSet_czj_t**** MS_czj_t;
	/* a dynamic array of 1+m, where m is the number of type I functions */

extern MS_czj_t MS_czj; /* the dynamic global table with mutation sets */

typedef struct
{
  int len;
  int *indexes;
} typesIndexes_t;

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

typedef oneTP_czj_t **TP_czj_t;

extern TP_czj_t TP_czj;              /* dynamic global array with type info */

extern int Function_czj; 
 	/* the node to be modified has this parent, -1 if the node  is root */

extern int Argument_czj; 
        /* the node to be modified is this argument of its parent 
	   uninitialized if the node is the root */

extern int Type_czj;
/* the return type expected by Function_czj on its Argument_czj */

extern int MinDepth_czj;

extern int Acgp_adj_regrow;
                 /* 0 -> no adjusting run
                    1 -> adjusting run but not regrowing this gen
                    2 -> adjusting and just adjusted and regrowing option */
extern int Acgp_stop_on_term;

extern const int RepeatsSrc_czj;      /* max repeats in crossover on no srcs */
extern const int RepeatsBad_czj;/* max repeats in crossover on bad offspring */

void savefileMS(const char* fname, const char* message,int uncMs, int wheel, int weight);

void create_MS_czj(void);
	/* will access global fset function table, and will allocate and
           initialize MS_czj; check that no pair is completely empty */
        /* Must be called after fset is created, but before initializing 
           the population */ 

void buildInterface();
/* buildInterface() determines which files need to be used for the
   interface and input files, if any, creates them and then sets up
   the building of the needed data structures. */

int random_F_czj(int tr);
	/* return a random type I index from fset, but which appear in the
	   mutation set for Function_czj/Argument_czj */
	/* if the set is empty, call random_T_czj() */

int random_T_czj(int tr);
	/* return a random type II/III index from fset, but which appear in the
           mutation set for Function_czj/Argument_czj */
	/* if the set is empty, call random_T_czj() */

int random_FT_czj(int tr);
	/* return a random type I/II/III index from fset, but which appear in 
	   the mutation set for Function_czj/Argument_czj */
	/* if the sets are both empty, generate an error */

//int verify_tree_czj (int tr, lnode *tree ); //gwg delete later
int verify_tree_czj (individual* ind);
    /* return #times the tree pointed by tree violates MS_czj constraints*/

int markXNodes_czj(int tr, lnode *data );
/* assume Function_czj and Argument_czj are set to indicate dest point */
/* mark all nodes in tree which are feasible sources with their wghts */
/* accummulate total wght marked in WghtSum_Int and WghtSum_Ext */
/*   for the internal and the external nodes, respectively */
/* return the number of marked nodes */

lnode *getSubtreeMarked_czj(lnode *data, int intExt);
/* assume tree is filled with both internal and external wheels */
/*   accummulated in WghtsInt and WghtsExt and at least one node is feasible */
/* return a node with selection prob. proportional to its weight */
/* if no nodes found return NULL */
/* if intExt==0 then looking for both internal and external */
/* if intExt==1 then looking for internal, and switch to external only if */
/*   no internal marked */
/* the opposite for intExt==2 */

void acgp_adjustWeights(popstats *popStat, population **pops, int numPops,
       int curGen, int maxGen, const char *basefile);
/* Adjust all weights in MS_czj according to counters
   normalize counters for every mut set, and then renormalize
   as some weights may have been dropped to 0
   Remember to set each wheel and the reset the counters
   numPops is the number of populations
   popStat[0] is accumulative best from all populations
   popStat[1] is best from pop 1, etc
   If Acgp_extract_quality then
     Acgp_extract_mult=1
   Else (extrating for size) then
     Acgp_extract_mult must be at least default
   Acgp_extract_from_pop=Acgp_use_trees*Acgp_extract_mult
   If Acgp_extract_quality then
     extract Acgp_extract_from_pop from each population
     take Acgp_use_trees best trees (needed if numPops>1)
     and count distribution
   Else (extracting for size)
     extract Acgp_extract_from_pop from each population
     take Acgp_extract_from_pop best trees (needed if numPops>1)
     and select Acgp_use_trees best in size, then count
   Note: make sure not to extract more than popSize
       from each population                                */

void acgp_reset_expressed_czj(individual *ind);
/* resets the field expressed_czj in every node
   even in unexpressed subtrees (possible due to crossover)
   NOTE: when resetting a node can be expressed even if parent wasn't
   due to crossover */

