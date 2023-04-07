int: m;
int: n;
m=5;
n=5;

int: maxtime;
maxtime = 4;
int: boxNumber;
boxNumber = 2;
int: drawerNumber;
drawerNumber = 2;
array[1..boxNumber, 0..maxtime, 0..1] of var 0..max(m,n): boxes;
%array[1..m, 1..n, 1..maxtime] of var 0..2: cells;
array[1..drawerNumber, 0..1] of 0..max(m,n): drawers;
drawers = array2d(1..drawerNumber, 0..1, [|2, 2 | 0,0 |]);

array[0..maxtime] of var 0..boxNumber: moves;


constraint
  boxes[1, 0, 0] = 4 /\
  boxes[1, 0, 1] = 3;
  
constraint
  boxes[2, 0, 0] = 4 /\
  boxes[2, 0, 1] = 1;
    

predicate freePath(1..boxNumber: movedBox, var 0..max(m,n): start, var 0..max(m,n): end, 0..maxtime: time, 0..1: coord) = 
    if coord = 0
    then
        forall(pos in min(start, end)..max(start, end))(
            freeCell(movedBox, pos, boxes[movedBox, time, 1], time)
        )
    else
        forall(pos in min(start, end)..max(start, end))(
            freeCell(movedBox, boxes[movedBox, time, 0], pos, time)
        )
    endif;

predicate freeCell(1..boxNumber: movedBox, var 0..max(m,n): cellX, var 0..max(m,n): cellY, 0..maxtime: time) = 
    (cellX = m /\ cellY = n-1) \/ 
    (not exists(box in 1..boxNumber)(
        box != movedBox /\ 
        boxes[box, time, 0] = cellX /\ 
        boxes[box, time, 1] = cellY
        ) /\
    freeFromDrawers(cellX, cellY, time)
    )
;

predicate freeFromDrawers(var 0..max(m,n): cellX, var 0..max(m,n): cellY, 0..maxtime: time) = 
    not exists(drawer in 1..drawerNumber)(
        (drawers[drawer, 0] = cellX /\ drawers[drawer, 1] = cellY) \/
        (drawers[drawer, 0] = (cellX-1) /\ drawers[drawer, 1] = cellY) \/
        (drawers[drawer, 0] = cellX /\ drawers[drawer, 1] = (cellY-1)) \/
        (drawers[drawer, 0] = (cellX-1) /\ drawers[drawer, 1] = (cellY-1))
        )
;

function var int: sign(var int: x) = if x < 0 then -1 else 1 endif;


% Inertia
constraint
  forall(box in 1..boxNumber)(
    forall(t in 1..maxtime)(
      moves[t] != box -> (boxes[box, t, 0] = boxes[box, t-1, 0] /\ boxes[box, t, 1] = boxes[box, t-1, 1])
    )
  )
;
 
constraint
    forall(box in 1..boxNumber)(
        forall(t in 1..maxtime)(
            if(boxes[box, t, 0] != boxes[box, t-1, 0]) % se la X e' differente...
            then
                boxes[box, t, 1] = boxes[box, t-1, 1] /\% la Y deve essere la stessa (solo movimenti orizzontali)
                freePath(box, boxes[box, t-1, 0], boxes[box, t, 0], t-1, 0) /\% movimento scatola singola (controllo che in mezzo non ci sia nulla)
                freeCell(box, boxes[box, t-1, 0] + sign(boxes[box, t-1, 0] - boxes[box, t, 0]), boxes[box, t-1, 1], t-1) /\
                moves[t] = box
            elseif(boxes[box, t, 1] != boxes[box, t-1, 1]) % altrimenti se la Y e' differente...
            then
                boxes[box, t, 0]= boxes[box, t-1, 0] /\ % la X deve essere la stessa (solo movimenti verticali)
                freePath(box, boxes[box, t-1, 1], boxes[box, t, 1], t-1, 1) /\
                freeCell(box, boxes[box, t-1, 0], boxes[box, t-1, 1] + sign(boxes[box, t-1, 1] - boxes[box, t, 1]), t-1) /\
                moves[t] = box
            else
              true
            endif
    )
  )
;

solve satisfy;

% Non possono esserci due scatole nella stessa posizione
constraint
    forall(t in 0..maxtime)(
        forall(x in 0..m)(
            x != m -> not exists(b1 in 1..boxNumber, b2 in 1..boxNumber)(b1 != b2 /\ boxes[b1, t, 0] = x /\ boxes[b2, t, 0] = x /\ boxes[b1, t, 1] = boxes[b2, t, 1])
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
        \/ (% il problema e' qua
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

output ["{\(box), \(t), (\(boxes[box, t, 0]), \(boxes[box, t, 1]))}, " | t in 0..maxtime, box in 1..boxNumber] ++ ["\n"] ++ ["\(moves[t]), " | t in 0..maxtime]


% moved (i, x, y) -> (i, x', y):
%   freepath(x,y, x",y) /\ dist(x', x") = count(boxes in x..x") /\ free(pushposition) /\ forall(b2 in x..x")
% forse funziona anche per mosse multiple

% box in x..x": xNew = L-M+1+K 
% L = |x - x'|
% M = |box[x] -x|
% K = count(x..box[x])  