data Data1; 
  input disease n age;
  datalines;
0 14 25
0 20 35
0 19 45
7 18 55
6 12 65
17 17 75
;

ods graphics on;
proc logistic data=Data1 plots(only)=(roc(id=obs) effect);
  model disease/n=age;
run;
ods graphics off;