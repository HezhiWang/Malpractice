data dtree;
input targ age sex$ job$;
datalines;
1 20 f a
0.1 25 m b
0.8 35 f b
0.4 28 m c
1 34 f c
0 20 f d
;
run;



proc hpsplit data=dtree maxdepth=2 maxbranch=2;
	target targ;
	input JOB sex / level=nom;
	input age  / level=int;
  	criterion entropy;
  	prune misc / N <= 3;
  	partition fraction(validate=0.2);
  	rules file='dtree-rules.txt';
  	score out=scored1;
run;