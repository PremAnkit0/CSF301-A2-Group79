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
