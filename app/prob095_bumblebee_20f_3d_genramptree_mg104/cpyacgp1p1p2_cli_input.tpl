[+ AutoGen5 template bashnc bashyc +] 
#!/bin/bash 
[+ CASE (suffix) +][+ 
==  bashnc +]
[+ FOR objlst +][+
IF (match-value? == "kname" "kernel.acgp1.1.2")+][+
IF (match-value? == "cons" "n")+]
cp -vf acgp1p1p2_cli_input.txtnc ./[+dirname+]/acgp1p1p2_cli_input.txt[+
ENDIF+][+
ENDIF+][+
ENDFOR objlist+][+
 ==  bashyc +][+ 
FOR objlst +][+
IF (match-value? == "kname" "kernel.acgp1.1.2")+][+
IF (match-value? == "cons" "y")+]
cp -vf acgp1p1p2_cli_input.txtyc ./[+dirname+]/acgp1p1p2_cli_input.txt[+
ENDIF+][+
ENDIF+][+
ENDFOR objlist+]
[+ ESAC +]

