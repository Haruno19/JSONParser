(defun JSONParser (JSONString) 
        (AnalizzaStringa (string-trim " \n" JSONString))
)

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

(defun AnalizzaOBJ (members) members)