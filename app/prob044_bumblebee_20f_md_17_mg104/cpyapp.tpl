[+ AutoGen5 template bashh bashc bashadf +] 
#!/bin/bash 
[+ CASE (suffix) +]
[+ ==  bashh +]
[+ FOR objlst +][+IF (exist? "kname")+]
cp -vf app.h ./[+dirname+]/app.h[+
ENDIF+][+ENDFOR objlist+]
[+ ==  bashc +]
[+ FOR objlst +][+IF (exist? "kname")+][+IF(match-value? == "adf" "n")+][+FOR dirname+]
cp -vf app.c ./[+dirname+]/app.c[+ENDFOR dirname+][+ENDIF+]
[+ENDIF+][+ENDFOR objlist+]
[+ ==  bashadf +]
[+ FOR objlst +][+IF (exist? "kname")+][+IF(match-value? == "adf" "y")+][+FOR dirname+]
cp -vf app.adf ./[+dirname+]/app.c[+ENDFOR dirname+][+ENDIF+]
[+ENDIF+][+ENDFOR objlist+]
[+ ESAC +]

