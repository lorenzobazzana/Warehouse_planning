m=6;
n=7;
maxtime=10;
boxNumber = 3;
drawerNumber = 1;
constraint boxes[1, 0, 0] = 2 /\ boxes[1, 0, 1] = 2;
constraint boxes[2, 0, 0] = 4 /\ boxes[2, 0, 1] = 4;
constraint boxes[3, 0, 0] = 5 /\ boxes[3, 0, 1] = 5;
drawers = array2d(1..drawerNumber, 0..1, [|4,0|]);
