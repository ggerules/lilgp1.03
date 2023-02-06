## Enhancing Scalability in Genetic Programming With Adaptable Constraints Type Constraints and Automatically Defined Functions

### Why this code exists

Code for CGPF2.1 and ACGPF2.1. Modified original lilgp1.02 -> lilgp1.03 kernel to handle bigger problems in support of 2019 dissertation for completion of Ph.D. in mathematical and computational sciences at the University of Missouri - St. Louis (UMSL).

### Why lilgp1.02 was changed

lilgp1.02  population statistics were all saved as ints.  Integer overflows happened on large gp runs. So, population statistics were changed from int to long
 
### Software needed to run this

Operating System Ubuntu 16.04 or better.  Not tested for Mac.  Won't run on Windows.  

gcc any modern version should work       -- compiler for lilgp

GNU parallel version 20161222 or better  -- helps to push lilgp runs to as many cores as possible

bash                                     -- lots of bash scripts that get the job done

sqlite3 3.28.0                           -- holds stats for runs, fed into R

R scripting version 3.4.2 (2017-09-28)   -- stats processing

autogen (GNU AutoGen) 5.18.7             -- help in creating consistent code for different gp problems

lush (lisp) http://lush.sourceforge.net/ -- some text file wrangling 

### To build all code for running problems 

Steps:
1) cd into lilgp1.03/app
2) ./runprob.bash
3) Go get a cup of coffee.... it will take about 3 days to a week or more depending on your machine.

### To run code for a particular problem

cd into a subdirectory named starting with prefix prob  
./start.bash         -- will run everything for a particular problem


### Key Subdirectories 

app                  -- holds experiments 

app/mg52             -- holds results of data for 52 generations

app/mg104            -- holds results of data for 104 generations

app/mg156            -- holds results of data for 156 generations

app/mg208            -- holds results of data for 208 generations


### Other information 

Warning -- this will fill up your hard disks with lots of data. Well over 1TB.
