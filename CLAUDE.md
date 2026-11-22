# CLAUDE.md

## Rules

Whenever I send a prompt about P1 or P2, first append my message word for word to prompts/P1.md or prompts/P2.md under a heading '## Prompt N', then do the task. Commit after every task with a short message naming the part done.


## Scheme part (S1 and S2), added for the Racket work

### Prompt log for S1 and S2
- Prompts that start with [S1] are appended word for word to `prompts/S1.md`.
- Prompts that start with [S2] are appended word for word to `prompts/S2.md`.
- Same format as P1/P2: `## Prompt <next number>` followed by the prompt exactly as typed.
  Log the prompt BEFORE doing the work. Do not log your replies.

### Files
- S1: `code/79_q3.rkt`, tests in `tests/test_q3.sh`
- S2: `code/79_q4.rkt`, tests in `tests/test_q4.sh`
- Built-ins checker: `tests/check_scheme_builtins.sh`
- Skill: `skills/scheme-dev/SKILL.md`, copied to `.claude/skills/scheme-dev/SKILL.md`.
  If you change one, change the other the same way.
- Do NOT edit any P1/P2 file (`code/79_q1.pl`, `code/79_q2.pl`, `tests/test_q1.pl`,
  `tests/test_q2.pl`, `prompts/P1.md`, `prompts/P2.md`, `P1_REPORT.md`, `skills/prolog-dev/`).

### Rules for every S1/S2 prompt
- Follow the scheme-dev skill. Read it before writing Racket code and apply its
  self-review checklist before saying a unit is done.
- One prompt = one unit (one function, one test file or one review). Do only what the
  prompt asks; do not write ahead.
- `.rkt` files contain only definitions, start with `#lang racket/base`, print nothing when
  run alone, and use only the built-ins allowed in the assignment.
- After each unit, when its tests pass and the built-ins checker says OK: `git add` the
  changed files plus the prompt log, and commit with a short message like
  `S1: add preorder-list with tests`. Never commit failing code. Never amend, rebase or
  force push. Do not push unless I ask.
- I am a beginner: give me exact commands to copy and explain each in one line.
