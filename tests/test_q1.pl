% Tests for P1 (code/79_q1.pl): Department Assignment Puzzle, Reloaded
% Group 79
%
% Run from the repository root:
%   swipl -q -g run_tests -t halt tests/test_q1.pl
%
% Every fixture below is a complete assignment (each attribute value used
% exactly once), because clue(N, S) is only defined on fully filled-in
% solutions.

:- use_module(library(plunit)).
:- use_module(library(readutil)).
:- consult('../code/79_q1.pl').

% --- Fixtures --------------------------------------------------------------

%! sol1(-S) is det.
%  Solution 1 of clues 1-8: the one main/0 prints. Clue 9 is false here.
sol1([p('Alex', design, java, 'AI'),
      p('Ben', development, javascript, web),
      p('Carla', research, 'c++', data),
      p('Dana', testing, python, embedded)]).

%! sol2(-S) is det.
%  Solution 2 of clues 1-8: the only one that also satisfies clue 9.
sol2([p('Alex', design, java, embedded),
      p('Ben', development, javascript, web),
      p('Carla', testing, python, 'AI'),
      p('Dana', research, 'c++', data)]).

%! sol3(-S) is det.
%  Solution 3 of clues 1-8. Same attribute combinations as sol1, but given
%  to different friends.
sol3([p('Alex', testing, python, embedded),
      p('Ben', development, javascript, web),
      p('Carla', design, java, 'AI'),
      p('Dana', research, 'c++', data)]).

%! all_three(-Ss) is det.
%  The three solutions of clues 1-8, in the order candidate/1 generates them.
all_three([S1, S2, S3]) :- sol1(S1), sol2(S2), sol3(S3).

% --- Clues -----------------------------------------------------------------
% Each clue holds on all three solutions of clues 1-8 (clue 9: only on
% sol2). For clues with two conditions, each condition is broken on its own.

:- begin_tests(clues).

test(clues_1_to_8_hold_on_all_three_solutions) :-
    all_three(Ss),
    forall(member(S, Ss), forall(between(1, 8, K), clue(K, S))).

% 1. The friend who prefers the AI project does not work in research and is
%    not Dana.
test(clue1_fails_ai_friend_in_research, [fail]) :-
    clue(1, [p('Alex', research, java, 'AI'), p('Ben', development, javascript, web),
             p('Carla', design, 'c++', data), p('Dana', testing, python, embedded)]).
test(clue1_fails_ai_friend_is_dana, [fail]) :-
    clue(1, [p('Alex', design, java, embedded), p('Ben', development, javascript, web),
             p('Carla', research, 'c++', data), p('Dana', testing, python, 'AI')]).

% 2. Alex does not work in development and does not prefer C++.
test(clue2_fails_alex_in_development, [fail]) :-
    clue(2, [p('Alex', development, java, 'AI'), p('Ben', design, javascript, web),
             p('Carla', research, 'c++', data), p('Dana', testing, python, embedded)]).
test(clue2_fails_alex_prefers_cpp, [fail]) :-
    clue(2, [p('Alex', design, 'c++', 'AI'), p('Ben', development, javascript, web),
             p('Carla', research, java, data), p('Dana', testing, python, embedded)]).

% 3. The friend working in the testing department likes Python.
test(clue3_fails_testing_friend_not_python, [fail]) :-
    clue(3, [p('Alex', design, java, 'AI'), p('Ben', development, javascript, web),
             p('Carla', research, python, data), p('Dana', testing, 'c++', embedded)]).

% 4. Ben prefers web projects and does not work in testing.
test(clue4_fails_ben_not_web, [fail]) :-
    clue(4, [p('Alex', design, java, web), p('Ben', development, javascript, 'AI'),
             p('Carla', research, 'c++', data), p('Dana', testing, python, embedded)]).
test(clue4_fails_ben_in_testing, [fail]) :-
    clue(4, [p('Alex', design, java, 'AI'), p('Ben', testing, javascript, web),
             p('Carla', research, 'c++', data), p('Dana', development, python, embedded)]).

% 5. The friend whose favorite language is Java works in the design
%    department.
test(clue5_fails_java_friend_not_design, [fail]) :-
    clue(5, [p('Alex', design, python, 'AI'), p('Ben', development, javascript, web),
             p('Carla', research, java, data), p('Dana', testing, 'c++', embedded)]).

% 6. Carla's project preference is not embedded, and her department is not
%    development.
test(clue6_fails_carla_embedded, [fail]) :-
    clue(6, [p('Alex', design, java, 'AI'), p('Ben', development, javascript, web),
             p('Carla', research, 'c++', embedded), p('Dana', testing, python, data)]).
test(clue6_fails_carla_in_development, [fail]) :-
    clue(6, [p('Alex', design, java, 'AI'), p('Ben', research, javascript, web),
             p('Carla', development, 'c++', data), p('Dana', testing, python, embedded)]).

% 7. Dana's favorite language is not Java, and she works in research or
%    testing. (sol1 covers Dana in testing, sol2 covers Dana in research.)
test(clue7_fails_dana_likes_java, [fail]) :-
    clue(7, [p('Alex', design, python, 'AI'), p('Ben', development, javascript, web),
             p('Carla', research, 'c++', data), p('Dana', testing, java, embedded)]).
