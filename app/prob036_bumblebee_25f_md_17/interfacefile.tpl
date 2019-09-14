[+ AutoGen5 template +][+ FOR objlst +][+IF (exist? "kname")+][+
IF (or (match-value? == "kcat" "cgp2p1") (match-value? == "kcat" "acgp1p1p2")(match-value? == "kcat" "acgp2p1")) +]
#dirname=[+dirname+][+ 
IF     (and (match-value? == "wadf" "n")(match-value? == "adf" "n")(match-value? == "cons" "n")) +] [+
FOR nadf+][+
 FOR fset +]
FTSPEC 
[+ IF (match-value? == "cons" "n")+][+
     FOR ncons+][+
row+]
[+   ENDFOR ncons+][+
   ELSE+][+
     FOR ycons+][+
row+]
[+   ENDFOR ycons+][+
   ENDIF+]ENDSECTION
[+ ENDFOR fset +][+
ENDFOR nadf+][+
ELIF (and (match-value? == "wadf" "n")(match-value? == "adf" "n")(match-value? == "cons" "y")) +][+
FOR nadf +][+
 FOR fset+]
FTSPEC 
[+ IF (match-value? == "cons" "n")+][+
     FOR ncons+][+
row+]
[+   ENDFOR ncons+][+
   ELSE+][+
     FOR ycons+][+
row+]
[+   ENDFOR ycons+][+
   ENDIF+]ENDSECTION
[+ ENDFOR fset+][+
ENDFOR nadf+][+ 
ELIF (and (match-value? == "wadf" "y")(match-value? == "adf" "n")(match-value? == "cons" "n")) +] [+
FOR nadf+][+
 FOR fset +]
FTSPEC=MAIN 
[+ IF (match-value? == "cons" "n")+][+
     FOR ncons+][+
row+]
[+   ENDFOR ncons+][+
   ELSE+][+
     FOR ycons+][+
row+]
[+   ENDFOR ycons+][+
   ENDIF+]ENDSECTION
[+ ENDFOR fset +][+
ENDFOR nadf+][+
ELIF (and (match-value? == "wadf" "y")(match-value? == "adf" "y")(match-value? == "cons" "n")) +][+
FOR yadf +][+
 FOR fset+]
FTSPEC=[+treename+]
[+ IF (match-value? == "cons" "n")+][+
     FOR ncons+][+
row+]
[+   ENDFOR ncons+][+
   ELSE+][+
     FOR ycons+][+
row+]
[+   ENDFOR ycons+][+
   ENDIF+]ENDSECTION
[+ ENDFOR fset+][+
ENDFOR yadf+][+ 
ELIF (and (match-value? == "wadf" "y")(match-value? == "adf" "n")(match-value? == "cons" "y")) +][+
FOR nadf +][+
 FOR fset+]
FTSPEC=MAIN
[+ IF (match-value? == "cons" "n")+][+
     FOR ncons+][+
row+]
[+   ENDFOR ncons+][+
   ELSE+][+
     FOR ycons+][+
row+]
[+   ENDFOR ycons+][+
   ENDIF+]ENDSECTION
[+ ENDFOR fset+][+
ENDFOR nadf+][+ 
ELIF (and (match-value? == "wadf" "y")(match-value? == "adf" "y")(match-value? == "cons" "y")) +][+
FOR yadf +][+
 FOR fset+]
FTSPEC=[+treename+]
[+ IF (match-value? == "cons" "n")+][+
     FOR ncons+][+
row+]
[+   ENDFOR ncons+][+
   ELSE+][+
     FOR ycons+][+
row+]
[+   ENDFOR ycons+][+
   ENDIF+]ENDSECTION
[+ ENDFOR fset+][+
ENDFOR yadf+][+ 
ELSE +][+ENDIF+]

[+ IF     (and (match-value? == "wadf" "n")(match-value? == "adf" "n")(match-value? == "types" "n")) +] [+
FOR nadf+][+
 FOR fset +]
TYPE
TYPELIST=[+ntypes_root+][+ 
  FOR func+][+
   FOR ntypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ntypes_node+][+
  ENDFOR func+][+
  FOR vars+][+
   FOR ntypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ntypes_node+][+
  ENDFOR vars+][+
  FOR const+][+
   FOR ntypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ntypes_node+][+
  ENDFOR const+][+
  FOR ercs+][+
   FOR ntypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ntypes_node+][+
  ENDFOR ercs+]
ROOT=[+ntypes_root+]
ENDSECTION
[+ ENDFOR fset +][+
ENDFOR nadf+][+
ELIF (and (match-value? == "wadf" "n")(match-value? == "adf" "n")(match-value? == "types" "y")) +][+
FOR nadf +][+
 FOR fset+]
