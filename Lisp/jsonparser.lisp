(defun JSONParser (JSONString) 
        (AnalizzaStringa (string-trim " \n" JSONString))
)

;(JSONARRAY (FIELD VALUE) (FIELD VALUE) (FIELD VALUE) ...)
(defun AnalizzaStringa (JSONString)
    (cond ((and  (CHAR= (char JSONString 0) #\{) 
                 (CHAR= (char JSONString (- (length JSONString) 1)) #\}))
          (list 'JSONOBJ 
                (AnalizzaOBJ (subseq JSONString 1 (- (length JSONString) 1)))))

          ((and  (CHAR= (char JSONString 0) #\[) 
                 (CHAR= (char JSONString (- (length JSONString) 1)) #\]))
          (list 'JSONARRAY 
                (AnalizzaArray (subseq JSONString 1 (- (length JSONString) 1)))))

          (T "Syntax Error")
    )
)



; (cons (cons FIELD VALUE) (AnalizzaObj TAIL))
(defun AnalizzaOBJ (Members)
      (let* ((A (StringSplitter Members #\: 0)))
            (cons (cons (isField (first A))
                        (isValue (second A)))
                  (AnalizzaObj (third A))))
)


; (cons FIELD (cons VALUE TAIL))
(defun StringSplitter (String Char Counter)
      (cond ((CHAR= (char String Counter) Char)
                  (cons (subseq String 0 Counter) 
                        (ControllaValue (string-trim " \n" (subseq String (+ Counter 1) (length String))))
                  )
            )
            (T (StringSplitter String Char (+ Counter 1)))
      )
)

;ControllaValue ritorna (cons VALUE TAIL)

#|
(defun ControllaValue (String) (Automa String 0 (list nil) 0))
(defun Automa (tail Q S Counter)
      (cond ((and (= Q 0) (Char= (char tail Counter) #\{)) (Automa tail 1 (append S '(#\{)) (+ Counter 1)))
            ((and (= Q 0) (Char= (char tail Counter) #\[)) (Automa tail 1 (append S '(#\[)) (+ Counter 1)))
            ((and (= Q 0) (Char= (char tail Counter) #\")) (Automa tail 1 (append S '(#\")) (+ Counter 1)))
            ((= Q 0) (Automa tail 2 S (+ Counter 1)))

            ((and (= Q 2) (= Counter (length tail))) (cons (subseq tail 0 Counter) nil))
            ((and (= Q 2) (Char= (Char tail Counter) #\,)) (cons (subseq tail 0 Counter) (subseq tail (+ Counter 1) (length tail))))
            ((= Q 2) (Automa tail 2 S (+ Counter 1)))

            ((and (= Q 1) (Char= (char tail Counter) #\{)) (Automa tail 1 (append S '(#\{)) (+ Counter 1)))
            ((and (= Q 1) (Char= (char tail Counter) #\[)) (Automa tail 1 (append S '(#\[)) (+ Counter 1)))
            ((and (and (= Q 1) (Char= (char tail Counter) #\")) (= (car (last S)) #\")) (Automa tail 2 S (+ Counter 1)))
            ;      "a" : "b"sdqdqwdasdas

            ((and (and (and (= Q 1) (Char= (char tail Counter) #\})) (CHAR= (car (last S)) #\{)) (NULL (POP3 S))) (Automa tail 2 (POP3 S) (+ Counter 1)))              
            ((and (and (and (= Q 1) (Char= (char tail Counter) #\])) (CHAR= (car (last S)) #\[)) (NULL (POP3 S))) (Automa tail 2 (POP3 S) (+ Counter 1)))
            ((and (and (= Q 1) (Char= (char tail Counter) #\})) (CHAR= (car (last S)) #\{)) (Automa tail 1 S (+ Counter 1)))
            ((and (and (= Q 1) (Char= (char tail Counter) #\])) (CHAR= (car (last S)) #\])) (Automa tail 1 S (+ Counter 1)))
            ((and (and (and (= Q 1) (Char= (char tail Counter) #\})) (CHAR/= (car (last S)) #\{)) (NULL (POP3 S))) (Automa tail 2 S (+ Counter 1)))              
            ((and (and (and (= Q 1) (Char= (char tail Counter) #\])) (CHAR/= (car (last S)) #\[)) (NULL (POP3 S))) (Automa tail 2 S (+ Counter 1)))
            ((and (= Q 1) (Char= (char tail Counter) #\\)) (Automa tail 3 S (+ Counter 1)))
            ((= Q 1) (Automa tail 1 S (+ Counter 1)))

            ((and (= Q 3) (Char= (char tail Counter) #\\)) (Automa tail 3 S (+ Counter 1)))
            ((= Q 3) (Automa tail 1 S (+ Counter 1)))
      )
)

(defun pop3 (S) (reverse (cdr (reverse S))))
 |#
