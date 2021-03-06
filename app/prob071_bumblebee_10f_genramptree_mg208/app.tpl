[+ AutoGen5 template +]
[+ CASE (suffix) +]
[+ ==  h  +]
#pragma once

#include <lilgp.h>

typedef struct
{
     vector* pfl;
     int* pvis;
     int nNumFlowers;
     float lawn_width;
     float lawn_height;
     float xpos;
     float ypos;
     int movecount;
     int abort;
} globaldata;

extern globaldata g;

[+ ==  c +]
#include <stdio.h>
#include <math.h>
#include <float.h>
#include <time.h>

#include <lilgp.h>

time_t tstart;  

globaldata g; 

[+ FOR nadf+][+FOR fset+][+IF (first-for? "fset")+]
#define TREE_CNT [+ (count "fset")+] [+
ENDIF+][+ENDFOR+][+ENDFOR+][+ 
FOR nadf+][+FOR fset+][+IF (first-for? "fset")+]
#define FSET_TOTAL [+ (+ (count "func") (count "vars") (count "const") (count "ercs")) +][+
ENDIF+][+ENDFOR+][+ENDFOR+]
[+ FOR nadf+][+FOR fset+][+IF (first-for? "fset")+]
static DATATYPE app_fitness_cases[APP_FITNESS_CASES][APP_DEFAULT_NUM_OF_FLOWERS];
static int      fvisited[APP_FITNESS_CASES][APP_DEFAULT_NUM_OF_FLOWERS];[+
ENDIF+][+ENDFOR+][+ENDFOR+]

int app_build_function_sets ( void )
{
  function_set fset;
  int tree_map;
  char *tree_name;
  int ret = 0;

  function sets[FSET_TOTAL] =
  { [+ FOR nadf +] [+ FOR fset +] [+ FOR func +]
    { [+name+], [+ercfun+], [+ercstr+], [+argcnt+], "[+altname+]", [+type+], -1, 0 },[+
    ENDFOR +][+ 
    FOR vars +]
    { [+name+], [+ercfun+], [+ercstr+], [+argcnt+], "[+altname+]", [+type+], -1, 0 },[+
    ENDFOR +][+ 
    FOR const +]
    { [+name+], [+ercfun+], [+ercstr+], [+argcnt+], "[+altname+]", [+type+], -1, 0 },[+
    ENDFOR +][+ 
    FOR ercs "," +]
    { [+name+], [+ercfun+], [+ercstr+], [+argcnt+], "[+altname+]", [+type+], -1, 0 }[+
    ENDFOR +][+ ENDFOR +] [+ ENDFOR +]
  };

  [+prob.interval+]

  fset.size = FSET_TOTAL;
  fset.cset = sets;
  tree_map = 0;
  [+ FOR nadf +][+ FOR fset +]tree_name = "[+treename+]";[+ ENDFOR +] [+ ENDFOR +]

  ret = function_sets_init ( &fset, TREE_CNT, &tree_map, &tree_name, TREE_CNT );
  return ret;
}

void app_eval_fitness ( individual *ind )
{
  int i, j, k;
  DATATYPE value;

  set_current_individual ( ind );

  g.xpos = 0.0;
  g.ypos = 0.0;
  g.movecount = 0;
  g.abort = 0;

  for ( i = 0; i < APP_FITNESS_CASES; ++i )
  {
    for(int f = 0; f < g.nNumFlowers; f++)
    {
      fvisited[i][f] = 0;
    }
  }

  for ( i = 0; i < APP_FITNESS_CASES; ++i )
  {
    for(int f = 0; f < g.nNumFlowers; f++)
    {
      g.pfl[i].x = app_fitness_cases[i][f].x;
      g.pfl[i].y = app_fitness_cases[i][f].y;
      g.pvis[i] = fvisited[i][f];
    }

    evaluate_tree ( ind->tr[0].data, 0 );

    for(int f = 0; f < g.nNumFlowers; f++)
    {
      fvisited[i][f] = g.pvis[i];
    }
  }

  k = 0;
  for ( i = 0; i < APP_FITNESS_CASES; ++i )
  {
    for(int f = 0; f < g.nNumFlowers; f++)
    {
      k += fvisited[i][f];
    }
  }

  ind->hits = k; 
  ind->r_fitness = k;
        
  /* compute the standardized and raw fitness. */ 
  ind->s_fitness = (g.nNumFlowers * APP_FITNESS_CASES) - ind->r_fitness;
  ind->a_fitness = 1/(1+ind->s_fitness);

  /* always leave this line in. */
  ind->evald = EVAL_CACHE_VALID;
  return;
}

