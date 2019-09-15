/* cgp_czj.h provides prototypes for cgp_czj.c */
/* 2019 gwg: modifications for making cgp2.1 work with ADFS */
#pragma once

#define VERIFY_CROSSOVER_czj 0
#define VERIFY_MUTATION_czj 0
#define VERIFY_POPULATE_czj 1
#define VERIFY_COLLAPSE_czj 0

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
Spec_t **FTp;

typedef struct
{
  int treeN;                                                     /* tree num */
  int numF;                                                        /* type I */
  int areFs;                          /* 0 if all F weights <(MINWGHT+SMALL) */
  int numT;                                               /* type II and III */
  int areTs;                          /* 0 if all T weights <(MINWGHT+SMALL) */
  int numFT;                                                    /* numF+numT */
  int *mbs;                     /* lists numF F members, then numT T members */
  /* listing the indexes from fset */
  double *weights;           /* weights -1 or [MINWGHT..1] for all NumF+NumT */
  /* -1 means corresponding element not in mut. set */
  double *wheel;             /* same size as 'members', accumulating weights */
  /* wheel[i+1]=wheel[i]+weights[i+1] */
} mutSet_czj_t;      /* a type to store info about one mutation pair F and T */

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


typedef mutSet_czj_t**** MST_czj_t;
typedef oneTP_czj_t **TP_czj_t;

//extern MST_czj_t MST_czj;         /* dynamic global table with mutation sets */
extern TP_czj_t TP_czj;              /* dynamic global array with type info */

extern int Function_czj;
/* the node to be modified has this parent, -1 if the node  is root */

extern int Argument_czj;
/* the node to be modified is this argument of its parent
uninitialized if the node is the root */

extern int Type_czj;
/* the return type expected by Function_czj on its Argument_czj */

extern int MinDepth_czj;

extern const int RepeatsSrc_czj;      /* max repeats in crossover on no srcs */
extern const int RepeatsBad_czj;/* max repeats in crossover on bad offspring */

void create_czj(void);
/* will access global fset function table, and will allocate and
         initialize MST_czj and TF_czj */
/* Must be called after fset is created, but before initializing
   the population */

int random_F_czj(int tr);
/* return a random type I index from fset, but which appear in the
   mutation set for Function_czj/Argument_czj */
/* if the set is empty, call random_FT_czj() */

int random_T_czj(int tr);
/* return a random type II/III index from fset, but which appear in the
         mutation set for Function_czj/Argument_czj */
/* if the set is empty, call random_FT_czj() */

int random_FT_czj(int tr);
/* return a random type I/II/III index from fset, but which appear in
   the mutation set for Function_czj/Argument_czj */
/* if the sets are both empty, generate an error */

int verify_tree_czj (int tr, lnode *tree );
/* return #times the tree pointed by tree violates MS_czj constraints*/

int markXNodes_czj(int tr, lnode *data );
/* assume Function_czj and Argument_czj are set to indicate dest point */
/* mark all nodes in tree which are feasible sources with their wghts */
/* accummulate total wght marked in WghtSum_Int and WghtSum_Ext */
/*   for the internal and the external nodes, respectively */
/* return the number of marked nodes */

int markXNodesNoRoot_czj(int tr, lnode *data );
/* Exactly like the markXNodes_czj function, except this skips */
/*  over the root */
/* return the number of marked nodes */

lnode *getSubtreeMarked_czj(int tr, lnode *data, int intExt);
/* assume tree is filled with both internal and external wheels */
/*   accummulated in WghtsInt and WghtsExt and at least one node is feasible */
/* return a node with selection prob. proportional to its weight */
/* if no nodes found return NULL */
/* if intExt==0 then looking for both internal and external */
/* if intExt==1 then looking for internal, and switch to external only if */
/*   no internal marked */
/* the opposite for intExt==2 */
