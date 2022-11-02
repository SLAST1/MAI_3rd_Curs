(defun map-cons (X Y)
  (if (null (member X Y))
    (cons X Y)
    Y))

(defun map-set (f X)
  (if (null X)
    ()
    (map-cons (funcall f (first X))
              (map-set f (rest X)))))

