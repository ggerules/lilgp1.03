[+ AutoGen5 template bash +]
#!/bin/bash[+ 
FOR objlst +][+FOR dirname+][+IF (exist? "runnable")+]
cd ./[+dirname+]
  echo $PWD
  lush checkhits.lsh
cd ..[+ 
ENDIF+][+ENDFOR dirname+][+ ENDFOR +]
