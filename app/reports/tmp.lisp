; quicklisp package usage
(ql:quickload "uiop")

;(defun directory-filenames (path types)
;  (sort
;   (iter (for file in (uiop:directory-files path))
;     (let ((type (pathname-type file)))
;       (when (member type types :test 'string=)
;         (collect (pathname-name file)))))
;   #'string<))


;(print (uiop:native-namestring (uiop:directory-files ".")))
;(print (uiop:directory-files "."))
;(print (uiop:hostname))
(defvar f)
(defvar l)
(defvar s)
;(setf f (uiop:directory-files "."))

(loop for x in (uiop:directory-files ".") do 
 ;(print x)
 (setq s (uiop:native-namestring x))
 (setq l (search ".tpl" s))
 (when l 
  ;(print l)
  (print s)
 )
; if ( l )
;  do (print s)
 
)

;(setq flist (files "."))
;(do ((it1 flist)) while (<> flist -1)
; (when (str-find "bind" it1 0)
;  (print it1)
; )
;)

