[+ AutoGen5 template +]
(lush-is-quiet t)
(chdir "./tmp")
(defconstant fc 10)
(defvar bf (filter (lambda (f) (str-endswith f "bind")) (ls ".")))
;(print bf)
(defvar f)
(defvar p)
(defvar m)
(defvar h)
(defvar i)
(defvar adfcnt)
(defvar passcnt)

(defvar ttz)
(defvar l0)
(defvar w0)
(defvar h0)
(defvar l1)
(defvar w1)
(defvar h1)

(setq passcnt 0)
;first check fitness cases with generated programs, they should match
(do ((fp bf)) while (<> fp -1) 
  (setq f (basename fp "bind"))
  (load (str-cat f ".bind") )
;  (printf "%s %s\n" (str-cat f ".bind") (str-cat f ".dat"))
  (setq p (flatten (funcdef main)))
  (printf "%s" (str-cat f ": "))
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

  (if (= h fc) (printf "PASS: Hits=%l/21 ADFs Used=" h) (printf "FAIL: Hits=%l/21 ADFs Used=" h))
  (when (= h fc) (incr passcnt) )
  (setq adfcnt 0)
  (do ((it p)) while (<> it -1)
   (if (= (symbol-name it) "adf0") (incr adfcnt) ())
   ;(prinf it)
  )
  (print adfcnt)
)

