[+ AutoGen5 template +]
[+ CASE (suffix) +]
[+ ==  h  +]
#pragma once

#include <lilgp.h>

typedef struct
{[+FOR nadf+][+FOR fset+][+FOR vars +]
  [+dtype+] [+name+]; [+
  ENDFOR +][+ENDFOR+][+ENDFOR+]
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

static int inter_min = 0;
static int inter_max = 0;
static double interv = 0.0;
static int inter_cnt = -1;

double* buildIntervalSpacedSamples()
{
  double i = (double)inter_min;
  int cnt = 0;
  double* pArr = NULL;
  while( i <= inter_max+0.001 )
  {
    //printf("%f\n", i);
    i += interv;
    cnt++;
  }
  if(inter_cnt == -1)
  {
    inter_cnt = cnt;
  }

  pArr = (double *)MALLOC ( cnt * sizeof ( double ) );

  double v = (double)inter_min;
  for(int i = 0; i < inter_cnt; i++)
  {
    pArr[i] = v;
    v += interv;
  }

  return pArr;
}

void freeIntervalSpacedSamples(double* pArr)
{
  FREE (pArr);
}
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
  int i;
  DATATYPE value;
  double diff;

  set_current_individual ( ind );

  ind->r_fitness = 0.0;
  ind->hits = 0;

  /* loop over all the fitness cases. */
  for ( i = 0; i < inter_cnt; ++i )
  {
    /* fill in global structure according to current fitness case. */ [+ 
    FOR nadf+][+FOR fset+][+ FOR vars +] 
    g.[+name+] = app_fitness_cases[[+(for-index)+]][i];[+
    ENDFOR +][+ENDFOR+][+ENDFOR+]

    /* evaluate the tree. */
    value = evaluate_tree ( ind->tr[0].data, 0 );

    /* here you would score the value returned by the individual
     * and update the raw fitness and/or hits. */ [+
    FOR nadf+][+FOR fset+][+IF (first-for? "fset")+] 
    diff = fabs ( value - app_fitness_cases[[+(count "vars")+]][i] );[+
    ENDIF+][+ENDFOR+][+ENDFOR+]
    if ( diff < 0.01 )
      ++ind->hits;
    ind->r_fitness += diff;
          
  }

  if ( isnan(ind->r_fitness) || !finite(ind->r_fitness) )
    ind->s_fitness = FLT_MAX;
  else
    ind->s_fitness = ind->r_fitness;
     
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

  return run_stats[0].besthits == APP_FITNESS_CASES;
}

