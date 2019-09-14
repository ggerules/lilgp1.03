/*  lil-gp Genetic Programming System, version 1.0, 11 July 1995
 *  Copyright (C) 1995  Michigan State University
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of version 2 of the GNU General Public License as
 *  published by the Free Software Foundation.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 *  Douglas Zongker       (zongker@isl.cps.msu.edu)
 *  Dr. Bill Punch        (punch@isl.cps.msu.edu)
 *
 *  Computer Science Department
 *  A-714 Wells Hall
 *  Michigan State University
 *  East Lansing, Michigan  48824
 *  USA
 *
 */

#include <stdio.h>
#include <math.h>
#include <float.h>

#include <lilgp.h>

globaldata g;

static DATATYPE app_fitness_cases[APP_FITNESS_CASES][5];

int app_build_function_sets ( void )
{
     function_set *fset;
     int *tree_map;
     char *tree_name[2];
     int ret;

     function sets[2][9] =

     /* rpb */
     { { { f_mul,   NULL,      NULL,  2, "mul",   FUNC_DATA, -1, 0 },
         { f_div,   NULL,      NULL,  2, "div",   FUNC_DATA, -1, 0 },
         { f_add,   NULL,      NULL,  2, "add",   FUNC_DATA, -1, 0 },
       //{ f_sub,   NULL,      NULL,  2, "sub",   FUNC_DATA, -1, 0 },
         { f_sin,   NULL,      NULL,  1, "sin",   FUNC_DATA, -1, 0 },
         { f_a,     NULL,      NULL,  0, "a",     TERM_NORM, -1, 0 },
         { f_p,     NULL,      NULL,  0, "p",     TERM_NORM, -1, 0 },
         { f_x,     NULL,      NULL,  0, "x",     TERM_NORM, -1, 0 },
         { f_s,     NULL,      NULL,  0, "s",     TERM_NORM, -1, 0 },
       //{ NULL,    NULL,      NULL, -1, "ADF2",  EVAL_DATA,  1, 0 } },
         { NULL,    NULL,      NULL, -1, "ADF3",  EVAL_EXPR,  1, 0 } },

     /* adf3 */
       { { f_mul,   NULL,      NULL,  2, "mul",   FUNC_DATA, -1, 0 },
         { f_div,   NULL,      NULL,  2, "div",   FUNC_DATA, -1, 0 },
         { f_add,   NULL,      NULL,  2, "add",   FUNC_DATA, -1, 0 },
       //{ f_sub,   NULL,      NULL,  2, "sub",   FUNC_DATA, -1, 0 },
         { f_sin,   NULL,      NULL,  1, "sin",   FUNC_DATA, -1, 0 },
         { NULL,    NULL,      NULL,  0, "ap",    TERM_ARG,   0, 0 },
         { NULL,    NULL,      NULL,  0, "ax",    TERM_ARG,   0, 0 },
         { NULL,    NULL,      NULL,  0, "as",    TERM_ARG,   0, 0 } } };

     fset = (function_set *)MALLOC ( 2 * sizeof ( function_set ) );

     fset[0].size = 9;
     fset[0].cset = sets[0];

     fset[1].size = 7;
     fset[1].cset = sets[1];

     tree_map = (int *)MALLOC ( 2 * sizeof ( int ) );
     tree_map[0] = 0;
     tree_map[1] = 1;

     tree_name[0] = (char*)MALLOC( 10 * sizeof(char));
     strcpy(tree_name[0], "RPB");
     tree_name[1] = (char*)MALLOC( 10 * sizeof(char));
     strcpy(tree_name[1], "ADF3");

     ret = function_sets_init ( fset, 2, tree_map, tree_name, 2 );

     FREE ( fset );
     FREE ( tree_name[1] );
     FREE ( tree_name[0]);
     FREE ( tree_map );

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
     for ( i = 0; i < APP_FITNESS_CASES; ++i )
     {
          /* fill in global structure according to current fitness case. */
          g.x = app_fitness_cases[i][0];
          g.a = app_fitness_cases[i][1];
          g.p = app_fitness_cases[i][2];
          g.s = app_fitness_cases[i][3];

          /* evaluate the tree. */
          value = evaluate_tree ( ind->tr[0].data, 0 );

          /* here you would score the value returned by the individual
           * and update the raw fitness and/or hits. */

          diff = fabs ( value - app_fitness_cases[i][4] );
          if ( diff < 0.01 )
          //if ( diff <= 1 )
               ++ind->hits;
          ind->r_fitness += diff;

     }

     if ( isnan(ind->r_fitness) || !finite(ind->r_fitness) )
          ind->s_fitness = FLT_MAX;
     else
          ind->s_fitness = ind->r_fitness;

     ind->a_fitness = 1/(1+ind->s_fitness);

     if ( test_detail_level ( 90 ) )
     {
       FILE* uout = output_filehandle( OUT_USER );
       oprintf(OUT_USER, 90, "\n%s\n","Tree");
       pretty_print_individual( ind, uout );
     }

     /* always leave this line in. */
     ind->evald = EVAL_CACHE_VALID;
}

