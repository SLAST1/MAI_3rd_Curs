(defun matrix-tl-br (n)
  (let ((matrix (make-array (list n n)))
        (count (ceiling n 2)) ; количество проходов вверх-вниз
        (cur_num 1))

  (dotimes (i count)
    ; заполняем столбец сверху вниз
    (loop for j from 0 upto (- n 1)
      do (setf (aref matrix j (* i 2)) cur_num)
         (setf cur_num (+ cur_num 1)))

    ; заполняем следующий столбец снизу вверх
    ; только если это не последний столбец матрицы нечетного порядка
    (unless (and (= (mod n 2) 1) (= i (- count 1)))
      (loop for j from (- n 1) downto 0
        do (setf (aref matrix j (+ (* i 2) 1)) cur_num)
           (setf cur_num (+ cur_num 1)))))

  matrix))


(defun print-matrix (matrix &optional (chars 3) stream)
  (let ((*print-right-margin* (+ 6 (* (1+ chars)
                                      (array-dimension matrix 1)))))
    (pprint matrix stream)
    (values)))