int app_initialize ( int startfromcheckpoint )
{
  int i;
  // [+comment_app_initialize_vars+]
  DATATYPE [+FOR nadf+][+FOR fset+][+IF (first-for? "fset")+][+ FOR vars ","+][+name+]=0[+ENDFOR+][+ENDIF+][+ENDFOR+][+ENDFOR+],[+rvar[0].name+]=0;

  if ( !startfromcheckpoint )
  {
    [+ FOR nadf +][+ FOR fset +][+ FOR vars +] 
    app_fitness_cases[[+(for-index)+]] = buildIntervalSpacedSamples(); [+ 
    ENDFOR +][+ENDFOR+][+ENDFOR+][+
    FOR nadf+][+FOR fset+][+IF (first-for? "fset")+] 
    app_fitness_cases[[+(count "vars")+]] = buildIntervalSpacedSamples();[+
    ENDIF+][+ENDFOR+][+ENDFOR+]

    for ( i = 0; i < inter_cnt; ++i )
    { 
      [+prob.init+]
      [+ FOR nadf +][+ FOR fset +][+ FOR vars +][+IF (not (match-value? == "name" "ttxv"))+] 
      app_fitness_cases[[+(for-index)+]][i] = [+name+];[+ 
      ELSE+]
      [+name+] = app_fitness_cases[[+(for-index)+]][i];[+ 
      ENDIF+][+ENDFOR+][+ENDFOR+][+ENDFOR+]

      [+prob.calc+]
      [+FOR nadf+][+FOR fset+][+IF (first-for? "fset")+] 
      app_fitness_cases[[+(count "vars")+]][i] = [+rvar[0].name+];[+
      ENDIF+][+ENDFOR+][+ENDFOR+]
    }
  }
  else
  {
    oprintf ( OUT_PRG, 20, "fitness cases loaded from checkpoint:\n" );
  }

  /*     
  [+FOR prob+]oprintf ( OUT_PRG, 20, "[+str+]\n" ); [+ENDFOR prob+]
  */
  for ( i = 0; i < inter_cnt; ++i )
  { [+FOR nadf+][+FOR fset+][+IF (first-for? "fset")+][+FOR vars+]
    [+name+] = app_fitness_cases[[+(for-index "vars")+]][i]; [+
    ENDFOR+][+ENDIF+][+ENDFOR+][+ENDFOR+]

    [+FOR nadf+][+FOR fset+][+IF (first-for? "fset")+][+ 
    rvar[0].name+] = app_fitness_cases[[+(count "vars")+]][i];[+
    ENDIF+][+ENDFOR+][+ENDFOR+]

    [+FOR prob+] oprintf ( OUT_PRG, 20, "[+strprintf+]\n", [+strprintfvar+]);
    [+ENDFOR prob+]
  }

  tstart = time(NULL);

  return 0;
}

void app_uninitialize ( void )
{
  int i,j,k;
  // [+comment_app_initialize_vars+]
  DATATYPE [+FOR nadf+][+FOR fset+][+IF (first-for? "fset")+][+ FOR vars ","+][+name+]=0[+ENDFOR+][+ENDIF+][+ENDFOR+][+ENDFOR+],[+rvar[0].name+]=0;

  const char* basefile = get_parameter( "output.basename" );
  char fname[BUFSIZ];
  static FILE* fptrtime=NULL;
  static FILE* fptrdat=NULL;

  strcpy(fname,basefile);
  strcat(fname,".rtime");
  if ((fptrtime=fopen(fname,"w"))==0)
  {
    fprintf(stderr,"Could not open %s to write population.\n",fname);
    exit(1);
  }

  fprintf(fptrtime, "%f", difftime(time(NULL), tstart));
  fclose(fptrtime);

  strcpy(fname,basefile);
  strcat(fname,".dat");
  if ((fptrdat=fopen(fname,"w"))==0)
  {
    fprintf(stderr,"Could not open %s to write dat file.\n",fname);
    exit(1);
  }

  fprintf(fptrdat, ".MAT 2 %d %d\n", inter_cnt, [+FOR nadf+][+FOR fset+][+IF (first-for? "fset")+][+(+ (count "vars") 1)+][+ENDIF+][+ENDFOR+][+ENDFOR+]);
  for(i = 0; i < inter_cnt; ++i)
  {
    [+FOR nadf+][+FOR fset+][+IF (first-for? "fset")+]j = [+(count "vars")+];[+ENDIF+][+ENDFOR+][+ENDFOR+]
    fprintf(fptrdat, "%f ", app_fitness_cases[j][i]);
    for(k = 0; k < j; k++)
    {
      fprintf(fptrdat, "%f ", app_fitness_cases[k][i]);
    }
    fprintf(fptrdat, "%s", "\n");
  }

  fclose(fptrdat);

  [+FOR nadf+][+FOR fset+][+IF (first-for? "fset")+][+FOR vars+]
  freeIntervalSpacedSamples(app_fitness_cases[[+(for-index "vars")+]]); [+
  ENDFOR+][+ENDIF+][+ENDFOR+][+ENDFOR+][+
  FOR nadf+][+FOR fset+][+IF (first-for? "fset")+] 
  freeIntervalSpacedSamples(app_fitness_cases[[+(count "vars")+]]);[+
  ENDIF+][+ENDFOR+][+ENDFOR+]

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

static int inter_min = 0;
static int inter_max = 0;
static double interv = 0.0;
static int inter_cnt = -1;

double* buildIntervalSpacedSamples()
{
  double i = (double)inter_min;
  int cnt = 0;
  double* pArr = NULL;
  while( i <= inter_max+0.001 )
  {
    //printf("%f\n", i);
    i += interv;
    cnt++;
  }
  if(inter_cnt == -1)
  {
    inter_cnt = cnt;
  }

  pArr = (double *)MALLOC ( cnt * sizeof ( double ) );

  double v = (double)inter_min;
  for(int i = 0; i < inter_cnt; i++)
  {
    pArr[i] = v;
    v += interv;
  }

  return pArr;
}

void freeIntervalSpacedSamples(double* pArr)
{
  FREE (pArr);
}
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
  fset[[+(for-index)+]].size = [+ (+ (count "func") (count "adfarg") (count "const") (count "ercs")) +];
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
  int i;
  DATATYPE value;
  double diff;

  set_current_individual ( ind );

  ind->r_fitness = 0.0;
  ind->hits = 0;

  /* loop over all the fitness cases. */
  for ( i = 0; i < inter_cnt; ++i )
  {
    /* fill in global structure according to current fitness case. */ [+ 
    FOR yadf+][+FOR fset+][+IF (first-for? "fset")+][+FOR vars+]
    g.[+name+] = app_fitness_cases[[+(for-index "vars")+]][i]; [+
    ENDFOR+][+ENDIF+][+ENDFOR+][+ENDFOR+]

    /* evaluate the tree. */
    value = evaluate_tree ( ind->tr[0].data, 0 );

    /* here you would score the value returned by the individual
     * and update the raw fitness and/or hits. */ [+
    FOR yadf+][+FOR fset+][+IF (first-for? "fset")+] 
    diff = fabs ( value - app_fitness_cases[[+(count "vars")+]][i] );[+
    ENDIF+][+ENDFOR+][+ENDFOR+]
    if ( diff < 0.01 )
      ++ind->hits;
    ind->r_fitness += diff;

  }

  if ( isnan(ind->r_fitness) || !finite(ind->r_fitness) )
    ind->s_fitness = FLT_MAX;
  else
    ind->s_fitness = ind->r_fitness;

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

  return run_stats[0].besthits == APP_FITNESS_CASES;
}

