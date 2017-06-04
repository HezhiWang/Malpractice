/*first Concatenating similar datasets in different years*/
/*Concatenating all Part D event data set from 2006 to 2012*/
proc sql;
select catt(libname,'.',memname) 
into :alldata separated by ' ' 
from dictionary.tables
where libname = 'IN028516' and prxmatch('/^PDE.*/', memname) > 0;
quit;
%put The names of the files to concatenate are: &alldata;
data Merged_pardD_event;
set &alldata;
keep BENE_ID SRVC_DT PROD_SRVC_ID QTY_DSPNSD_NUM DAYS_SUPLY_NUM TOT_RX_CST_AMT
     PRSCRBR_ID PRSCRBR_ID_QLFYR_CD;
run;


**Get Part D claim files for provider from FL; 
proc sql;
        create table PDE_AMA(compress=yes) as
        select a.*,b.npi,
               YEAR(a.SRVC_DT) as Year, 
               MONTH(a.SRVC_DT) as Month, 
               b.sex as Provider_gender, 
               b.LicPrefState, 
               b.PrimarySpecialty, 
               b.MedTrainFlag, 
               b.MedSchoolYOG,
               b.USTrained, 
               b.YOB
        from Merged_pardD_event as a, DCH070SL.AMA_master as b
        where input(a.PRSCRBR_ID,20.) = b.npi
        and b.LicPrefState = 'FL'
        and a.PRSCRBR_ID_QLFYR_CD = '01';
run;
quit;

data DCH070SL.PDE_AMA; set PDE_AMA; run;
proc datasets library=work;
delete Merged_pardD_event PDE_AMA; 
run;quit;

/*Save unique Provider_ID from PDE_AMA file*/
proc sort data=DCH070SL.PDE_AMA out=DCH070SL.provider_key(keep=PRSCRBR_ID) nodupkey;
by PRSCRBR_ID;
run;


**Get Part B carrier claim files for provider from FL; 
proc sql;
select catt(libname,'.',memname)
into :alldata separated by ' '
from dictionary.tables
where libname = 'IN028516' and prxmatch('/^BCARCLMSJ.*/', memname) > 0;
quit;
data Merged_bcarclm_raw;
set &alldata;
keep BENE_ID CLM_FROM_DT CLM_PMT_AMT RFR_PHYSN_NPI
     NCH_CLM_PRVDR_PMT_AMT DOB_DT GNDR_CD BENE_RACE_CD;
run;

proc sql;
 create table DCH070SL.Merged_bcarclm as
 select *, Year(CLM_FROM_DT) as Year, Month(CLM_FROM_DT) as Month,
       Year(CLM_FROM_DT) - Year(DOB_DT) as Patient_age
 from Merged_bcarclm_raw
 where RFR_PHYSN_NPI in (select PRSCRBR_ID from DCH070SL.provider_key);
run;quit;

proc delete data=Merged_bcarclm_raw;run;quit;


/*Save unique Bene_ID from both PDE_AMA and Merged_bcarclm file,
  for those patients who went to see physicians in FL state*/
proc sort data=DCH070SL.PDE_AMA(keep=bene_id) nodupkey out=pde_ama_id;by bene_id;
run;
proc sort data=DCH070SL.Merged_bcarclm(keep=bene_id DOB_DT) out=bene_id_dob nodupkey;
by bene_id descending dob_dt;
run;
proc sort data=DCH070SL.Merged_bcarclm(keep=bene_id GNDR_CD) out=bene_id_sex nodupkey;
by bene_id descending GNDR_CD;
run;
proc sort data=DCH070SL.Merged_bcarclm(keep=bene_id BENE_RACE_CD) out=bene_id_race nodupkey;
by bene_id descending BENE_RACE_CD;
run;

data DCH070SL.bene_Id;
 merge pde_ama_id bene_id_dob bene_id_sex bene_id_race;
 by bene_id;
run;

