[+ AutoGen5 template bash +]
#!/bin/bash [+ 
FOR objlst +][+IF (exist? "kname")+]
make -j -C $PWD/[+dirname+][+
ENDIF+][+ENDFOR objlist+]