int app_end_of_evaluation ( int gen, multipop *mpop, int newbest,
                           popstats *gen_stats, popstats *run_stats )
{
  int i, j, tr;
  char fname[BUFSIZ];
  static FILE* fptr=NULL;
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
    if ((fptr=fopen(fname,"w"))==0)
    {
      fprintf(stderr,"Could not open %s to write weights\n",fname);
      exit(1);
    }

    for (i=0; i<numPops; i++) // pop
    {
      for (j=0; j<popSize; j++) // individual
      {
        fprintf(fptr, "Gen %d PopNum %d IndNum %d\n", gen, i, j);
        int tr = 0;
        for(tr = 0; tr < tree_count; tr++) // tree
        {
          fprintf(fptr, " Tree %d ", tr);
          pretty_print_tree ( pops[i]->ind[j].tr[tr].data, fptr);
        }
        fprintf(fptr, "%s", "\n");
        fflush(fptr); // gwgdelete
      }
    }
  }

  return run_stats[0].besthits == APP_FITNESS_CASES;
}

void app_end_of_breeding ( int gen, multipop *mpop )
{
     return;
}

int app_create_output_streams()
{
    if ( create_output_stream ( OUT_USER, ".fn", 1, "w", 0 ) != OUTPUT_OK )
      return 1;

    return 0;
}


int app_initialize ( int startfromcheckpoint )
{
     int i;
     // a = amplitude, p = period, x is a number between 0 and 2PI
     DATATYPE a,p,x,s,z;

     if ( !startfromcheckpoint )
     {
      oprintf ( OUT_PRG, 20, "generating fitness cases:\n" );

      for ( i = 0; i < APP_FITNESS_CASES; ++i )
      {
           x = random_double(); // returns a value between [0,1)  f frequency
           x = 2*M_PI*x; // a percentage somewhere on the circle  also angular velocity
           a = random_double();
           a = 2 * a; // random amplitude                         a amplitude
           p = random_double(); // random period
           p = 2 * p; //  if p < 1 it is 1/number
           //a = random_int(2); // 0,1,2
           s = random_double();  // random shift
           s = 2*M_PI * s; // shift right from 0 to 2 PI          s shift
           app_fitness_cases[i][0] = x;
           app_fitness_cases[i][1] = a;
           app_fitness_cases[i][2] = p;
           app_fitness_cases[i][3] = s;

           z = a * sin(p * x + s);

           app_fitness_cases[i][4] = z;
      }
     }
     else
     {
      oprintf ( OUT_PRG, 20, "fitness cases loaded from checkpoint:\n" );
     }

     oprintf ( OUT_PRG, 20, " z = a * sin(p * x + s) \n" );
     for ( i = 0; i < APP_FITNESS_CASES; ++i )
     {
       x = app_fitness_cases[i][0];
       a = app_fitness_cases[i][1];
       p = app_fitness_cases[i][2];
       s = app_fitness_cases[i][3];
       z = app_fitness_cases[i][4];
       oprintf ( OUT_PRG, 20, "%f=%f*sin(%f*%f+%f)\n", z, a, p, x , s);
     }

     return 0;

}

void app_uninitialize ( void )
{
     return;
}

void app_read_checkpoint ( FILE *f )
{
#if 0
     int i, j;
     fscanf ( f, "%*s %d\n", &i );
     if ( i != APP_FITNESS_CASES )
          error ( E_FATAL_ERROR, "wrong # of fitness cases in checkpoint file." );
     for ( i = 0; i < APP_FITNESS_CASES; ++i )
     {
      for ( j = 0; j < 7; ++j )
      {
           read_hex_block ( app_fitness_cases[i]+j, sizeof ( double ), f );
           fscanf ( f, " %*d\n" );
      }
     }
#endif
     return;
}

void app_write_checkpoint ( FILE *f )
{
#if 0
     int i, j;
     fprintf ( f, "fitness-case-count: %d\n", APP_FITNESS_CASES );
     for ( i = 0; i < APP_FITNESS_CASES; ++i )
     {
      for ( j = 0; j < 7; ++j )
      {
           write_hex_block ( app_fitness_cases[i]+j,
                sizeof ( double ), f );
           fprintf ( f, " %d\n", app_fitness_cases[i][j] );
      }
     }
#endif
     return;
}


