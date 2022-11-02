(defun square (x) (* x x))

; ќбъ€вим класс точек на плоскости в декартовой системе координат
(defclass cart ()
  ((x :initarg :x :reader cart-x)
   (y :initarg :y :reader cart-y)))

(defmethod print-object ((c cart) stream)
  (format stream "[CART x ~d y ~d]"
          (cart-x c) (cart-y c)))

; ќбъ€вим класс точек на плоскости в пол€рной системе координат
(defclass polar ()
  ((radius :initarg :radius :accessor radius)
   (angle  :initarg :angle  :accessor angle)))

(defmethod print-object ((p polar) stream)
  (format stream "[POLAR radius ~d angle ~d]"
          (radius p) (angle p)))

; ѕеревод из декартовой системы в пол€рную
(defmethod radius ((c cart))
  (sqrt (+ (square (cart-x c))
           (square (cart-y c)))))

(defmethod angle ((c cart))
  (atan (cart-y c) (cart-x c)))

(defgeneric to-polar (arg)
 (:documentation "ѕреобразование аргумента в пол€рную систему.")
 (:method ((p polar))
  p)
 (:method ((c cart))
  (make-instance 'polar
                 :radius (radius c)
                 :angle (angle c))))

; ѕеревод из пол€рной системы в декартову
(defmethod cart-x ((p polar))
  (* (radius p) (cos (angle p))))

(defmethod cart-y ((p polar))
  (* (radius p) (sin (angle p))))

(defgeneric to-cart (arg)
  (:documentation "ѕреобразование аргумента в декартову систему.")
  (:method ((c cart))
   c)
  (:method ((p polar))
   (make-instance 'cart
                 :x (cart-x p)
                 :y (cart-y p))))

; ќбобщенна€ функци€ сложени€
(defgeneric add2 (arg1 arg2)
 (:method ((n1 number) (n2 number))
  (+ n1 n2)))

(defmethod add2 ((c1 cart) (c2 cart))
  (make-instance 'cart
                 :x (+ (cart-x c1) (cart-x c2))
                 :y (+ (cart-y c1) (cart-y c2))))

(defmethod add2 ((p1 polar) (p2 polar))
  (to-polar (add2 (to-cart p1)
                  (to-cart p2))))

(defmethod add2 ((c cart) (p polar))
  (add2 c (to-cart p)))

; ќбобщенна€ функци€ умножени€
(defgeneric mul2 (arg1 arg2)
  (:method ((n1 number) (n2 number))
   (* n1 n2)))

(defmethod mul2 ((n number) (c cart))
  (make-instance 'cart
                 :x (* n (cart-x c))
                 :y (* n (cart-y c))))

(defun normalize-angle (a)
  ;; ѕривести пол€рный угол a в диапазон (-pi, pi]
  (let* ((2pi (* 2 pi))
         (rem (rem a 2pi)))
    (cond ((< pi rem)
           (- rem 2pi))
          ((<= rem (- pi))
           (+ 2pi rem))
          (t rem))))

(defmethod mul2 ((n number) (p polar))
  (let ((a (angle p)))
    (make-instance 'polar
                   :radius (abs (* n (radius p)))
                   :angle (if (< n 0)
                              (normalize-angle (+ a pi))
                              a))))

; Ќахождение скал€рного произведени€ радиус-векторов
(defgeneric scalar-product (arg1 arg2)
  (:method ((c1 cart) (c2 cart))
    (+ (* (cart-x c1) (cart-x c2)) (* (cart-y c1) (cart-y c2)))))

; ќбобщенна€ функци€ определени€, лежат ли три точки на одной пр€мой
; (возможно с некоторым допустимым отклонением)
(defgeneric on-single-line3-p (v1 v2 v3 &optional tolerance))

(defmethod on-single-line3-p ((v1 cart) (v2 cart) (v3 cart) &optional (tolerance 0.001))
  (let ((v12 (add2 v2 (mul2 -1 v1))) ; v2 - v1
        (v13 (add2 v3 (mul2 -1 v1))) ; v3 - v1
       )
    (setq cos_v12_v13 (/ (scalar-product v12 v13) (* (radius v12) (radius v13))))
    (> (abs cos_v12_v13) (- 1 tolerance))))

(defmethod on-single-line3-p ((v1 polar) (v2 polar) (v3 polar) &optional (tolerance 0.001))
  (let ((v12 (add2 v2 (mul2 -1 v1))) ; v2 - v1
        (v13 (add2 v3 (mul2 -1 v1))) ; v3 - v1
       )
    (setq cos_v12_v13 (cos (- (angle v12) (angle v13))))
    (> (abs cos_v12_v13) (- 1 tolerance))))