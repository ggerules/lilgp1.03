[+ AutoGen5 template bash +]
#!/bin/bash[+ 
FOR objlst +][+FOR dirname+][+IF (exist? "tmp")+]
mkdir -vp [+dirname+]/tmp[+ 
ELSE+]
mkdir -vp [+dirname+][+ 
ENDIF+][+ENDFOR dirname+][+ ENDFOR +]