/*Concatenating all Master Beneficiary Summary File AB Enrollment data set from 2006 to 2012*/
***Suppose dob, gender, race, and death information should be unique and no change over time;
%readintosas(/^MBSF_AB.*/, Merged_mbsf_ab_enrclm, BENE_ID bene_birth_dt BENE_RACE_CD BENE_SEX_IDENT_CD NDI_DEATH_DT);

/* add bene characteristics to patient unique dataset*/
data DCH070SL.Merged_mbsf_ab_enrclm;
set Merged_mbsf_ab_enrclm;
run;
proc sort data = DCH070SL.Merged_mbsf_ab_enrclm;by bene_Id descending NDI_DEATH_DT;run;
proc sort data = DCH070SL.Merged_mbsf_ab_enrclm out = DCH070SL.bene_id_demo nodupkey; by BENE_ID; run;



data bene_id;
set DCH070SL.bene_id;
dob_dt_char = put(dob_dt,date9.);
run;

data bene_id_demo;
set DCH070SL.bene_id_demo;
bene_birth_dt_char = put(bene_birth_dt,date9.);
run;

proc sql;
create table bene_key as  
select a.bene_id, coalescec(b.BENE_RACE_CD,a.BENE_RACE_CD) as BENE_RACE_CD, coalescec(b.bene_birth_dt_char,a.dob_dt_char) as DOB_dt,
       coalescec(b.BENE_SEX_IDENT_CD,a.gndr_cd) as BENE_SEX_IDENT_CD,b.NDI_DEATH_DT
from bene_id as a
     left join 
     bene_id_demo as b
on a.BENE_ID = b.BENE_ID;

/* 0 = Unknown 1 = White 2 = Black 3 = Other 4 = Asian 5 = Hispanic 6 = North American Native*/
  create table bene_key as
  select *,
  case when BENE_SEX_IDENT_CD = '1' then 1 else 0 end as Male,
  case when BENE_SEX_IDENT_CD = '2' then 1 else 0 end as Female,
  case when BENE_RACE_CD = '0' then 1 else 0 end as Race_Unknown,
  case when BENE_RACE_CD = '1' then 1 else 0 end as Race_White,
  case when BENE_RACE_CD = '2' then 1 else 0 end as Race_Black,
  case when BENE_RACE_CD = '3' then 1 else 0 end as Race_Other,
  case when BENE_RACE_CD = '4' then 1 else 0 end as Race_Asian,
  case when BENE_RACE_CD = '5' then 1 else 0 end as Race_Hispanic,
  case when BENE_RACE_CD = '6' then 1 else 0 end as Race_North_American_Native
  from bene_key;
  quit;run;


data DCH070SL.bene_key(drop = DOB_dt DOB_dt_date);
  set bene_key;
  format DOB_dt_date date9.;
  DOB_dt_date = input(DOB_dt, date9.);
  patient_birth_year = YEAR(DOB_dt_date);
run;

/* add patient demographic features to PDE_AMA */;
proc sql;
create table DCH070SL.PDE_AMA as
select a.*, b.*
from DCH070SL.PDE_AMA as a 
     left join 
     DCH070SL.bene_key as b 
on a.BENE_ID = b.BENE_ID; quit;run;

%macro readintosas(file,dat,keepvar);
%global alldata;
proc sql;
select catt(libname,'.',memname)
into :alldata separated by ' '
from dictionary.tables
where libname = 'IN028516' and prxmatch("&file", memname) > 0;
quit;
%put The names of the files to concatenate are: &alldata;
data &dat._raw;
set &alldata;
keep &keepvar;
run;
proc sql;
 create table &dat. as
 select *
 from &dat._raw
 where BENE_ID in (select BENE_ID from bene_id);  
quit;run;
proc datasets library=work;
delete &dat._raw;
run;quit;
%mend readintosas;
/*Concatenating all Part B Carrier Line items from 2006 to 2012*/
%readintosas(/^BCARLINEJ.*/, Merged_bcarline,
             BENE_ID PRF_PHYSN_NPI PRVDR_STATE_CD PRVDR_SPCLTY 
             LINE_CMS_TYPE_SRVC_CD LINE_PLACE_OF_SRVC_CD LINE_1ST_EXPNS_DT LINE_LAST_EXPNS_DT
             HCPCS_CD LINE_NCH_PMT_AMT LINE_PRVDR_PMT_AMT);
