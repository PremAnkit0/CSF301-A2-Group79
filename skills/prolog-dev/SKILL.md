---
name: prolog-dev
description: Conventions, run commands, self-review checklist and known AI pitfalls for writing SWI-Prolog code in CS F301 Assignment 2 (group 79). Use whenever writing, changing, reviewing or testing Prolog for P1 (code/79_q1.pl, department puzzle) or P2 (code/79_q2.pl, arithmetic equations), or their tests.
---

# prolog-dev

## Language and version

- **Target: SWI-Prolog 9.x.** The grader runs 9.x. Write only portable 9.x code. Do not rely on anything added later.
- **Tested on SWI-Prolog 11.0.0** (x64-win64, at `C:\Program Files\swipl\bin\swipl.exe`, not on PATH). The P1 and P2 code and tests were all run on 11.0.0, not 9.x. Nothing they use (`permutation/2`, `append/3`, `memberchk/2`, `findall/3`, `sort/2`, `format/2,3`, integer arithmetic, `plunit`) behaves differently between 9.x and 11.0, so we didn't downgrade. Don't add anything that only exists in versions after 9.x.
- Solution files may only use these libraries: `lists`, `apply`, `yall`, `aggregate`. Built-in predicates (`is/2`, `between/3`, `findall/3`, `format/2,3`, `number_codes/2`, `string_concat/3`, `sort/2`, `msort/2`, …) are fine.

## Files

| Problem | Solution file       | Test file            |
|---------|---------------------|----------------------|
| P1      | `code/79_q1.pl`     | `tests/test_q1.pl`   |
| P2      | `code/79_q2.pl`     | `tests/test_q2.pl`   |

Solution files contain **only definitions**: no `:- initialization`, no top-level calls, no `halt`.

## Conventions

### Naming
- Predicates and atoms: `snake_case` (`count_solutions`, `expr_value`). Variables: `CamelCase` (`Solution`, `LeftVal`).
- Use the exact names and arities in the assignment: `main/0`, `clue/2`, `count_solutions/2`, `generate_equation/2`, `all_equations/2`, `count_equations/2`. Name helpers after what they *mean*, not how they work (`split_list/3`, not `helper2/3`).
- Use `_` for variables you don't care about. Never leave singleton warnings.

### Comments
Above **every** predicate, write a block with:
1. A mode line in standard notation: `%! pred(+In, -Out) is det/semidet/nondet.`
2. A **declarative reading**, i.e. what is true when the predicate succeeds, not the steps it takes:
   ```prolog
   %! split_list(+List, -Left, -Right) is nondet.
   %  Left and Right are both non-empty and Left followed by Right is List.
   split_list(List, Left, Right) :- ...
   ```
3. For recursive predicates, a short note on the base case and the recursive case.

Other rules:
- In P1, put each `clue(N, S)` clause directly under a comment giving the English text of that clue. Clue 9 must be written exactly as `% CLUE 9: <sentence>` on the line directly above it.
- Keep all clauses of one predicate next to each other. Don't use `:- discontiguous` to hide clauses that got split up.

## How to run

Run from inside `code/` (the grader runs it this way):

```sh
SWIPL="/c/Program Files/swipl/bin/swipl.exe"
cd code
"$SWIPL" -q -f 79_q1.pl -g main -t halt
"$SWIPL" -q -f 79_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8],N), print(N), nl" -t halt
"$SWIPL" -q -f 79_q2.pl -g "all_equations([4,2,5,3],Es), print(Es), nl" -t halt
```

- If the `-g` goal fails, swipl prints a warning and exits with status 1. A goal that should fail (e.g. `generate_equation([2,3,4],E)`) is therefore tested as `\+ generate_equation([2,3,4],_)`.
- Also check that the file loads cleanly: `"$SWIPL" -q -f 79_q1.pl -g true -t halt` must print **nothing** (no warnings about singletons, discontiguous clauses or redefinitions).

## How to test

- Tests go in `tests/test_qN.pl` and use `plunit`. The library limit applies only to solution files, not test files. A test file loads its solution with `:- consult('../code/79_q1.pl').` (or similar) and is run with:
  ```sh
  "$SWIPL" -q -g run_tests -t halt tests/test_q1.pl
  ```
- Include **every example from the assignment** as a test, plus your own edge cases:
  - P1: each clue on a solution where it holds and one where it doesn't; `count_solutions` for `[]`, single clues, `1..8` and `1..9`; the exact text `main` prints (capture it with `with_output_to/2`).
  - P2: lists of length 0, 1 and 2; zeros (division by zero); inexact division; negative intermediate results; duplicate-free sorted output; the result must be a **string** (`string/1`).
- Run all tests before every commit.

## Self-review checklist (apply before every answer)

Check each item. If any fails, fix it before answering.

