This is a list of runtime errors that are problems with setting up lilgp.

1) Problem:  acgp1.1.2_wadf The 0,5,0 random_T error.
   Solution: Make sure that TRoot has at least one terminal set up.  If root on RPB only has Fun defined at some point program will crash on a call to random_T with 0,5,0.

2) Problem: acgp1.1.2_wadf If interface.file has all *'s for Tspecs program will crash for what=2 and what=3.  If there are some constraints on what functions in Tspecs then it will work.
   Solution: It was missing code.  The 20170922 date code has code that fixes this.

3) Problem: cgp2.1_wadf and acgp1.1.2_wadf, (see code below)
   Solution: It will crash in function_sets_init when we put in the use_ercs = 1 code. (see cgp2.1_wadf_simple_adf_qt app.c)
    problem is manifest when we don't allocate space (see below) for the names of the tree_name[0] tree_name[1] and just store a pointer to the string, then call a call is made to function_set_init.
     tree_map = (int *)MALLOC ( 2 * sizeof ( int ) );
     tree_map[0] = 0;
     tree_map[1] = 1;

     tree_name = (char**)MALLOC( 2 * sizeof(char*) );
     tree_name[0] = (char*)MALLOC ( 10 * sizeof(char) ); // problem happens if we leave out this and the next line
     tree_name[1] = (char*)MALLOC ( 10 * sizeof(char) );
     strcpy(tree_name[0], "RPB");
     strcpy(tree_name[1], "ADF2");

     ret = function_sets_init ( fset, 2, tree_map, tree_name, 2 ); // crashes here

     have R defined in interface.file and app.use_ercs = 1

4) Problem: cgp2.1* in future acgp1.1.2.  A terminal node can have only one type.  
     i.e. x1 = float. cann't have x1 = int, x1 = float.  There is no code to handle this possibility, so it will crash.
   Solution: Make sure to only have one type for a TERMinal.  

5) Problem: in acgp1.1.2_* need to have at least some T's in constraints or program will crash,
   Here is the interface file that causes the error.
         interface.file is:
           #z=a*sin(p*x+s)
           FTSPEC
           F_(*)=
           F_(*)[*]=
           F_(sin)[0]=add
           F_ROOT=sin
           T_(*)[*]=*
           T_ROOT=*
           ENDSECTION

           TYPE
           TYPELIST = amp per rad shft num
           (mul)(amp num)=num
           (mul)(per rad )=rad
           (div)(num num)=num
           (add)(rad shft)=rad
           (add)(rad rad)=rad
           (sin)(rad)=num
           (x)=rad
           (a)=amp
           (p)=per
           (s)=shft
           ROOT=num
           ENDSECTION

      Notice, there is a num type but no terminal is defined as a num.  
        We can't have overloaded types, or a type coercion operation, code doesn't exist.

      Solution: get rid of num and work only with types of terminals for resolution of functions.
           TYPE
           TYPELIST = amp per rad shft
           (mul)(amp amp)=amp
           (mul)(per rad )=rad
           (div)(rad rad )=rad
           (add)(rad shft)=rad
           (add)(rad rad)=rad
           (sin)(rad)=amp
           (x)=rad
           (a)=amp
           (p)=per
           (s)=shft
           ROOT=amp
           ENDSECTION

        the idea here is that we are type promoting the type through each eval to its ending type
        this is only done at constraint stage, only trees that conform to the grammar above are generated, 
         via random_(t)(f)(ft)_czj function
           #z=a*sin(p*x+s)
           so for type resoluton
           mul p:per x:rad -> rad1 
           add rad1:rad s:shft -> rad2
           sin rad2:rad -> amp1
           mul a:amp amp1:amp -> amp3
           root:amp         
   
6) Problem: random crash in acgp1p1p2_wadf_simple_trig_* on release build.  It worked on debug build.
   Solution: Make sure that MAXARGS is set to 3 for an ADF that is expecting 3 args.
   
7) Problem: get low hit count if interface.file is not set up correctly
TYPE
TYPELIST=zero one 
(mul)(zero zero)=zero
(mul)(one one)=one
(div)(zero zero)=zero
(div)(one one)=one
(sub)(zero one)=one  <<< here if i swap so that (sub)(zero one)=one so that (sub)(one zero )=one 
                         it will get a very low hit count
(add)(zero zero)=zero
(add)(one one)=one
(l0)=zero
(w0)=zero
(h0)=zero
(l1)=one
(w1)=one
(h1)=one
ROOT=one
ENDSECTION

