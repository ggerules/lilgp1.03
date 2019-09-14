[+ AutoGen5 template +]
(lush-is-quiet t)
(chdir "./tmp")
(defconstant fc 21)
(defvar bf (filter (lambda (f) (str-endswith f "bind")) (ls ".")))
;(print bf)
(defvar f)
(defvar p)
(defvar m)
(defvar h)
(defvar i)[+ FOR yadf+][+FOR fset+][+IF (first-for? "fset")+][+FOR adffunc +]
(defvar [+altname+]cnt)[+
 ENDFOR adffunc +][+ENDIF+][+ENDFOR fset+][+ENDFOR yadf+]
;first check fitness cases with generated programs, they should match
(do ((fp bf)) while (<> fp -1) 
  (setq f (basename fp "bind"))
  (load (str-cat f ".bind") )
;  (printf "%s %s\n" (str-cat f ".bind") (str-cat f ".dat"))
  (setq p (flatten (funcdef main)))
  (printf "%s" (str-cat f ": "))
  (setq m (load-array (str-cat f ".dat")))
  (setq h 0)
  (for (i 0 20)  
   ;( printf "ttz=%.5f, ttx=%.5f (main %.5f)=%.5f diff=%.5f\n" (m 0 i) (m 1 i) (m 1 i) (main(m 1 i))  (- (main(m 1 i)) (m 0 i) ) )
   ;(if (< (abs (- (main(m i 1)) (m i 0) )) 0.01) ( print "hit" ) ())
   ;(if (< (abs (- (main(m i 1)) (m i 0) )) 0.01) ( print h ) ())
   (if (< (abs (- (main(m i 1)) (m i 0) )) 0.01) ( incr h) ())
  )
  (if (= h fc) (printf " PASS: Hits=%l/21 " h) (printf " FAIL: Hits=%l/21 " h))
  [+ FOR yadf+][+FOR fset+][+IF (first-for? "fset")+][+FOR adffunc +]
  (setq [+altname+]cnt 0)[+ ENDFOR adffunc+][+ENDIF+][+ENDFOR fset+][+ENDFOR yadf+]
  (do ((it p)) while (<> it -1)
   ;(prin (symbol-name it))[+ FOR yadf+][+FOR fset+][+IF (first-for? "fset")+][+FOR adffunc +]
   (when (symbolp it) 
    (if (= (symbol-name it) "[+altname+]") (incr [+altname+]cnt) ())
   )[+ ENDFOR adffunc+][+ENDIF+][+ENDFOR fset+][+ENDFOR yadf+]
  )[+ FOR yadf+][+FOR fset+][+IF (first-for? "fset")+][+FOR adffunc +]
  (printf " [+altname+] Used=%l " [+altname+]cnt)[+ 
  ENDFOR adffunc+][+ENDIF+][+ENDFOR fset+][+ENDFOR yadf+]
  (print)
)