test(clue7_fails_dana_in_design, [fail]) :-
    clue(7, [p('Alex', testing, java, 'AI'), p('Ben', development, javascript, web),
             p('Carla', research, 'c++', data), p('Dana', design, python, embedded)]).
test(clue7_fails_dana_in_development, [fail]) :-
    clue(7, [p('Alex', design, java, 'AI'), p('Ben', testing, javascript, web),
             p('Carla', research, 'c++', data), p('Dana', development, python, embedded)]).

% 8. The friend who prefers data projects works in research and does not use
%    JavaScript.
test(clue8_fails_data_friend_not_research, [fail]) :-
    clue(8, [p('Alex', design, java, 'AI'), p('Ben', development, javascript, web),
             p('Carla', research, 'c++', embedded), p('Dana', testing, python, data)]).
test(clue8_fails_data_friend_uses_javascript, [fail]) :-
    clue(8, [p('Alex', design, java, 'AI'), p('Ben', development, 'c++', web),
             p('Carla', research, javascript, data), p('Dana', testing, python, embedded)]).

% 9. The friend who works in the testing department prefers the AI project.
test(clue9_holds_on_sol2) :-
    sol2(S), clue(9, S).
test(clue9_fails_on_sol1, [fail]) :-
    sol1(S), clue(9, S).
test(clue9_fails_on_sol3, [fail]) :-
    sol3(S), clue(9, S).

% Each clue succeeds at most once on every assignment, so findall/3 never
% counts a solution twice.
test(every_clue_succeeds_at_most_once) :-
    forall(( between(1, 9, K), candidate(S) ),
           ( aggregate_all(count, clue(K, S), C), C =< 1 )).

% Clues only check, they never bind anything in the solution.
test(clues_do_not_bind_solution) :-
    sol1(S), copy_term(S, S0),
    forall(between(1, 9, K), ( clue(K, S) -> true ; true )),
    S == S0.

:- end_tests(clues).

% --- Clue 9 placement and wording (P1.c rules) ----------------------------

:- begin_tests(clue9_source).

%! clue9_comment_line(-Comment, -Next) is semidet.
%  Comment is the line starting with "% CLUE 9:" in the solution file, and
%  Next is the line right after it.
clue9_comment_line(Comment, Next) :-
    source_file(user:clue(_, _), File),   % clue/2 lives in user, not the test module
    read_file_to_string(File, Text, []),
    split_string(Text, "\n", "\r", Lines),
    append(_, [Comment, Next | _], Lines),
    string_concat("% CLUE 9:", _, Comment), !.

test(clue9_comment_is_directly_above_clause) :-
    clue9_comment_line(_, Next),
    string_concat("clue(9,", _, Next).

test(clue9_mentions_no_friend_by_name) :-
    clue9_comment_line(Comment, _),
    forall(member(Name, ["Alex", "Ben", "Carla", "Dana"]),
           \+ sub_string(Comment, _, _, _, Name)).

:- end_tests(clue9_source).

% --- main/0 (P1.a) ---------------------------------------------------------

:- begin_tests(main).

test(main_prints_exact_four_lines) :-
    with_output_to(string(Out), main),
    Out == "Alex = [design, java, AI]\nBen = [development, javascript, web]\nCarla = [research, c++, data]\nDana = [testing, python, embedded]\n".

test(main_output_has_no_quotes) :-
    with_output_to(string(Out), main),
    \+ sub_string(Out, _, _, _, "'").

test(main_succeeds_exactly_once) :-
    aggregate_all(count, with_output_to(string(_), main), 1).

test(main_solution_satisfies_clues_1_to_8) :-
    once(( candidate(S), satisfies_clues([1, 2, 3, 4, 5, 6, 7, 8], S) )),
    sol1(S).

:- end_tests(main).

% --- count_solutions/2 (P1.b, P1.c) ----------------------------------------

:- begin_tests(count_solutions).

test(clues_1_to_8_give_3, [true(N =:= 3)]) :-
    count_solutions([1, 2, 3, 4, 5, 6, 7, 8], N).

test(clues_1_to_9_give_1, [true(N =:= 1)]) :-
    count_solutions([1, 2, 3, 4, 5, 6, 7, 8, 9], N).

test(clues_1_to_9_keep_sol2) :-
    findall(S, ( candidate(S),
                 satisfies_clues([1, 2, 3, 4, 5, 6, 7, 8, 9], S) ), [Only]),
    sol2(Only).

test(clues_1_to_8_give_exactly_the_three_solutions) :-
    findall(S, ( candidate(S),
                 satisfies_clues([1, 2, 3, 4, 5, 6, 7, 8], S) ), Found),
    all_three(Found).

test(no_clues_gives_all_assignments, [true(N =:= 13824)]) :-
    count_solutions([], N).

test(single_clues, [true(Ns == [7776, 7776, 3456, 2592, 3456, 7776, 5184, 2592, 3456])]) :-
    findall(N, ( between(1, 9, K), count_solutions([K], N) ), Ns).

test(order_of_active_does_not_matter, [true(N =:= 3)]) :-
    count_solutions([8, 7, 6, 5, 4, 3, 2, 1], N).

test(count_is_deterministic, [true(Ns == [3])]) :-
    findall(N, count_solutions([1, 2, 3, 4, 5, 6, 7, 8], N), Ns).

:- end_tests(count_solutions).
