; Marcaccio Riccardo 886023
; Simioni Giorgio 887522
; Gini Stefano 879276

(defun JSONParse (JSONString) 
        (StringAnalyzer (string-trim " \n" JSONString)))

;(JSONARRAY (FIELD VALUE) (FIELD VALUE) (FIELD VALUE) ...)
(defun StringAnalyzer (JSONString)
    (cond ((and  (CHAR= (char JSONString 0) #\{) 
                 (CHAR= (char JSONString (- (length JSONString) 1)) #\}))
          (append (list 'JSONOBJ) 
                (OBJAnalyzer 
                  (subseq JSONString 1 (- (length JSONString) 1)))))

          ((and  (CHAR= (char JSONString 0) #\[) 
                 (CHAR= (char JSONString (- (length JSONString) 1)) #\]))
          (append (list 'JSONARRAY) 
                (ArrayAnalyzer 
                  (subseq JSONString 1 (- (length JSONString) 1)))))

          (T (ERROR "Syntax Error in JSON String"))))

; (cons (cons FIELD VALUE) (OBJAnalyzer TAIL))
(defun OBJAnalyzer (Members)
      (let* ((A (StringSplitter (string-trim " \n" Members) #\: 0)))
            (cond ((NULL A) nil)
                  (T (cons (cons (isField (string-trim " \n" (car A)))
                        (list (isValue (string-trim " \n" (car (cdr A))))))
                        (OBJAnalyzer (cdr (cdr A))))))))


(defun ArrayAnalyzer (Elements)
      (let* ((EL (tailsplitter Elements)))
            (cond ((NULL Elements) nil)
                  ((string= Elements "") nil)
                  (T (append 
                        (list (isValue (string-trim " \n" (car EL)))) 
                        (ArrayAnalyzer (cdr EL)))))))

(defun isValue (Value)
      (cond ((NULL Value) nil)
            ((string= Value "true") 'true)
            ((string= Value "false") 'false)
            ((string= Value "null") 'null)
            ((char= (char Value 0) #\{) (StringAnalyzer Value))
            ((char= (char Value 0) #\[) (StringAnalyzer Value))
            ((char= (char Value 0) #\") (isField Value))
            (T (isNumber Value))))

(defun isNumber (Value)
      (cond ((find #\. Value) (parse-float Value))
            (T (parse-integer Value))))

(defun isField (Field)
      (cond ((and  
                  (CHAR= (char Field 0) #\") 
                  (CHAR= (char Field (- (length Field) 1)) #\")) 
                  (subseq Field 1 (- (length Field) 1)))
            (T (ERROR "Syntax Error in JSON String")))) 

(defun StringSplitter (String Char Counter) 
      (cond ((string= String "NIL") nil)
            ((string= String "") nil)
            ((= Counter (length String)) 
                  (ERROR "Syntax Error in JSON String"))
            ((CHAR= (char String Counter) Char)
                  (cons (subseq String 0 Counter) 
                        (TailSplitter 
                        (string-trim " \n" 
                          (subseq String (+ Counter 1) (length String))))))
            (T (StringSplitter String Char (+ Counter 1)))))

;ControllaValue ritorna (cons VALUE TAIL)
(defun TailSplitter (String) 
      (let*
            ((V (ValueSplitter String 0 0 0)))
            (cond ((NULL V) nil)
                  ((< V (length String)) 
                        (cons 
                              (subseq String 0 V) 
                              (subseq String (+ V 1) (length String))))
                  (T (cons (subseq String 0 V) nil)))))

;ValueSplitter ritorna la posizione della fine del campo value AKA (fine stringa / prima virgola significativa)
(defun ValueSplitter (String Pcounter Acounter Ccounter) 
      (cond ((NULL String) nil)
            ((and (= ccounter (length String)) 
                  (= Pcounter 0) 
                  (= Acounter 0)) 
                Ccounter)
            ((and (= ccounter (length String)) 
                  (\= Pcounter 0) 
                  (\= Acounter 0)) 
                (ERROR "Syntax Error in JSON String"))
            ((char= (char string Ccounter) #\{) 
                (ValueSplitter String (+ Pcounter 1) Acounter (+ Ccounter 1)))
            ((char= (char string Ccounter) #\[) 
                (ValueSplitter String (+ Pcounter 1) Acounter (+ Ccounter 1)))
            ((and (char= (char string Ccounter) #\") 
                  (= ACounter 0)) 
                (ValueSplitter String Pcounter 1 (+ Ccounter 1)))
            ((char= (char string Ccounter) #\}) 
                (ValueSplitter String (- Pcounter 1) Acounter (+ Ccounter 1)))
            ((char= (char string Ccounter) #\]) 
                (ValueSplitter String (- Pcounter 1) Acounter (+ Ccounter 1)))
            ((and (char= (char string Ccounter) #\") 
                  (= ACounter 1) 
                  (char= (char String (- Ccounter 1)) #\\))
                (ValueSplitter String Pcounter Acounter (+ Ccounter 1)))
            ((and (char= (char string Ccounter) #\") 
                  (= ACounter 1)) 
                (ValueSplitter String Pcounter 0 (+ Ccounter 1)))
            ((and (char= (char string Ccounter) #\,) 
                  (= PCounter 0) 
                  (= Acounter 0)) 
                Ccounter)
            (T (ValueSplitter String Pcounter Acounter (+ Ccounter 1)))))

(defun JSONread (FileName)
      (with-open-file (stream filename)
            (let ((contents (make-string (file-length stream))))
            (read-sequence contents stream)
            (jsonparse contents))))

(defun JSONaccess (Obj &rest Fields)
      (GetFields Obj Fields))

(defun GetFields (Obj Fields)
      (cond ((NULL (car Fields)) Obj)
            ((and 
                  (stringp (car Fields)) 
                  (eq (car Obj) 'JSONOBJ)) 
                 (FieldFinder (rest Obj) Fields))
            ((and (numberp (car Fields)) 
                  (eq (car Obj) 'JSONARRAY)) 
                 (Indexfinder (rest Obj) Fields))
            (T (ERROR "Invalid Field"))))

(defun FieldFinder (Obj Fields)
      (cond ((NULL Obj) (ERROR "Field not found"))
            ((string= (car Fields) (car (car Obj))) 
                  (GetFields (second (car Obj)) (rest Fields)))
            (T (FieldFinder (rest Obj) Fields))))

(defun IndexFinder (Obj Indexes)
      (cond ((NULL Obj) (ERROR "Index not found"))
            ((= 0 (car Indexes)) (GetFields (car Obj) (rest Indexes)))
            (T (IndexFinder 
                  (rest Obj) (append (list 
                        (- (car Indexes) 1)) (rest Indexes))))))

(defun JSONDump (Obj FileName) 
      (with-open-file (stream filename :direction :output 
                                       :if-exists :supersede
                                       :if-does-not-exist :create)
            (cond ((write-string (ParseReverse Obj) stream) filename))))

(defun ParseReverse (Obj)
      (cond ((eq (car obj) 'JSONOBJ) 
                  (concatenate 'string "{" (JSONobjParser (rest Obj)) "}"))
            ((eq (car obj) 'JSONARRAY) 
                  (concatenate 'string "[" (JSONarrayParser (rest Obj)) "]"))
            (T (ERROR "Invalid Object"))))

(defun JSONobjParser (Obj)
      (cond ((NULL Obj) "")
            ((not (NULL (rest Obj))) 
                  (concatenate 'string 
                        (jsonfieldparser (car (car Obj))) ":" 
                        (jsonvalueparser (car (cdr (car Obj)))) ", " 
                        (jsonobjparser (rest Obj))))
            (T (concatenate 'string 
                        (jsonfieldparser (car (car Obj))) ":" 
                        (jsonvalueparser (car (cdr (car Obj))))))))

(defun JSONarrayParser (Obj)
      (cond ((NULL Obj) "")
            ((not (NULL (rest Obj))) 
                  (concatenate 'string 
                        (jsonvalueparser (car Obj)) ", " 
                        (jsonarrayparser (rest Obj))))
            (T (concatenate 'string 
                  (jsonvalueparser (car Obj))))))

(defun JSONfieldParser (Field)
      (cond ((stringp Field) 
                  (concatenate 'string (string #\") Field (string #\")))
            (T (ERROR "Invalid Field"))))

(defun JSONvalueParser (Value)
      (cond ((listp Value) (ParseReverse Value))
            ((stringp Value) (jsonfieldparser Value))
            ((numberp Value)  (write-to-string Value))
            ((eq Value 'true) (string Value))
            ((eq Value 'false) (string Value))
            ((eq Value 'null) (string Value))
            (T (ERROR "Invalid Value"))))
