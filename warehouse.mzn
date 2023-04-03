int: m;
int: n;
int: maxtime;
int: boxNumber;
int: drawerNumber;
array[1..boxNumber, 0..maxtime, 1..2] of var int: boxes;
%array[1..m, 1..n, 1..maxtime] of var 0..2: cells;
array[1..drawerNumber, 1..2] of int: drawers;

array[1..maxtime] of var 0..boxNumber: moves;

boxNumber = 1;

constraint
  boxes[1, 0, 1] = 3 /\
  boxes[1, 0, 2] = 3;

% Inertia
constraint
  forall(box in 1..boxNumber)(
    forall(t in 1..maxtime)(
      moves[t] != box -> (boxes[box, t, 1] = boxes[box, t-1, 1] /\ boxes[box, t, 2] = boxes[box, t-1, 2])
    )
  )
 ;