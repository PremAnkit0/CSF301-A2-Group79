% Tests for P2 (code/79_q2.pl): Form a Valid Arithmetic Equation
% Group 79
%
% Run from the repository root:
%   swipl -q -g run_tests -t halt tests/test_q2.pl
%
% Expected results for the edge cases were worked out by hand (see the
% comment above each test), not copied from the program's output.

:- use_module(library(plunit)).
:- consult('../code/79_q2.pl').

%! independently_valid(+List, +Equation) is semidet.
%  Checks Equation without using any of the solution's predicates: reads
%  the string back with Prolog's own reader (same precedence and left
%  associativity as the canonical form), then checks that the numbers
%  appear in List's order, that every division is exact with a non-zero
%  divisor, and that both sides have the same value. Parsing is fine here
%  in the tests; it is only banned in the solution.
independently_valid(List, Equation) :-
    string(Equation),
    \+ sub_string(Equation, _, _, _, " "),
    term_string(L = R, Equation),
    leaves(L, LL), leaves(R, RL),
    LL \== [], RL \== [],
    append(LL, RL, List),
    value(L, V), value(R, V).

%! leaves(+Expr, -Numbers) is det.
%  Numbers are the numbers in Expr, left to right.
leaves(N, [N]) :- integer(N).
leaves(E, Ns) :-
    compound(E), E =.. [_, A, B],
    leaves(A, As), leaves(B, Bs), append(As, Bs, Ns).

%! value(+Expr, -V) is semidet.
%  V is the integer value of Expr. Fails if any division is not exact or
%  divides by zero.
value(N, N) :- integer(N).
value(A + B, V) :- value(A, X), value(B, Y), V is X + Y.
value(A - B, V) :- value(A, X), value(B, Y), V is X - Y.
value(A * B, V) :- value(A, X), value(B, Y), V is X * Y.
value(A / B, V) :- value(A, X), value(B, Y), Y =\= 0, 0 =:= X rem Y, V is X // Y.

%! well_formed_result(+List) is semidet.
%  all_equations(List, Es) is a sorted list of strings without duplicates,
%  every one is independently valid, count_equations/2 agrees with its
%  length, and generate_equation/2 succeeds exactly when Es is non-empty,
%  with an answer from Es.
well_formed_result(List) :-
    all_equations(List, Es),
    sort(Es, Es),
    forall(member(E, Es), independently_valid(List, E)),
    length(Es, N),
    count_equations(List, N),
    (   Es == []
    ->  \+ generate_equation(List, _)
    ;   generate_equation(List, G), memberchk(G, Es)
    ).

% --- PDF examples ------------------------------------------------------------

:- begin_tests(pdf_examples).

test(generate_4253_is_one_of_the_seven) :-
    generate_equation([4,2,5,3], E),
    memberchk(E, ["4*2-5=3", "4*2=5+3", "4-2=5-3", "4/2=5-3",
                  "4=2*(5-3)", "4=2+(5-3)", "4=2+5-3"]).

test(all_4253, [true(Es == ["4*2-5=3", "4*2=5+3", "4-2=5-3", "4/2=5-3",
                            "4=2*(5-3)", "4=2+(5-3)", "4=2+5-3"])]) :-
    all_equations([4,2,5,3], Es).

test(generate_234_fails, [fail]) :-
    generate_equation([2,3,4], _).

test(all_234_is_empty, [true(Es == [])]) :-
    all_equations([2,3,4], Es).

test(all_248, [true(Es == ["2*4=8"])]) :-
    all_equations([2,4,8], Es).

test(counts, [true(Ns == [7, 0, 1])]) :-
    findall(N, ( member(L, [[4,2,5,3], [2,3,4], [2,4,8]]),
                 count_equations(L, N) ), Ns).

:- end_tests(pdf_examples).

% --- Edge cases --------------------------------------------------------------

:- begin_tests(edge_cases).

% [] and [5]: fewer than two numbers, so no place for the "=".
test(generate_empty_fails, [fail]) :-
    generate_equation([], _).
test(all_empty, [true(Es == [])]) :-
    all_equations([], Es).
