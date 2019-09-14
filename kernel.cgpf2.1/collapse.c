/******** czj:
*  New mutate operator - collapse -
*    Valid Parameters:
*      select - same as for crossover
*      keep_trying - same as for crossover
*      internal - same as for crossover - but just for source
*      external - same as for crossover - but just for source
*      tree - same as for crossover
*      tree# - same as for crossover
*    Based on the cgp modified crossover operator.
*    Collapse will select a parent, and a subtree within that
*      parent.  This subtree is both the destination for
*      the crossover-like mutation, and also the second parent.
*     All allowable nodes in the second parent are marked, and
*     one is selected randomly.  That subtree then replaces the
*     destination subtee.
************/

#include <lilgp.h>

typedef struct
{
  int keep_trying;
  double internal;
  double external;
  double *tree;       /* probability that a given tree
			    will be selected for collapse. */
  double treetotal;   /* total of all tree fields. */
  char *sname;
  sel_context *sc;
} collapse_data;

/* operator_collapse_init()
 *
 * called to parse collapse options and initialize one record
 * of a breedphase table appropriately.
 */

int operator_collapse_init ( char *options, breedphase *bp )
{
  int errors = 0;
  collapse_data *cd;
  int i, j, k, m;
  double r;
  char **argv, **targv;
  int internalset = 0, externalset = 0;
  char *cp;

  cd = (collapse_data *)MALLOC ( sizeof ( collapse_data ) );

  /* place values into the breedphase table record. */
  bp->operator = OPERATOR_COLLAPSE;
  bp->data = (void *)cd;
  bp->operator_free = operator_collapse_free;
  bp->operator_start = operator_collapse_start;
  bp->operator_end = operator_collapse_end;
  bp->operator_operate = operator_collapse;

  /* default values for all the collapse options. */
  cd->keep_trying = 0;
  cd->internal = 0.0;
  cd->external = 0.0;
  cd->tree = (double *)MALLOC ( tree_count * sizeof ( double ) );
  for ( j = 0; j < tree_count; ++j )
    cd->tree[j] = 0.0;
  cd->treetotal = 0.0;
  cd->sname = NULL;

  /* break the options string into an argv-style array of strings. */
  j = parse_o_rama ( options, &argv );

  for ( i = 0; i < j; ++i )
  {
    /* parse "keep_trying" option. */
    if ( strcmp ( "keep_trying", argv[i] ) == 0 )
    {
      /* translate a string into a binary value.  returns -1 if
      the string is not one of the valid strings meaning
      yes or no. */
      cd->keep_trying = translate_binary ( argv[++i] );
      if ( cd->keep_trying == -1 )
      {
        ++errors;
        error ( E_ERROR, "collapse: \"%s\" is not a valid setting for \"keep_trying\".",
                argv[i] );
      }
    }
    /* parse "internal" option. */
    else if ( strcmp ( "internal", argv[i] ) == 0 )
    {
      internalset = 1;
      cd->internal = strtod ( argv[++i], NULL );
      if ( cd->internal < 0.0 )
      {
        ++errors;
        error ( E_ERROR, "collapse: \"internal\" must be nonnegative." );
      }
    }
    /* parse "external" option. */
    else if ( strcmp ( "external", argv[i] ) == 0 )
    {
      externalset = 1;
      cd->external = strtod ( argv[++i], NULL );
      if ( cd->external < 0.0 )
      {
        ++errors;
        error ( E_ERROR, "collapse: \"external\" must be nonnegative." );
      }
    }
    /* parse "select" option. */
    else if ( strcmp ( "select", argv[i] ) == 0 )
    {
      if ( !exists_select_method ( argv[++i] ) )
      {
        ++errors;
        error (E_ERROR,"collapse: \"%s\" is not a known selection method.",
               argv[i] );
      }
      FREE ( cd->sname );
      cd->sname = (char *)MALLOC ( (strlen(argv[i])+1) * sizeof ( char ) );
      strcpy ( cd->sname, argv[i] );
    }
    /* parse "tree" option. */
    else if ( strcmp ( "tree", argv[i] ) == 0 )
    {
      k = parse_o_rama ( argv[++i], &targv );
      if ( k != tree_count )
      {
        ++errors;
        error ( E_ERROR, "collapse: wrong number of tree fields: \"%s\".",
                argv[i] );
      }
      else
      {
        for ( m = 0; m < k; ++m )
        {
          cd->tree[m] = strtod ( targv[m], &cp );
          if ( *cp )
          {
            ++errors;
            error ( E_ERROR, "collapse: \"%s\" is not a number.",
                    targv[m] );
          }
        }
      }

      free_o_rama ( k, &targv );
    }
    /* parse "tree#" option. */
    else if ( strncmp ( "tree", argv[i], 4 ) == 0 )
    {
      k = strtol ( argv[i]+4, &cp, 10 );
      if ( *cp )
      {
        ++errors;
        error ( E_ERROR, "collaps: unknown option \"%s\".",
                argv[i] );
      }
      if ( k < 0 || k >= tree_count )
      {
        ++errors;
        error ( E_ERROR, "collapse: \"%s\" is out of range.",
                argv[i] );
      }
      else
      {
        cd->tree[k] = strtod ( argv[++i], &cp );
        if ( *cp )
        {
          ++errors;
          error ( E_ERROR, "collapse: \"%s\" is not a number.",
                  argv[i] );
        }
      }
    }
    else
    {
      ++errors;
      error ( E_ERROR, "collapse: unknown option \"%s\".",
              argv[i] );
    }
  }

  free_o_rama ( j, &argv );

  if ( internalset && !externalset )
    cd->external = 0.0;
  else if ( !internalset && externalset )
    cd->internal = 0.0;

  if ( cd->sname == NULL )
  {
    ++errors;
    error ( E_ERROR, "collapse: no selection method specified." );
  }

  for ( j = 0; j < tree_count; ++j )
    cd->treetotal += cd->tree[j];
  if ( cd->treetotal == 0.0 )
  {
    for ( j = 0; j < tree_count; ++j )
      cd->tree[j] = 1.0;
    cd->treetotal = tree_count;
  }

  r = 0.0;
  for ( j = 0; j < tree_count; ++j )
    r = (cd->tree[j] += r);

#ifdef DEBUG
  if ( !errors )
  {
    printf ( "collapse options:\n" );
    printf ( "   internal: %lf  external: %lf\n", cd->internal, cd->external );
    printf ( "   keep_trying: %d\n", cd->keep_trying );
    printf ( "   primary selection: %s\n", cd->sname==NULL?"NULL":cd->sname );
    printf ( "   tree total: %lf\n", cd->treetotal );
    for ( j = 0; j < tree_count; ++j )
      printf ( "   tree %d: %lf\n", j, cd->tree[j] );
  }
#endif

  return errors;
}

