% Warehouse planning problem
% Lorenzo Bazzana
% Automated Reasoning course, University of Udine
% 2023

% Room modeling ------------------------------------------------------------------------------
% The m x n room is a set of cells (x,y)
coordX(0..m-1).
coordY(0..n-1).

cell(X, Y) :- coordX(X), coordY(Y).
cell(m, n-1). % Exit cell

% Movement directions
direction(no;so;ea;we).

% Time steps
time(0..maxtime).

% Each box is placed in its starting location at t=0
boxIn(I, X, Y, 0) :- cell(X, Y), box(I, X, Y).

% A cell is not free if there is a box or a drawer on it
notFree(X, Y, Ti) :- cell(X, Y), time(Ti), boxIn(_, X, Y, Ti), X != m. 
notFree(X, Y, Ti) :- cell(X, Y), time(Ti), coveredByDrawer(X, Y).

% Drawers cover a 2x2 area
coveredByDrawer(X, Y) :- cell(X, Y), drawer(X, Y).
coveredByDrawer(X, Y) :- cell(X, Y), drawer(X-1, Y).
coveredByDrawer(X, Y) :- cell(X, Y), drawer(X, Y-1).
coveredByDrawer(X, Y) :- cell(X, Y), drawer(X-1, Y-1).

% (X1,Y1) is north of (X2,Y2) with distance L
north(X1, Y1, X2, Y2, L) :- cell(X, Y), north(X1, Y1, X, Y, L1), north(X, Y, X2, Y2, L2), L1+L2=L.
north(X1, Y1, X2, Y2, 1) :- cell(X1, Y1), cell(X2, Y2), X1 = X2, Y1 = Y2+1.

% (X1, Y1) is south of (X2, Y2), with distance L
south(X1, Y1, X2, Y2, L) :- north(X2, Y2, X1, Y1, L).

% (X1, Y1) is east of (X2, Y2), with distance L
east(X1, Y1, X2, Y2, L) :- cell(X, Y), east(X1, Y1, X, Y, L1), east(X, Y, X2, Y2, L2), L1+L2=L.
east(X1, Y1, X2, Y2, 1) :- cell(X1, Y1), cell(X2, Y2), Y1 = Y2, X1 = X2+1.

% (X1, Y1) is west of (X2, Y2), with distance L
west(X1, Y1, X2, Y2, L) :- east(X2, Y2, X1, Y1, L).

% (XNew, YNew) is the destination of a movement from (X,Y) with distance L, in the direction no/so/ea/we
dest(XNew, YNew, X, Y, L, no) :- north(XNew, YNew, X, Y, L).
dest(XNew, YNew, X, Y, L, so) :- south(XNew, YNew, X, Y, L).
dest(XNew, YNew, X, Y, L, ea) :- east(XNew, YNew, X, Y, L).
dest(XNew, YNew, X, Y, L, we) :- west(XNew, YNew, X, Y, L).

% Movement rules --------------------------------------------------------------------------------

% (XPush, YPush) is the pushing position for (X, Y) in direction D 
% (meaning that (X,Y) must be in direction D respective to (XPush, YPush) and at distance 1; (m,Y) cannot be a pushing position (we cannot move away from the goal))
pushPosition(XPush, YPush, X, Y, D) :- dest(X, Y, XPush, YPush, 1, D), XPush != m.

% Valid single box movements at time t
validMoves(I, D, L, Ti) :- box(I, _, _),
                            direction(D),
                            time(Ti),
                            Ti < maxtime, 
                            not notFree(XNew, YNew, Ti),            % The destination must be free
                            boxIn(I, X, Y, Ti),                     
                            not notFree(XPush, YPush, Ti),          % The box must be pushable (free pushing position)
                            dest(XNew, YNew, X, Y, L, D),            
                            pushPosition(XPush, YPush, X, Y, D),
                            not blockedPath(X, Y, XNew, YNew, Ti).  % The path must not be blocked

% A path is blocked if there exists an intermediate cell that is not free
blockedPath(XStart, YStart, XEnd, YEnd, Ti) :- notFree(X, Y, Ti), dest(X, Y, XStart, YStart, L1, D), dest(XEnd, YEnd, X, Y, L2, D), dest(XEnd, YEnd, XStart, YStart, L1+L2, D).

