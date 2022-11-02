(defun whitespace-char-p (char)
  (member char '(#\Space #\Tab #\Newline)))

(defun word-list (string)
  ;; –азбить строки на слова, разделЄнные знаками whitespace
  ;; A la (split-seq-if #'whitespace-char-p string)
  (loop with len = (length string)
        for left = 0 then (1+ right)
        for right = (or (position-if #'whitespace-char-p string
                                     :start left)
                        len)
        unless (= right left)	; исключить пустые слова
          collect (subseq string left right)
        while (< right len)))

(defun russian-upper-case-p (char)
  (position char "јЅ¬√ƒ≈®∆«»… ЋћЌќѕ–—“”‘’÷„ЎўЏџ№Ёёя"))

(defun russian-char-downcase (char)
  (let ((i (russian-upper-case-p char)))
    (if i 
        (char "абвгдеЄжзийклмнопрстуфхцчшщъыьэю€" i)
        (char-downcase char))))

(defun russian-char-equal (char1 char2)
  (char-equal (russian-char-downcase char1)
              (russian-char-downcase char2)))


(defun count-words-with-start-eq-end (sentence)
  (let ((cnt 0))
    (dolist (word (word-list sentence))
      (let ((first NIL) (last NIL))
      (setf first (char word 0))
      (setf last (char word (- (length word) 1)))
      (if (or (russian-char-equal first last) (char-equal first last))
        (setf cnt (+ cnt 1)))))
  cnt))
