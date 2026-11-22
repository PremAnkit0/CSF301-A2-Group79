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

# ---- inorder-list / print-inorder (S1.a)
check "print-inorder t1"  "(print-inorder t1)"  "(1 2 3 4 5 6 7)"
check "print-inorder t2"  "(print-inorder t2)"  "(1 2 3)"
check "print-inorder t3"  "(print-inorder t3)"  "(b a c)"
check "print-inorder ()"  "(print-inorder '())" "()"
check "print-inorder single" "(print-inorder single)" "(9)"
check "inorder-list t1 is a list" "$(show '(inorder-list t1)')" "(1 2 3 4 5 6 7)"

# ---- preorder-list
check "preorder-list t1" "$(show '(preorder-list t1)')"  "(4 2 1 3 6 5 7)"
check "preorder-list t2" "$(show '(preorder-list t2)')"  "(1 2 3)"
check "preorder-list t3" "$(show '(preorder-list t3)')"  "(a b c)"
check "preorder-list ()" "$(show "(preorder-list '())")" "()"

# ---- postorder-list
check "postorder-list t1" "$(show '(postorder-list t1)')"  "(1 3 2 5 7 6 4)"
check "postorder-list t2" "$(show '(postorder-list t2)')"  "(3 2 1)"
check "postorder-list t3" "$(show '(postorder-list t3)')"  "(b c a)"
check "postorder-list ()" "$(show "(postorder-list '())")" "()"

# ---- print-all-traversals (S1.b)
check "print-all-traversals t1" "(print-all-traversals t1)" "(1 2 3 4 5 6 7)
(4 2 1 3 6 5 7)
(1 3 2 5 7 6 4)"
check "print-all-traversals t2" "(print-all-traversals t2)" "(1 2 3)
(1 2 3)
(3 2 1)"
check "print-all-traversals t3" "(print-all-traversals t3)" "(b a c)
(a b c)
(b c a)"
check "print-all-traversals ()" "(print-all-traversals '())" "()
()
()"

# ---- tree-height
check "tree-height t1"     "$(show '(tree-height t1)')"     "3"
check "tree-height t2"     "$(show '(tree-height t2)')"     "3"
check "tree-height t3"     "$(show '(tree-height t3)')"     "2"
check "tree-height ()"     "$(show "(tree-height '())")"    "0"
check "tree-height single" "$(show '(tree-height single)')" "1"

# ---- count-leaves / print-height-and-leaves (S1.c)
check "count-leaves t1"     "$(show '(count-leaves t1)')"     "4"
check "count-leaves ()"     "$(show "(count-leaves '())")"    "0"
check "count-leaves single" "$(show '(count-leaves single)')" "1"
check "print-height-and-leaves t1" "(print-height-and-leaves t1)"  "(3 4)"
check "print-height-and-leaves t2" "(print-height-and-leaves t2)"  "(3 1)"
check "print-height-and-leaves t3" "(print-height-and-leaves t3)"  "(2 2)"
check "print-height-and-leaves ()" "(print-height-and-leaves '())" "(0 0)"

echo "TOTAL: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
