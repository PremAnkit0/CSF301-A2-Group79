#!/bin/bash
# check_scheme_builtins.sh FILE.rkt
# Reports every identifier in FILE.rkt that is neither an allowed built-in
# (assignment whitelist) nor a name bound in the file itself
# (define, function parameters, lambda/let/let*/letrec/named-let variables).
# `read` is allowed only for the S2 file (name containing q4).
# Also rejects string and vector literals. Prints OK, or the bad names and exits 1.

if [ $# -ne 1 ] || [ ! -f "$1" ]; then
  echo "usage: $0 FILE.rkt" >&2
  exit 2
fi

racket -e '
(define file (vector-ref (current-command-line-arguments) 0))

(define allowed
  (append
   (list (quote define) (quote lambda) (quote let) (quote let*) (quote letrec)
         (quote if) (quote cond) (quote else) (quote and) (quote or) (quote not)
         (quote begin) (quote quote) (quote cons) (quote car) (quote cdr) (quote list)
         (quote null?) (quote pair?) (quote eq?) (quote assq) (quote assoc)
         (quote +) (quote -) (quote *) (quote <) (quote >) (quote <=) (quote >=) (quote =)
         (quote max) (quote display) (quote newline))
   (if (regexp-match? #rx"q4" file) (list (quote read)) (list))))

;; every c[ad]{1,4}r except car/cdr themselves (already listed)
(define (cxr? s)
  (regexp-match? #px"^c[ad]{1,4}r$" (symbol->string s)))

;; read all forms, skipping the #lang line
(define forms
  (with-input-from-file file
    (lambda ()
      (define first-line (read-line))
      (unless (regexp-match? #rx"^#lang racket/base" (or first-line ""))
        (printf "first line is not #lang racket/base\n"))
      (let loop ([acc (list)])
        (define d (read))
        (if (eof-object? d) (reverse acc) (loop (cons d acc)))))))

(define bound (make-hash))
(define used (make-hash))
(define bad-literals (make-hash))

(define (bind-params! p)            ; (a b . c) or a single rest symbol
  (cond [(symbol? p) (hash-set! bound p #t)]
        [(pair? p) (bind-params! (car p)) (bind-params! (cdr p))]
        [else (void)]))

(define (bind-let-names! bs)        ; ((x e) (y e) ...)
  (for ([b (if (list? bs) bs (list))])
    (when (and (pair? b) (symbol? (car b))) (hash-set! bound (car b) #t))))

(define (walk d)
  (cond
    [(symbol? d) (hash-set! used d #t)]
    [(string? d) (hash-set! bad-literals "string literal" #t)]
    [(vector? d) (hash-set! bad-literals "vector literal" #t)]
    [(pair? d)
     (define h (car d))
     (cond
       [(eq? h (quote quote)) (hash-set! used (quote quote) #t)]   ; quoted data is not code
       [else
        (case h
          [(define)
           (when (pair? (cdr d))
             ;; (define x ...) binds x; (define (f a b) ...) binds f a b
             (bind-params! (cadr d)))]
          [(lambda) (when (pair? (cdr d)) (bind-params! (cadr d)))]
          [(let)
           (when (pair? (cdr d))
             (if (symbol? (cadr d))
                 (begin (hash-set! bound (cadr d) #t)
                        (when (pair? (cddr d)) (bind-let-names! (caddr d))))
                 (bind-let-names! (cadr d))))]
          [(let* letrec) (when (pair? (cdr d)) (bind-let-names! (cadr d)))]
          [else (void)])
        (let loop ([x d])
          (cond [(pair? x) (walk (car x)) (loop (cdr x))]
                [(null? x) (void)]
                [else (walk x)]))])]
    [else (void)]))

(for-each walk forms)

(define bad
  (sort (for/list ([s (in-hash-keys used)]
                   #:unless (or (memq s allowed) (cxr? s) (hash-ref bound s #f)))
          (symbol->string s))
        string<?))
(define lits (sort (hash-keys bad-literals) string<?))

(if (and (null? bad) (null? lits))
    (begin (printf "OK\n") (exit 0))
    (begin
      (for ([b bad]) (printf "NOT ALLOWED: ~a\n" b))
      (for ([l lits]) (printf "NOT ALLOWED: ~a\n" l))
      (exit 1)))
' "$1"
