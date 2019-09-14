[+ AutoGen5 template bash +]
#!/bin/bash 
for x in `ls -b Interfacefile*`;  
do
  for a in `cat $x | grep "#dirname=" | sed 's/#dirname=//g'`;
  do
    #echo $a 
    case "$a" in[+ 
     FOR objlst +][+IF (exist? "kname")+]
     [+dirname+])[+FOR dirname+]
      cp -vf $x ./[+dirname+]/interface.file[+ENDFOR dirname+]
     ;;[+ENDIF+][+ENDFOR objlist+]
    esac
  done;
done;
