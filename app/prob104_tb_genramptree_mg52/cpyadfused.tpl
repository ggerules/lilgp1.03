[+ AutoGen5 template bash +]
#!/bin/bash [+
FOR objlst +][+IF (exist? "kname")+][+FOR dirname+]
cp -vf adfused.lsh ./[+dirname+]/adfused.lsh[+ENDFOR+]
[+ENDIF+][+ENDFOR objlist+]

