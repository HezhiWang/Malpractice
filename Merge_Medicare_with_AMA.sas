/*Merge merged Medicare with AMA master file by npi*/

/*First please upload AMA master file into SAS WORD Library, and name it as 'AMA_master'*/

/*This step will drop rows that 'PRSCRBR_ID_QLFYR_CD' != '01' from the Merged_Medicare dataset.*/

DATA Medicare_delete_without_npi;
    SET Merged_Medicare;
    IF (PRSCRBR_ID_QLFYR_CD ^= '01') THEN DELETE;
RUN;

/*Change column 'PRSCRBR_ID' to name 'npi' in the dataset Medicare_delete_without_npi*/
Set Medicare_delete_without_npi(rename= (PRSCRBR_ID = npi) );


/*Then we will merge Medicare_delete_without_npi dataset with AMA_master dataset*/
data Merged_Medicare_with_AMA;
	merge Medicare_delete_without_npi AMA_master;
		by npi;
run;
