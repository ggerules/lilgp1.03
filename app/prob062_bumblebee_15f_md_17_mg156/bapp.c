int app_initialize ( int startfromcheckpoint )
{
  int i = 0;
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

  return 0;
}


/* app_uninitialize()
 *
 * perform application cleanup (free memory, etc.)
 */

void app_uninitialize ( void )
{
  int i;

  FREE( g.pfl );
  FREE( g.pvis );

  return;
}


