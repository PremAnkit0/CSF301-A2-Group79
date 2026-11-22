# P1 Report: Department Assignment Puzzle (Group 79)

## Result

```
?- count_solutions([1,2,3,4,5,6,7,8], N).
N = 3.
```

Run with: `swipl -q -f 79_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8],N), print(N), nl" -t halt` (from `code/`).

**N = 3.** Out of the 24 × 24 × 24 = 13,824 ways to give each friend a department, a language and a project with every value used exactly once, three satisfy all eight clues.

## What this says about the puzzle

**The puzzle as given does not have a unique solution.** A logic puzzle like this is meant to determine exactly one assignment, so N = 1 would mean the clues are complete. With N = 3, clues 1–8 are consistent (there is at least one solution) but **under-constrained**: they rule out 13,821 assignments but leave three that no clue can tell apart.

This also means the output of `main/0` (P1.a) is not "the" answer. It prints the first solution in the order the search generates them (solution 1 below). Searching in a different order could print one of the others, and that would be just as correct.

## The three solutions

| # | Alex | Ben | Carla | Dana |
|---|------|-----|-------|------|
| 1 | design, java, AI | development, javascript, web | research, c++, data | testing, python, embedded |
| 2 | design, java, embedded | development, javascript, web | testing, python, AI | research, c++, data |
| 3 | testing, python, embedded | development, javascript, web | design, java, AI | research, c++, data |

Each solution was checked by hand against all eight clues, and against a second, independently written version of the clues on all 13,824 assignments.

## What the clues fix and what they leave open

**Fixed in all three solutions:**
- Ben is development, javascript, web.
- Each department always goes with the same language: design–java, development–javascript, research–c++, testing–python.
- The research friend prefers data, and the development friend prefers web.

**Left open:** two things the clues don't decide.
1. **Which of design and testing gets the AI project** (the other one gets embedded). Solutions 1 and 3 give AI to design; solution 2 gives it to testing.
2. **Which friend gets which role.** Alex, Carla and Dana are arranged differently in each solution, within the limits clue 7 sets for Dana (research or testing).

So the puzzle is missing information.

## Repair (P1.c)

With names removed, solutions 1 and 3 are identical: they have the same four (department, language, project) combinations, given to different people. A clue that mentions no names can't tell them apart, so the only solution such a clue can keep on its own is **solution 2**. The added clue is:

```prolog
% CLUE 9: The friend who works in the testing department prefers the AI project.
clue(9, S) :-
    memberchk(p(_, testing, _, Project), S),
    Project == 'AI'.
```

It is true in solution 2 and false in solutions 1 and 3 (where the testing friend prefers embedded), so `count_solutions([1,2,3,4,5,6,7,8,9], N)` gives **N = 1**:

```
Alex = [design, java, embedded]
Ben = [development, javascript, web]
Carla = [testing, python, AI]
Dana = [research, c++, data]
```

`main/0` still uses only clues 1–8, as P1.a asks, so it still prints solution 1.
