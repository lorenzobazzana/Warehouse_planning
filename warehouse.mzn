include "Instances/Easy/ins6/ins6.mzn";
int: m;
int: n;
int: maxtime;
int: boxNumber;
int: drawerNumber;

array[1..boxNumber, 0..maxtime, 0..1] of var 0..max(m,n): boxes;
array[1..drawerNumber, 0..1] of 0..max(m,n): drawers;
array[0..maxtime-1] of var 0..boxNumber: moves;
    

predicate freePath(1..boxNumber: movedBox, var 0..max(m,n): start, var 0..max(m,n): end, 0..maxtime: time, 0..1: coord) = 
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

predicate freeCell(var 0..max(m,n): cellX, var 0..max(m,n): cellY, 0..maxtime: time) = 
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

predicate freeFromDrawers(var 0..max(m,n): cellX, var 0..max(m,n): cellY) = 
    not exists(drawer in 1..drawerNumber)(
        (drawers[drawer, 0] = cellX /\ drawers[drawer, 1] = cellY) \/
        (drawers[drawer, 0] = (cellX-1) /\ drawers[drawer, 1] = cellY) \/
        (drawers[drawer, 0] = cellX /\ drawers[drawer, 1] = (cellY-1)) \/
        (drawers[drawer, 0] = (cellX-1) /\ drawers[drawer, 1] = (cellY-1))
        )
;

function var int: sign(var int: x) = if x < 0 then -1 else 1 endif;

predicate moved(1..boxNumber: box, 1..maxtime: t, 0..1: coord) = boxes[box, t-1, coord] != boxes[box, t, coord];

predicate freePushPosition(1..boxNumber: box, 0..1: coord, 0..maxtime-1: t) = 
    if coord = 0
    then
        let {var 0..max(m,n): xPush = boxes[box, t, 0] + sign(boxes[box, t, 0] - boxes[box, t+1, 0]); var 0..max(m,n): yPush = boxes[box, t, 1]} in
        xPush != m /\ 
        freeCell(xPush, yPush, t)
    else
        let {var 0..max(m,n): xPush = boxes[box, t, 0]; var 0..max(m,n): yPush = boxes[box, t, 1] + sign(boxes[box, t, 1] - boxes[box, t+1, 1])} in
        freeCell(xPush, yPush, t)
    endif;

predicate precedes(1..boxNumber: b1, 1..boxNumber: b2, 0..1: coord, 0..maxtime: t) =  % b1 precede b2 nella direzione di spostamento
    let {0..1: otherCoord = (coord+1) mod 2} in
    (boxes[b1, t, otherCoord] = boxes[b2, t, otherCoord]) /\
    if sign(boxes[b1, t+1, coord] - boxes[b1, t, coord]) = 1
    then
        boxes[b2, t, coord] > boxes[b1, t, coord]
    else
        boxes[b2, t, coord] < boxes[b1, t, coord]
    endif;


constraint
    forall(t in 1..maxtime)(
        forall(box in 1..boxNumber)(
            moves[t-1] = box -> (moved(box, t, 0) \/ moved(box, t, 1))
        )
    )
;

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


predicate sameDirection(1..boxNumber: b1, 1..boxNumber: b2, 0..1: coord, 1..maxtime: t) = 
    sign(boxes[b1, t, coord] - boxes[b1, t-1, coord]) = sign(boxes[b2, t, coord] - boxes[b2, t-1, coord]);

predicate fullPath(var 0..max(m,n): start, var 0..max(m,n): end, 0..1: coord, var 0..max(m,n): fixedCoord, 1..maxtime: t) = 
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


% Non possono esserci due scatole nella stessa posizione
constraint
    forall(t in 0..maxtime)(
        forall(x in 0..m)(
            x != m -> not exists(b1 in 1..boxNumber, b2 in 1..boxNumber)(b1 != b2 /\ boxes[b1, t, 0] = x /\ boxes[b2, t, 0] = x /\ boxes[b1, t, 1] = boxes[b2, t, 1])
        )
  )
;

% Integrita' di ordine (non si possono scavalcare)
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

% posizione finale
constraint
    forall(box in 1..boxNumber)(
        boxes[box, maxtime, 0] = m /\
        boxes[box, maxtime, 1] = n-1
    )
;

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

constraint
    not exists(t in 0..maxtime-2)(
        moves[t+1] != 0 /\ moves[t] = 0
    )
;

var int: moveNumber = count(t in 0..maxtime-1)(moves[t] != 0);

%solve satisfy;
solve minimize moveNumber;

%output ["{\(box), \(t), (\(boxes[box, t, 0]), \(boxes[box, t, 1]))}, " | t in 0..maxtime, box in 1..boxNumber] ++ ["\n"] ++ ["\(moves[t]), " | t in 0..maxtime-1];

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