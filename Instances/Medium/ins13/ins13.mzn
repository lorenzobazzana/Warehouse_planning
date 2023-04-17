m=7;
n=7;
maxtime=10;
boxNumber = 3;
drawerNumber = 2;
constraint boxes[1, 0, 0] = 1 /\ boxes[1, 0, 1] = 1;
constraint boxes[2, 0, 0] = 4 /\ boxes[2, 0, 1] = 3;
constraint boxes[3, 0, 0] = 6 /\ boxes[3, 0, 1] = 3;
drawers = array2d(1..drawerNumber, 0..1, [|1,4|1,2|]);
