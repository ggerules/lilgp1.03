
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

/*
 * print_tree_array:  print the tree, as an array, on stdout.  primarily
 *     for debugging.
 */

void prn_tree_array_recurse ( lnode **l, int *index, FILE* fp );

void prn_tree_array ( lnode *data, FILE* fp )
{
  lnode *l = data;
  int i = 0;
  prn_tree_array_recurse ( &l, &i, fp );
}

void prn_tree_array_recurse ( lnode **l, int *index, FILE* fp )
{
  function *f = (**l).f;
  int i;

  fprintf (fp, "%3d: function: \"%s\"\n", *index, f->string );

  ++*l;
  ++*index;

  if ( f->arity == 0 )
  {
    if ( f->ephem_gen )
    {
      fprintf (fp, "%3d:    value: %s\n", *index, (f->ephem_str)((**l).d->d) );
      ++*l;
      ++*index;
    }
  }
  else
  {
    switch ( f->type )
    {
    case FUNC_DATA:
    case EVAL_DATA:
      for ( i = 0; i < f->arity; ++i )
      {
        prn_tree_array_recurse ( l, index, fp );
      }
      break;
    case FUNC_EXPR:
    case EVAL_EXPR:
      for ( i = 0; i < f->arity; ++i )
      {
        fprintf (fp, "%3d:    {skip %d}\n", *index, (**l).s );
        ++*l;
        ++*index;
        prn_tree_array_recurse ( l, index, fp );
      }
      break;
    }
  }

}

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

#define TREE_CNT 2
#define FITCASE_TOTAL_VARS 2
#define FSET_TOTAL 5

static DATATYPE* app_fitness_cases[FITCASE_TOTAL_VARS];

int app_build_function_sets ( void )
{
  function_set *fset;
  int *tree_map;
  char **tree_name;
  int ret;

  function sets[TREE_CNT][5] =
  {
    { /* MAIN */
      { fmul, NULL, NULL, 2, "fmul", FUNC_DATA, -1, 0 },
      { fdiv, NULL, NULL, 2, "fdiv", FUNC_DATA, -1, 0 },
      { fsub, NULL, NULL, 2, "fsub", FUNC_DATA, -1, 0 },
      { ttx, NULL, NULL, 0, "x", TERM_NORM, -1, 0 },
      { NULL, NULL, NULL, -1, "ADF0", EVAL_DATA, 1, 0 },

    },
    { /* ADF0 */
      { fadd, NULL, NULL, 2, "fadd", FUNC_DATA, -1, 0 },
      { NULL, NULL, NULL, 0, "a0", TERM_ARG, 0, 0 },
      { NULL, NULL, NULL, 0, "a1", TERM_ARG, 0, 0 },

    }
  };

  fset = (function_set *)malloc( TREE_CNT * sizeof ( function_set ) );

  fset[0].size = 5;
  fset[0].cset = sets[0];
  fset[1].size = 3;
  fset[1].cset = sets[1];

  tree_map = (int *)malloc( TREE_CNT  * sizeof ( int ) );
  tree_map[0] = 0;
  tree_map[1] = 1;

  tree_name = (char**)malloc( TREE_CNT  * sizeof ( char*) );
  tree_name[0] = (char*)malloc( 10 * sizeof(char));
  strcpy(tree_name[0], "MAIN");
  tree_name[1] = (char*)malloc( 10 * sizeof(char));
  strcpy(tree_name[1], "ADF0");

  /*used to help allocate memory for this problem*/
  inter_min = 0;
  inter_max = 20;
  interv = 1;

  ret = function_sets_init ( fset, TREE_CNT, tree_map, tree_name, TREE_CNT );

  free ( fset );
  free ( tree_name[0] );
  free ( tree_name[1] );
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
    /* fill in global structure according to current fitness case. */
    g.ttx = app_fitness_cases[0][i];

    /* evaluate the tree. */
    value = evaluate_tree ( ind->tr[0].data, 0 );

    /* here you would score the value returned by the individual
     * and update the raw fitness and/or hits. */
    diff = fabs ( value - app_fitness_cases[1][i] );
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
  //static FILE* fptrta=NULL;
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
          pretty_print_tree ( pops[i]->ind[j].tr[tr].data, fptr);
          fprintf(fptr, "%s", "\n");
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

  fprintf(fptrbind, "%s\n", "(defun fmul (x y) (* x y))");
  fprintf(fptrbind, "%s\n", "(defun fdiv (x y) (/ x y))");
  fprintf(fptrbind, "%s\n", "(defun fsub (x y) (- x y))");
  fprintf(fptrbind, "%s\n", "(defun fadd (x y) (+ x y))");

  for ( i = 0; i < run_stats[0].bestn; ++i )
  {
    //pretty_print_individual ( run_stats[0].best[i]->ind, fptrbind);
    int tr = tree_count-1;
    for(; tr >= 0; tr--) // tree
    {
      if(tr != 0)
      {
        fprintf(fptrbind, "%s", "(defun ADF0 (a0 a1) ");
        pretty_print_tree ( run_stats[0].best[i]->ind->tr[tr].data, fptrbind);
      }
      else
      {
        fprintf(fptrbind, "(defun %s (x)", tree_map[tr].name);
        pretty_print_tree ( run_stats[0].best[i]->ind->tr[tr].data, fptrbind);
      }
      fprintf(fptrbind, "%s", ")");
      fprintf(fptrbind, "%s", "\n");
    }

    fflush(fptrbind);
  }

  fprintf(fptrbind, "%s\n", "(each ((arg (cdr argv)))");
  fprintf(fptrbind, "  %s\n", "(load-matrix m arg)");
  fprintf(fptrbind, "  %s\n", "(for (i 0 20)");
  fprintf(fptrbind, ";   %s\n", "( prin (MAIN(m 1 i)) (m 0 i) (- (MAIN(m 1 i)) (m 0 i) ) )");
  fprintf(fptrbind, ";   %s\n", "(print)");
  fprintf(fptrbind, "    %s\n", "(if (< (abs (- (MAIN(m 1 i)) (m 0 i) )) 0.01) (print \"hit\") ())");
  fprintf(fptrbind, ";    %s\n", "(print)");
  fprintf(fptrbind, "  %s\n", ")");
  fprintf(fptrbind, "%s\n", ")");
  fflush(fptrbind);

#if 0
  strcpy(fname,basefile);
  strcat(fname,".ta");
  if ((fptrta=fopen(fname,"w"))==0)
  {
    fprintf(stderr,"Could not open %s to write best tree array individual.\n",fname);
    exit(1);
  }

  for ( i = 0; i < run_stats[0].bestn; ++i )
  {
    //pretty_print_individual ( run_stats[0].best[i]->ind, fptrbind);
    int tr = tree_count-1;
    for(; tr >= 0; tr--) // tree
    {
      if(tr != 0)
      {

        prn_tree_array ( run_stats[0].best[i]->ind->tr[tr].data, fptrta);
      }
      else
      {
        prn_tree_array ( run_stats[0].best[i]->ind->tr[tr].data, fptrta);
      }
    }

    fflush(fptrta);
  }
#endif

  return run_stats[0].besthits == APP_FITNESS_CASES;
}

