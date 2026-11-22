---
name: scheme-dev
description: Rules for writing, running and testing restricted Racket 8.x (#lang racket/base) code for CS F301 Assignment 2 (S1 tree traversals, S2 nested insert). Use for any work on 79_q3.rkt, 79_q4.rkt or their tests.
---

# scheme-dev

## Language and environment
- Racket 8.x, every solution file starts with the line `#lang racket/base`.
  Check with `racket --version`.
- The file contains ONLY definitions. No top-level calls, no printing on load,
  no `provide`, no `require`, no `module+`. The grader appends its own calls to the end.

## The ONLY built-ins allowed (whitelist)
`define lambda let let* letrec` named `let`, `if cond else and or not begin quote '`
`cons car cdr list` and every car/cdr composition up to 4 levels (`cadr cddr caddr cdddr cadddr cddddr caar cdar ...`)
`null? pair? eq? assq assoc`
`+ - * < > <= >= = max`
`display newline`
`read` (S2 only)
Literals `#t`, `#f`, numbers and quoted data are fine.

Everything else is FORBIDDEN, including common ones AI tools reach for:
`length append reverse map filter foldl foldr apply member memq list-ref list-tail
set! vector hash string printf write displayln print void when unless
equal? eqv? zero? add1 sub1 number? symbol? list? null empty first rest else-less case
error raise for do min abs quotient` and every `racket/list` function.
If a helper is needed, write it yourself with an `my-` prefix (`my-reverse`, `my-length`, `my-map`).

## Coding conventions
- Names: `kebab-case`; predicates end with `?` (`leaf?`, `empty-tree?`).
- Above every function:
  ```
  ;; (name arg1 arg2) -> what it returns
  ;; Recursive reading: "for the empty case ...; otherwise ... in terms of the smaller case".
  ;; Tail recursive: yes/no.
  ```
- Pass all state through arguments (accumulators). No mutation.
- Prefer tail recursion where natural (named `let` with an accumulator).
- Build lists with `cons` and accumulators; to collect traversal values without `append`,
  thread an accumulator (e.g. inorder: `(walk left (cons value (walk right acc)))`).
- A tree node is `(value left right)`: value = `car`, left = `cadr`, right = `caddr`.
  Empty tree is `'()`, test with `null?`.
- Output: `(display x)` then `(newline)`. Every printing function ends with a newline.

## Problem-specific facts
### S1
- Height of `()` = 0; node = 1 + `max` of subtree heights. Leaf = node whose two
  subtrees are both `()`. Empty tree has 0 leaves and prints `(0 0)`.
- `(display '(1 2 3))` prints `(1 2 3)`; `(display '())` prints `()`. Symbols print bare (`a`).

### S2
- Length is measured on the ORIGINAL list, before inserting.
- `()` is a LIST, not an atom: an empty sublist becomes `(x)` when `0 < n`.
  Element tests: `(pair? e)` or `(null? e)` → it is a list, recurse; otherwise atom.
- The top-level list is treated like every other list.
- `print-insert-result` reads x, lst, n in this order, with `let*` so the order is guaranteed,
  and prints only the result plus newline (no prompts).
- Final file has ONE `insert-if-short`, defined through `make-inserter`.
- Must handle nesting depth 100 and lists of 10,000 elements (test this).

## How to run and test
- Run a file: `racket code/79_q3.rkt` (must print nothing on its own).
- Tests imitate the grader: a shell script copies the solution to a temp file, appends calls,
  runs `racket` on it and compares the output to the expected text:
  ```
  bash tests/test_q3.sh
  echo "42 ((1 2) (3 4 5) (6) ()) 3" | racket /tmp/q4_with_call.rkt
  ```
- Run the whitelist checker `bash tests/check_scheme_builtins.sh code/79_q3.rkt`
  after every change; it must report no forbidden identifiers.

## Self-review checklist (apply before saying a unit is done)
1. First line is `#lang racket/base`; file prints nothing when run alone.
2. Whitelist checker passes: every identifier is either allowed or defined in this file.
3. No `set!`, no strings, no vectors, no loops, no forbidden list functions, no `displayln`.
4. Every function has the recursive-reading comment and states if it is tail recursive.
5. Parentheses balanced; `cond` clauses use `else` for the last case.
6. All PDF examples pass, plus the empty tree / empty list / n = 0 edge cases. I ran them.
7. Output matches the spec exactly, ending with a newline.
8. Only the unit asked for in this prompt was changed.

## Known AI failure modes in Scheme/Racket (check for each)
- Using `length`, `append`, `reverse`, `map`, `filter`, `foldl`, `apply` out of habit.
- Using `displayln`, `printf`, `write` instead of `display` + `newline`.
- Using `equal?`, `zero?`, `add1`, `sub1`, `number?`, `symbol?`, `list?`, `empty?`, `first`, `rest`.
- Treating `()` as an atom in S2 (it must get x inserted when 0 < n).
- Measuring length after insertion instead of on the original list.
- Building traversals with `append` (forbidden and quadratic) instead of an accumulator.
- Reversing accumulator order by mistake (traversal comes out backwards).
- Adding `(provide ...)`, `(require ...)`, test calls, or `(module+ test ...)` to the solution file.
- Leaving example calls like `(print-inorder t1)` at the top level.
- Using `#lang racket` instead of `#lang racket/base`.
- Leaving the old S2.b `insert-if-short` in the file next to the new one (duplicate define error).
- Claiming tests pass without running them.
