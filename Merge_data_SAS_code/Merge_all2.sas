DATA Medicare_delete_without_npi;
    SET SASUSER.Merged_Medicare(rename= (PRSCRBR_ID = npi));
    IF (PRSCRBR_ID_QLFYR_CD ^= '01') THEN DELETE;
RUN;

proc DELETE data = Merged_Medicare;run;

/*Then we will merge Medicare_delete_without_npi dataset with AMA_master dataset*/

/*inner join Medicare with AMA master by npi*/

proc sql;
        create table Merged_Medicare_with_AMA as
        select Medicare_delete_without_npi.*, SASUSER.AMA_master.*
        from Medicare_delete_without_npi inner join SASUSER.AMA_master
        on Medicare_delete_without_npi.npi = SASUSER.AMA_master.npi;
quit;

proc DELETE data = Medicare_delete_without_npi;run;

/*Add variable Target to the Malpractice dataset*/
data Malpractice;
        set SASUSER.Malpractice;
        Target = 1;
run;


/*Merge the above merged file with Malpractice dataset*/
proc sql;
        create table Merged_all as
        select Merged_Medicare_with_AMA.*, Malpractice.*
        from Merged_Medicare_with_AMA left join Malpractice
        on Malpractice.npi = Merged_Medicare_with_AMA.npi;
quit;

proc DELETE data = Merged_Medicare_with_AMA;run;

proc sql;
        update Merged_all 
	    set Target = 0
        where Target is NULL;
quit;

data Merged_all;
	set Merged_all;
	year_diff = 1;
	Target = 1;
    	year_Medicare = YEAR(SRVC_DT);
run;

data Merged_all;
	set Merged_all;
	year_diff = year_Medicare - year_Malpractice;
run;

proc sql;
        update Merged_all 
        set Target = 0.6 ** year_diff
        where year_diff < 5;
quit;

data SASUSER.Merged_all;
    set Merged_all;
run;

/*Get all physicians in FL*/
proc sql;
        create table physicians_FL as
        select Merged_all.*
        from Merged_all
        where (Target = 1 or (Target = 0 and MailState = 'FL'));
quit;

data SASUSER.physicians_FL;
    set physicians_FL;
run;

proc export data = SASUSER.Merged_all
outfile = '/Files/dua_028516/Merged_all.csv'
dbms = csv
replace;
run;

proc export data = SASUSER.physicians_FL
outfile = '/Files/dua_028516/physicians_FL.csv'
dbms = csv
replace;
run;