int app_initialize ( int startfromcheckpoint )
{
  int i;  
  // [+comment_app_initialize_vars+]
  DATATYPE [+FOR yadf+][+FOR fset+][+IF (first-for? "fset")+][+ FOR vars ","+][+name+]=0[+ENDFOR+][+ENDIF+][+ENDFOR+][+ENDFOR+],[+rvar[0].name+]=0;

  if ( !startfromcheckpoint )
  {
    [+ FOR yadf+][+FOR fset+][+IF (first-for? "fset")+][+ FOR vars +] 
    app_fitness_cases[[+(for-index "vars")+]] = buildIntervalSpacedSamples(); [+ 
    ENDFOR +][+ENDIF+][+ENDFOR+][+ENDFOR+][+
    FOR yadf+][+FOR fset+][+IF (first-for? "fset")+] 
    app_fitness_cases[[+(count "vars")+]] = buildIntervalSpacedSamples();[+
    ENDIF+][+ENDFOR+][+ENDFOR+]

    for ( i = 0; i < inter_cnt; ++i )
    {
      [+prob.init+]
      [+ FOR yadf +][+ FOR fset +][+ FOR vars +][+IF (not (match-value? == "name" "ttxv"))+] 
      app_fitness_cases[[+(for-index)+]][i] = [+name+];[+ 
      ELSE+]
      [+name+] = app_fitness_cases[[+(for-index)+]][i];[+ 
      ENDIF+][+ENDFOR+][+ENDFOR+][+ENDFOR+]

      [+prob.calc+]
      [+FOR yadf+][+FOR fset+][+IF (first-for? "fset")+] 
      app_fitness_cases[[+(count "vars")+]][i] = [+rvar[0].name+];[+
      ENDIF+][+ENDFOR+][+ENDFOR+]
    }
  }
  else
  {
    oprintf ( OUT_PRG, 20, "fitness cases loaded from checkpoint:\n" );
  }

  /*
  [+FOR prob+]oprintf ( OUT_PRG, 20, "[+str+]\n" );[+ENDFOR prob+]
  */
  for ( i = 0; i < inter_cnt; ++i )
  { [+FOR yadf+][+FOR fset+][+IF (first-for? "fset")+][+FOR vars+]
    [+name+] = app_fitness_cases[[+(for-index "vars")+]][i]; [+
    ENDFOR+][+ENDIF+][+ENDFOR+][+ENDFOR+]

    [+FOR yadf+][+FOR fset+][+IF (first-for? "fset")+][+ 
    rvar[0].name+] = app_fitness_cases[[+(count "vars")+]][i];[+
    ENDIF+][+ENDFOR+][+ENDFOR+]

    [+FOR prob+] oprintf ( OUT_PRG, 20, "[+strprintf+]\n", [+strprintfvar+]);
    [+ENDFOR prob+]
  }

  tstart = time(NULL);

  return 0;
}

