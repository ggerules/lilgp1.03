## Linux users should uncomment this when using gcc
# CFLAGS += -mieee-fp

## if you have the vfork() system call available (most Un*x systems),
## use it to spawn the checkpoint file compression process.
CFLAGS += -DUSEVFORK
## if you don't have vfork(), use the (much) less efficient system()
## system call.
# CFLAGS += -DUSESYSTEM
## if both of these are commented out, checkpoint compression will not
## be available.

###
### end of configuration section
###

kobjects = main.o gp.o eval.o tree.o change.o crossovr.o reproduc.o \
	mutate.o uniform_mutate.o regrow.o select.o tournmnt.o bstworst.o \
	fitness.o genspace.o exch.o populate.o ephem.o ckpoint.o event.o pretty.o \
	individ.o params.o random.o memory.o output.o cgp_czj.o

kheaders = event.h defines.h types.h protos.h protoapp.h cgp_czj.h

.PHONY : all clean

LIBS += -lm -lubsan 
CFLAGS += -I. -I$(KERNELDIR) 

all : $(TARGET)

lilgp.h = $(addprefix $(KERNELDIR)/,$(kheaders)) $(uheaders)

$(kobjects) : %.o : $(KERNELDIR)/%.c
	$(CC) -c $(CFLAGS) $< -o $@ -pg

$(uobjects) : %.o : %.c
	$(CC) -c $(CFLAGS) $< -o $@ -pg

$(kobjects) $(uobjects) : $(lilgp.h)

$(TARGET) : $(kobjects) $(uobjects)
	$(CC) $(LFLAGS) -o $@ $^ $(LIBS) -pg

clean :
	\rm -f $(kobjects) $(uobjects) core
