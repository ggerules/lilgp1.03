[+ AutoGen5 template bash +]
#!/bin/bash [+ 
FOR objlst +][+IF (exist? "kname")+]
make -j -C $PWD/[+dirname+] clean[+
ENDIF+][+ENDFOR objlist+]
find . -name "gp" -delete
