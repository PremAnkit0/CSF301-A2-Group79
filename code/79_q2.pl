% CS F301 Assignment 2, P2: Form a Valid Arithmetic Equation
% Group 79
%
% Given a list of non-negative integers, place + - * / and exactly one =
% between them (every number used once, in order, with optional
% parentheses) so that both sides have the same integer value.

:- use_module(library(lists)).

%! split_list(+List, -Left, -Right) is nondet.
%  Left and Right are both non-empty, and Left followed by Right is List.
%  On backtracking it gives every split point in order: Left with 1 element,
%  then 2, ..., up to length(List) - 1. It fails for lists with fewer than
%  two elements, since they cannot be split into two non-empty parts.
%  Both parts are always shorter than List, so recursion on either part ends.
split_list(List, Left, Right) :-
    Left = [_|_],
    Right = [_|_],
    append(Left, Right, List).

%! expr(+Numbers, -Expr, -Value) is nondet.
%  Expr is an expression tree that uses every number in Numbers exactly once
%  and in order, and Value is its integer value. A tree is either a number
%  or L+R, L-R, L*R, L/R where L and R are trees. Every division in the tree
%  is exact with a non-zero divisor. On backtracking it gives every such tree
%  exactly once.
%  Base case: a one-number list is just that number.
%  Recursive case: split Numbers into two non-empty parts (split_list/3),
%  build a tree for each part and join them with one operator. Each part is
%  shorter than Numbers, so the recursion ends. An empty list has no tree.
expr([N], N, N).
expr(Numbers, Expr, Value) :-
    split_list(Numbers, LeftNums, RightNums),
    expr(LeftNums, LeftExpr, LeftVal),
    expr(RightNums, RightExpr, RightVal),
    combine(LeftExpr, LeftVal, RightExpr, RightVal, Expr, Value).

%! combine(+LeftExpr, +LeftVal, +RightExpr, +RightVal, -Expr, -Value) is nondet.
%  Expr joins LeftExpr and RightExpr with one of + - * /, and Value is
%  LeftVal op RightVal. Division is only allowed when RightVal is non-zero
%  and divides LeftVal exactly, so Value is always an integer. Exact
%  division leaves remainder 0 for either sign, and // then gives the exact
%  quotient.
combine(L, LV, R, RV, L+R, V) :- V is LV + RV.
combine(L, LV, R, RV, L-R, V) :- V is LV - RV.
combine(L, LV, R, RV, L*R, V) :- V is LV * RV.
combine(L, LV, R, RV, L/R, V) :-
    RV =\= 0,
    LV mod RV =:= 0,
    V is LV // RV.
