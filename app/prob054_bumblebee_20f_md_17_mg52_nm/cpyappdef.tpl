[+ AutoGen5 template bashh bashadf +] 
#!/bin/bash 
[+ CASE (suffix) +]
[+ ==  bashh +]
[+ FOR objlst +][+IF (exist? "kname")+][+IF(match-value? == "adf" "n")+][+FOR dirname+]
cp -vf appdef.h ./[+dirname+]/appdef.h[+ENDFOR dirname+][+ENDIF+]
[+ENDIF+][+ENDFOR objlist+]
[+ ==  bashadf +]
[+ FOR objlst +][+IF (exist? "kname")+][+IF(match-value? == "adf" "y")+][+FOR dirname+]
cp -vf appdef.adf ./[+dirname+]/appdef.h[+ENDFOR dirname+][+ENDIF+]
[+ENDIF+][+ENDFOR objlist+]
[+ ESAC +]

