/*Merge merged Medicare with AMA master file by npi*/

/*First please upload AMA master file into SAS WORD Library, and name it as 'AMA_master'*/

/*This step will drop rows that 'PRSCRBR_ID_QLFYR_CD' != '01' from the Merged_Medicare dataset.*/

/*And change column 'PRSCRBR_ID' to name 'npi' in the dataset Medicare_delete_without_npi*/

DATA Medicare_delete_without_npi;
    SET Merged_Medicare(rename= (PRSCRBR_ID = npi));
    IF (PRSCRBR_ID_QLFYR_CD ^= '01') THEN DELETE;
RUN;

/*Then we will merge Medicare_delete_without_npi dataset with AMA_master dataset*/

proc sort data = AMA_master;
by npi;
proc sort data = Medicare_delete_without_npi;
by npi;

data Merged_Medicare_with_AMA;
	merge Medicare_delete_without_npi AMA_master;
	by npi;
run;
