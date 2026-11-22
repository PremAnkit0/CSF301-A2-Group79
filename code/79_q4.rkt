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
