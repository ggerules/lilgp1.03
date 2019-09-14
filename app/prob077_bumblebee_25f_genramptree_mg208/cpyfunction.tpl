[+ AutoGen5 template bash +]
#!/bin/bash [+ 
FOR objlst +][+IF (exist? "kname")+]
cp -vf function.h ./[+dirname+]/function.h
cp -vf function.c ./[+dirname+]/function.c
[+ENDIF+][+ENDFOR objlist+]
