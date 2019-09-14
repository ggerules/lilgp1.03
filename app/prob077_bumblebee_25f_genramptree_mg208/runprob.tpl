[+ AutoGen5 template bash +]
#!/bin/bash[+ 
FOR objlst +][+FOR dirname+][+IF (exist? "runnable")+]
cd ./[+dirname+]
  #./run.sh &>out.txt
  ./run.sh 
cd ..[+ 
ENDIF+][+ENDFOR dirname+][+ ENDFOR +]
