coordX(1..3).
coordY(1..3).
direction(n).
direction(s).
direction(e).
direction(w).
time(0..2).

length(1..3).

box(1, 2, 2).

fluent(boxIn(I, X, Y)) :- coordX(X), coordY(Y), box(I, X, Y).    % scatola in posizione (X,Y)
%fluent(drawerIn(I, X, Y)) :- coordX(X), coordY(Y). % armadio in posizione (X,Y)
%fluent(wall(X,Y)). %per ogni X e Y tranne nel punto di uscita

action(move(I, D, L)) :- box(I, _, _), direction(D), length(L).

executable(move(I, D, L), Ti) :- time(Ti), box(I, _, _), direction(D), length(L).
causes(move(I, D, L), boxIn(I, XNew, YNew)) :- box(I, _, _), direction(D), length(L), coordX(XNew), coordY(YNew).
ok(move(I, D, L), boxIn(I, XNew, YNew), Ti) :- time(Ti), holds(boxIn(I, X, Y), Ti), target(X, Y, XNew, YNew, D, L).
holds(Fl,Ti+1) :- time(Ti), literal(Fl),
        occ(Act,Ti), causes(Act,Fl),
        ok(Act,Fl,Ti), executable(Act,Ti).


causes(move(I, D, L), neg(boxIn(I, X, Y))) :- box(I, _, _), direction(D), length(L), coordX(X), coordY(Y).
ok(move(I, D, L), neg(boxIn(I, X, Y)), Ti) :- time(Ti), holds(boxIn(I, X, Y), Ti), box(I), direction(D), length(L), coordX(X), coordY(Y).
holds(Fl,Ti+1) :- time(Ti), literal(Fl),
        occ(Act,Ti), causes(Act,Fl),
        ok(Act,Fl,Ti), executable(Act,Ti).


target(X, Y, XNew, YNew, n, L) :- validX(X, XNew), validY(Y, YNew), L = Y - YNew, L > 0.
target(X, Y, XNew, YNew, s, L) :- validX(X, XNew), validY(Y, YNew), L = YNew - Y, L > 0.
target(X, Y, XNew, YNew, e, L) :- validX(X, XNew), validY(Y, YNew), L = XNew - X, L > 0.
target(X, Y, XNew, YNew, w, L) :- validX(X, XNew), validY(Y, YNew), L = X - XNew, L > 0.

validX(X1, X2) :- coordX(X1), coordX(X2).
validY(Y1, Y2) :- coordY(Y1), coordY(Y2).



1{occ(Act,Ti):action(Act)}1 :- time(Ti), Ti < maxtime.
:- occ(Act,Ti), action(Act),
   time(Ti), not executable(Act,Ti).

holds(L, T + 1) :- time(T), literal(L),
        holds(L, T ), not holds(L1, T + 1),
        complement(L, L1).


complement(Fl,neg(Fl)) :- fluent(Fl).
complement(neg(Fl),Fl) :- fluent(Fl).

holds(boxIn(1, 2, 2), 0).

goal :- holds(boxIn(1, 4, 1)).
:- goal.
