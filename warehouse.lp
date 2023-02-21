#const maxtime=5.
#const m=3.
#const n=3.
coordX(1..m).
coordY(1..n).
direction(n).
direction(s).
direction(e).
direction(w).
time(0..maxtime).
boxNumber(1).
box(1, 2, 1).
box(2, 3, 1).

cell(X, Y) :- coordX(X), coordY(Y).
cell(m+1, 1).
holds(free(X,Y), 0) :- cell(X, Y), not box(_, X, Y).
holds(boxIn(I, X, Y), 0) :- cell(X, Y), box(I, X, Y).

fluent(boxIn(I, X, Y)) :- box(I, X, Y), cell(X, Y).
%fluent(not_free(X, Y)) :- boxIn(I, X, Y), cell(X, Y).
fluent(free(X, Y)) :- cell(X, Y).

%1{holds(F,T); holds(neg(F),T)}1 :- time(T), T <= maxtime, fluent(F).

complement(Fl,neg(Fl)) :- fluent(Fl).
complement(neg(Fl),Fl) :- fluent(Fl).

action(move(I, D, L)) :- box(I, _, _), direction(D), coordX(L).
action(move(I, D, L)) :- box(I, _, _), direction(D), coordY(L).

exec(move(I, D, L), Ti) :- action(move(I, D, L)), time(Ti), 
                            holds(free(XNew, YNew), Ti), 
                            holds(boxIn(I, X, Y), Ti),
                            holds(free(XPush, YPush), Ti), 
                            dest(XNew, YNew, X, Y, L, D), 
                            push_position(XPush, YPush, X, Y, D).

% Lo spostamento dello scatolone I aggiorna la sua posizione corrente
causes(move(I, D, L), boxIn(I, XNew, YNew)) :- box(I, _, _), cell(XNew, YNew).
ok(move(I, D, L), boxIn(I, XNew, YNew), Ti) :- time(Ti), holds(boxIn(I, X, Y),Ti), dest(XNew, YNew, X, Y, L, D).

causes(move(I, D, L), free(X, Y)) :- box(I, _, _), cell(X, Y).
ok(move(I, D, L), free(X, Y), Ti) :- time(Ti), holds(boxIn(I, X, Y),Ti).

holds(Fl,Ti+1) :- time(Ti), fluent(Fl),
        occ(Act,Ti), causes(Act,Fl),
        ok(Act,Fl,Ti), exec(Act,Ti).

% La cella (X1, Y1) e' sopra a (X2, Y2), con distanza L
north(X1, Y1, X2, Y2, L) :- coordX(X), coordY(Y), north(X1, Y1, X, Y, L1), north(X, Y, X2, Y2, L2), L1+L2=L.
north(X1, Y1, X2, Y2, 1) :- cell(X1, Y1), cell(X2, Y2), X1 = X2, Y1 = Y2-1.
% La cella (X1, Y1) e' in basso a (X2, Y2), con distanza L
south(X1, Y1, X2, Y2, L) :- north(X2, Y2, X1, Y1, L).
% La cella (X1, Y1) e' a destra di (X2, Y2), con distanza L
east(X1, Y1, X2, Y2, L) :- coordX(X), coordY(Y), east(X1, Y1, X, Y, L1), east(X, Y, X2, Y2, L2), L1+L2=L.
east(X1, Y1, X2, Y2, 1) :- cell(X1, Y1), cell(X2, Y2), Y1 = Y2, X1 = X2+1.
% La cella (X1, Y1) e' direttamente a destra di (X2, Y2)
west(X1, Y1, X2, Y2, L) :- east(X2, Y2, X1, Y1, L).

dest(XNew, YNew, X, Y, L, n) :- north(XNew, YNew, X, Y, L).
dest(XNew, YNew, X, Y, L, s) :- south(XNew, YNew, X, Y, L).
dest(XNew, YNew, X, Y, L, e) :- east(XNew, YNew, X, Y, L).
dest(XNew, YNew, X, Y, L, w) :- west(XNew, YNew, X, Y, L).

% (X1, Y1) e' la posizione per spingere una cassa in (X2, Y2) nella direzione D
push_position(X1, Y1, X2, Y2, D) :- dest(X2, Y2, X1, Y1, 1, D).


%move(I, L) :- boxIn(I, X, Y), free(XNew, YNew), east(XNew, YNew, X, Y, L).
%boxIn(I, XNew, YNew) :- move(I, L), cell(XNew, YNew).
%free(X, Y) :- move(I, L), boxIn(I, X, Y).

%
%%1{occ(Act,Ti):action(Act)}1 :- time(Ti), Ti < 5.
%%:- occ(Act,Ti), action(Act), time(Ti), not exec(Act,Ti).
%
%goal :- boxIn(I, 4, 1): box(I, _, _).
%:- not goal.


#show action/1.