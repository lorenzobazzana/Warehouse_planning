#const maxtime=10.
#const m=4.
#const n=5.
coordX(0..m-1).
coordY(0..n-1).

direction(no;so;ea;we).

time(0..maxtime).

box(1, 1, n-1).
box(2, 2, n-1).
%box(3, 2, 4).

drawer(1, 2).

boxIn(I, X, Y, 0) :- cell(X, Y), box(I, X, Y).

cell(X, Y) :- coordX(X), coordY(Y).
cell(m, n-1).

notFree(X, Y, Ti) :- cell(X, Y), time(Ti), boxIn(_, X, Y, Ti), X != m. 
notFree(X, Y, Ti) :- cell(X, Y), time(Ti), coveredByDrawer(X, Y).

coveredByDrawer(X, Y) :- cell(X, Y), drawer(X, Y).
coveredByDrawer(X, Y) :- cell(X, Y), drawer(X-1, Y).
coveredByDrawer(X, Y) :- cell(X, Y), drawer(X, Y-1).
coveredByDrawer(X, Y) :- cell(X, Y), drawer(X-1, Y-1).

% Mosse disponibili al tempo Ti
validMoves(I, D, L, Ti) :- box(I, _, _), direction(D),
                        time(Ti),
                        Ti < maxtime, 
                        not notFree(XNew, YNew, Ti), 
                        boxIn(I, X, Y, Ti),
                        not notFree(XPush, YPush, Ti), 
                        dest(XNew, YNew, X, Y, L, D),
                        pushPosition(XPush, YPush, X, Y, D),
                        not blockedPath(X, Y, XNew, YNew, Ti).

% Controllo che in mezzo al cammino non ci sia nulla
blockedPath(XStart, YStart, XEnd, YEnd, Ti) :- notFree(X, Y, Ti), dest(X, Y, XStart, YStart, L1, D), dest(XEnd, YEnd, X, Y, L2, D), dest(XEnd, YEnd, XStart, YStart, L1+L2, D).

validMultipleMove(I, D, L, Ti) :- box(I, _, _), direction(D),
                                    time(Ti),
                                    Ti < maxtime,
                                    boxIn(I, X, Y, Ti), % La scatola che spostiamo e' in posizione (X,Y)
                                    not notFree(XPush, YPush, Ti), % La posizione di spostamento e' libera
                                    pushPosition(XPush, YPush, X, Y, D),
                                    not blockedByDrawer(X, Y, XNew, YNew), % Il percorso non e' bloccato da armadi
                                    dest(X1, Y1, X, Y, L, D), % (XNew, YNew) e' destinazione di uno spostamento lungo L+K
                                    dest(XNew, YNew, X1, Y1, K, D),
                                    %conto le scatole nel mezzo (quelle che risiedono in una posizione di destinazione per uno spostamento di lunghezza L1 < L nella stessa direzione)
                                    K = #count{I2:boxIn(I2, X2, Y2, Ti), I2 != I, dest(X2, Y2, X, Y, L1, D), L1 <= L}. 

blockedByDrawer(XStart, YStart, XEnd, YEnd) :- coveredByDrawer(X,Y), dest(X, Y, XStart, YStart, L1, D), dest(XEnd, YEnd, X, Y, L2, D), dest(XEnd, YEnd, XStart, YStart, L1+L2, D).

% In ogni istante esattamente una mossa
0{move(I, D, L, Ti):validMoves(I, D, L, Ti);multipleMove(I, D, L, Ti):validMultipleMove(I, D, L, Ti)}1 :- time(Ti), Ti < maxtime. 



boxIn(I, XNew, YNew, Ti+1) :- time(Ti),
                                Ti < maxtime,
                                cell(XNew, YNew),
                                boxIn(I, X, Y, Ti),
                                dest(XNew, YNew, X, Y, L, D),
                                move(I, D, L, Ti).

boxIn(I, XNew, YNew, Ti+1) :- time(Ti),
                                Ti < maxtime,
                                cell(XNew, YNew),
                                boxIn(I, X, Y, Ti),
                                boxIn(I2, X2, Y2, Ti),
                                dest(X, Y, X2, Y2, M, D),
                                dest(XNew, YNew, X, Y, N, D),
                                M <= L,
                                N = L-M+1,
                                multipleMove(I2, D, L, Ti).

boxIn(I, X, Y, Ti+1) :- time(Ti),
                        Ti < maxtime,
                        boxIn(I, X, Y, Ti), 
                        not move(I, _, _, Ti),
                        not pushedByAnotherBox(I, Ti).

pushedByAnotherBox(I, Ti) :- time(Ti),
                             boxIn(I, X, Y, Ti),
                             boxIn(I2, X2, Y2, Ti),
                             I != I2,
                             dest(X, Y, X2, Y2, M, D),
                             M <= L,
                             multipleMove(I2, D, L, Ti).
                             
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

%requiredMoves(M) :- M = #sum{T:move(I, D, L, T)}.
%#minimize {M:requiredMoves(M)}.

#show move/4.
#show multipleMove/4.
%#show validMoves/4.
%#show boxIn/4.
%#show pushedByAnotherBox/2.