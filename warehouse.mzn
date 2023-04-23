% Warehouse planning problem
% Lorenzo Bazzana
% Automated Reasoning course, University of Udine
% 2023

% Room size
int: m;
int: n;

% Time instants
int: maxtime;

int: boxNumber;
int: drawerNumber;

set of int: COORDS = 0..max(m,n);

% Variables: for each box and time instant, we record the position of that box at that time instant
array[1..boxNumber, 0..maxtime, 0..1] of var COORDS: boxes;
% Drawers are constants (they cannot be moved)
array[1..drawerNumber, 0..1] of COORDS: drawers;
% Moves are variables, and their value will be determined from the movement constraints
array[0..maxtime-1] of var 0..boxNumber: moves;
    
% Movement constraints ------------------------------------------------------------------------------------------------------------------------------

% We check that the path between the starting and endind point of a movement was not blocked by drawers
predicate freePath(1..boxNumber: movedBox, var COORDS: start, var COORDS: end, 0..maxtime: time, 0..1: coord) = 
    if coord = 0
    then
        forall(pos in min(start, end)..max(start, end))(
            freeFromDrawers(pos, boxes[movedBox, time, 1])
        )
    else
        forall(pos in min(start, end)..max(start, end))(
            freeFromDrawers(boxes[movedBox, time, 0], pos)
        )
    endif;


% A cell is free is there are no boxes or drawers on it
predicate freeCell(var COORDS: cellX, var COORDS: cellY, 0..maxtime: time) = 
    (cellX = m /\ cellY = n-1) \/ 
    (
        not exists(box in 1..boxNumber)(
        boxes[box, time, 0] = cellX /\ 
        boxes[box, time, 1] = cellY
        ) /\
        freeFromDrawers(cellX, cellY) /\
        cellX < m /\
        cellX >= 0 /\
        cellY >= 0 /\
        cellY < n
    )
;

% Drawers cover a 2x2 area
predicate freeFromDrawers(var COORDS: cellX, var COORDS: cellY) = 
    not exists(drawer in 1..drawerNumber)(
        (drawers[drawer, 0] = cellX /\ drawers[drawer, 1] = cellY) \/
        (drawers[drawer, 0] = (cellX-1) /\ drawers[drawer, 1] = cellY) \/
        (drawers[drawer, 0] = cellX /\ drawers[drawer, 1] = (cellY-1)) \/
        (drawers[drawer, 0] = (cellX-1) /\ drawers[drawer, 1] = (cellY-1))
        )
;

function var int: sign(var int: x) = if x < 0 then -1 else 1 endif;

predicate moved(1..boxNumber: box, 1..maxtime: t, 0..1: coord) = boxes[box, t-1, coord] != boxes[box, t, coord];

% Box in (x,y) -> pushing position in (x-1,y) if it was moved east, (x+1,y) if it was moved west
% Analogous for north and south
predicate freePushPosition(1..boxNumber: box, 0..1: coord, 0..maxtime-1: t) = 
    if coord = 0
    then
        let {var COORDS: xPush = boxes[box, t, 0] + sign(boxes[box, t, 0] - boxes[box, t+1, 0]); var COORDS: yPush = boxes[box, t, 1]} in
        xPush != m /\ 
        freeCell(xPush, yPush, t)
    else
        let {var COORDS: xPush = boxes[box, t, 0]; var COORDS: yPush = boxes[box, t, 1] + sign(boxes[box, t, 1] - boxes[box, t+1, 1])} in
        freeCell(xPush, yPush, t)
    endif;

% b1 precedes b2 in the movement direction
predicate precedes(1..boxNumber: b1, 1..boxNumber: b2, 0..1: coord, 0..maxtime: t) =  
    let {0..1: otherCoord = (coord+1) mod 2} in
    (boxes[b1, t, otherCoord] = boxes[b2, t, otherCoord]) /\
    if sign(boxes[b1, t+1, coord] - boxes[b1, t, coord]) = 1
    then
        boxes[b2, t, coord] > boxes[b1, t, coord]
    else
        boxes[b2, t, coord] < boxes[b1, t, coord]
    endif;

% b1 and b2 were moved in the same direction (we check the sign of the difference of the coordinates)
predicate sameDirection(1..boxNumber: b1, 1..boxNumber: b2, 0..1: coord, 1..maxtime: t) = 
    sign(boxes[b1, t, coord] - boxes[b1, t-1, coord]) = sign(boxes[b2, t, coord] - boxes[b2, t-1, coord]);

% The path from a starting cell to an ending cell must not have free cells in between; this is needed to model multiple boxes pushing each other
% It must also be used in conjunction with the "freeFromDrawers" predicate, in order to avoid situations where boxes jump over drawers
predicate fullPath(var COORDS: start, var COORDS: end, 0..1: coord, var COORDS: fixedCoord, 1..maxtime: t) = 
    if coord = 0
    then 
        not exists(x in start..end)(
            freeCell(x, fixedCoord, t) /\ x != m
        )
    else
        not exists(y in start..end)(
            freeCell(fixedCoord, y, t)
        )
    endif;

% Main movement constraint:
% - A box is either pushed (free pushing position and its movement is recorded as the "official" move) OR
% - A box is pushed by another box that precedes it and it was moved in the same direction; we must ensure that after the movement there are no free cells between these two boxes
predicate movementConstraint(1..boxNumber: box, 1..maxtime: t, 0..1: coord) =
    let {0..1: otherCoord = (coord+1) mod 2} in
    not moved(box, t, otherCoord) /\
    freePath(box, boxes[box, t-1, coord], boxes[box, t, coord], t-1, coord) /\
    (
        (freePushPosition(box, coord, t-1) /\ moves[t-1] = box) \/
        (
            exists(b2 in 1..boxNumber)(
                b2 != box /\
                moves[t-1] = b2 /\
                precedes(b2, box, coord, t-1) /\
                sameDirection(b2, box, coord, t) /\
                fullPath(min(boxes[b2, t, coord], boxes[box, t, coord]), max(boxes[b2, t, coord], boxes[box, t, coord]), coord, boxes[box, t, otherCoord], t)
            )
        )
    );


