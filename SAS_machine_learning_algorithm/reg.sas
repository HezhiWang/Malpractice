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


ods graphics on;

proc glmselect data=train testdata=test
               seed=1 plots(stepAxis=number)=(criterionPanel ASEPlot);
   partition fraction(validate=0.3);

   class sex PrimarySpecialty;
   model Target = sex|PrimarySpecialty|Num_of_Patients_CLAIM|Avg_PMT_AMT_CLAIM|Avg_PRVDR_PMT_AMT_CLAIM|Num_of_Male_CLAIM|Num_of_Female_CLAIM|Avg_patient_birth_year_CLAIM|Race_Unknown_CLAIM|Race_White_CLAIM|Race_Black_CLAIM|Race_Other_CLAIM
   |Race_Asian_CLAIM|Race_Hispanic_CLAIM|Race_North_American_Native_CLAIM|NUM_OF_DEATH_PATIENT_CLAIM|avg_num_phyvis_CLAIM|avg_er_vis_CLAIM|avg_loscnt|avg_mdcr_pmt_amt|Num_of_Patients_PDE|Num_of_Male_PDE|Num_of_Female_PDE 
   |Avg_Quantity_Dispensed_PDE|Avg_Days_Supply_PDE|Avg_Drug_Cost_PDE|Avg_patient_birth_year_PDE|Race_Unknown_PDE|Race_White_PDE|Race_Black_PDE|Race_Other_PDE|Race_Asian_PDE|Race_Hispanic_PDE|Race_North_American_Native_PDE|NUM_OF_DEATH_PATIENT_PDE
  |avg_num_phyvis_PDE|avg_er_vis_PDE|phy_exp|phy_age @2
           / selection=stepwise(choose = validate
                                select = sl)
             hierarchy=single stb;
run;
ods graphics off;
