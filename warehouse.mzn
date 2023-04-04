int: m;
int: n;
m=5;
n=5;

int: maxtime;
maxtime = 2;
int: boxNumber;
boxNumber = 1;%2;
int: drawerNumber;
drawerNumber = 0;
array[1..boxNumber, 0..maxtime, 1..2] of var int: boxes;
%array[1..m, 1..n, 1..maxtime] of var 0..2: cells;
array[1..drawerNumber, 1..2] of int: drawers;
drawers = [];

array[0..maxtime] of var 0..boxNumber: moves;


constraint
  boxes[1, 0, 1] = 3 /\
  boxes[1, 0, 2] = 3;
  
%constraint
%  boxes[2, 0, 1] = 3 /\
%  boxes[2, 0, 2] = 2;
    

% Inertia
constraint
  forall(box in 1..boxNumber)(
    forall(t in 1..maxtime)(
      moves[t] != box -> (boxes[box, t, 1] = boxes[box, t-1, 1] /\ boxes[box, t, 2] = boxes[box, t-1, 2])
    )
  )
 ;
 
constraint
    forall(box in 1..boxNumber)(
        forall(t in 1..maxtime)(
            if(boxes[box, t, 1] != boxes[box, t-1, 1]) % se la X e' differente...
            then
                boxes[box, t, 2] = boxes[box, t-1, 2] /\% la Y deve essere la stessa (solo movimenti orizzontali)
                not exists(b2 in 1..boxNumber)(b2 != box /\ boxes[b2, t-1, 2] = boxes[box, t-1, 2] /\ boxes[b2, t-1, 1] > boxes[box, t-1, 1] /\ boxes[b2, t-1, 1] <= boxes[box, t, 1]) /\ % movimento scatola singola (controllo che in mezzo non ci sia nulla)
                moves[t] = box
            elseif(boxes[box, t, 2] != boxes[box, t-1, 2]) % alrtimenti se la Y e' differente...
            then
                boxes[box, t, 1] = boxes[box, t-1, 1] /\ % la X deve essere la stessa (solo movimenti verticali)
                not exists(b2 in 1..boxNumber)(b2 != box /\ boxes[b2, t-1, 1] = boxes[box, t-1, 1] /\ boxes[b2, t-1, 2] > boxes[box, t-1, 2] /\ boxes[b2, t-1, 2] <= boxes[box, t, 2]) /\
                moves[t] = box
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
            x != m -> not exists(b1 in 1..boxNumber, b2 in 1..boxNumber)(b1 != b2 /\ boxes[b1, t, 1] = x /\ boxes[b2, t, 1] = x /\ boxes[b1, t, 2] = boxes[b2, t, 2])
        )
  )
;

constraint
  forall(box in 1..boxNumber)(
    forall(t in 0..maxtime)((
        boxes[box, t, 1] < m /\
        boxes[box, t, 1] >= 0 /\
        boxes[box, t, 2] >= 0 /\
        boxes[box, t, 2] < n)
        %\/ (
        %boxes[box, t, 1] == m /\
        %boxes[box, t, 2] == n-1)
    )
  )
;

% posizione finale
constraint
    forall(box in 1..boxNumber)(
        boxes[box, maxtime, 1] = m-1 /\
        boxes[box, maxtime, 2] = n-1
    )
;