constraint
    forall(box in 1..boxNumber)(
        forall(t in 1..maxtime)(
            if(moved(box, t, 0)) % se la X e' differente...
            then
                movementConstraint(box, t, 0)
            elseif(moved(box, t, 1)) % altrimenti se la Y e' differente...
            then
                movementConstraint(box, t, 1)
            else
              true
            endif
    )
  )
;

% Consistency constraints ----------------------------------------------------------------------------------------------------------
% If a box was recorded as the moved box, it must actually have been moved
constraint
    forall(t in 1..maxtime)(
        forall(box in 1..boxNumber)(
            moves[t-1] = box -> (moved(box, t, 0) \/ moved(box, t, 1))
        )
    )
;

% There cannot be multiple boxes on the same cell, except for the exit cell
constraint
    forall(t in 0..maxtime)(
        forall(x in 0..m)(
            x != m -> not exists(b1 in 1..boxNumber, b2 in 1..boxNumber)(b1 != b2 /\ boxes[b1, t, 0] = x /\ boxes[b2, t, 0] = x /\ boxes[b1, t, 1] = boxes[b2, t, 1])
        )
  )
;

% Consistency of order: boxes cannot jump over each other, their order must be maintained between consecutive time instants (if they share one coordinate at t and t+1)
constraint
    forall(t in 0..maxtime-1)(
        not exists(b1 in 1..boxNumber, b2 in 1..boxNumber)(
            b1 != b2 /\
            (
                boxes[b1, t, 0] = boxes[b2, t, 0] /\ boxes[b1, t+1, 0] = boxes[b2, t+1, 0] /\
                boxes[b1, t, 1] < boxes[b2, t, 1] /\
                boxes[b1, t+1, 1] > boxes[b2, t+1, 1]  
            ) \/
            (
                boxes[b1, t, 1] = boxes[b2, t, 1] /\ boxes[b1, t+1, 1] = boxes[b2, t+1, 1] /\
                boxes[b1, t, 0] < boxes[b2, t, 0] /\
                boxes[b1, t+1, 0] > boxes[b2, t+1, 0]  
            )
        )
    )
;

% Boxes cannot go out of bounds
constraint
  forall(box in 1..boxNumber)(
    forall(t in 0..maxtime)((
        boxes[box, t, 0] < m /\
        boxes[box, t, 0] >= 0 /\
        boxes[box, t, 1] >= 0 /\
        boxes[box, t, 1] < n)
        \/ (
        boxes[box, t, 0] = m /\
        boxes[box, t, 1] = n-1)
    )
  )
;

% Goal constraints ----------------------------------------------------------------------------------------------------------------------------------------------

% Final position
constraint
    forall(box in 1..boxNumber)(
        boxes[box, maxtime, 0] = m /\
        boxes[box, maxtime, 1] = n-1
    )
;

% Only one box can exit at a time
constraint
    not exists(b1 in 1..boxNumber, b2 in 1..boxNumber)(
        exists(t in 0..maxtime-1)(
            (boxes[b1, t, 0] != m \/ boxes[b1, t, 1] != n-1) /\ (boxes[b1, t+1, 0] = m /\ boxes[b1, t+1, 1] = n-1) /\
            (boxes[b2, t, 0] != m \/ boxes[b2, t, 1] != n-1) /\ (boxes[b2, t+1, 0] = m /\ boxes[b2, t+1, 1] = n-1) /\ b1 != b2
        )
    )
;


% Domain knowledge constraints, added to stop search early in case of trivially unsatisfiable instances ---------------------------
% Exit cannot be blocked
constraint
    not exists(drawer in 1..drawerNumber)(
        drawers[drawerNumber, 0] = m-2 /\
        drawers[drawerNumber, 1] = n-2
    )
;
% There cannot be a box covering the push position to the exit
constraint
    not exists(drawer in 1..drawerNumber)(
        drawers[drawerNumber, 0] = m-3 /\
        drawers[drawerNumber, 1] = n-2
    )
;

% We cannot have idle instants before reaching the goal
constraint
    not exists(t in 0..maxtime-2)(
        moves[t+1] != 0 /\ moves[t] = 0
    )
;

% Number of moves required to reach the goal
var int: moveNumber = count(t in 0..maxtime-1)(moves[t] != 0);

%solve satisfy;
solve minimize moveNumber;

output ["move(\(box), \(direction(t)), \(l), \(t)) " | t in 0..maxtime-1, box = moves[t], l = abs(boxes[moves[t], t+1, 0] - boxes[moves[t], t, 0] + boxes[moves[t], t+1, 1] - boxes[moves[t], t, 1]) where fix(moves[t]) != 0];


function string: direction(0..maxtime-1: t) = 
    if (fix(boxes[moves[t], t+1, 0] - boxes[moves[t], t, 0]) > 0)
    then
        "ea"
    elseif (fix(boxes[moves[t], t+1, 0] - boxes[moves[t], t, 0]) < 0)
    then
        "we"
    elseif (fix(boxes[moves[t], t+1, 1] - boxes[moves[t], t, 1]) > 0)
    then
        "no"
    else
        "so"
    endif;