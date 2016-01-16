;; machine.scm

(load "register.scm")
(load "stack.scm")

(define (make-new-machine)
  (let ((pc (make-register 'pc))
	(flag (make-register 'flag))
	(stack (make-stack))
	(the-instruction-sequence '()))
    
    (let ((the-ops
	   (list (list 'initialize-stack
		       (lambda () (stack 'initialize)))))
	  (register-table
	   (list (list 'pc pc) (list 'flag flag))))
      
      (define (allocate-register name)
	(if (assoc name register-table)
	    (error "allocate-register: Multiply defined register: " name)
	    (set! register-table
		  (cons (list name (make-register name))
			register-table)))
	'register-allocated)

      (define (lookup-register name)
	(let ((val (assoc name register-table)))
	  (if val
	      (cadr val)
	      (error "lookup-register: Unknown register:" name))))

      (define (execute)
	(let ((insts (get-contents pc)))
	  (if (null? insts)
	      'done
	      (begin
		((instruction-execution-proc) (car insts))
		(execute)))))

      (define (dispatch msg)
	(cond ((eq? msg 'start)
	       (set-contents! pc the-instruction-sequence)
	       (execute))
	      ((eq? msg 'install-instruction-sequence)
	       (lambda (seq) (set! the-instruction-sequence seq)))
	      ((eq? msg 'allocate-register) allocate-register)
	      ((eq? msg 'get-register) lookup-registre)
	      ((eq? msg 'install-operations)
	       (lambda (ops) (set! the-ops (append the-ops ops))))
	      ((eq? msg 'stack) stack)
	      ((eq? msg 'operations) the-ops)
	      (else
	       (error "make-new-machine: Unknown request: " msg))))
      dispatch)))


(define (get-register machine reg) ((machine 'get-register) reg))


(define (start machine) (machine 'start))


(define (get-register-contents machine register-name)
  (get-contents (get-register machine register-name)))


(define (set-register-contents! machine register-name value)
  (set-contents! (get-register machine register-name)))


(define (make-machine register-names ops controller-text)
  (let ((machine (make-new-machine)))
    (for-each (lambda (register-names)
		((machine 'allocate-register))))))
