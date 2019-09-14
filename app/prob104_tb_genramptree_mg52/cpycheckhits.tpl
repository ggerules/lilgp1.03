[+ AutoGen5 template bash +]
#!/bin/bash [+
FOR objlst +][+IF (exist? "kname")+][+FOR dirname+]
cp -vf checkhits.lsh ./[+dirname+]/checkhits.lsh[+ENDFOR+]
[+ENDIF+][+ENDFOR objlist+]

