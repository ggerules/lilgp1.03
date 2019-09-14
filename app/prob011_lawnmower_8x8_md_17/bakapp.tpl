[+ AutoGen5 template +]
[+ CASE (suffix) +]
[+ ==  h  +]
#pragma once

#include <lilgp.h>

typedef struct
{
     unsigned char **lawn;
     int lawn_width;
     int lawn_height;
     int xpos, ypos;
     int dir;
     int leftcount, movecount;
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
#define FITCASE_TOTAL_VARS [+ (+ (count "vars") 1 ) +][+
ENDIF+][+ENDFOR+][+ENDFOR+][+ 
FOR nadf+][+FOR fset+][+IF (first-for? "fset")+]
#define FSET_TOTAL [+ (+ (count "func") (count "vars") (count "const") (count "ercs")) +][+
ENDIF+][+ENDFOR+][+ENDFOR+]
[+ FOR nadf+][+FOR fset+][+IF (first-for? "fset")+]
static DATATYPE* app_fitness_cases[FITCASE_TOTAL_VARS];[+
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

  g.xpos = 4;
  g.ypos = 4;
  g.dir = APP_NORTH;
  g.leftcount = 0;
  g.movecount = 0;
  g.abort = 0;
  for ( i = 0; i < g.lawn_width; ++i ) 
    for ( j = 0; j < g.lawn_height; ++j )
      g.lawn[i][j] = APP_UNMOWN;

  /* evaluate the tree. */
  evaluate_tree ( ind->tr[0].data, 0 );

  k = 0;
  for ( i = 0; i < g.lawn_width; ++i ) 
    for ( j = 0; j < g.lawn_height; ++j )
      k += (g.lawn[i][j] == APP_MOWN);

  ind->hits = k; 
  ind->r_fitness = k;
        
  /* compute the standardized and raw fitness. */ 
  ind->s_fitness = ( g.lawn_width * g.lawn_height ) - ind->r_fitness;
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

  fprintf(fptrbind, "%s\n", "(lush-is-quiet t)");
  [+ FOR nadf+][+FOR fset +][+FOR func +][+FOR lispdefun +]fprintf(fptrbind, "%s\n", "[+row+]");
  [+ENDFOR lispdefun +][+ ENDFOR func+][+ ENDFOR fset+][+ENDFOR nadf+]
  for ( i = 0; i < run_stats[0].bestn; ++i )
  {
    //pretty_print_individual ( run_stats[0].best[i]->ind, fptrbind);
    int tr = tree_count-1;
    for(; tr >= 0; tr--) // tree
    {
      if(tr != 0)
      {
        //should never get here for single tree, because there are no adfs
        fprintf(fptrbind, "(de %s", tree_map[tr].name);
        pretty_print_tree ( run_stats[0].best[i]->ind->tr[tr].data, fptrbind);
      }
      else
      { 
        [+ FOR nadf+][+FOR fset+]fprintf(fptrbind, "(de [+treename+] ([+ FOR vars +][+altname+] [+ ENDFOR +][+ENDFOR+]) [+ENDFOR+][+ FOR nadf+][+FOR fset+][+ FOR vars +] (declare (-double-) [+altname+])[+ ENDFOR +][+ENDFOR+]");[+ENDFOR+]
        pretty_print_tree ( run_stats[0].best[i]->ind->tr[tr].data, fptrbind);
      }
      fprintf(fptrbind, "%s", ")");
      fprintf(fptrbind, "%s", "\n");
    }

    fflush(fptrbind); 
  }

  return run_stats[0].best[0]->ind->hits == g.lawn_width * g.lawn_height;
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

  g.lawn = (unsigned char **)MALLOC ( g.lawn_width * sizeof ( unsigned char * ) );
  for ( i = 0; i < g.lawn_width; ++i )
    g.lawn[i] = (unsigned char *)MALLOC ( g.lawn_height * sizeof ( unsigned char ) );

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

  for ( i = 0; i < g.lawn_width; ++i )
    FREE ( g.lawn[i] );
  FREE ( g.lawn );

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
ENDIF+][+ENDFOR+][+ENDFOR+][+ 
FOR yadf+][+FOR fset+][+IF (first-for? "fset")+]
#define FITCASE_TOTAL_VARS [+ (+ (count "vars") 1 ) +][+
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
static DATATYPE* app_fitness_cases[FITCASE_TOTAL_VARS];[+
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
      IF (first-for? "fset")+] [+ FOR func +]
      { [+name+], [+ercfun+], [+ercstr+], [+argcnt+], "[+altname+]", [+type+], [+evaltree+], 0 },[+
      ENDFOR +][+ 
      FOR vars +]
      { [+name+], [+ercfun+], [+ercstr+], [+argcnt+], "[+altname+]", [+type+], [+evaltree+], 0 },[+
      ENDFOR +][+
      FOR adffunc +]
      { [+name+], [+ercfun+], [+ercstr+], [+argcnt+], "[+altname+]", [+type+], [+evaltree+], 0 },[+
      ENDFOR +][+ 
      FOR const +]
      { [+name+], [+ercfun+], [+ercstr+], [+argcnt+], "[+altname+]", [+type+], [+evaltree+], 0 },[+
      ENDFOR +][+ 
      FOR ercs "," +]
      { [+name+], [+ercfun+], [+ercstr+], [+argcnt+], "[+altname+]", [+type+], [+evaltree+], 0 }[+
      ENDFOR +][+ 
      ELSE+] [+ FOR func +]
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
      ENDFOR +][+ENDIF+]

    }[+ ENDFOR fset +][+ ENDFOR yadf +]
  };

  fset = (function_set *)malloc( TREE_CNT * sizeof ( function_set ) );
  [+ FOR yadf+] [+ FOR fset+][+IF (first-for? "fset")+]
  fset[[+(for-index)+]].size = [+ (+ (count "func")(count "vars") (count "adffunc") (count "const") (count "ercs") ) +];
  fset[[+(for-index)+]].cset = sets[[+(for-index)+]];[+
  ELSE+]
  fset[[+(for-index)+]].size = [+ (+ (count "func")(count "vars") (count "adfarg") (count "adffunc") (count "const") (count "ercs") ) +];
  fset[[+(for-index)+]].cset = sets[[+(for-index)+]];[+
  ENDIF+][+ ENDFOR fset +][+ ENDFOR yadf +]

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

  g.xpos = 4;
  g.ypos = 4;
  g.dir = APP_NORTH;
  g.leftcount = 0;
  g.movecount = 0;
  g.abort = 0;
  for ( i = 0; i < g.lawn_width; ++i ) 
    for ( j = 0; j < g.lawn_height; ++j )
      g.lawn[i][j] = APP_UNMOWN;

  /* evaluate the tree. */
  evaluate_tree ( ind->tr[0].data, 0 );

  k = 0;
  for ( i = 0; i < g.lawn_width; ++i ) 
    for ( j = 0; j < g.lawn_height; ++j )
      k += (g.lawn[i][j] == APP_MOWN);

  ind->hits = k; 
  ind->r_fitness = k;
        
  /* compute the standardized and raw fitness. */ 
  ind->s_fitness = ( g.lawn_width * g.lawn_height ) - ind->r_fitness;
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

  fprintf(fptrbind, "%s\n", "(lush-is-quiet t)");
  [+ FOR yadf+][+FOR fset +][+IF (first-for? "fset")+][+FOR func +][+FOR lispdefun+]fprintf(fptrbind, "%s\n", "[+row+]");
  [+ENDFOR func+][+ENDFOR lispdefun+]
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
          break;
        }[+ENDFOR lispdefun+][+ENDFOR func+][+ENDIF+][+ENDFOR fset+][+ENDFOR yadf+]
        case 0:
        {
          [+FOR yadf+][+FOR fset+][+IF (first-for? "fset")+]fprintf(fptrbind, "(de [+treename+] ([+ FOR vars +][+altname+] [+ ENDFOR +])[+ENDIF+][+ENDFOR fset+][+ENDFOR yadf+] [+ FOR yadf+][+FOR fset+][+ FOR vars +] (declare (-double-) [+altname+])[+ ENDFOR +][+ENDFOR+]");[+ENDFOR+]
          pretty_print_tree ( run_stats[0].best[i]->ind->tr[tr].data, fptrbind);
          break;
        }
      }
      fprintf(fptrbind, "%s", ")");
      fprintf(fptrbind, "%s", "\n");
    }

    fflush(fptrbind); 
  }

  return run_stats[0].best[0]->ind->hits == g.lawn_width * g.lawn_height;
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

  g.lawn = (unsigned char **)MALLOC ( g.lawn_width * sizeof ( unsigned char * ) );
  for ( i = 0; i < g.lawn_width; ++i )
    g.lawn[i] = (unsigned char *)MALLOC ( g.lawn_height * sizeof ( unsigned char ) );

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

  for ( i = 0; i < g.lawn_width; ++i )
    FREE ( g.lawn[i] );
  FREE ( g.lawn );

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
  
