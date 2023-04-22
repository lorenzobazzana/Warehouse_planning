m=8;
n=8;
maxtime=10;
boxNumber = 3;
drawerNumber = 2;
constraint boxes[1, 0, 0] = 3 /\ boxes[1, 0, 1] = 5;
constraint boxes[2, 0, 0] = 3 /\ boxes[2, 0, 1] = 7;
constraint boxes[3, 0, 0] = 2 /\ boxes[3, 0, 1] = 2;
drawers = array2d(1..drawerNumber, 0..1, [|4,3|6,5|]);