test(count_empty, [true(N == 0)]) :-
    count_equations([], N).

test(generate_single_fails, [fail]) :-
    generate_equation([5], _).
test(all_single, [true(Es == [])]) :-
    all_equations([5], Es).
test(count_single, [true(N == 0)]) :-
    count_equations([5], N).

% [0,0]: only split is 0 | 0, so "0=0".
test(all_00, [true(Es == ["0=0"])]) :-
    all_equations([0,0], Es).
test(generate_00, [true(E == "0=0")]) :-
    generate_equation([0,0], E).

% [1,0]: only split is 1 | 0, and 1 =\= 0.
test(all_10, [true(Es == [])]) :-
    all_equations([1,0], Es).
test(generate_10_fails, [fail]) :-
    generate_equation([1,0], _).

% [6,0,3]:
%   6 | 0,3 : right side is 3, -3, 0 (0*3) or 0 (0/3), never 6.
%   6,0 | 3 : left side is 6, 6 or 0 (6/0 is not allowed), never 3.
% So there is no equation, and trying 6/0 must not raise an error.
test(all_603, [true(Es == [])]) :-
    all_equations([6,0,3], Es).
test(generate_603_fails, [fail]) :-
    generate_equation([6,0,3], _).
test(count_603, [true(N == 0)]) :-
    count_equations([6,0,3], N).

:- end_tests(edge_cases).

% --- Further cases (our own) -------------------------------------------------

:- begin_tests(further_cases).

% [0,0,0]: 0 = (0+0 | 0-0 | 0*0) and (0+0 | 0-0 | 0*0) = 0. 0/0 is never
% allowed. Sorted by character codes: * (42) < + (43) < - (45) < = (61).
test(all_000, [true(Es == ["0*0=0", "0+0=0", "0-0=0",
                           "0=0*0", "0=0+0", "0=0-0"])]) :-
    all_equations([0,0,0], Es).

% [7,2,3]: 7/2 is not exact, so "7/2=3" must not appear (it would if
% division rounded down). By hand there are no equations at all.
test(inexact_division_rejected, [true(Es == [])]) :-
    all_equations([7,2,3], Es).

% Negative values on both sides: 2-4 = -2 = 1-3.
test(negative_values) :-
    all_equations([2,4,1,3], Es),
    memberchk("2-4=1-3", Es).

% Exact division of a negative value: (3-5)/2 = -1 = 1-2.
test(negative_exact_division) :-
    all_equations([3,5,2,1,2], Es),
    memberchk("(3-5)/2=1-2", Es).

% Division by a negative divisor: 6/(2-5) = -2 = 1-3.
test(negative_divisor) :-
    all_equations([6,2,5,1,3], Es),
    memberchk("6/(2-5)=1-3", Es).

% 1+(2+3) and 1+2+3 are different trees, so both appear.
test(different_trees_both_listed) :-
    all_equations([1,2,3,6], Es),
    memberchk("1+(2+3)=6", Es),
    memberchk("1+2+3=6", Es).

% Results are strings (not atoms or code lists).
test(results_are_strings) :-
    all_equations([4,2,5,3], Es),
    forall(member(E, Es), string(E)),
    generate_equation([4,2,5,3], G),
    string(G).

% generate_equation gives one answer only.
test(generate_one_answer, [true(N == 1)]) :-
    aggregate_all(count, generate_equation([4,2,5,3], _), N).

% Nothing is printed.
test(prints_nothing, [true(Out == "")]) :-
    with_output_to(string(Out),
                   ( all_equations([4,2,5,3], _),
                     count_equations([6,0,3], _),
                     ( generate_equation([2,3,4], _) -> true ; true ) )).

% Every result list is sorted, duplicate-free, independently valid, and
% consistent with count_equations and generate_equation.
test(well_formed_results) :-
    forall(member(L, [[], [5], [0,0], [1,0], [6,0,3], [0,0,0], [4,2,5,3],
                      [2,3,4], [2,4,8], [1,2,3,4,5], [5,0,3,0,2]]),
           well_formed_result(L)).

:- end_tests(further_cases).