8) Problem: for adfs lilgp1.02... will generate incorrect sexpressions 
   ammended README 20180215,
   see README 20180131
   if TERM_ARG params are set to all 0 then ....
   it was in how i was setting up TERM_ARG,
     all 21 fitness cases work now!!
     Make sure that if i have 2 TERM_ARGS a0 and a1 in fset
     I set a0 TERM_ARG = 0 and then a1 TERM_arg = 1
     if I don't do that it will use only a0 .... for eval...
     if I put a0 = 1 and a1 = 1 it will only work with second param

   Solution with relevant code: 
   relevant code in app.c:
     function sets[TREE_CNT][5] =
     {
       { /* main */
         { fmul, NULL, NULL, 2, "fmul", FUNC_DATA, -1, 0 },
         { fdiv, NULL, NULL, 2, "fdiv", FUNC_DATA, -1, 0 },
         { fsub, NULL, NULL, 2, "fsub", FUNC_DATA, -1, 0 },
         { ttx, NULL, NULL, 0, "x", TERM_NORM, -1, 0 },
         { NULL, NULL, NULL, -1, "adf0", EVAL_DATA, 1, 0 },
     
       },
       { /* adf0 */
         { fadd, NULL, NULL, 2, "fadd", FUNC_DATA, -1, 0 },
         { NULL, NULL, NULL, 0, "a0", TERM_ARG, 0, 0 },
         was***
         { NULL, NULL, NULL, 0, "a1", TERM_ARG, 0, 0 },
         needs to be***
         { NULL, NULL, NULL, 0, "a1", TERM_ARG, 1, 0 },
       }
     };
 

9) Problem: acgp2.1_adf segfaults randomly for constraints on what1, what2, what3
   acgp2p1_ywadf_yadf_*types_ycons_ywhat1
   acgp2p1_ywadf_yadf_*types_ycons_ywhat2
   acgp2p1_ywadf_yadf_*types_ycons_ywhat3
  
   This was found when checkhits.lsh failed to load a dat 
    file associated with a particular independent run.
    Some of the independent runs generated correctly, others just random crashed

   if interface file has F_ROOT not banned for fdiv and fadd
   the goal was to ban fdiv and fadd from being used
    ycons = { row = "F_(*)=fdiv fadd"; };
    ycons = { row = "F_(*)[*]=fdiv fadd"; };
    ycons = { row = "F_ROOT="; };
    ycons = { row = "T_(*)[*]=*"; };
    ycons = { row = "T_ROOT=*"; };

   Solution:
    ycons = { row = "F_(*)=fdiv fadd"; };
    ycons = { row = "F_(*)[*]=fdiv fadd"; };
    ycons = { row = "F_ROOT=fdiv fadd"; };
    ycons = { row = "T_(*)[*]=*"; };
    ycons = { row = "T_ROOT=*"; };

10) Problem: checkhits.lsh will get a divide by zero error if altname is div in info.def file
    Solution: rename div to fdiv
    fixed: prob_003_tb check into divide by zero error on orig_ywadf_yadf_....
     it was a problem in info.def, altname div should have been fdiv
      for lush div is a function that only works on integers
     in adfused.lsh and checkstt.lsh
     0-0-20-y-y-n-n-n-4.bind 0-0-20-y-y-n-n-n-4.dat
     ttz=57.00000, l0=10.00000, w0=2.00000, h0=6.00000, l1=3.00000, w1=3.00000, h1=7.00000, (main l0 w0 h0 l1 w1 h1)=57.00000 diff=0.00000
     ttz=-205.00000, l0=5.00000, w0=4.00000, h0=10.00000, l1=9.00000, w1=5.00000, h1=9.00000, (main l0 w0 h0 l1 w1 h1)=-205.00000 diff=0.00000
     ttz=-119.00000, l0=5.00000, w0=3.00000, h0=7.00000, l1=7.00000, w1=4.00000, h1=8.00000, (main l0 w0 h0 l1 w1 h1)=-119.00000 diff=0.00000
     ttz=937.00000, l0=10.00000, w0=10.00000, h0=10.00000, l1=3.00000, w1=3.00000, h1=7.00000, (main l0 w0 h0 l1 w1 h1)=937.00000 diff=0.00000
     *** xdivi : divide by zero
  
11) Problem : the following runtime error message appeared in prob017 lawnmower md17
   ../../../kernel.cgp2.1/memory.c:75:17: runtime error: signed integer overflow: 2147433802 + 264000 cannot be represented in type 'int'
   ../../../kernel.cgp2.1/memory.c:109:16: runtime error: signed integer overflow: 2147447064 + 199560 cannot be represented in type 'int'
   ../../../kernel.cgp2.1/memory.c:76:15: runtime error: signed integer overflow: 2147347346 + 1239320 cannot be represented in type 'int'
  ../../../kernel.cgp2.1/memory.c:108:15: runtime error: signed integer overflow: -2146380630 - 1239320 cannot be represented in type 'int'
   the problem is with even original kernel.  
   it happens in all frameworks
   it has to do with an int being used to track how much memory is being used, 
    getting integer wrap around 
    once this runtime error occurs the process is aborted
    to see how many times this occurs uncompress error_log_int_overflow_nohup.out.xz
   Solution: temporary solution would be to change int to long long for all memory tracking.
 