TYPE
TYPELIST=[+FOR ytypes_typelist+][+row+] [+ENDFOR ytypes_typelist+][+ 
  FOR func+][+
   FOR ytypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ytypes_node+][+
  ENDFOR func+][+
  FOR vars+][+
   FOR ytypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ytypes_node+][+
  ENDFOR vars+][+
  FOR const+][+
   FOR ytypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ytypes_node+][+
  ENDFOR const+][+
  FOR ercs+][+
   FOR ytypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ytypes_node+][+
  ENDFOR ercs+]
ROOT=[+ytypes_root+]
ENDSECTION
[+ ENDFOR fset+][+
ENDFOR nadf+][+ 
ELIF (and (match-value? == "wadf" "y")(match-value? == "adf" "n")(match-value? == "types" "n")) +] [+
FOR nadf+][+
 FOR fset +]
TYPE=MAIN 
TYPELIST=[+ntypes_root+][+ 
  FOR func+][+
   FOR ntypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ntypes_node+][+
  ENDFOR func+][+
  FOR vars+][+
   FOR ntypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ntypes_node+][+
  ENDFOR vars+][+
  FOR const+][+
   FOR ntypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ntypes_node+][+
  ENDFOR const+][+
  FOR ercs+][+
   FOR ntypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ntypes_node+][+
  ENDFOR ercs+]
ROOT=[+ntypes_root+]
ENDSECTION
[+ ENDFOR fset +][+
ENDFOR nadf+][+
ELIF (and (match-value? == "wadf" "y")(match-value? == "adf" "y")(match-value? == "types" "n")) +][+
FOR yadf +][+
 FOR fset+]
TYPE=[+treename+]
TYPELIST=[+ntypes_root+][+ 
  FOR func+][+
   FOR ntypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ntypes_node+][+
  ENDFOR func+][+
  FOR adffunc+][+
   FOR ntypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ntypes_node+][+
  ENDFOR adffunc+][+
  FOR vars+][+
   FOR ntypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ntypes_node+][+
  ENDFOR vars+][+
  FOR adfarg+][+
   FOR ntypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ntypes_node+][+
  ENDFOR adfarg+][+
  FOR const+][+
   FOR ntypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ntypes_node+][+
  ENDFOR const+][+
  FOR ercs+][+
   FOR ntypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ntypes_node+][+
  ENDFOR ercs+]
ROOT=[+ntypes_root+]
ENDSECTION
[+ ENDFOR fset+][+
ENDFOR yadf+][+ 
ELIF (and (match-value? == "wadf" "y")(match-value? == "adf" "n")(match-value? == "types" "y")) +][+
FOR nadf +][+
 FOR fset+]
TYPE=MAIN
TYPELIST=[+FOR ytypes_typelist+][+row+] [+ENDFOR ytypes_typelist+][+ 
  FOR func+][+
   FOR ytypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ytypes_node+][+
  ENDFOR func+][+
  FOR vars+][+
   FOR ytypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ytypes_node+][+
  ENDFOR vars+][+
  FOR const+][+
   FOR ytypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ytypes_node+][+
  ENDFOR const+][+
  FOR ercs+][+
   FOR ytypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ytypes_node+][+
  ENDFOR ercs+]
ROOT=[+ytypes_root+]
ENDSECTION
[+ ENDFOR fset+][+
ENDFOR nadf+][+ 
ELIF (and (match-value? == "wadf" "y")(match-value? == "adf" "y")(match-value? == "types" "y")) +][+
FOR yadf +][+
 FOR fset+]
TYPE=[+treename+]
TYPELIST=[+FOR ytypes_typelist+][+row+] [+ENDFOR ytypes_typelist+][+ 
  FOR func+][+
   FOR ytypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ytypes_node+][+
  ENDFOR func+][+
  FOR adffunc+][+
   FOR ytypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ytypes_node+][+
  ENDFOR adffunc+][+
  FOR vars+][+
   FOR ytypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ytypes_node+][+
  ENDFOR vars+][+
  FOR adfarg+][+
   FOR ytypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ytypes_node+][+
  ENDFOR adfarg+][+
  FOR const+][+
   FOR ytypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ytypes_node+][+
  ENDFOR const+][+
  FOR ercs+][+
   FOR ytypes_node+]
([+altname+])[+row+][+ 
   ENDFOR ytypes_node+][+
  ENDFOR ercs+]
ROOT=[+ytypes_root+]
ENDSECTION
[+ ENDFOR fset+][+
ENDFOR yadf+][+ 
ELSE +]
[+ENDIF+]

ENDFILE
-|[+ENDIF+][+ENDIF+][+ENDFOR objlist+]
