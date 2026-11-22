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

%! op_prec(?Op, ?Prec) is nondet.
%  Prec is the precedence of operator Op: * and / bind tighter (2) than
%  + and - (1).
op_prec(+, 1).
op_prec(-, 1).
op_prec(*, 2).
op_prec(/, 2).

%! expr_string(+Expr, -String) is det.
%  String is the canonical text of the tree Expr: decimal numbers, no
%  spaces, and parentheses only where the rules need them. Each different
%  tree gives a different string.
%  Base case: a number is written as itself, never in parentheses.
%  Recursive case: write both operands (each in parentheses if
%  needs_parens/3 says so) with the operator between them.
expr_string(N, S) :-
    integer(N),
    number_string(N, S).
expr_string(Expr, S) :-
    compound(Expr),
    Expr =.. [Op, L, R],
    op_prec(Op, P),
    operand_string(L, P, left, LS),
    operand_string(R, P, right, RS),
    format(string(S), "~w~w~w", [LS, Op, RS]).

%! operand_string(+Expr, +ParentPrec, +Side, -String) is det.
%  String is the canonical text of Expr used as the Side (left or right)
%  operand of an operator with precedence ParentPrec. It is in parentheses
%  exactly when needs_parens/3 holds.
operand_string(Expr, ParentPrec, Side, S) :-
    expr_string(Expr, Inner),
    (   needs_parens(Expr, ParentPrec, Side)
    ->  format(string(S), "(~w)", [Inner])
    ;   S = Inner
    ).

%! needs_parens(+Expr, +ParentPrec, +Side) is semidet.
%  Expr has to be in parentheses as the Side operand of an operator with
%  precedence ParentPrec. Operators are left-associative, so:
%  - a left operand needs them only if its operator binds less tightly;
%  - a right operand needs them if its operator binds less tightly or the
%    same;
%  - a number never needs them (it has no operator, so neither rule holds).
needs_parens(Expr, ParentPrec, left) :-
    compound(Expr),
    Expr =.. [Op, _, _],
    op_prec(Op, P),
    P < ParentPrec.
needs_parens(Expr, ParentPrec, right) :-
    compound(Expr),
    Expr =.. [Op, _, _],
    op_prec(Op, P),
    P =< ParentPrec.

%! equation(+List, -Equation) is nondet.
%  Equation is the canonical string "L=R" of a valid equation over List:
%  List is split into non-empty parts LeftNums and RightNums, L is a tree
%  over LeftNums, R is a tree over RightNums, and both have the same
%  integer value. On backtracking it gives every valid equation. It fails
%  for lists with fewer than two numbers (split_list/3 fails).
equation(List, Equation) :-
    split_list(List, LeftNums, RightNums),
    expr(LeftNums, LeftExpr, Value),
    expr(RightNums, RightExpr, RightValue),
    Value =:= RightValue,
    expr_string(LeftExpr, LeftStr),
    expr_string(RightExpr, RightStr),
    format(string(Equation), "~w=~w", [LeftStr, RightStr]).

%! generate_equation(+List, ?Equation) is semidet.
%  Equation is a valid equation for List (the first one found). Fails,
%  without looping or raising an error, if List has no valid equation,
%  including when it has fewer than two numbers.
generate_equation(List, Equation) :-
    once(equation(List, Equation)).

%! all_equations(+List, -Equations) is det.
%  Equations is the list of every valid equation for List, without
%  duplicates, in standard order of terms (sort/2). It is [] if there are
%  none.
all_equations(List, Equations) :-
    findall(Equation, equation(List, Equation), Found),
    sort(Found, Equations).

%! count_equations(+List, -N) is det.
%  N is the number of valid equations for List, i.e. the length of the
%  list all_equations/2 gives.
count_equations(List, N) :-
    all_equations(List, Equations),
    length(Equations, N).
