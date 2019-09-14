sbcl --no-userinit --load tmp.lisp --eval "(sb-ext:save-lisp-and-die \"main\" :toplevel 'main:main :executable t)"