**Get Part B carrier line files for provider from FL; 

proc sql;
 create table DCH070SL.Merged_bcarcline as
 select *
 from Merged_bcarline
 where PRF_PHYSN_NPI in (select PRSCRBR_ID from DCH070SL.provider_key);
run;quit;
proc delete data=Merged_bcarline;run;quit;


/****Total number of Physician visit by each patient in each month_year among each provider;*/
data docvisit_outpt(drop=HCPCS_cd);
  set DCH070SL.Merged_bcarcline(keep=bene_id HCPCS_cd LINE_1ST_EXPNS_DT PRF_PHYSN_NPI);
year=year(LINE_1ST_EXPNS_DT);
month=month(LINE_1ST_EXPNS_DT);
if substr(HCPCS_cd,1,3) in ('992','993','994') and substr(HCPCS_cd,5,1) ne ' '
then docvisit=1;
if docvisit=1;
run;

proc sort data=docvisit_outpt nodup; by _all_;run;

proc sql;
 create table DCH070SL.num_phyvis as
 select PRF_PHYSN_NPI,bene_id,year,month,
  count(PRF_PHYSN_NPI) as num_phyvis
  from docvisit_outpt
  group by PRF_PHYSN_NPI,bene_id,year,month;
quit;run;
proc delete data=er_outpt;run;quit;

/*** ER visit-from outpatient;*/
data ER_outpt(drop=HCPCS_cd);
  set DCH070SL.Merged_bcarcline(keep=bene_id HCPCS_cd LINE_1ST_EXPNS_DT PRF_PHYSN_NPI);
year=year(LINE_1ST_EXPNS_DT);
month=month(LINE_1ST_EXPNS_DT);
if '99281'<=HCPCS_cd<='99285' then ER=1;
if ER=1;
run;
proc sort data=ER_outpt nodup; by _all_;run; 
proc sql;
 create table DCH070SL.er_vis as
 select PRF_PHYSN_NPI,bene_id,year,month,
  sum(er) as er_vis
  from er_outpt
  group by PRF_PHYSN_NPI,bene_id,year,month;
quit;run;
proc delete data=er_outpt;run;quit;

proc sql;
create table DCH070SL.PDE_AMA as
  select a.*, b.num_phyvis
  from DCH070SL.PDE_AMA as a left join DCH070SL.num_phyvis as b  
  on b.PRF_PHYSN_NPI = a.PRSCRBR_ID
    and a.YEAR = b.YEAR
    and a.Month = b.Month
    and a.bene_id = b.bene_id;
quit;run;

proc sql;
create table DCH070SL.PDE_AMA as
  select a.*, b.er_vis
  from DCH070SL.PDE_AMA as a left join DCH070SL.er_vis as b  
  on b.PRF_PHYSN_NPI = a.PRSCRBR_ID
    and a.YEAR = b.YEAR
    and a.Month = b.Month
    and a.bene_id = b.bene_id;
quit;run;   
      
/****Patient's total number of prescriptions by each month_year;
*NDC code in the following format: MMMMMDDDDPP followed by 8 spaces.
 The NDC is reported in an 11-digit format, which is divided into three sections. 
 The first five digits indicate the manufacturer or the labeler.
 The next four digits indicate the ingredient, strength, dosage form and route of administration.
 The last two digits indicate the packaging;  */  
data drug_cnt;
 set DCH070SL.PDE_AMA(keep = bene_id PRSCRBR_ID year month PROD_SRVC_ID SRVC_DT);
run;

data drug_cnt;
 set drug_cnt;
 ndc=substr(PROD_SRVC_ID,1,9);
run;
proc sql;
 create table DCH070SL.drug_cnt as
 select PRSCRBR_ID,year,
        count(distinct ndc) as drug_cnt_total
 from drug_cnt
 group by PRSCRBR_ID,year;