int app_end_of_evaluation ( int gen, multipop *mpop, int newbest, popstats *gen_stats, popstats *run_stats )
{
  int i, j, tr;
  char fname[BUFSIZ];
  static FILE* fptr=NULL;
  static FILE* fptrbind=NULL;
  int numPops = mpop->size;
  const char* basefile = get_parameter( "output.basename" );
  const int popSize=atoi(get_parameter("pop_size"));
  population** pops = mpop->pop;

  binary_parameter ( "app.save_pop" , 0);

  if ( atoi ( get_parameter ( "app.save_pop" ) ) == 1)
  {
    /* open pop file and print individuals in population */
    strcpy(fname,basefile);
    strcat(fname,".pop");
    if ((fptr=fopen(fname,"a"))==0)
    {
      fprintf(stderr,"Could not open %s to write weights\n",fname);
      exit(1);
    }

    for (i=0; i<numPops; i++) // pop
    {
      for (j=0; j<popSize; j++) // individual
      {
        fprintf(fptr, "Gen %d PopNum %d IndNum %d\n", gen, i, j);
        int tr = tree_count-1;
        for(; tr >= 0; tr--) // tree
        {
          fprintf(fptr, " %s", tree_map[tr].name);
          //pretty_print_tree ( pops[i]->ind[j].tr[tr].data, fptr);
          print_tree ( pops[i]->ind[j].tr[tr].data, fptr);
          //fprintf(fptr, "%s", "\n");
        }
        fflush(fptr); 
      }
    }
  }

  /* save best individual  */
  strcpy(fname,basefile);
  strcat(fname,".bind");
  if ((fptrbind=fopen(fname,"w"))==0)
  {
    fprintf(stderr,"Could not open %s to write best individual.\n",fname);
    exit(1);
  }

  fprintf(fptrbind, "%s\n", "(ql:quickload \"read-csv\" :silent t)");
  fprintf(fptrbind, "%s\n", "(ql:quickload \"cl-strings\" :silent t)");
  fprintf(fptrbind, "%s\n", "(use-package :read-csv)");
  fprintf(fptrbind, "%s\n", "(use-package :cl-strings)");
  fprintf(fptrbind, "%s\n", ";;read in csv file");
  fprintf(fptrbind, "%s\n", "(defvar flowerloc)");
  fprintf(fptrbind, "%s\n", "(defvar fv)");
  fprintf(fptrbind, "%s\n", "(defvar lc)");
  fprintf(fptrbind, "%s\n", "(defvar row)");
  fprintf(fptrbind, "%s\n", "(defvar rc)");
  fprintf(fptrbind, "%s\n", "(defvar fc)");
  fprintf(fptrbind, "%s\n", "(defvar xx)");
  fprintf(fptrbind, "%s\n", "(defvar yy)");
  fprintf(fptrbind, "%s\n", "(defvar fcn)");
  fprintf(fptrbind, "%s\n", "(defvar xxn)");
  fprintf(fptrbind, "%s\n", "(defvar yyn)");
  fprintf(fptrbind, "%s\n", "(defvar pt)");
  fprintf(fptrbind, "%s\n", "(defvar g)");
  fprintf(fptrbind, "%s\n", "(defvar a0)");
  fprintf(fptrbind, "%s\n", "(setf lc 0)");
  fprintf(fptrbind, "%s\n", "(setf rc 0)");
  fprintf(fptrbind, "%s\n", "(defstruct vec (x 0) (y 0)) ; define structure");
  fprintf(fptrbind, "%s\n", ";; Loading fitness cases .....");
  fprintf(fptrbind, "%s\n", "(defstruct gdat ");
  fprintf(fptrbind, "%s\n", " (pfl (make-array '(10 10) :initial-element (make-vec :x 0.0 :y 0.0)))");
  fprintf(fptrbind, "%s\n", " (pvis(make-array '(10) :initial-element 0))");
  fprintf(fptrbind, "%s\n", " (nNumFlowers 10) ;int nNumFlowers;");
  fprintf(fptrbind, "%s\n", " (lawn_width 10)  ;float lawn_width;");
  fprintf(fptrbind, "%s\n", " (lawn_height 10) ;float lawn_height;");
  fprintf(fptrbind, "%s\n", " (xpos 0.0)       ;float xpos;");
  fprintf(fptrbind, "%s\n", " (ypos 0.0)       ;float ypos;");
  fprintf(fptrbind, "%s\n", " (curfc 0)        ; current fitness case");
  fprintf(fptrbind, "%s\n", " ;int movecount;");
  fprintf(fptrbind, "%s\n", " ;int abort;");
  fprintf(fptrbind, "%s\n", ")");
  fprintf(fptrbind, "%s\n", "(setf g (make-gdat :nNumFlowers 10 :lawn_width 10 :xpos 0 :ypos 0)) ");
  fprintf(fptrbind, "%s\n", "(setf fv (with-open-file (s \"./file.dat\") (parse-csv s)))");
  fprintf(fptrbind, "%s\n", ";; load flowers locations in to fitness cases array");
  fprintf(fptrbind, "%s\n", "(loop for row in fv");
  fprintf(fptrbind, "%s\n", "  do(setf fc (nth 0 row))");
  fprintf(fptrbind, "%s\n", "  do(setf fcn (parse-number fc))");
  fprintf(fptrbind, "%s\n", "  do(setf xx (nth 1 row))");
  fprintf(fptrbind, "%s\n", "  do(setf xxn (parse-number xx))");
  fprintf(fptrbind, "%s\n", "  do(setf yy (nth 2 row))");
  fprintf(fptrbind, "%s\n", "  do(setf yyn (parse-number yy))");
  fprintf(fptrbind, "%s\n", "  ;;do(format t \"~a,~a,~a~%\"  fc xx yy)");
  fprintf(fptrbind, "%s\n", "  (setf pt (make-vec :x xxn :y yyn)) ;  set value of slots of var ");
  fprintf(fptrbind, "%s\n", "  do(setf (aref (gdat-pfl g) fcn rc) pt)");
  fprintf(fptrbind, "%s\n", "  do(setf rc (+ rc 1))");
  fprintf(fptrbind, "%s\n", "  do(if (> rc 9) (setf rc 0) )");
  fprintf(fptrbind, "%s\n", "  do(setf lc (+ lc 1))");
  fprintf(fptrbind, "%s\n", ")");
  fprintf(fptrbind, "%s\n", ";; functions.....");
  fprintf(fptrbind, "%s\n", "(defun vadd (a b)");
  fprintf(fptrbind, "%s\n", " (make-vec :x (+ (vec-x a) (vec-x b)) :y (+ (vec-y a) (vec-y b)))");
  fprintf(fptrbind, "%s\n", ")");
  fprintf(fptrbind, "%s\n", "(defun vsub (a b)");
  fprintf(fptrbind, "%s\n", " (make-vec :x (- (vec-x a) (vec-x b)) :y (- (vec-y a) (vec-y b)))");
  fprintf(fptrbind, "%s\n", ")");
  fprintf(fptrbind, "%s\n", "(defun gox (a)");
  fprintf(fptrbind, "%s\n", " (setf (gdat-xpos g) (+ (gdat-xpos g)))");
  fprintf(fptrbind, "%s\n", " ;;check if bee is near a flower");
  fprintf(fptrbind, "%s\n", " (terpri)");
  fprintf(fptrbind, "%s\n", " (loop for i from 0 below (gdat-nNumFlowers g) do");
  fprintf(fptrbind, "%s\n", "   (if(<= (abs(- (vec-x (aref (gdat-pfl g) (gdat-curfc g) i)) (vec-x a))) 0.02) ");
  fprintf(fptrbind, "%s\n", "    (if(<= (abs(- (vec-y (aref (gdat-pfl g) (gdat-curfc g) i)) (vec-y a))) 0.02)");
  fprintf(fptrbind, "%s\n", "      (setf (aref (gdat-pvis g) i) 1)");
  fprintf(fptrbind, "%s\n", "    )");
  fprintf(fptrbind, "%s\n", "   )");
  fprintf(fptrbind, "%s\n", " )");
  fprintf(fptrbind, "%s\n", " (make-vec :x 0.0 :y 0.0)");
  fprintf(fptrbind, "%s\n", ")");
  fprintf(fptrbind, "%s\n", "(defun goy (a)");
  fprintf(fptrbind, "%s\n", " (setf (gdat-ypos g) (+ (gdat-ypos g) (vec-y a)))");
  fprintf(fptrbind, "%s\n", " ;;check if bee is near a flower");
  fprintf(fptrbind, "%s\n", " (terpri)");
  fprintf(fptrbind, "%s\n", " (loop for i from 0 below (gdat-nNumFlowers g) do");
  fprintf(fptrbind, "%s\n", "   (if(<= (abs(- (vec-x (aref (gdat-pfl g) (gdat-curfc g) i)) (vec-x a))) 0.02) ");
  fprintf(fptrbind, "%s\n", "    (if(<= (abs(- (vec-y (aref (gdat-pfl g) (gdat-curfc g) i)) (vec-y a))) 0.02)");
  fprintf(fptrbind, "%s\n", "      (setf (aref (gdat-pvis g) i) 1)");
  fprintf(fptrbind, "%s\n", "    )");
  fprintf(fptrbind, "%s\n", "   )");
  fprintf(fptrbind, "%s\n", " )");
  fprintf(fptrbind, "%s\n", " (make-vec :x 0.0 :y 0.0)");
  fprintf(fptrbind, "%s\n", ")");
  fprintf(fptrbind, "%s\n", "(defun nf()");
  fprintf(fptrbind, "%s\n", " (aref (gdat-pfl g) (gdat-curfc g) (random 10))");
  fprintf(fptrbind, "%s\n", ")");
  fprintf(fptrbind, "%s\n", "(defun bee()");
  fprintf(fptrbind, "%s\n", " (make-vec :x (gdat-xpos g) :y (gdat-ypos g)) ;  set value of slots of var ");
  fprintf(fptrbind, "%s\n", ")");

  [+ FOR nadf+][+FOR fset +][+FOR func +][+FOR lispdefun +][+ENDFOR lispdefun +][+ ENDFOR func+][+ ENDFOR fset+][+ENDFOR nadf+]
  for ( i = 0; i < run_stats[0].bestn; ++i )
  {
    //pretty_print_individual ( run_stats[0].best[i]->ind, fptrbind);
    int tr = tree_count-1;
    for(; tr >= 0; tr--) // tree
    {
      if(tr != 0)
      {
        //should never get here for single tree, because there are no adfs
        fprintf(fptrbind, "(defun %s", tree_map[tr].name);
        pretty_print_tree ( run_stats[0].best[i]->ind->tr[tr].data, fptrbind);
        fflush(fptrbind); 
      }
      else
      { 
        [+ FOR nadf+][+FOR fset+]fprintf(fptrbind, "(defun [+treename+] ()[+ENDFOR+][+ENDFOR+][+ FOR nadf+][+FOR fset+][+ FOR vars +][+ ENDFOR +][+ENDFOR+]");[+ENDFOR+]
        pretty_print_tree ( run_stats[0].best[i]->ind->tr[tr].data, fptrbind);
        fflush(fptrbind); 
      }
      fprintf(fptrbind, "%s", ")");
      fprintf(fptrbind, "%s", "\n");
    }

    fflush(fptrbind); 
  }

  fprintf(fptrbind, "%s\n", "(loop for fc from 0 below 10 do");
  fprintf(fptrbind, "%s\n", " (setf (gdat-curfc g) fc)");
  fprintf(fptrbind, "%s\n", " (setf (gdat-xpos g) 0.0)");
  fprintf(fptrbind, "%s\n", " (setf (gdat-ypos g) 0.0)");
  fprintf(fptrbind, "%s\n", " (loop for i from 0 below 10 do");
  fprintf(fptrbind, "%s\n", "  (setf (aref (gdat-pvis g) i) 0)");
  fprintf(fptrbind, "%s\n", " )");
  fprintf(fptrbind, "%s\n", " ;;(if(eql fc 3) (progn (print g) (quit) ))");
  fprintf(fptrbind, "%s\n", " ;;(format t \"fitness case ~d: ~s~%\" fc (gdat-pvis g))");
  fprintf(fptrbind, "%s\n", " ;;(print (gdat-pvis g))");
  fprintf(fptrbind, "%s\n", " (main)");
  fprintf(fptrbind, "%s\n", " (format t \"fitness case ~d: ~s~%\" fc (gdat-pvis g))");
  fprintf(fptrbind, "%s\n", " ;;(print (gdat-pvis g))");
  fprintf(fptrbind, "%s\n", ")");
  fprintf(fptrbind, "%s\n", "(quit)");

  fflush(fptrbind); 

  fclose(fptrbind);

  return run_stats[0].best[0]->ind->hits == g.nNumFlowers * APP_FITNESS_CASES;
}

