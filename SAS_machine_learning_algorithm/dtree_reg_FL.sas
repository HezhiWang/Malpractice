/*split dataset to training set and testing set (7:3)*/
data temp;
set DCH070SL.Merged_all;
n=ranuni(8);
proc sort data=temp;
  by n;
  data train test;
   set temp nobs=nobs;
   if _n_<=.7*nobs then output train;
    else output test;
   run;

PROC DELETE DATA=TEMP;RUN;

/*Fiting the traing dataset to dataset training, and save the split rules as 'dtree-rules.txt' and save the model as 'hpspldtree-code.sas'*/

ODS GRAPHICS ON;

%MACRO hpdtree(Val_leafsize = 2, Val_maxdepth = 10, Val_mincatsize = 1, Val_missing = SIMILARITY, index=1);
proc hpsplit data=train leafsize=&Val_leafsize maxdepth = &Val_maxdepth mincatsize=&Val_mincatsize missing = &Val_missing;
	target Target / level = int;

  input Num_of_Patients_CLAIM Avg_PMT_AMT_CLAIM Avg_PRVDR_PMT_AMT_CLAIM Num_of_Male_CLAIM Num_of_Female_CLAIM Avg_patient_birth_year_CLAIM Race_Unknown_CLAIM Race_White_CLAIM Race_Black_CLAIM Race_Other_CLAIM 
    Race_Asian_CLAIM Race_Hispanic_CLAIM Race_North_American_Native_CLAIM NUM_OF_DEATH_PATIENT_CLAIM avg_num_phyvis_CLAIM avg_er_vis_CLAIM avg_loscnt avg_mdcr_pmt_amt Num_of_Patients_PDE Num_of_Male_PDE Num_of_Female_PDE Avg_Quantity_Dispensed_PDE Avg_Days_Supply_PDE 
    Avg_Drug_Cost_PDE Avg_patient_birth_year_PDE Race_Unknown_PDE Race_White_PDE Race_Black_PDE Race_Other_PDE Race_Asian_PDE Race_Hispanic_PDE Race_North_American_Native_PDE NUM_OF_DEATH_PATIENT_PDE avg_num_phyvis_PDE
    avg_er_vis_PDE phy_exp phy_age / level = int;

  input sex PrimarySpecialty MedTrainFlag USTrained / level=nom;

  	criterion VARIANCE;
  	prune ASE / ASE >= 1.0;
  	partition fraction(validate=0.2);
  	rules file='/sas/vrdc/users/dch070/files/_uploads/dtree-rules.txt';
  	code file = '/sas/vrdc/users/dch070/files/_uploads/hpspldtree-code.sas';
run;

/*Using the saved model 'hpspldtree-code.sas' to predict the testing set and analyze its performance.*/
data scored_dtree&index;
set test;
	%include '/sas/vrdc/users/dch070/files/_uploads/hpspldtree-code.sas';
run;

%MEND hpdtree;

%hpdtree(Val_maxdepth = 20, index = 1);
/*%hpdtree(Val_maxdepth = 30, index = 2);
%hpdtree(Val_maxdepth = 50, index = 3);*/

ODS GRAPHICS OFF;