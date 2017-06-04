/*Import dataset dtree.csv to WORK linrary and named it as DTREE*/

/*split dataset to training set and testing set (7:3)*/
data temp;
set DTREE;
n=ranuni(8);
proc sort data=temp;
  by n;
  data training testing;
   set temp nobs=nobs;
   if _n_<=.7*nobs then output training;
    else output testing;
   run;

data train;
set training(keep = JOB sex age targ);
run;

data test;
set testing(keep = JOB sex age targ);
run;

/*Fiting the traing dataset to dataset training, and save the split rules as 'dtree-rules.txt' and save the model as 'hpspldtree-code.sas'*/

proc hpsplit data=training maxdepth=200 maxbranch=;
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