int app_initialize ( int startfromcheckpoint )
{
  int i;
  char *param;

  param = get_parameter ( "app.lawn_width" );
  if ( param == NULL )
    g.lawn_width = APP_DEFAULT_LAWN_WIDTH;
  else
  {
    g.lawn_width = atoi ( param );
    if ( g.lawn_width < 1 )
      error ( E_FATAL_ERROR, "invalid value for \"app.lawn_width\"." );
  }
     
  param = get_parameter ( "app.lawn_height" );
  if ( param == NULL )
    g.lawn_height = APP_DEFAULT_LAWN_HEIGHT;
  else
  {
    g.lawn_height = atoi ( param );
    if ( g.lawn_height < 1 )
      error ( E_FATAL_ERROR, "invalid value for \"app.lawn_height\"." );
  }

  g.nNumFlowers = APP_DEFAULT_NUM_OF_FLOWERS;

  g.pfl = (vector*)MALLOC(g.nNumFlowers * sizeof(vector));
  if(!g.pfl)
    return 1; // out of memory 

  g.pvis = (int*)MALLOC(g.nNumFlowers * sizeof(int));
  if(!g.pvis)
    return 1;

  // assign flower locations based on lawn dimmensions
  // no two flowers can be with-in 0.02 of another flower
  for ( i = 0; i < APP_FITNESS_CASES; ++i )
  {
    for(int f = 0; f < g.nNumFlowers; f++)
    {
      app_fitness_cases[i][f].x = g.lawn_width * random_double();
      app_fitness_cases[i][f].y = g.lawn_height * random_double();
      // move numbers to be centered at 0,0
      app_fitness_cases[i][f].x = app_fitness_cases[i][f].x - (g.lawn_width / 2.0);
      app_fitness_cases[i][f].y = app_fitness_cases[i][f].y - (g.lawn_height / 2.0);
      fvisited[i][f] = 0;

      //check to see if any previous points are the same for this fitness case
      if(f > 0)
      {
        for(int j = f - 1; j >= 0; j--)
        {
          if(fabs(app_fitness_cases[i][f].x - app_fitness_cases[i][j].x) < 0.02)
          {
            //printf("%s\n", "match x");
            if(fabs(app_fitness_cases[i][f].y - app_fitness_cases[i][j].y) < 0.02)
            {
              //printf("%s\n", "match y");
              app_fitness_cases[i][f].x = g.lawn_width * random_double();
              app_fitness_cases[i][f].y = g.lawn_height * random_double();
              // move numbers to be centered at 0,0
              app_fitness_cases[i][f].x = app_fitness_cases[i][f].x - (g.lawn_width / 2.0);
              app_fitness_cases[i][f].y = app_fitness_cases[i][f].y - (g.lawn_height / 2.0);
              j = f;  // restart check
            }
          }
        }
      }
    }
  }

  tstart = time(NULL);

  return 0;
}

