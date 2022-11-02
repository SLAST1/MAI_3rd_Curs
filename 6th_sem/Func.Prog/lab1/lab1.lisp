(defun f-iterative (a b c cnt)
  (if (= cnt 0)
      c
      (f-iterative b c (+ a b c) (- cnt 1))
  )
)

(defun f (n)
  (if (< n 3)
      n
      (f-iterative 0 1 2 (- n 2))
  )
)
