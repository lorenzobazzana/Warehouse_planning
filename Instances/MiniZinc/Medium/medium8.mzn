m=7;
n=7;
maxtime=10;
boxNumber = 2;
drawerNumber = 3;
constraint boxes[1, 0, 0] = 2 /\ boxes[1, 0, 1] = 6;
constraint boxes[2, 0, 0] = 2 /\ boxes[2, 0, 1] = 1;
drawers = array2d(1..drawerNumber, 0..1, [|3,3|3,0|3,5|]);
