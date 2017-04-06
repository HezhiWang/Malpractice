data analysisData;
	drop i j;
	array x{5} x1-x5;
	do i=1 to 5000;
	/* Continuous predictors */
	do j=1 to 5;
	x{j} = ranuni(1);
	end;

	yTrue = 2 + x3 + 3*x2**2 - 8*x5 - 7*x1*x2;
	y = yTrue + 6*rannor(1);

	output analysisData;

	end;
run;



proc glmselect data=analysisData plots(stepaxis = normb) = all;
	model y = x1 x2 x3 x4 x5
		/ selection=lasso(stop=none choose = cvex); /*5-fold cross validation error*/
run;

		/* /selection=lasso(stop=none choose = validate) 
			partition fraction (validate = 0.3)    train/validation*/
