m=8;
n=8;
maxtime=10;
boxNumber = 2;
drawerNumber = 3;
constraint boxes[1, 0, 0] = 1 /\ boxes[1, 0, 1] = 1;
constraint boxes[2, 0, 0] = 5 /\ boxes[2, 0, 1] = 7;
drawers = array2d(1..drawerNumber, 0..1, [|5,2|2,2|4,4|]);