void app_uninitialize ( void )
{
  int i,j,k;

  const char* basefile = get_parameter( "output.basename" );
  char fname[BUFSIZ];
  static FILE* fptrtime=NULL;

  strcpy(fname,basefile);
  strcat(fname,".rtime");
  if ((fptrtime=fopen(fname,"w"))==0)
  {
    fprintf(stderr,"Could not open %s to write population.\n",fname);
    exit(1);
  }

  fprintf(fptrtime, "%f", difftime(time(NULL), tstart));
  fclose(fptrtime);

  FREE( g.pfl );
  FREE( g.pvis );

  return;
}

void app_end_of_breeding ( int gen, multipop *mpop )
{
  return;
}

int app_create_output_streams()
{
  return 0;
}
 
void app_read_checkpoint ( FILE *f )
{
  return;
}

void app_write_checkpoint ( FILE *f )
{
  return;
} 
[+ ==  adf  +]
#include <stdio.h>
#include <math.h>
#include <float.h>
#include <time.h>

#include <lilgp.h>

time_t tstart;  

globaldata g;

[+ FOR yadf+][+FOR fset+][+IF (first-for? "fset")+]
#define TREE_CNT [+ (count "fset")+] [+
ENDIF+][+ENDFOR+][+ENDFOR+] 
#define FSET_TOTAL[+(define fsz 0) 
  (define tot 0) 
  (set! fsz 0)
  (set! tot 0)
