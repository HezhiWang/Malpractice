proc glmselect data=a plots(stepaxis = normb) = all;
	model target = x1 x2
		/selection=lasso(stop=none choose = cvex); /*5-fold cross validation error*/
run;

		/* /selection=lasso(stop=none choose = validate) 
			partition fraction (validate = 0.3)    train/validation*/