/* operator_collapse_free()
 *
 * free the collapse-specific data structure.
 */

void operator_collapse_free ( void *data )
{
  collapse_data * cd;

  cd = (collapse_data *)data;

  FREE ( cd->sname );
  FREE ( cd->tree );
  FREE ( cd );
}

/* operator_collapse_start()
 *
 * called at the start of the breeding process each generation.
 * initializes the selection contexts for this phase.
 */

void operator_collapse_start ( population *oldpop, void *data )
{
  collapse_data * cd;
  select_context_func_ptr select_con;

  cd = (collapse_data *)data;

  select_con = get_select_context ( cd->sname );
  cd->sc = select_con ( SELECT_INIT, NULL, oldpop, cd->sname );
}

/* operator_collapse_end()
 *
 * called when breeding is finished each generation.  frees up selection
 * contexts for this phase.
 */

void operator_collapse_end ( void *data )
{
  collapse_data * cd;

  cd = (collapse_data *)data;
  cd->sc->context_method ( SELECT_CLEAN, cd->sc, NULL, NULL );
}

/* operator_collapse()
 *
 * performs the collapse, inserting one or both offspring into the
 * new population.
 */
/* czj: modified for dealing with constraints */

void operator_collapse ( population *oldpop, population *newpop,
                         void *data )
{
  collapse_data * cd;
  int p;
  int ps;
  int l;
  lnode *st[3];
  int sts1, sts2;
  int ns;
  double total;
  int forceany;
  int repcount;
  int repSrc_czj=0;            /* counts repeats if no feasible source found */
  int repBad_czj=0;             /* counts repeats if offspring violates size */
  int f, t, j;
  double r;
  int totalnodes;
  tree newtree, *newtree_p;
  int sourcesFound=0;
#ifdef DEBUG_COLLAPSE
  static int numCalls_czj=0;                           /* czj for debugging */
  numCalls_czj++;                                      /* czj debug */
#endif

  newtree_p = &newtree;
  /* get the collapse-specific data structure. */
  cd = (collapse_data *)data;
  total = cd->internal + cd->external;

  /* select the tree. */
  r = random_double() * cd->treetotal;
  for ( t = 0; r >= cd->tree[t]; ++t );

#ifdef DEBUG_COLLAPSE
  printf ("collapse # %d\n",numCalls_czj);       /* czj debug */
#endif

  /* choose parent */
  p = cd->sc->select_method ( cd->sc );
  ps = tree_nodes (oldpop->ind[p].tr[t].data);
  /*duplicate_individual(&hold_individual, oldpop->ind+p); */

  forceany = (total==0.0);
  copy_tree(newtree_p, oldpop->ind[p].tr+t);


#ifdef DEBUG_COLLAPSE
  printf("Parent  is:\n" );
  print_individual ( oldpop->ind+p, stdout );
  printf("Parent has %d nodes\n",ps);            /* czj debug */
#endif

  repBad_czj=0;
  while ( (ps != 1) && (repBad_czj++<RepeatsBad_czj))
    /* repeat when no feasible dest found, up to RepeatsBad_czj */
  {
    /* choose internal dest */
    l=random_int(tree_nodes_internal(oldpop->ind[p].tr[t].data));
    st[1] = get_subtree_internal(t,oldpop->ind[p].tr[t].data, l); /* true tree */
    st[0] = get_subtree_internal(t,newtree_p->data, l);           /* copy of tree */
#ifdef DEBUG_COLLAPSE
    printf("Trying dest %d\n",l);
#endif

    /* czj: note that Function_/Argument_czj are set by calls to get_subtree* */
    if (markXNodesNoRoot_czj(t, st[0] )==0)
      continue;                        /* no sources found, try another dest */
    if (forceany)                  /* here only if some sources were found */
      st[2]=getSubtreeMarked_czj(t, st[0] ,0);
    else if (total*random_double() < cd->internal)
      st[2]=getSubtreeMarked_czj(t, st[0] ,1);
    else
      st[2]=getSubtreeMarked_czj(t, st[0],2);
    sourcesFound = 1;

#ifdef DEBUG_COLLAPSE
    printf("p (dest) selected %dth node\n",l);
    printf ( "Dest subtree is: " );
    print_tree ( st[1], stdout );
    printf ( "Source subtree is: " );
    print_tree ( st[2], stdout );
#endif
    sts1 = tree_nodes(st[1]);      /* count nodes in the selected subtrees */
    sts2 = tree_nodes(st[2]);
    ns = ps - sts1 + sts2;       /* calculate the sizes of the offspring */
    totalnodes = ns;
#ifdef DEBUG_COLLAPSE
    printf("Dest subtr has size %d, source subtree has size %d\n",sts1,sts2);
    printf("Newtree  has size %d\n",ns);
#endif
    /* no validation of the offspring against the tree node and depth limits */
    /*  is necessary as this is a collapsing mutation.  The offspring is     */
    /*  always smaller than the parent.                                      */

#ifdef DEBUG_COLLAPSE
    printf ("Offspring 1 is allowable.\n" );
#endif
    duplicate_individual(newpop->ind+newpop->next,oldpop->ind+p);
    /* free the appropriate tree of the new individual */
    free_tree ( newpop->ind[newpop->next].tr+t );
    /* make a copy of the collapse tree, replacing the */
    /* selected subtree with the crossed-over subtree. */
    copy_tree_replace_many(0,oldpop->ind[p].tr[t].data,st+1,st+2,1,
                           &repcount);
    if (repcount != 1)             /* this can't happen, but check anyway. */
      error ( E_FATAL_ERROR,"botched collapse:  this can't happen" );

    /* copy the crossovered tree to the freed space */
    gensp_dup_tree (0,newpop->ind[newpop->next].tr+t);
    /* the new individual's fitness fields are of course invalid. */
    newpop->ind[newpop->next].evald = EVAL_CACHE_INVALID;
    newpop->ind[newpop->next].flags = FLAG_NONE;
    break;     /* will break from the outer since offspring has been created */
  }                                                 /* end of the outer loop */
  if (!sourcesFound)
    duplicate_individual ( (newpop->ind)+newpop->next,(oldpop->ind)+p);

  free_tree (newtree_p);
  ++newpop->next;               /* an offspring created (or parent copied) */

#ifdef DEBUG_COLLAPSE
  printf ("Offspring :\n" );
  print_individual ( newpop->ind+(newpop->next-1), stdout );
#endif
#if VERIFY_COLLAPSE_czj /* czj */
  printf("Verify for cgp\n");
  if (verify_tree_czj (t, newpop->ind[newpop->next-1].tr[t].data))
  {
    oprintf(OUT_SYS, 10, "tree 1");
    /* print_tree ( newpop->ind[newpop->next-1].tr[t].data, stdout ); */
    oprintf (OUT_SYS, 10, "INVALID TREE in collapse: \n");
    printf("INVALID TREE in collapse \n");
    exit(1);
  }
#endif
#ifdef DEBUG_COLLAPSE
  printf ( "COLLAPSE COMPLETE.\n\n\n" );
#endif
}