quit;run;
proc delete data=drug_cnt;run;quit;

proc sql;
  create table DCH070SL.PDE_AGG as
  select PRSCRBR_ID,YEAR, COUNT(BENE_ID) as Num_of_Patients_PDE, sum(Male) as Num_of_Male_PDE, sum(Female) as Num_of_Female_PDE, 
  Avg(QTY_DSPNSD_NUM) as Avg_Quantity_Dispensed_PDE, avg(DAYS_SUPLY_NUM) as Avg_Days_Supply_PDE, 
  avg(TOT_RX_CST_AMT) as Avg_Drug_Cost_PDE, avg(patient_birth_year) as Avg_patient_birth_year_PDE, sum(Race_Unknown) as Race_Unknown_PDE,
  sum(Race_White) as Race_White_PDE, sum(Race_Black) as Race_Black_PDE, sum(Race_Other) as Race_Other_PDE, 
  sum(Race_Asian) as Race_Asian_PDE,sum(Race_Hispanic) as Race_Hispanic_PDE, 
  sum(Race_North_American_Native) as Race_North_American_Native_PDE, COUNT(NDI_DEATH_DT) as NUM_OF_DEATH_PATIENT_PDE, avg(num_phyvis) as avg_num_phyvis_PDE, 
  avg(er_vis) as avg_er_vis_PDE
  from DCH070SL.PDE_AMA
  group by PRSCRBR_ID,Year
  order by PRSCRBR_ID,Year;
  quit;run;

proc sql;
create table DCH070SL.Provider as 
select a.PRSCRBR_ID, b.sex, b.PrimarySpecialty, b.MedTrainFlag, b.MedSchoolYOG, b.USTrained, b.YOB
from DCH070SL.provider_key as a left join DCH070SL.AMA_master as b
on input(a.PRSCRBR_ID,20.) = b.npi;
quit;run;

data DCH070SL.Provider(drop = MedSchoolYOG);
set DCH070SL.Provider;
MedSchool_YOG = input(MedSchoolYOG, 4.);
run;

proc sql;
  create table DCH070SL.PDE_AMA_AGG as
  select a.*, b.*
  from DCH070SL.PDE_AGG as a left join DCH070SL.Provider as b
  on a.PRSCRBR_ID = b.PRSCRBR_ID;
quit;run;


proc sql;
  create table DCH070SL.PDE_AMA_AGG as
  select a.*, b.*
  from DCH070SL.PDE_AMA_AGG as a inner join DCH070SL.drug_cnt as b
  on a.PRSCRBR_ID = b.PRSCRBR_ID and a.YEAR = b.YEAR;
  quit;run;

/*Concatenating all MedPAR data set from 2006 to 2012*/
%readintosas(/^MEDPAR.*/, Merged_Medparclm,bene_id bene_age_cnt bene_sex_cd bene_race_cd admsn_dt dschrg_dt bene_death_dt los_day_cnt mdcr_pmt_amt);

data DCH070SL.Merged_Medparclm; 
 set Merged_Medparclm;
 Year=YEAR(ADMSNDT);
 Month=MONTH(ADMSNDT); 
run;
proc delete data = Merged_Medparclm;run;

/*merge merpar with part b claim by bene_id, year, month*/
proc sql;
  create table DCH070SL.Merged_bcarclm as
  select a.*,b.*
  from DCH070SL.Merged_bcarclm as a
       left join 
       DCH070SL.Merged_Medparclm as b
       on a.BENE_ID = b.BENE_ID
       and a.Month = b.Month
       and a.Year = b.Year; 
quit;run;

/* add patient demographic features to partb */
proc sql;
create table DCH070SL.bcarclm as
select a.*, b.*
from DCH070SL.Merged_bcarclm as a 
     left join 
     DCH070SL.bene_key as b 
on a.BENE_ID = b.BENE_ID; 
quit;run;