int app_initialize ( int startfromcheckpoint )
{
  int i;
  //
  DATATYPE ttx=0,ttz=0;

  if ( !startfromcheckpoint )
  {

    app_fitness_cases[0] = buildIntervalSpacedSamples();
    app_fitness_cases[1] = buildIntervalSpacedSamples();

    for ( i = 0; i < inter_cnt; ++i )
    {
      ttx = (random_double()*2.0)-1.0;

      app_fitness_cases[0][i] = ttx;

      ttz = ttx*ttx*ttx*ttx + ttx*ttx*ttx + ttx*ttx + ttx;

      app_fitness_cases[1][i] = ttz;
    }
  }
  else
  {
    oprintf ( OUT_PRG, 20, "fitness cases loaded from checkpoint:\n" );
  }

  /*
  oprintf ( OUT_PRG, 20, "z = x*x*x*x + x*x*x + x*x + x\n" );
  */
  for ( i = 0; i < inter_cnt; ++i )
  {
    ttx = app_fitness_cases[0][i];

    ttz = app_fitness_cases[1][i];

    oprintf ( OUT_PRG, 20, "%f = %f*%f*%f*%f + %f*%f*%f + %f*%f + %f)\n", ttz,ttx,ttx,ttx,ttx,ttx,ttx,ttx,ttx,ttx,ttx,ttx);

  }

  tstart = time(NULL);

  return 0;
}

void app_uninitialize ( void )
{
  int i;
  //
  DATATYPE ttx=0,ttz=0;

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

  fprintf(fptrdat, ".MAT 2 2 %d\n", inter_cnt);
  /*results i.e. ttz */
  for ( i = 0; i < inter_cnt; ++i )
  {
    fprintf(fptrdat, "%f\n", app_fitness_cases[1][i]);
  }
  /*vars i.e. ttx, tty etc */
  for ( i = 0; i < inter_cnt; ++i )
  {
    fprintf(fptrdat, "%f\n", app_fitness_cases[0][i]);
  }
  fclose(fptrdat);


  freeIntervalSpacedSamples(app_fitness_cases[0]);
  freeIntervalSpacedSamples(app_fitness_cases[1]);

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


