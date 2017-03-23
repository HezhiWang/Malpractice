/*first Concatenating similar datasets in different years*/

/*Concatenating all Part D event data set from 2006 to 2012*/
proc sql;
select catt(libname,'.',memname) 
into :alldata separated by ' ' 
from dictionary.tables
where libname = 'IN028516' and prxmatch('/^pde.*/', memname);
quit;

%put The names of the files to concatenate are: &alldata;


data Merged_pardD_event;
set &alldata;
run;

/*Concatenating all Part D event data set from 2006 to 2012*/
/*
proc sql;
select catt(libname,'.',memname)
into :alldata separated by ' '
from dictionary.tables
where libname = 'IN028516' and memname = 'pde*';
quit;

%put The names of the files to concatenate are: &alldata;


data Merged_pardD_event;
set &alldata;
run;*/

/*Merge add Merged dataset*/

proc sql;
select catt(libname,'.',memname)
into :alldata separated by ' '
from dictionary.tables
where libname = 'WORK' and prxmatch('/^Merged.*/', memname);
quit;

%put The names of the files to concatenate are: &alldata;

data Merged_Medicare;
	merge &alldata;
		by BENE_ID;
run;





