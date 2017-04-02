/*This code implement random forest in SAS*/

/*This part create a MARCO to */
%MACRO hpforest(Var_maxtrees = 500, Var_vars_to_try = 4, Var_seed = 600, Var_trainfraction = 0.6, Var_maxdepth = 50, Var_leafsize = 6, Var_alpha = 0.1, num2);

proc hpforest data = banana_train 
	maxtrees = &Var_maxtrees vars_to_try = &Var_vars_to_try
	seed = &Var_seed trainfraction = &Var_trainfraction 
	maxdepth = &Var_maxdepth leafsize = &Var_leafsize alpha = &Var_alpha;

		/*This part states that the target variable name and type, and each input variable name and type in the datafile Var_data*/

		target Target/ level=interval;
		input input1 input2/ level=interval;
    ods output fitstatistics = fitstats&num2;

    save file = 'FilePath\model_fit.bin';
run;
%MEND hpforest;

%hpforest(Var_vars_to_try = 2, num2 = 1);
%hpforest(Var_vars_to_try = 3, num2 = 2);
%hpforest(Var_vars_to_try = 4, num2 = 3);

/*This part uses to score new data*/

/*proc hp4score data = samp;
	id target;
	score file = 'FilePath\model_fit.bin'
	out = scored;
run;*/


proc sql;
create table ASE_groups as
           select x.ntrees ,
           x.predoob as ASE2vars_to_try,
           y.predoob as ASE3vars_to_try,
           z.predoob as ASE4vars_to_try
           from fitstats1 x, fitstats2 y, fitstats3 z
           where x.ntrees = y.ntrees
           and x.ntrees =  z.ntrees
           and y.ntrees = z.ntrees;
run;

proc transpose data= ASE_groups out=ASE_groups1;
	var ASE2vars_to_try ASE3vars_to_try ASE4vars_to_try;
run;

data ASE_groups2;
	set ASE_groups1;
	array RF(1:500) col1- col500;
 	do NTREES = 1 to 500;
 		ASE = RF(NTREES);
 	output;
 	end;
 	drop col1-col500 _LABEL_;
run;

proc sgplot data=ASE_groups2;
    series x=NTREES y=ASE/ group = _name_ ;
    LABEL ASE = "Average Square Error"
    NTREES = "Number of Trees"
    _name_ = "Variables to Try Group";
run;