+][+ 
FOR yadf+][+FOR fset+] [+ 
(set! tot (+ (count "func") (count "vars") (count "adffunc") (count "adfarg") (count "const") (count "ercs") ) ) 
(if (> tot fsz) (set! fsz tot))
+][+ ENDFOR+][+ENDFOR+][+(sprintf "%d" fsz)+]
[+ FOR yadf+][+FOR fset+][+IF (first-for? "fset")+]
static DATATYPE app_fitness_cases[APP_FITNESS_CASES][APP_DEFAULT_NUM_OF_FLOWERS];
static int      fvisited[APP_FITNESS_CASES][APP_DEFAULT_NUM_OF_FLOWERS];[+
ENDIF+][+ENDFOR+][+ENDFOR+]

int app_build_function_sets ( void )
{
  function_set *fset;
  int *tree_map;
  char **tree_name;
  int ret;
  [+ FOR yadf+][+FOR fset+][+IF (first-for? "fset")+]
  function sets[TREE_CNT][FSET_TOTAL] =[+
  ENDIF+][+ENDFOR+][+ENDFOR+]
  { [+ FOR yadf "," +] [+ FOR fset ","+]
    { /* [+treename+] */ [+
      FOR func +]
      { [+name+], [+ercfun+], [+ercstr+], [+argcnt+], "[+altname+]", [+type+], [+evaltree+], 0 },[+
      ENDFOR +][+ 
      FOR vars +]
      { [+name+], [+ercfun+], [+ercstr+], [+argcnt+], "[+altname+]", [+type+], [+evaltree+], 0 },[+
      ENDFOR +][+
      FOR adffunc +]
      { [+name+], [+ercfun+], [+ercstr+], [+argcnt+], "[+altname+]", [+type+], [+evaltree+], 0 },[+
      ENDFOR +][+
      FOR adfarg +]
      { [+name+], [+ercfun+], [+ercstr+], [+argcnt+], "[+altname+]", [+type+], [+evaltree+], 0 },[+
      ENDFOR +][+ 
      FOR const +]
      { [+name+], [+ercfun+], [+ercstr+], [+argcnt+], "[+altname+]", [+type+], [+evaltree+], 0 },[+
      ENDFOR +][+ 
      FOR ercs "," +]
      { [+name+], [+ercfun+], [+ercstr+], [+argcnt+], "[+altname+]", [+type+], [+evaltree+], 0 }[+
      ENDFOR +]

    }[+ ENDFOR fset +][+ ENDFOR yadf +]
  };

  fset = (function_set *)malloc( TREE_CNT * sizeof ( function_set ) );
  [+ FOR yadf+] [+ FOR fset+]
  fset[[+(for-index)+]].size = [+ (+ (count "func")(count "vars") (count "adfarg") (count "adffunc") (count "const") (count "ercs") ) +];
  fset[[+(for-index)+]].cset = sets[[+(for-index)+]];[+
  ENDFOR fset +][+ ENDFOR yadf +]

  tree_map = (int *)malloc( TREE_CNT  * sizeof ( int ) );[+
  FOR yadf +][+ FOR fset +]
  tree_map[[+(for-index)+]] = [+(for-index)+]; [+ 
  ENDFOR yadf +][+ ENDFOR fset +]

  tree_name = (char**)malloc( TREE_CNT  * sizeof ( char*) );[+ 
  FOR yadf +][+ FOR fset +]
  tree_name[[+(for-index)+]] = (char*)malloc( 10 * sizeof(char));
  strcpy(tree_name[[+(for-index)+]], "[+treename+]");[+ 
  ENDFOR yadf +][+ ENDFOR fset +]

  [+prob.interval+]

  ret = function_sets_init ( fset, TREE_CNT, tree_map, tree_name, TREE_CNT );

  free ( fset ); [+ FOR yadf +][+ FOR fset +]
  free ( tree_name[[+(for-index)+]] );[+ 
  ENDFOR yadf +][+ ENDFOR fset +]
  free ( tree_map );

  return ret;
}

void app_eval_fitness ( individual *ind )
{
  int i, j, k;
  DATATYPE value;

  set_current_individual ( ind );

  g.xpos = 0.0;
  g.ypos = 0.0;
  g.movecount = 0;
  g.abort = 0;

  for ( i = 0; i < APP_FITNESS_CASES; ++i )
  {
    for(int f = 0; f < g.nNumFlowers; f++)
    {
      fvisited[i][f] = 0;
    }
  }

  for ( i = 0; i < APP_FITNESS_CASES; ++i )
  {
    for(int f = 0; f < g.nNumFlowers; f++)
    {
      g.pfl[i].x = app_fitness_cases[i][f].x;
      g.pfl[i].y = app_fitness_cases[i][f].y;
      g.pvis[i] = fvisited[i][f];
    }

    evaluate_tree ( ind->tr[0].data, 0 );

    for(int f = 0; f < g.nNumFlowers; f++)
    {
      fvisited[i][f] = g.pvis[i];
    }
  }

  k = 0;
  for ( i = 0; i < APP_FITNESS_CASES; ++i )
  {
    for(int f = 0; f < g.nNumFlowers; f++)
    {
      k += fvisited[i][f];
    }
  }


  ind->hits = k; 
  ind->r_fitness = k;
        
  /* compute the standardized and raw fitness. */ 
  ind->s_fitness = (g.nNumFlowers * APP_FITNESS_CASES) - ind->r_fitness;
  ind->a_fitness = 1/(1+ind->s_fitness);

  /* always leave this line in. */
  ind->evald = EVAL_CACHE_VALID;
  return;
}

