m=7;
n=8;
boxNumber = 3;
drawerNumber = 5;
constraint boxes[1, 0, 0] = 3 /\ boxes[1, 0, 1] = 5;
constraint boxes[2, 0, 0] = 3 /\ boxes[2, 0, 1] = 2;
constraint boxes[3, 0, 0] = 4 /\ boxes[3, 0, 1] = 2;
drawers = array2d(1..drawerNumber, 0..1, [['|', '2', ',', '3', '|', '0', ',', '2', '|', '1', ',', '5', '|', '5', ',', '3', '|', '4', ',', '0', '|']]);
