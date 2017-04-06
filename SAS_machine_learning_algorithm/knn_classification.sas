data knn;
input type x y z;
datalines;
1 2 5 7
1 3 6 8
0 8 10 15
0 9 20 28
0.5 90 98 70
;


title 'k-nn classification';

proc discrim data=knn;
   class type;
   var x y;
run;