void app_uninitialize ( void )
{
  int i,j,k;  
  // [+comment_app_initialize_vars+]
  DATATYPE [+FOR yadf+][+FOR fset+][+IF (first-for? "fset")+][+ FOR vars ","+][+name+]=0[+ENDFOR+][+ENDIF+][+ENDFOR+][+ENDFOR+],[+rvar[0].name+]=0;

  const char* basefile = get_parameter( "output.basename" );
  char fname[BUFSIZ];
  static FILE* fptrtime=NULL;
  static FILE* fptrdat=NULL;

  strcpy(fname,basefile);
  strcat(fname,".rtime");
  if ((fptrtime=fopen(fname,"w"))==0)
  {
    fprintf(stderr,"Could not open %s to write population.\n",fname);
    exit(1);
  }

  fprintf(fptrtime, "%f", difftime(time(NULL), tstart));
  fclose(fptrtime);

  strcpy(fname,basefile);
  strcat(fname,".dat");
  if ((fptrdat=fopen(fname,"w"))==0)
  {
    fprintf(stderr,"Could not open %s to write dat file.\n",fname);
    exit(1);
  }

  fprintf(fptrdat, ".MAT 2 %d %d\n", inter_cnt, [+FOR yadf+][+FOR fset+][+IF (first-for? "fset")+][+(+ (count "vars") 1)+][+ENDIF+][+ENDFOR+][+ENDFOR+]);
  for(i = 0; i < inter_cnt; ++i)
  {
    [+FOR yadf+][+FOR fset+][+IF (first-for? "fset")+]j = [+(count "vars")+];[+ENDIF+][+ENDFOR+][+ENDFOR+]
    fprintf(fptrdat, "%f ", app_fitness_cases[j][i]);
    for(k = 0; k < j; k++)
    {
      fprintf(fptrdat, "%f ", app_fitness_cases[k][i]);
    }
    fprintf(fptrdat, "%s", "\n");
  }

  fclose(fptrdat);

  [+FOR nadf+][+FOR fset+][+IF (first-for? "fset")+][+FOR vars+]
  freeIntervalSpacedSamples(app_fitness_cases[[+(for-index "vars")+]]); [+
  ENDFOR+][+ENDIF+][+ENDFOR+][+ENDFOR+][+
  FOR nadf+][+FOR fset+][+IF (first-for? "fset")+] 
  freeIntervalSpacedSamples(app_fitness_cases[[+(count "vars")+]]);[+
  ENDIF+][+ENDFOR+][+ENDFOR+]

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
  
