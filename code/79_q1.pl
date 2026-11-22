% CS F301 Assignment 2, P1: Department Assignment Puzzle, Reloaded
% Group 79
%
% A solution is a list of four p(Name, Dept, Lang, Project) terms, in the
% order 'Alex', 'Ben', 'Carla', 'Dana'.

:- use_module(library(lists)).

%! departments(-Depts) is det.
%  Depts is the list of the four departments.
departments([research, development, design, testing]).

%! languages(-Langs) is det.
%  Langs is the list of the four favorite languages.
languages([python, java, 'c++', javascript]).

%! projects(-Projects) is det.
%  Projects is the list of the four project preferences.
projects(['AI', web, embedded, data]).

%! candidate(-Solution) is nondet.
%  Solution is a complete assignment for Alex, Ben, Carla and Dana (in that
%  order), in which the departments, the languages and the projects are each
%  a permutation of their four values, so every value is used exactly once.
%  On backtracking it gives all 24 * 24 * 24 = 13824 such assignments, each
%  exactly once. No clue is checked here.
candidate([p('Alex',  D1, L1, P1),
           p('Ben',   D2, L2, P2),
           p('Carla', D3, L3, P3),
           p('Dana',  D4, L4, P4)]) :-
    departments(Depts),
    permutation(Depts, [D1, D2, D3, D4]),
    languages(Langs),
    permutation(Langs, [L1, L2, L3, L4]),
    projects(Projects),
    permutation(Projects, [P1, P2, P3, P4]).
