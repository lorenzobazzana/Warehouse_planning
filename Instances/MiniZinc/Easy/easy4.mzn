m=5;
n=6;
maxtime=10;
boxNumber = 2;
drawerNumber = 1;
constraint boxes[1, 0, 0] = 3 /\ boxes[1, 0, 1] = 5;
constraint boxes[2, 0, 0] = 4 /\ boxes[2, 0, 1] = 4;
drawers = array2d(1..drawerNumber, 0..1, [|2,3|]);
