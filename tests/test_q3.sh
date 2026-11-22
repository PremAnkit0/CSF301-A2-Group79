#!/bin/bash
# Tests for code/79_q3.rkt, run as: bash tests/test_q3.sh
# Like the grader: copy the solution to a temp file, append the tree definitions
# and the calls of one test, run racket, and compare the output exactly.

cd "$(dirname "$0")/.." || exit 1
CODE=code/79_q3.rkt
TMP=$(mktemp --suffix=.rkt)
trap 'rm -f "$TMP"' EXIT
pass=0; fail=0

TREES="
(define t1 '(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ()))))
(define t2 '(1 () (2 () (3 () ()))))
(define t3 '(a (b () ()) (c () ())))
(define t0 '())
(define single '(9 () ()))
"

# check NAME CALLS EXPECTED
check() {
  cp "$CODE" "$TMP"
  printf '%s\n%s\n' "$TREES" "$2" >> "$TMP"
  actual=$(racket "$TMP" 2>&1; printf x)   # the x keeps trailing newlines
  if [ -z "$3" ]; then expected=x; else expected=$(printf '%s\nx' "$3"); fi
  if [ "$actual" == "$expected" ]; then
    pass=$((pass + 1)); echo "PASS $1"
  else
    fail=$((fail + 1)); echo "FAIL $1"
    echo "  expected: $(printf '%q' "${expected%x}")"
    echo "  actual:   $(printf '%q' "${actual%x}")"
  fi
}

# show EXPR: display EXPR followed by a newline
show() { printf '(display %s) (newline)' "$1"; }

# ---- file prints nothing by itself
check "file alone prints nothing" "" ""

# ---- helpers
check "node-value t1"        "$(show '(node-value t1)')"   "4"
check "node-left t1"         "$(show '(node-left t1)')"    "(2 (1 () ()) (3 () ()))"
check "node-right t1"        "$(show '(node-right t1)')"   "(6 (5 () ()) (7 () ()))"
check "node-value t3 symbol" "$(show '(node-value t3)')"   "a"
check "node-left t2 empty"   "$(show '(node-left t2)')"    "()"
check "empty-tree? ()"       "$(show '(empty-tree? t0)')"  "#t"
check "empty-tree? t1"       "$(show '(empty-tree? t1)')"  "#f"
check "leaf? single"         "$(show '(leaf? single)')"    "#t"
check "leaf? t1"             "$(show '(leaf? t1)')"        "#f"
check "leaf? ()"             "$(show '(leaf? t0)')"        "#f"
check "leaf? t2 (right child only)" "$(show '(leaf? t2)')" "#f"
check "leaf? (node-left t3)" "$(show '(leaf? (node-left t3))')" "#t"

echo "TOTAL: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
