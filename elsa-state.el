(require 'trinary)

(require 'elsa-scope)

;; TODO: add some methods for looking up variables/defuns, so we don't
;; directly work with the hashtable
(defclass elsa-state nil
  ((defuns :initform nil)
   (defvars :initform (make-hash-table))
   (errors :initform nil)
   (reachable :initform (list (trinary-true)))
   (scope :initform (elsa-scope))))

(defun elsa-state-add-defun (state name type)
  (put name 'elsa-type type)
  (push `(defun ,name ,type) (oref state defuns)))

;; TODO: take defvar directly? For consistency
(cl-defmethod elsa-state-add-defvar ((this elsa-state) name type)
  (let ((defvars (oref this defvars)))
    (puthash name (elsa-defvar :name name :type type) defvars)))

(defun elsa-state-add-message (state error)
  "In STATE, record an ERROR.

STATE is `elsa-state', ERROR is `elsa-message'."
  (push error (oref state errors)))

(defun elsa-state-get-reachability (state)
  (car (oref state reachable)))

(defmacro elsa-with-reachability (state reachability &rest body)
  (declare (indent 2))
  `(progn
     (push ,reachability (oref ,state reachable))
     ,@body
     (pop (oref ,state reachable))))

(put 'elsa-state-add-message 'lisp-indent-function 1)

(provide 'elsa-state)