proc sql;
create table DCH070SL.bcarclm as
  select a.*, b.num_phyvis
  from DCH070SL.bcarclm as a left join DCH070SL.num_phyvis as b  
  on b.PRF_PHYSN_NPI = a.RFR_PHYSN_NPI
    and a.YEAR = b.YEAR
    and a.Month = b.Month
    and a.bene_id = b.bene_id;
quit;run;

proc sql;
create table DCH070SL.bcarclm as
  select a.*, b.er_vis
  from DCH070SL.bcarclm as a left join DCH070SL.er_vis as b  
  on b.PRF_PHYSN_NPI = a.RFR_PHYSN_NPI
    and a.YEAR = b.YEAR
    and a.Month = b.Month
    and a.bene_id = b.bene_id;
quit;run; 

/* here we aggregate the patient information by providers in Partb-carrier */
proc sql;
  create table DCH070SL.Carrier_agg as
  select RFR_PHYSN_NPI as PRSCRBR_ID, YEAR, COUNT(BENE_ID) as Num_of_Patients_CLAIM, Avg(CLM_PMT_AMT) as Avg_PMT_AMT_CLAIM,  
     Avg(NCH_CLM_PRVDR_PMT_AMT) as Avg_PRVDR_PMT_AMT_CLAIM,
     sum(Male) as Num_of_Male_CLAIM, sum(Female) as Num_of_Female_CLAIM, avg(Patient_age) as Avg_PATIENT_Age_CLAIM, 
     sum(Race_Unknown) as Race_Unknown_CLAIM,
    sum(Race_White) as Race_White_CLAIM, sum(Race_Black) as Race_Black_CLAIM, sum(Race_Other) as Race_Other_CLAIM, 
    sum(Race_Asian) as Race_Asian_CLAIM, sum(Race_Hispanic) as Race_Hispanic_CLAIM, 
    sum(Race_North_American_Native) as Race_North_American_Native_CLAIM, COUNT(NDI_DEATH_DT) as NUM_OF_DEATH_PATIENT_CLAIM,
    avg(num_phyvis) as avg_num_phyvis_CLAIM, avg(er_vis) as avg_er_vis_CLAIM, avg(los_day_cnt) as avg_loscnt, avg(mdcr_pmt_amt) as avg_mdcr_pmt_amt
  from DCH070SL.bcarclm
  group by RFR_PHYSN_NPI, Year
  order by RFR_PHYSN_NPI, Year;
  quit;run;


proc sql;
create table DCH070SL.merge_pde_b_agg as
select a.*, b.*
from DCH070SL.PDE_AMA_AGG as a inner join DCH070SL.Carrier_agg as b
on a.PRSCRBR_ID = b.PRSCRBR_ID
and a.YEAR = b.YEAR;
quit;run;

/*Add variable Target to the Malpractice dataset*/
data DCH070SL.Malpractice;
  set DCH070SL.Malpractice;
  Target = 1;
run;

/*Merge the above merged file with Malpractice dataset*/
proc sql;
  create table DCH070SL.Merged_all as
  select a.*, b.*
  from DCH070SL.merge_pde_b_agg as a left join DCH070SL.Malpractice as b
  on input(a.PRSCRBR_ID,20.) = b.npi;
quit;run;

proc sql;
  update DCH070SL.Merged_all 
  set Target = 0 where Target = .;
quit;run;

data DCH070SL.Merged_all(drop = year_Medicare) ;
    set DCH070SL.Merged_all ;
    year_diff = abs(year_Malpractice - YEAR);
run;
proc sql;
  update DCH070SL.Merged_all 
  set Target = 0.6 ** year_diff
  where year_diff ^= . and year_diff < 5;
quit;run;

data DCH070SL.Merged_all ;
    set DCH070SL.Merged_all ;
    phy_exp = Year - MedSchool_YOG;
    phy_age = Year - YOB;
run;

proc export data = DCH070SL.Merged_all
outfile = '/sas/vrdc/users/dch070/files/_uploads/Merged_all_FL.csv'
dbms = csv
replace;
run;