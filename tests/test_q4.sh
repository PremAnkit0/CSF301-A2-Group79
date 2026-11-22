#!/bin/bash
# Tests for code/79_q4.rkt, run as: bash tests/test_q4.sh
# Like the grader: copy the solution to a temp file, append the helpers and the
# calls of one test, run racket (optionally feeding text on standard input),
# and compare the output exactly.

cd "$(dirname "$0")/.." || exit 1
CODE=code/79_q4.rkt
TMP=$(mktemp --suffix=.rkt)
trap 'rm -f "$TMP"' EXIT
pass=0; fail=0

# Test-only helpers (not part of the solution file).
HELPERS="
(define (make-range n) (let loop ((i n) (acc '())) (if (= i 0) acc (loop (- i 1) (cons i acc)))))
"

# check NAME CALLS EXPECTED [STDIN]
check() {
  cp "$CODE" "$TMP"
  printf '%s\n%s\n' "$HELPERS" "$2" >> "$TMP"
  actual=$(printf '%s' "$4" | racket "$TMP" 2>&1; printf x)   # the x keeps trailing newlines
  if [ -z "$3" ]; then expected=x; else expected=$(printf '%s\nx' "$3"); fi
  if [ "$actual" == "$expected" ]; then
    pass=$((pass + 1)); echo "PASS $1"
  else
    fail=$((fail + 1)); echo "FAIL $1"
    echo "  expected: $(printf '%q' "${expected%x}" | cut -c1-300)"
    echo "  actual:   $(printf '%q' "${actual%x}" | cut -c1-300)"
  fi
}

# show EXPR: display EXPR followed by a newline
show() { printf '(display %s) (newline)' "$1"; }

# ---- file prints nothing by itself
check "file alone prints nothing" "" ""

# ---- my-length
check "my-length ()"            "$(show "(my-length '())")"            "0"
check "my-length (1 2 3)"       "$(show "(my-length '(1 2 3))")"       "3"
check "my-length ((1 2) () 3)"  "$(show "(my-length '((1 2) () 3))")"  "3"
check "my-length 10000 elements" "$(show "(my-length (make-range 10000))")" "10000"
check "stdin works: read then my-length" "$(show "(my-length (read))")" "4" "(a (b c) () d)"

# ---- my-reverse / my-map
check "my-reverse ()"            "$(show "(my-reverse '())")"            "()"
check "my-reverse (1 2 3)"       "$(show "(my-reverse '(1 2 3))")"       "(3 2 1)"
check "my-reverse top level only" "$(show "(my-reverse '((1 2) () 3))")" "(3 () (1 2))"
check "my-map ()"                "$(show "(my-map (lambda (x) (+ x 1)) '())")" "()"
check "my-map keeps order"       "$(show "(my-map (lambda (x) (* x 10)) '(1 2 3 4))")" "(10 20 30 40)"
check "my-map top level only"    "$(show "(my-map (lambda (x) (cons 0 x)) '((1) () (2 3)))")" "((0 1) (0) (0 2 3))"
check "my-map 10000: length"     "$(show "(my-length (my-map (lambda (x) (* x 2)) (make-range 10000)))")" "10000"
check "my-map 10000: first and last in order" "$(show "(let ((r (my-map (lambda (x) (* x 2)) (make-range 10000)))) (list (car r) (car (my-reverse r))))")" "(2 20000)"
check "my-reverse 10000: first" "$(show "(car (my-reverse (make-range 10000)))")" "10000"

echo "TOTAL: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
