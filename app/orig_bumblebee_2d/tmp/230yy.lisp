(ql:quickload "read-csv" :silent t)
(ql:quickload "cl-strings" :silent t)
(use-package :read-csv)
(use-package :cl-strings)
;;read in csv file
(defvar flowerloc)
(defvar fv)
(defvar lc)
(defvar row)
(defvar rc)
(defvar fc)
(defvar xx)
(defvar yy)
(defvar fcn)
(defvar xxn)
(defvar yyn)
(defvar pt)
(defvar g)
(defvar a0)
(setf lc 0)
(setf rc 0)
(defstruct vec (x 0) (y 0)) ; define structure
;; Loading fitness cases .....
(defstruct gdat 
 (pfl (make-array '(10 10) :initial-element (make-vec :x 0.0 :y 0.0)))
 (pvis(make-array '(10) :initial-element 0))
 (nNumFlowers 10) ;int nNumFlowers;
 (lawn_width 10)  ;float lawn_width;
 (lawn_height 10) ;float lawn_height;
 (xpos 0.0)       ;float xpos;
 (ypos 0.0)       ;float ypos;
 (curfc 0)        ; current fitness case
 ;int movecount;
 ;int abort;
)
(setf g (make-gdat :nNumFlowers 10 :lawn_width 10 :xpos 0 :ypos 0)) 
(setf fv (with-open-file (s "./file.dat") (parse-csv s)))
;; load flowers locations in to fitness cases array
(loop for row in fv
  do(setf fc (nth 0 row))
  do(setf fcn (parse-number fc))
  do(setf xx (nth 1 row))
  do(setf xxn (parse-number xx))
  do(setf yy (nth 2 row))
  do(setf yyn (parse-number yy))
  ;;do(format t "~a,~a,~a~%"  fc xx yy)
  (setf pt (make-vec :x xxn :y yyn)) ;  set value of slots of var 
  do(setf (aref (gdat-pfl g) fcn rc) pt)
  do(setf rc (+ rc 1))
  do(if (> rc 9) (setf rc 0) )
  do(setf lc (+ lc 1))
)
;; functions.....
(defun vadd (a b)
 (make-vec :x (+ (vec-x a) (vec-x b)) :y (+ (vec-y a) (vec-y b)))
)
(defun vsub (a b)
 (make-vec :x (- (vec-x a) (vec-x b)) :y (- (vec-y a) (vec-y b)))
)
(defun gox (a)
 (setf (gdat-xpos g) (+ (gdat-xpos g)))
 ;;check if bee is near a flower
 (terpri)
 (loop for i from 0 below (gdat-nNumFlowers g) do
   (if(<= (abs(- (vec-x (aref (gdat-pfl g) (gdat-curfc g) i)) (vec-x a))) 0.02) 
    (if(<= (abs(- (vec-y (aref (gdat-pfl g) (gdat-curfc g) i)) (vec-y a))) 0.02)
      (setf (aref (gdat-pvis g) i) 1)
    )
   )
 )
 (make-vec :x 0.0 :y 0.0)
)
(defun goy (a)
 (setf (gdat-ypos g) (+ (gdat-ypos g) (vec-y a)))
 ;;check if bee is near a flower
 (terpri)
 (loop for i from 0 below (gdat-nNumFlowers g) do
   (if(<= (abs(- (vec-x (aref (gdat-pfl g) (gdat-curfc g) i)) (vec-x a))) 0.02) 
    (if(<= (abs(- (vec-y (aref (gdat-pfl g) (gdat-curfc g) i)) (vec-y a))) 0.02)
      (setf (aref (gdat-pvis g) i) 1)
    )
   )
 )
 (make-vec :x 0.0 :y 0.0)
)
(defun nf()
 (aref (gdat-pfl g) (gdat-curfc g) (random 10))
)
(defun bee()
 (make-vec :x (gdat-xpos g) :y (gdat-ypos g)) ;  set value of slots of var 
)
(defun ADF0 (a0)
 (vadd (vsub (prog2 (gox (goy (goy (goy a0))))
                    (prog2 (gox (vsub (goy (make-vec :x 3.585809 :y -4.052097 ))
                                      (vsub (make-vec :x 4.415748 :y 4.169348 ) (bee))))
                           (goy (vsub (vadd (make-vec :x 0.129060 :y -0.620296 ) (make-vec :x -4.420930 :y 2.757711 ))
                                      (gox a0)))))
             (prog2 (vsub (nf) (bee))
                    (gox (vadd (gox (goy (gox (vsub (prog2 a0 (bee))
                                                    (gox (nf))))))
                               (gox (vsub (bee) (bee)))))))
       (vsub (prog2 (vsub (prog2 (vadd (gox a0)
                                       (vsub (nf)
                                             (vsub (vsub (vsub (prog2 (vadd a0 a0)
                                                                      (vadd (make-vec :x 3.212253 :y 3.858220 ) (make-vec :x 4.395971 :y -4.275402 )))
                                                               (goy (vsub (nf) (bee))))
                                                         (prog2 (gox (vsub (nf) (bee)))
                                                                (vadd (vsub (nf) (bee))
                                                                      (prog2 a0 (bee)))))
                                                   (vadd (gox (prog2 (vsub a0 (bee))
                                                                     (gox (nf))))
                                                         (vadd (prog2 (vsub (bee) (bee))
                                                                      (vsub (bee) (make-vec :x -1.186131 :y 4.818565 )))
                                                               (goy (goy (nf))))))))
                                 (goy (vadd (goy (make-vec :x -1.470830 :y -2.698630 ))
                                            (vadd (nf) (bee)))))
                          (goy (goy (vadd a0 (nf)))))
                    (vsub (vsub (vsub (prog2 (nf) (make-vec :x -2.584629 :y 0.924056 ))
                                      (prog2 (nf) (make-vec :x -2.495941 :y -0.106452 )))
                                (vadd (gox (make-vec :x -3.330478 :y -3.867984 ))
                                      (vsub (bee) (make-vec :x 3.152308 :y -2.179630 ))))
                          (prog2 (goy (vsub (make-vec :x 0.442519 :y -0.294645 ) (make-vec :x -4.685926 :y -4.954974 )))
                                 (vsub (prog2 (gox (vsub (nf) (bee)))
                                              (vadd (vsub (nf) (bee))
                                                    (vsub (vsub (vsub (prog2 (vadd a0 a0)
                                                                             (vadd (make-vec :x 3.212253 :y 3.858220 ) (make-vec :x 4.395971 :y -4.275402 )))
                                                                      (goy (vsub (nf) (bee))))
                                                                (prog2 (gox (vsub (nf) (bee)))
                                                                       (vadd (vsub (nf) (bee))
                                                                             (prog2 a0 (bee)))))
                                                          (vadd (gox (prog2 (vsub a0 (bee))
                                                                            (gox (nf))))
                                                                (vadd (prog2 (vsub (bee) (bee))
                                                                             (vsub (bee) (make-vec :x -1.186131 :y 4.818565 )))
                                                                      (goy (goy (nf))))))))
                                       (vadd (bee)
                                             (vsub (prog2 (vsub (prog2 (vadd (gox a0)
                                                                             (vsub (nf) (make-vec :x 3.490988 :y -4.152361 )))
                                                                       (goy (vadd (gox (nf))
                                                                                  (vadd (nf) (bee)))))
                                                                (goy (goy (vadd a0 (nf)))))
                                                          (vsub (vsub (vsub (prog2 (nf) (make-vec :x -2.584629 :y 0.924056 ))
                                                                            (prog2 (nf) (make-vec :x -2.495941 :y -0.106452 )))
                                                                      (vadd (gox (make-vec :x -3.330478 :y -3.867984 ))
                                                                            (vsub (bee) (make-vec :x 3.152308 :y -2.179630 ))))
                                                                (prog2 (goy (vsub (make-vec :x 0.442519 :y -0.294645 ) (make-vec :x -4.685926 :y -4.954974 )))
                                                                       (vsub (goy (nf))
                                                                             (vadd (bee) a0)))))
                                                   (vsub (vsub (vsub (prog2 (vadd a0 a0)
                                                                            (vadd (make-vec :x 3.212253 :y 3.858220 ) (make-vec :x 4.395971 :y -4.275402 )))
                                                                     (goy (vsub (nf) (bee))))
                                                               (prog2 (gox (vsub (nf) (bee)))
                                                                      (vadd (vsub (nf) (bee))
                                                                            (prog2 a0 (bee)))))
                                                         (vadd (gox (prog2 (vsub a0 (bee))
                                                                           (gox (nf))))
                                                               (vadd (prog2 (vsub (bee) (bee))
                                                                            (vsub (bee) (make-vec :x -1.186131 :y 4.818565 )))
                                                                     (goy (goy (nf))))))))))))
             (vsub (vsub (vsub (prog2 (vadd a0 a0)
                                      (vadd (make-vec :x 3.212253 :y 3.858220 ) (make-vec :x 4.395971 :y -4.275402 )))
                               (goy (vsub (nf) (bee))))
                         (prog2 (gox (vsub (nf) (bee)))
                                (vadd (vsub (nf) (bee))
                                      (prog2 a0 (bee)))))
                   (vadd (gox (prog2 (vsub a0 (bee))
                                     (gox (nf))))
                         (vadd (prog2 (vsub (bee) (bee))
                                      (vsub (bee) (make-vec :x -1.186131 :y 4.818565 )))
                               (goy (goy (nf))))))))
)
(defun main ()
 (vadd (vsub (vsub (vadd (prog2 (goy (vsub (goy (adf0 (nf)))
                                           (vsub (vsub (adf0 (make-vec :x 1.503151 :y 1.841998 ))
                                                       (prog2 (adf0 (vsub (nf) (nf)))
                                                              (vadd (goy (adf0 (make-vec :x 1.503151 :y 1.841998 )))
                                                                    (adf0 (gox (nf)))))) (bee))))
                                (adf0 (make-vec :x -4.850261 :y -1.475480 )))
                         (vsub (make-vec :x 1.503151 :y 1.841998 )
                               (prog2 (bee) (make-vec :x 2.610723 :y -3.247332 ))))
                   (adf0 (vsub (gox (bee))
                               (prog2 (nf) (bee)))))
             (prog2 (goy (vsub (prog2 (make-vec :x 2.728524 :y 2.675587 ) (make-vec :x 4.170119 :y 0.264762 ))
                               (adf0 (vsub (gox (bee))
                                           (prog2 (nf) (bee))))))
                    (vadd (goy (adf0 (make-vec :x 1.503151 :y 1.841998 )))
                          (adf0 (gox (nf))))))
       (vsub (adf0 (vadd (vsub (gox (bee))
                               (goy (bee)))
                         (vadd (gox (bee))
                               (vsub (nf) (bee)))))
             (adf0 (adf0 (prog2 (vsub (nf) (make-vec :x -4.651214 :y -2.625910 ))
                                (gox (bee)))))))
)
(loop for fc from 0 below 10 do
 (setf (gdat-curfc g) fc)
 (setf (gdat-xpos g) 0.0)
 (setf (gdat-ypos g) 0.0)
 (loop for i from 0 below 10 do
  (setf (aref (gdat-pvis g) i) 0)
 )
 ;;(if(eql fc 3) (progn (print g) (quit) ))
 ;;(format t "fitness case ~d: ~s~%" fc (gdat-pvis g))
 ;;(print (gdat-pvis g))
 (main)
 (format t "fitness case ~d: ~s~%" fc (gdat-pvis g))
 ;;(print (gdat-pvis g))
)
(quit)