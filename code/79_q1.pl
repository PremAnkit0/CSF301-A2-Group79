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

%! clue(+N, +Solution) is semidet.
%  Clue number N holds in the fully filled-in Solution.
%  Each clause first finds the one friend the clue is about (memberchk/2,
%  since every value occurs exactly once), then checks that friend's other
%  attributes with ==/\== so nothing in Solution gets bound. It succeeds at
%  most once, so findall/3 counts every solution once.

% 1. The friend who prefers the AI project does not work in research and is
%    not Dana.
clue(1, S) :-
    memberchk(p(Name, Dept, _, 'AI'), S),
    Dept \== research,
    Name \== 'Dana'.
% 2. Alex does not work in development and does not prefer C++.
clue(2, S) :-
    memberchk(p('Alex', Dept, Lang, _), S),
    Dept \== development,
    Lang \== 'c++'.
% 3. The friend working in the testing department likes Python.
clue(3, S) :-
    memberchk(p(_, testing, Lang, _), S),
    Lang == python.
% 4. Ben prefers web projects and does not work in testing.
clue(4, S) :-
    memberchk(p('Ben', Dept, _, Project), S),
    Project == web,
    Dept \== testing.