int app_end_of_evaluation ( int gen, multipop *mpop, int newbest, popstats *gen_stats, popstats *run_stats )
{
  int i, j, tr;
  char fname[BUFSIZ];
  static FILE* fptr=NULL;
  static FILE* fptrbind=NULL;
  int numPops = mpop->size;
  const char* basefile = get_parameter( "output.basename" );
  const int popSize=atoi(get_parameter("pop_size"));
  population** pops = mpop->pop;

  binary_parameter ( "app.save_pop" , 0);

  if ( atoi ( get_parameter ( "app.save_pop" ) ) == 1)
  {
    /* open pop file and print individuals in population */
    strcpy(fname,basefile);
    strcat(fname,".pop");
    if ((fptr=fopen(fname,"a"))==0)
    {
      fprintf(stderr,"Could not open %s to write population.\n",fname);
      exit(1);
    }

    for (i=0; i<numPops; i++) // pop
    {
      for (j=0; j<popSize; j++) // individual
      {
        fprintf(fptr, "Gen %d PopNum %d IndNum %d\n", gen, i, j);
        int tr = tree_count-1;
        for(; tr >= 0; tr--) // tree
        {
          fprintf(fptr, " %s", tree_map[tr].name);
          //pretty_print_tree ( pops[i]->ind[j].tr[tr].data, fptr);
          print_tree ( pops[i]->ind[j].tr[tr].data, fptr);
          //fprintf(fptr, "%s", "\n");
        }
        fflush(fptr); 
      }
    }
  }

  /* save best individual  */
  strcpy(fname,basefile);
  strcat(fname,".bind");
  if ((fptrbind=fopen(fname,"w"))==0)
  {
    fprintf(stderr,"Could not open %s to write best individual.\n",fname);
    exit(1);
  }

  fprintf(fptrbind, "%s\n", "(ql:quickload \"read-csv\" :silent t)");
  fprintf(fptrbind, "%s\n", "(ql:quickload \"cl-strings\" :silent t)");
  fprintf(fptrbind, "%s\n", "(use-package :read-csv)");
  fprintf(fptrbind, "%s\n", "(use-package :cl-strings)");
  fprintf(fptrbind, "%s\n", ";;read in csv file");
  fprintf(fptrbind, "%s\n", "(defvar flowerloc)");
  fprintf(fptrbind, "%s\n", "(defvar fv)");
  fprintf(fptrbind, "%s\n", "(defvar lc)");
  fprintf(fptrbind, "%s\n", "(defvar row)");
  fprintf(fptrbind, "%s\n", "(defvar rc)");
  fprintf(fptrbind, "%s\n", "(defvar fc)");
  fprintf(fptrbind, "%s\n", "(defvar xx)");
  fprintf(fptrbind, "%s\n", "(defvar yy)");
  fprintf(fptrbind, "%s\n", "(defvar fcn)");
  fprintf(fptrbind, "%s\n", "(defvar xxn)");
  fprintf(fptrbind, "%s\n", "(defvar yyn)");
  fprintf(fptrbind, "%s\n", "(defvar pt)");
  fprintf(fptrbind, "%s\n", "(defvar g)");
  fprintf(fptrbind, "%s\n", "(defvar a0)");
  fprintf(fptrbind, "%s\n", "(setf lc 0)");
  fprintf(fptrbind, "%s\n", "(setf rc 0)");
  fprintf(fptrbind, "%s\n", "(defstruct vec (x 0) (y 0)) ; define structure");
  fprintf(fptrbind, "%s\n", ";; Loading fitness cases .....");
  fprintf(fptrbind, "%s\n", "(defstruct gdat ");
  fprintf(fptrbind, "%s\n", " (pfl (make-array '(10 10) :initial-element (make-vec :x 0.0 :y 0.0)))");
  fprintf(fptrbind, "%s\n", " (pvis(make-array '(10) :initial-element 0))");
  fprintf(fptrbind, "%s\n", " (nNumFlowers 10) ;int nNumFlowers;");
  fprintf(fptrbind, "%s\n", " (lawn_width 10)  ;float lawn_width;");
  fprintf(fptrbind, "%s\n", " (lawn_height 10) ;float lawn_height;");
  fprintf(fptrbind, "%s\n", " (xpos 0.0)       ;float xpos;");
  fprintf(fptrbind, "%s\n", " (ypos 0.0)       ;float ypos;");
  fprintf(fptrbind, "%s\n", " (curfc 0)        ; current fitness case");
  fprintf(fptrbind, "%s\n", " ;int movecount;");
  fprintf(fptrbind, "%s\n", " ;int abort;");
  fprintf(fptrbind, "%s\n", ")");
  fprintf(fptrbind, "%s\n", "(setf g (make-gdat :nNumFlowers 10 :lawn_width 10 :xpos 0 :ypos 0)) ");
  fprintf(fptrbind, "%s\n", "(setf fv (with-open-file (s \"./file.dat\") (parse-csv s)))");
  fprintf(fptrbind, "%s\n", ";; load flowers locations in to fitness cases array");
  fprintf(fptrbind, "%s\n", "(loop for row in fv");
  fprintf(fptrbind, "%s\n", "  do(setf fc (nth 0 row))");
  fprintf(fptrbind, "%s\n", "  do(setf fcn (parse-number fc))");
  fprintf(fptrbind, "%s\n", "  do(setf xx (nth 1 row))");
  fprintf(fptrbind, "%s\n", "  do(setf xxn (parse-number xx))");
  fprintf(fptrbind, "%s\n", "  do(setf yy (nth 2 row))");
  fprintf(fptrbind, "%s\n", "  do(setf yyn (parse-number yy))");
  fprintf(fptrbind, "%s\n", "  ;;do(format t \"~a,~a,~a~%\"  fc xx yy)");
  fprintf(fptrbind, "%s\n", "  (setf pt (make-vec :x xxn :y yyn)) ;  set value of slots of var ");
  fprintf(fptrbind, "%s\n", "  do(setf (aref (gdat-pfl g) fcn rc) pt)");
  fprintf(fptrbind, "%s\n", "  do(setf rc (+ rc 1))");
  fprintf(fptrbind, "%s\n", "  do(if (> rc 9) (setf rc 0) )");
  fprintf(fptrbind, "%s\n", "  do(setf lc (+ lc 1))");
  fprintf(fptrbind, "%s\n", ")");
  fprintf(fptrbind, "%s\n", ";; functions.....");
  fprintf(fptrbind, "%s\n", "(defun vadd (a b)");
  fprintf(fptrbind, "%s\n", " (make-vec :x (+ (vec-x a) (vec-x b)) :y (+ (vec-y a) (vec-y b)))");
  fprintf(fptrbind, "%s\n", ")");
  fprintf(fptrbind, "%s\n", "(defun vsub (a b)");
  fprintf(fptrbind, "%s\n", " (make-vec :x (- (vec-x a) (vec-x b)) :y (- (vec-y a) (vec-y b)))");
  fprintf(fptrbind, "%s\n", ")");
  fprintf(fptrbind, "%s\n", "(defun gox (a)");
  fprintf(fptrbind, "%s\n", " (setf (gdat-xpos g) (+ (gdat-xpos g)))");
  fprintf(fptrbind, "%s\n", " ;;check if bee is near a flower");
  fprintf(fptrbind, "%s\n", " (terpri)");
  fprintf(fptrbind, "%s\n", " (loop for i from 0 below (gdat-nNumFlowers g) do");
  fprintf(fptrbind, "%s\n", "   (if(<= (abs(- (vec-x (aref (gdat-pfl g) (gdat-curfc g) i)) (vec-x a))) 0.02) ");
  fprintf(fptrbind, "%s\n", "    (if(<= (abs(- (vec-y (aref (gdat-pfl g) (gdat-curfc g) i)) (vec-y a))) 0.02)");
  fprintf(fptrbind, "%s\n", "      (setf (aref (gdat-pvis g) i) 1)");
  fprintf(fptrbind, "%s\n", "    )");
  fprintf(fptrbind, "%s\n", "   )");
  fprintf(fptrbind, "%s\n", " )");
  fprintf(fptrbind, "%s\n", " (make-vec :x 0.0 :y 0.0)");
  fprintf(fptrbind, "%s\n", ")");
  fprintf(fptrbind, "%s\n", "(defun goy (a)");
  fprintf(fptrbind, "%s\n", " (setf (gdat-ypos g) (+ (gdat-ypos g) (vec-y a)))");
  fprintf(fptrbind, "%s\n", " ;;check if bee is near a flower");
  fprintf(fptrbind, "%s\n", " (terpri)");
  fprintf(fptrbind, "%s\n", " (loop for i from 0 below (gdat-nNumFlowers g) do");
  fprintf(fptrbind, "%s\n", "   (if(<= (abs(- (vec-x (aref (gdat-pfl g) (gdat-curfc g) i)) (vec-x a))) 0.02) ");
  fprintf(fptrbind, "%s\n", "    (if(<= (abs(- (vec-y (aref (gdat-pfl g) (gdat-curfc g) i)) (vec-y a))) 0.02)");
  fprintf(fptrbind, "%s\n", "      (setf (aref (gdat-pvis g) i) 1)");
  fprintf(fptrbind, "%s\n", "    )");
  fprintf(fptrbind, "%s\n", "   )");
  fprintf(fptrbind, "%s\n", " )");
  fprintf(fptrbind, "%s\n", " (make-vec :x 0.0 :y 0.0)");
  fprintf(fptrbind, "%s\n", ")");
  fprintf(fptrbind, "%s\n", "(defun nf()");
  fprintf(fptrbind, "%s\n", " (aref (gdat-pfl g) (gdat-curfc g) (random 10))");
  fprintf(fptrbind, "%s\n", ")");
  fprintf(fptrbind, "%s\n", "(defun bee()");
  fprintf(fptrbind, "%s\n", " (make-vec :x (gdat-xpos g) :y (gdat-ypos g)) ;  set value of slots of var ");
  fprintf(fptrbind, "%s\n", ")");

  [+ FOR yadf+][+FOR fset +][+IF (first-for? "fset")+][+FOR func +][+FOR lispdefun+][+ENDFOR func+][+ENDFOR lispdefun+]
  for ( i = 0; i < run_stats[0].bestn; ++i )
  {
    int tr = tree_count-1;
    for(; tr >= 0; tr--) // tree
    {
      switch(tr)
      {[+FOR adffunc+]
        case [+(+(for-index) 1)+]: 
        {[+FOR lispdefun+]
          fprintf(fptrbind, "%s\n", "[+row+]");
          pretty_print_tree ( run_stats[0].best[i]->ind->tr[tr].data, fptrbind);
          fflush(fptrbind); 
          break;
        }[+ENDFOR lispdefun+][+ENDFOR func+][+ENDIF+][+ENDFOR fset+][+ENDFOR yadf+]
        case 0:
        {
          [+FOR yadf+][+FOR fset+][+IF (first-for? "fset")+]fprintf(fptrbind, "(defun [+treename+] ()[+ENDIF+][+ENDFOR fset+][+ENDFOR yadf+][+ FOR yadf+][+FOR fset+][+ FOR vars +][+ ENDFOR +][+ENDFOR+]");[+ENDFOR+]
          pretty_print_tree ( run_stats[0].best[i]->ind->tr[tr].data, fptrbind);
          fflush(fptrbind); 
          break;
        }
      }
      fprintf(fptrbind, "%s", ")");
      fprintf(fptrbind, "%s", "\n");
    }

    fflush(fptrbind); 
  }

  fprintf(fptrbind, "%s\n", "(loop for fc from 0 below 10 do");
  fprintf(fptrbind, "%s\n", " (setf (gdat-curfc g) fc)");
  fprintf(fptrbind, "%s\n", " (setf (gdat-xpos g) 0.0)");
  fprintf(fptrbind, "%s\n", " (setf (gdat-ypos g) 0.0)");
  fprintf(fptrbind, "%s\n", " (loop for i from 0 below 10 do");
  fprintf(fptrbind, "%s\n", "  (setf (aref (gdat-pvis g) i) 0)");
  fprintf(fptrbind, "%s\n", " )");
  fprintf(fptrbind, "%s\n", " ;;(if(eql fc 3) (progn (print g) (quit) ))");
  fprintf(fptrbind, "%s\n", " ;;(format t \"fitness case ~d: ~s~%\" fc (gdat-pvis g))");
  fprintf(fptrbind, "%s\n", " ;;(print (gdat-pvis g))");
  fprintf(fptrbind, "%s\n", " (main)");
  fprintf(fptrbind, "%s\n", " (format t \"fitness case ~d: ~s~%\" fc (gdat-pvis g))");
  fprintf(fptrbind, "%s\n", " ;;(print (gdat-pvis g))");
  fprintf(fptrbind, "%s\n", ")");
  fprintf(fptrbind, "%s\n", "(quit)");

  fflush(fptrbind); 

  fclose(fptrbind);

  return run_stats[0].best[0]->ind->hits == g.nNumFlowers * APP_FITNESS_CASES;
}

