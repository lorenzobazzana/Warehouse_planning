m=10;
n=4;
maxtime=15;
boxNumber = 2;
drawerNumber = 3;
constraint boxes[1, 0, 0] = 1 /\ boxes[1, 0, 1] = 2;
constraint boxes[2, 0, 0] = 2 /\ boxes[2, 0, 1] = 1;
constraint boxes[3, 0, 0] = 1 /\ boxes[3, 0, 1] = 1;
drawers = array2d(1..drawerNumber, 0..1, [|2,2|6,0|]);
