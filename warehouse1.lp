#const maxtime=5.
#const m=4.
#const n=4.
coordX(0..m-1).
coordY(0..n-1).

%verticalDirection(no;so).
%horizontalDirection(ea;we).
%direction(D) :- verticalDirection(D).
%direction(D) :- horizontalDirection(D).
direction(no;so;ea;we).

time(0..maxtime).

box(1, 2, 2).
box(2, 3, 1).
box(3, 3, 3).

boxIn(I, X, Y, 0) :- cell(X, Y), box(I, X, Y).

cell(X, Y) :- coordX(X), coordY(Y).
cell(m, n-1).

free(X, Y, Ti) :- cell(X, Y), not boxIn(_, X, Y, Ti), time(Ti).
% La cella di uscita e' sempre "libera"
free(m, n-1, Ti) :- time(Ti).

% Non posso avere una cella libera e contemporaneamente occupata (a meno che non sia la cella di uscita)
% Nel caso in cui sia la cella di uscita, mi basta controllare la coordinata X, perche' nessun'altra cella condivide la stessa X della cella di uscita
% La coordinata Y invece e' condivisa da tutta la riga piu' in alto
:- free(X, Y, Ti), boxIn(_, X, Y, Ti), time(Ti), X != m. 

%validLength(L, D) :- coordY(L), verticalDirection(D).
%validLength(L, D) :- coordX(L), horizontalDirection(D).

% Mosse disponibili al tempo Ti
validMoves(I, D, L, Ti) :- box(I, _, _), direction(D), %validLength(L, D),
                        time(Ti),
                        Ti < maxtime, 
                        free(XNew, YNew, Ti), 
                        boxIn(I, X, Y, Ti),
                        free(XPush, YPush, Ti), 
                        dest(XNew, YNew, X, Y, L, D),
                        pushPosition(XPush, YPush, X, Y, D),
                        not blockedPath(X, Y, XNew, YNew, Ti).

%%%% Controllo che in mezzo al cammino non ci sia nulla
blockedPath(XStart, YStart, XEnd, YEnd, Ti) :- boxIn(I, X, Y, Ti), dest(X, Y, XStart, YStart, L1, D), dest(XEnd, YEnd, X, Y, L2, D), dest(XEnd, YEnd, XStart, YStart, L1+L2, D).

% In ogni istante esattamente una mossa
0{move(I, D, L, Ti):validMoves(I, D, L, Ti)}1 :- time(Ti), Ti < maxtime. % NB: cosi pero' puo' sprecare tempo 

boxIn(I, X, Y, Ti+1) :- time(Ti),
                        Ti < maxtime,
                        boxIn(I, X, Y, Ti), 
                        not move(I, _, _, Ti).

boxIn(I, XNew, YNew, Ti+1) :- time(Ti),
                                Ti < maxtime,
                                cell(XNew, YNew),
                                boxIn(I, X, Y, Ti),
                                dest(XNew, YNew, X, Y, L, D),
                                move(I, D, L, Ti).



% La cella (X1, Y1) e' sopra a (X2, Y2), con distanza L
north(X1, Y1, X2, Y2, L) :- cell(X, Y), north(X1, Y1, X, Y, L1), north(X, Y, X2, Y2, L2), L1+L2=L.
north(X1, Y1, X2, Y2, 1) :- cell(X1, Y1), cell(X2, Y2), X1 = X2, Y1 = Y2+1.

% La cella (X1, Y1) e' in basso a (X2, Y2), con distanza L
south(X1, Y1, X2, Y2, L) :- north(X2, Y2, X1, Y1, L).

% La cella (X1, Y1) e' a destra di (X2, Y2), con distanza L
east(X1, Y1, X2, Y2, L) :- cell(X, Y), east(X1, Y1, X, Y, L1), east(X, Y, X2, Y2, L2), L1+L2=L.
east(X1, Y1, X2, Y2, 1) :- cell(X1, Y1), cell(X2, Y2), Y1 = Y2, X1 = X2+1.

% La cella (X1, Y1) e' direttamente a destra di (X2, Y2)
west(X1, Y1, X2, Y2, L) :- east(X2, Y2, X1, Y1, L).

dest(XNew, YNew, X, Y, L, no) :- north(XNew, YNew, X, Y, L).
dest(XNew, YNew, X, Y, L, so) :- south(XNew, YNew, X, Y, L).
dest(XNew, YNew, X, Y, L, ea) :- east(XNew, YNew, X, Y, L).
dest(XNew, YNew, X, Y, L, we) :- west(XNew, YNew, X, Y, L).

% (X1, Y1) e' la posizione per spingere una cassa in (X2, Y2) nella direzione D (ovvero, (X2, Y2) deve essere nella direzione D rispetto a (X1, Y1)) e a distanza 1
pushPosition(XPush, YPush, X, Y, D) :- dest(X, Y, XPush, YPush, 1, D).


% Unfinished: la box I all'istante di tempo Ti non e' in posizione finale
unfinished(I, Ti) :- time(Ti), not boxIn(I, X, Y, Ti), box(I, _, _), X = m, Y = n-1.
% Non puo' essere che al tempo maxTime esista una box in posizione non finale
:- unfinished(I, maxtime), box(I, _, _).


%#show free/3.
%#show boxIn/4.
%#show goal/0.
%#show north/5.
%#show validMoves/4.
#show move/4.