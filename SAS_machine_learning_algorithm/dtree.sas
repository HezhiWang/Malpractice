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


/*split dataset to training set and testing set (7:3)*/
data temp;
set dtree;
n=ranuni(8);
proc sort data=temp;
  by n;
  data training testing;
   set temp nobs=nobs;
   if _n_<=.7*nobs then output training;
    else output testing;
   run;

/*Fiting the traing dataset to dataset training, and save the split rules as 'dtree-rules.txt' and save the model as 'hpspldtree-code.sas'*/

proc hpsplit data=training maxdepth=2 maxbranch=2;
	target targ;
	input JOB sex / level=nom;
	input age  / level=int;
  	criterion entropy;
  	prune misc / N <= 3;
  	partition fraction(validate=0.2);
  	rules file='dtree-rules.txt';
  	code file = 'hpspldtree-code.sas'
run;

/*Using the saved model 'hpspldtree-code.sas' to predict the testing set and analyze its performance.*/
data scored;
set testing;
	%include 'hpspldtree-code.sas';
run;