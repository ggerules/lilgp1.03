#CC	= g++
CC	= gcc
#CFLAGS	= -g -std=c++0x 
CFLAGS	= -g -I. -mieee-fp -DUSEVFORK

INCDIR	= /home/ggerules/cs6340/lilgp1.02/kernel

PROG1	= gp
OBJ1	= bstworst.o change.o ckpoint.o crossovr.o ephem.o eval.o event.o exch.o fitness.o genspace.o gp.o individ.o main.o memory.o mutate.o output.o params.o populate.o pretty.o random.o reproduc.o select.o tournmnt.o tree.o


.SUFFIXES:.c .o

all: $(PROG1) 

$(PROG1):	$(OBJ1)
	$(CC) $(CFLAGS) -o $@ $(OBJ1) 

clean:
	/bin/rm -f *.o core $(PROG1) 

.cpp.o: 
	$(CC) $(CFLAGS) -c $(INCLDIRS) $<

