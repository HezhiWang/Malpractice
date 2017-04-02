/**/
proc sort data = Malpractice;
by npi;
proc sort data = Merged_Medicare_with_AMA;
by npi;

/*
data Merged_all;
	merge Merged_Medicare_with_AMA Malpractice;
    by npi;

data ;
   set yourdata;
   array change _numeric_;
        do over change;
            if change=. then change=0;
        end;
 run ;
*/


proc sql;
	create table Merged_all as
	select Malpractice.* Merged_Medicare_with_AMA.*
	from Malpractice full outer join Merged_Medicare_with_AMA
	on Malpractice.npi = Merged_Medicare_with_AMA.npi
quit;

data Merged_all;
	set Merged_all;
	year_diff = 1;
	Target = 1;
	year_Medicare = SRVC_DT;
run;



data Merged_all;
	set Merged_all;
	year_diff = year_Medicare - year_Malpractice;
	Target = 
run;