int app_initialize ( int startfromcheckpoint )
{
  int i;
  char *param;

  param = get_parameter ( "app.lawn_width" );
  if ( param == NULL )
    g.lawn_width = APP_DEFAULT_LAWN_WIDTH;
  else
  {
    g.lawn_width = atoi ( param );
    if ( g.lawn_width < 1 )
      error ( E_FATAL_ERROR, "invalid value for \"app.lawn_width\"." );
  }
     
  param = get_parameter ( "app.lawn_height" );
  if ( param == NULL )
    g.lawn_height = APP_DEFAULT_LAWN_HEIGHT;
  else
  {
    g.lawn_height = atoi ( param );
    if ( g.lawn_height < 1 )
      error ( E_FATAL_ERROR, "invalid value for \"app.lawn_height\"." );
  }

  g.nNumFlowers = APP_DEFAULT_NUM_OF_FLOWERS;

  g.pfl = (vector*)MALLOC(g.nNumFlowers * sizeof(vector));
  if(!g.pfl)
    return 1; // out of memory 

  g.pvis = (int*)MALLOC(g.nNumFlowers * sizeof(int));
  if(!g.pvis)
    return 1;

  // assign flower locations based on lawn dimmensions
  // no two flowers can be with-in 0.02 of another flower
  for ( i = 0; i < APP_FITNESS_CASES; ++i )
  {
    for(int f = 0; f < g.nNumFlowers; f++)
    {
      app_fitness_cases[i][f].x = g.lawn_width * random_double();
      app_fitness_cases[i][f].y = g.lawn_height * random_double();
      // move numbers to be centered at 0,0
      app_fitness_cases[i][f].x = app_fitness_cases[i][f].x - (g.lawn_width / 2.0);
      app_fitness_cases[i][f].y = app_fitness_cases[i][f].y - (g.lawn_height / 2.0);
      fvisited[i][f] = 0;

      //check to see if any previous points are the same for this fitness case
      if(f > 0)
      {
        for(int j = f - 1; j >= 0; j--)
        {
          if(fabs(app_fitness_cases[i][f].x - app_fitness_cases[i][j].x) < 0.02)
          {
            //printf("%s\n", "match x");
            if(fabs(app_fitness_cases[i][f].y - app_fitness_cases[i][j].y) < 0.02)
            {
              //printf("%s\n", "match y");
              app_fitness_cases[i][f].x = g.lawn_width * random_double();
              app_fitness_cases[i][f].y = g.lawn_height * random_double();
              // move numbers to be centered at 0,0
              app_fitness_cases[i][f].x = app_fitness_cases[i][f].x - (g.lawn_width / 2.0);
              app_fitness_cases[i][f].y = app_fitness_cases[i][f].y - (g.lawn_height / 2.0);
              j = f;  // restart check
            }
          }
        }
      }
    }
  }

  tstart = time(NULL);

  return 0;
}

void app_uninitialize ( void )
{
  int i,j,k;  

  const char* basefile = get_parameter( "output.basename" );
  char fname[BUFSIZ];
  static FILE* fptrtime=NULL;

  strcpy(fname,basefile);
  strcat(fname,".rtime");
  if ((fptrtime=fopen(fname,"w"))==0)
  {
    fprintf(stderr,"Could not open %s to write population.\n",fname);
    exit(1);
  }

  fprintf(fptrtime, "%f", difftime(time(NULL), tstart));
  fclose(fptrtime);

  FREE( g.pfl );
  FREE( g.pvis );

 return;
}

void app_end_of_breeding ( int gen, multipop *mpop )
{
  return;
}

int app_create_output_streams()
{
  return 0;
}
 
void app_read_checkpoint ( FILE *f )
{
  return;
}

void app_write_checkpoint ( FILE *f )
{
  return;
} 
[+ESAC+]

