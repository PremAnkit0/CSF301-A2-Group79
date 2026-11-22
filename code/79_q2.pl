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
