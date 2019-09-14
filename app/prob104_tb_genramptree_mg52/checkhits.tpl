[+ AutoGen5 template +]
(lush-is-quiet t)
(chdir "./tmp")

;define variables and constanst used
(defconstant fc 10) ;constant holding number of fitness cases
(defvar bf (filter (lambda (f) (str-endswith f "bind")) (ls "."))) ;list containing all of bind files
;(print bf)
(defvar f) ;filename for bind or dat
(defvar p) ;program in bind file
(defvar m) ;fitness case data in dat file, m is an array
(defvar h) ;hit count
(defvar i) ;loop variable
(defvar htp (htable 30 =-equality)) ;hash table key is file name, value is pass hit count
(defvar htf (htable 30 =-equality)) ;hash table key is file name, value is fail hit count

(defvar ttz)
(defvar l0)
(defvar w0)
(defvar h0)
(defvar l1)
(defvar w1)
(defvar h1)

;first check fitness cases with generated programs in bind file, 
; the goal is that they should match with fitness cases in hits file
(do ((fp bf)) while (<> fp -1) 
  (setq f (basename fp "bind"))
  (load (str-cat f ".bind") )
  ;(printf "%s %s\n" (str-cat f ".bind") (str-cat f ".dat"))
  (setq p (flatten (funcdef main)))
  ;(printf "%s" (str-cat f ": "))
  (when (not (filep (str-cat f ".dat"))) 
   (printf "File not found: %s\n" (str-cat f ".dat"))
   (exit 1)
  )
  (setq m (load-array (str-cat f ".dat")))
  (setq h 0)
  (for (r 0 9)
   (setq ttz (m r 0))
   (setq l0 (m r 1))
   (setq w0 (m r 2))
   (setq h0 (m r 3))
   (setq l1 (m r 4))
   (setq w1 (m r 5))
   (setq h1 (m r 6))
   ;(printf "ttz=%.5f, l0=%.5f, w0=%.5f, h0=%.5f, l1=%.5f, w1=%.5f, h1=%.5f, (main l0 w0 h0 l1 w1 h1)=%.5f diff=%.5f\n" 
    ;ttz 
    ;l0
    ;w0
    ;h0
    ;l1
    ;w1
    ;h1
    ;(main l0 w0 h0 l1 w1 h1)
    ;(- (main l0 w0 h0 l1 w1 h1) ttz)
   ;)
   ;( printf "ttz=%.5f, ttx=%.5f (main %.5f)=%.5f diff=%.5f\n" (m 0 i) (m 1 i) (m 1 i) (main(m 1 i))  (- (main(m 1 i)) (m 0 i) ) )
   ;(if (< (abs (- (main l0 w0 h0 l1 w1 h1) (m r 0))) 0.01) ( print "hit" ) ())
   (if (< (abs (- (main l0 w0 h0 l1 w1 h1) (m r 0))) 0.01) ( incr h) ())
   ;(for (i 0 6)
    ;(printf "%.5f " (m r i))
   ;)
   ;(print)
   ;(printf "%.5f %.5f %.5f %.5f %.5f %.5f %.5f" ttz l0 w0 h0 l1 w1 h1)
   ;(print)
  )
  ;(if (= h fc) (printf "%s: PASS: Hits=%l/10\n" f h) )
  ;(if (<> h fc) (printf "%s: FAIL: Hits=%l/10\n" f h))
  (when (=  h fc) (htp f h))
  (when (<> h fc) (htf f h))
)
;(printf "%s:\n" "BIND PASS");
;(each (((key . value) (htable-alist htp)))
;  (printf "%s %4d\n" key value) )
;(print (htable-keys htp))
;(printf "%s:\n" "BIND FAIL");
;(print (htable-keys htf))
;(print (htable-size htp))
;(print (htable-size htf))


;now work on hits.txt file
;hash table key is the hits pass row in hits.txt, value is pass hit count, which is 10 
(defvar htph (htable 30 =-equality)) 
(defvar htfh (htable 30 =-equality)) 
(defvar ln (lines "hits.txt"))
(defvar row)
(defvar htxt)
(defvar skey) ;search key
(defvar val)
(do ((it ln)) while (<> it -1) 
  (setq row (str-split it ","))
  (setq htxt (str-stripl(nth 9 row)))
  (list-insert row 9 htxt)
  (list-delete row 10)
  ;(print row)
  (setq skey (sprintf "%s-%s-%s-%s-%s-%s-%s-%s-%s" (nth 0 row) (nth 1 row) (nth 2 row) (nth 3 row) (nth 4 row) (nth 5 row) (nth 6 row) (nth 7 row) (nth 8 row)  ))
  ;(print srow)
  (setq h (str-val (nth 9 row)))
  (when (=  h fc) (htph skey h))
  (when (<> h fc) (htfh skey h))
)
;(printf "%s:\n" "HITS.TXT PASS");
;(each (((key . value) (htable-alist htph)))
;  (printf "%s %4d\n" key value) )
;(print (htable-keys htph))
;(printf "%s:\n" "HITS.TXT FAIL");
;(print (htable-keys htfh))
;(print (htable-info htph))
;(print (htable-size htph))
;(print (htable-size htfh))

;print message if there is a match
;(if (and (= (htable-size htp) (htable-size htph)) (= (htable-size htf) (htable-size htfh)))
; (print "match")
;)

(when (not(and (= (htable-size htp) (htable-size htph)) (= (htable-size htf) (htable-size htfh))))
 (print "nmatch")
 (printf "%s:\n" "CHECK HITS in hits.txt not bind")
 (defvar k)
 ;checking htp against htph
 (each (((key . value) (htable-alist htph)))
   (setq k (htp key)) 
   (if (= k ()) 
    ;(printf "%s %4d\n" key k) 
    (printf "%s\n" key) 
   )
 )
 (printf "%s:\n" "CHECK HITS in bind not hits.txt");
 (defvar k)
 ;checking htp against htph
 (each (((key . value) (htable-alist htp)))
   (setq k (htph key)) 
   (if (= k ()) 
    ;(printf "%s %4d\n" key k) 
    (printf "%s\n" key) 
   )
 )
)

(chdir "..")
