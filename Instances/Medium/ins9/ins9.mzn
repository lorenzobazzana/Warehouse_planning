m=8;
n=8;
maxtime=10;
boxNumber = 3;
drawerNumber = 3;
constraint boxes[1, 0, 0] = 1 /\ boxes[1, 0, 1] = 4;
constraint boxes[2, 0, 0] = 2 /\ boxes[2, 0, 1] = 3;
constraint boxes[3, 0, 0] = 6 /\ boxes[3, 0, 1] = 1;
drawers = array2d(1..drawerNumber, 0..1, [|0,5|0,1|3,3|]);
