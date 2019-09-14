# Version
VERSION = 0.0.1

# Compiler flags
CFLAGS = -Wall -W -O2 -s -pipe
CLMFLAGS = -Wall -W -O2 -s -pipe -lm
LFLAGS =  -O2 -s -pipe

all: lemon evallex eval evaluator 


evaluator: eval.c evallex
	cat eval_main.txt >> eval.c
	g++ -o evaluator -O2 -s -pipe  eval.c evallex.o -lm

evallex: evallex.l evallexglobal.h eval
	flex evallex.l
	test -e lex.yy.c && mv lex.yy.c evallex.c
	gcc -o evallex.o -c evallex.c 


eval: eval.y lemon
	  ./lemon eval.y


lemon: lemon.c
	  gcc -o $@ $(LFLAGS)  $<

run:
	echo "3+5" | ./evaluator

clean:	
	rm  -f  evaluator eval.c eval.h evallex.c  lemon a.out *.out *.o