- [ ] No `assert`, `asserta`, `assertz`, `retract`, `retractall`, `b_setval`, `b_getval`, `nb_setval`, `nb_getval`, `recorda`, flags or other global state.
- [ ] No `:- initialization(...)` directive in any form.
- [ ] No `halt` anywhere in a solution file.
- [ ] Only `lists`, `apply`, `yall`, `aggregate` are loaded or used. Watch for predicates that *autoload* from other libraries (e.g. `string_code/3` is fine as a built-in, but `foldl/4` comes from `apply`, `sum_list/2` from `lists`, `format_atom` doesn't exist). If you're not sure where a predicate comes from, check with `predicate_property(P, imported_from(M))`.
- [ ] No output except what the spec asks for. P1: only `main/0` prints, exactly four lines. P2: prints nothing. No debug `writeln`, `print_message` or `format` left behind.
- [ ] Output format matches character for character (P1: `Alex = [research, python, AI]`, with spaces after commas and no quotes around `c++` or `AI`).
- [ ] The file loads with no warnings (singletons, discontiguous, clauses not together).
- [ ] Every predicate has a mode line and a declarative reading above it.
- [ ] Predicates that must fail actually fail: no loops, no exceptions (watch `is/2` on unbound variables, division by zero, type errors).
- [ ] Deterministic where the spec implies one answer (`main/0`, `count_solutions/2`, `all_equations/2`): no leftover choice points that give wrong answers on backtracking.
- [ ] No hard-coded answers. The P1 solution comes from the clues, and P2 equations are evaluated on terms, never by building a string and parsing it back (`term_string`, `read_term_from_atom`, `atom_to_term` are banned).
- [ ] The code was actually run (load check and tests above) and the result is reported honestly.

## Known AI failure modes in Prolog

Watch for these; they are the mistakes AI tools make most often.

1. **Negation on unbound variables.** `\+ X = research` before `X` is bound always fails. Use `\+` / `dif/2` / `\=` only after the values are bound, or generate first and then test. P1 clues are defined on a *fully filled-in* solution, so generate everything (permutations) before checking clues.
2. **`=` vs `is` vs `=:=` vs `==`.** `X = 3+4` gives the term `3+4`, not `7`. Use `is` to evaluate, `=:=` to compare numbers, `==` to compare terms.
3. **Float division.** `/` in SWI-Prolog can give a float or a rational, depending on flags. For exact integer division, check `Y =\= 0, X mod Y =:= 0`, then use `X // Y`. Be careful with negative numbers: `mod` takes the sign of the divisor and `rem` the sign of the dividend, but either one is `0` exactly when the division is exact. `//` truncates toward zero, which is correct when the division is exact.
4. **Strings vs atoms vs code lists.** In SWI-Prolog 7+, `"abc"` is a string by default. `atom_concat` returns atoms and `format(atom(A), …)` returns an atom. Use `format(string(S), …)`, `string_concat/3` or `number_string/2`, and check with `string(S)`. `sort/2` on strings sorts in standard order of terms, which is the order the spec asks for.
5. **`sort/2` removes duplicates, `msort/2` does not.** Use `sort/2` when a sorted list without duplicates is wanted.
6. **Duplicate solutions from `findall`.** Different search paths can produce the same answer. Remove duplicates (`sort/2`) where the spec says "without duplicates". For counting, make sure each solution is generated exactly once rather than depending on dedup.
7. **Printing quoted atoms.** `print/1` and `writeq/1` print `'c++'` and `'AI'` with quotes. `write/1` and `format("~w")` print `c++` and `AI`. P1 output must have no quotes.
8. **Left recursion / non-termination.** Expression generators that recurse on an unrestricted list loop forever. Always split the list into two **non-empty** parts before recursing, so every call works on a smaller list.
9. **Wrong parenthesization in printing.** Precedence and associativity rules are easy to get backwards. Right operands need brackets at *equal* precedence, left operands only at *lower* precedence. Test against every example (`8/4*2`, `8/(4*2)`, `1-(2-3)`, `1+(2+3)`).
10. **Inventing predicates or libraries.** AI often writes calls to predicates that don't exist (`string_join`, `list_to_string`, `sumlist` vs `sum_list`) or loads banned libraries (`clpfd`, `strings`, `dcg/basics`). Check each predicate exists in 9.x and comes from an allowed library.
11. **Cuts that remove real answers.** A `!` added "for efficiency" can make `findall` miss answers. Only use cuts where you can explain why no answer is lost. Prefer `once/1` at the call site.
12. **Clue misreading.** Things like "does not work in research **and** is not Dana" (both must hold) or "research **or** testing" (at least one) get translated with the wrong connective. Check every clue against its English text, one condition at a time.
13. **Claiming success without running the code.** Never say code works unless it has been run with the commands above, and quote the actual output.
