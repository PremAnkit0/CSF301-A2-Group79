#lang racket/base
;; CS F301 Assignment 2, S2: conditionally insert into a nested list (group 79)

;; (my-length lst) -> number of top-level elements of lst
;; Reading: the length of () is 0; the length of (e . rest) is 1 + the length of rest.
;; Written as a named let that counts while walking, so the count is the accumulator.
;; Tail recursive: yes.
(define (my-length lst)
  (let count ((l lst) (n 0))
    (if (null? l)
        n
        (count (cdr l) (+ n 1)))))

;; (my-reverse lst) -> the top-level elements of lst in reverse order
;; Reading: move elements one by one from the front of l onto acc; when l is ()
;; acc holds them reversed.
;; Tail recursive: yes.
(define (my-reverse lst)
  (let rev ((l lst) (acc '()))
    (if (null? l)
        acc
        (rev (cdr l) (cons (car l) acc)))))

;; (my-map f lst) -> list of (f e) for each top-level element e of lst, same order
;; Reading: for () the result is the (reversed) results gathered so far; otherwise
;; cons (f first) onto acc and continue with the rest. acc is built backwards, so it
;; is put back in order with my-reverse at the end.
;; Tail recursive: yes (the walk and my-reverse), so 10,000 elements are fine.
(define (my-map f lst)
  (let walk ((l lst) (acc '()))
    (if (null? l)
        (my-reverse acc)
        (walk (cdr l) (cons (f (car l)) acc)))))

;; (insert-if-short x lst n) -> lst with x put at the front of every list, at every
;; level, whose ORIGINAL length is less than n.
;; Reading: first handle each top-level element: a list (pair or ()) is processed
;; recursively, an atom stays. Then, if lst itself had fewer than n elements before
;; any insertion, put x in front of the processed list.
;; Tail recursive: no; it recurses once per nesting level (my-map handles the width).
(define (insert-if-short x lst n)
  (let ((done (my-map (lambda (e)
                        (if (or (pair? e) (null? e))
                            (insert-if-short x e n)
                            e))
                      lst)))
    (if (< (my-length lst) n)
        (cons x done)
        done)))

;; (print-insert-result) -> reads x, lst and n from standard input (in that order),
;; prints (insert-if-short x lst n) and a newline, and nothing else.
;; Reading: let* forces the three reads to happen one after another, x first.
;; Tail recursive: not recursive.
(define (print-insert-result)
  (let* ((x (read))
         (lst (read))
         (n (read)))
    (display (insert-if-short x lst n))
    (newline)))

;; (make-inserter x len-ok?) -> a function of one list that puts x at the front of
;; every list, at every level, whose ORIGINAL length k satisfies (len-ok? k).
;; Reading: ins first handles each top-level element (a list, pair or (), is passed
;; to ins again; an atom stays), then puts x in front when the original length of
;; this list passes len-ok?. letrec lets ins call itself.
;; Tail recursive: no; it recurses once per nesting level (my-map handles the width).
(define (make-inserter x len-ok?)
  (letrec ((ins (lambda (lst)
                  (let ((done (my-map (lambda (e)
                                        (if (or (pair? e) (null? e))
                                            (ins e)
                                            e))
                                      lst)))
                    (if (len-ok? (my-length lst))
                        (cons x done)
                        done)))))
    ins))