% Valid multiple box movements at time t
validMultipleMoves(I, D, L, Ti) :- box(I, _, _), direction(D),
                                    time(Ti),
                                    Ti < maxtime,
                                    boxIn(I, X, Y, Ti),                     % Pushed box
                                    not notFree(XPush, YPush, Ti),          % Free pushing position
                                    pushPosition(XPush, YPush, X, Y, D),
                                    not blockedByDrawer(X, Y, XMax, YMax),  % The path must not be blocked by drawers
                                    dest(X1, Y1, X, Y, L, D),               % We check a path that is long L+K, L = actual length of movement, K = number of boxes involved (except the pushed one)
                                    dest(XMax, YMax, X1, Y1, K, D),
                                    dest(XMax, YMax, X, Y, LMax, D),
                                    not notFree(XMax, YMax, Ti),            
                                    LMax = L+K,
                                    % We count the boxes that are between the pushed box and the final destination
                                    K = #count{I2:boxIn(I2, X2, Y2, Ti), I2 != I, dest(XMax, YMax, X2, Y2, L2, D), L2 < LMax}.

% A path is blocked by a drawer if there exists a drawer in an intermediate position occupied by a drawer
blockedByDrawer(XStart, YStart, XEnd, YEnd) :- coveredByDrawer(X,Y), dest(X, Y, XStart, YStart, L1, D), dest(XEnd, YEnd, X, Y, L2, D), dest(XEnd, YEnd, XStart, YStart, L1+L2, D).

% At every time instant we nondeterministically choose a move
0{move(I, D, L, Ti):validMoves(I, D, L, Ti);move(I, D, L, Ti):validMultipleMoves(I, D, L, Ti)}1 :- time(Ti), Ti < maxtime. 

% A box is moved if it was pushed or it was pushed by another box
moved(I, D, L, Ti) :- move(I, D, L, Ti).
moved(I, D, L, Ti) :- collateralMove(I, D, L, Ti).

% Similar to the calculation for valid multiple moves, but we just take into consideration the boxes between the pushed one and the box we are checking
collateralMove(I, D, N, Ti) :- move(I2, D, L, Ti),
                                boxIn(I2, X2, Y2, Ti),
                                dest(X2Final, Y2Final, X2, Y2, L, D),
                                boxIn(I, X, Y, Ti),
                                dest(X, Y, X2, Y2, M, D),
                                dest(XNew, YNew, X, Y, N, D),
                                N = L-M+1+K,
                                K = #count{I3:boxIn(I3, X3, Y3, Ti), dest(X3, Y3, X2, Y2, L3, D), L3 < M}.

% Position update -----------------------------------------------------------------------------------------------------------------

% If a box was moved we update its position
boxIn(I, XNew, YNew, Ti+1) :- time(Ti),
                                Ti < maxtime,
                                cell(XNew, YNew),
                                boxIn(I, X, Y, Ti),
                                dest(XNew, YNew, X, Y, L, D),
                                moved(I, D, L, Ti).

% If a box was not moved it maintains its position (inertia)
boxIn(I, X, Y, Ti+1) :- time(Ti),
                        Ti < maxtime,
                        boxIn(I, X, Y, Ti), 
                        not move(I, _, _, Ti),
                        not collateralMove(I, _, _, Ti).

% Domain knowledge constraints, added to stop search early in case of trivially unsatisfiable instances ---------------------------
% Exit cannot be blocked
:- coveredByDrawer(m-1, n-1).
% There cannot be a box covering the push position to the exit
:- coveredByDrawer(m-2, n-1).

% Goal constraints ----------------------------------------------------------------------------------------------------------------

% Unfinished: box I at time instant Ti is not in the goal position
unfinished(I, Ti) :- time(Ti), not boxIn(I, X, Y, Ti), box(I, _, _), X = m, Y = n-1.
% At t=maxtime all boxes must be in the goal position
:- unfinished(I, maxtime), box(I, _, _).

% Number of required moves to reach the goal
requiredMoves(M) :- M = #count{T:move(I, D, L, T)}.
% We cannot have idle instants before reaching the goal
:- time(Ti), time(Ti+1), move(_,_,_, Ti+1), not move(_,_,_,Ti), Ti < maxtime.
#minimize {M:requiredMoves(M)}.

#show move/4.