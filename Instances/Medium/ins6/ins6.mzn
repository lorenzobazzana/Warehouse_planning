m=7;
n=7;
maxtime=10;
boxNumber = 1;
drawerNumber = 3;
constraint boxes[1, 0, 0] = 2 /\ boxes[1, 0, 1] = 3;
drawers = array2d(1..drawerNumber, 0..1, [|1,5|3,3|0,2|]);
