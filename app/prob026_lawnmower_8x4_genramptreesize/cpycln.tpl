[+ AutoGen5 template bash +]
#!/bin/bash [+
FOR objlst +][+IF (exist? "kname")+][+FOR dirname+]
cp -vf cln.sh ./[+dirname+]/cln.sh[+ENDFOR+]
[+ENDIF+][+ENDFOR objlist+]

