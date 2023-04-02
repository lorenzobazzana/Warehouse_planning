int: m;
int: n;
int: maxtime;
int: boxNumber;
int: drawerNumber;
array[1..boxNumber, 1..maxtime, 1..2] of var int: boxes;
array[1..m, 1..n, 1..maxtime] of var 0..2: cells;
array[1..drawerNumber, 1..2] of var int: drawers;