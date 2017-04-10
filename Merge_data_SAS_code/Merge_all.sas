/*first Concatenating similar datasets in different years*/

/*Concatenating all Part D event data set from 2006 to 2012*/
proc sql;
select catt(libname,'.',memname) 
into :alldata separated by ' ' 
from dictionary.tables
where libname = 'IN028516' and prxmatch('/^pde.*/', memname) > 0;
quit;

%put The names of the files to concatenate are: &alldata;


data Merged_pardD_event;
set &alldata;
run;

/*Concatenating all Part B Carrier Base Claim data set from 2006 to 2012*/
proc sql;
select catt(libname,'.',memname)
into :alldata separated by ' '
from dictionary.tables
where libname = 'IN028516' and prxmatch('/^bcarclmsj.*/', memname) > 0;
quit;

%put The names of the files to concatenate are: &alldata;


data Merged_part_B_carrier_raw;
set &alldata;
run;

data Merged_part_B_carrier;
set Merged_part_B_carrier_raw(keep = BENE_ID CLM_FROM_DT CLM_THRU_DT CLM_PMT_AMT RFR_PHYSN_UPIN RFR_PHYSN_NPI NCH_CLM_PRVDR_PMT_AMT NCH_CLM_BENE_PMT_AMT CARR_CLM_RFRNG_PIN_NUM RFR_PHYSN_UPIN RFR_PHYSN_NPI DOB_DT GNDR_CD BENE_RACE_CD BENE_CNTY_CD BENE_STATE_CD);
run;

/*Concatenating all Home Health Assessment data set from 2006 to 2012*/

/*Concatenating all Home Health Claims Base Claim data set from 2006 to 2012*/
proc sql;
select catt(libname,'.',memname)
into :alldata separated by ' '
from dictionary.tables
where libname = 'IN028516' and prxmatch('/^hhaclmsj.*/', memname) > 0;
quit;

%put The names of the files to concatenate are: &alldata;


data Merged_Home_Health_Claims_Base_Claim_raw;
set &alldata;
run;

data Merged_Home_Health_Claims_Base_Claim;
set Merged_Home_Health_Claims_Base_Claim_raw(keep = BENE_ID CLM_FROM_DT CLM_THRU_DT AT_PHYSN_UPIN AT_PHYSN_NPI OP_PHYSN_UPIN OP_PHYSN_NPI OT_PHYSN_UPIN OT_PHYSN_NPI CLM_TOT_CHRG_AMT CLM_ADMSN_DT CLM_IP_ADMSN_TYPE_CD ADMTG_DGNS_CD PRNCPAL_DGNS_CD FST_DGNS_E_CD DOB_DT GNDR_CD BENE_RACE_CD BENE_CNTY_CD BENE_STATE_CD);
run;

/*Concatenating all Master Beneficiary Summary File AB Enrollment data set from 2006 to 2012*/
proc sql;
select catt(libname,'.',memname)
into :alldata separated by ' '
from dictionary.tables
where libname = 'IN028516' and prxmatch('/^mbsf_ab.*/', memname) > 0;
quit;

%put The names of the files to concatenate are: &alldata;


data Merged_Master_Beneficiary_Summary_File_AB_Enrollment_raw;
set &alldata; 
run;

data Merged_Master_Beneficiary_Summary_File_AB_Enrollment; 
set Merged_Master_Beneficiary_Summary_File_AB_Enrollment_raw(keep = BENE_ID STATE_CODE BENE_COUNTY_CD BENE_AGE_AT_END_REF_YR BENE_VALID_DEATH_DT_SW NDI_DEATH_DT BENE_SEX_IDENT_CD BENE_RACE_CD);
run;

/*Concatenating all Master Beneficiary Summary File Cost and Use data set from 2006 to 2012, we keep all columns as features*/

proc sql;
select catt(libname,'.',memname)
into :alldata separated by ' '
from dictionary.tables
where libname = 'IN028516' and prxmatch('/^mbsf_cu.*/', memname) > 0;
quit;

%put The names of the files to concatenate are: &alldata;


data Merged_Master_Beneficiary_Summary_File_Cost_and_Use;
set &alldata;
run;

/*Concatenating all Master Beneficiary Summary File NDI data set from 2006 to 2008*/
proc sql;
select catt(libname,'.',memname)
into :alldata separated by ' '
from dictionary.tables
where libname = 'IN028516' and prxmatch('/^mbsf_ndi.*/', memname) > 0;
quit;

%put The names of the files to concatenate are: &alldata;


data Merged_Master_Beneficiary_Summary_File_NDI_raw;
set &alldata;
run;

data Merged_Master_Beneficiary_Summary_File_NDI;
set Merged_Master_Beneficiary_Summary_File_NDI_raw(keep = ICD_CODE ICD_TITLE ICD_CODE_358 ICD_CODE_113);
run;

/*Concatenating all MedPAR data set from 2006 to 2012*/
proc sql;
select catt(libname,'.',memname)
into :alldata separated by ' '
from dictionary.tables
where libname = 'IN028516' and prxmatch('/^medpar.*/', memname) > 0;
quit;

%put The names of the files to concatenate are: &alldata;


data Merged_Medpar_raw;
set &alldata;
run;

data Merged_Medpar;
set Merged_Medpar_raw(keep = AGE_CNT SEX RACE MS_CD STATE_CD CNTY_CD GHOPDCD PPS_IND SSLSSNF FACLMCNT LOSCNT OUTLRDAY UTIL_DAY COIN_DAY LRD_USE COIN_AMT DED_AMT BLDDEDAM PRPAYAMT OUTLRAMT DISP_SHR IME_AMT DRGPRICE PASSTHRU PPS_CPTL IP_LOW_VOL_PYMT_AMT TOTCHRG CVRCHRG PMT_AMT ACMDTNS DPRTMNTL PRVTDAY SPRVTDAY WARDDAY ICARECNT CRNRYDAY PRVTAMT SPRVTAMT WARDAMT ICAREAMT CRNRYAMT OTHRAMT PHRMCAMT SUPLYAMT DME_AMT UDME_AMT PHYTHAMT OCPTLAMT SPCH_AMT INHLTAMT BLOODAMT BLDADMIN OROOMAMT LTHTRPSY CRDLGY ANSTHSA LAB_AMT RDLGYAMT MRI_AMT OPSRVC ER_AMT AMBLNC PROFFEES ORGNAMT ESRDSETG CLNC_AMT ICUINDCD CRNRY_CD PHRMCYCD TRNSPLNT ONCLGYSW DGNSTCSW THRPTCSW NUCLR_SW CTSCANSW IMGNG_SW OPSRVCCD ORGNCD DGNSCNT DGNSCD{x} PRCDRSW PRCDRCNT PRCDTCNT PRCDRCD BLDFRNSH DSTNTNCD ESRD_CD TYPE_ADM CARE_IMPRVMT_MODEL_{x}_CD INFRMTL_ENCTR_IND_SW PROD_RPLCMT_LIFECYC_SW CRED_RCVD_RPLCD_DVC_SW NEW_TCHNLGY_ADD_ON_AMT BASE_OPRTG_DRG_AMT OPRTG_HSP_AMT MDCL_SRGCL_GNRL_AMT TAKE_HOME_AMT INVSTGTNL_DVC_AMT RDLGY_ONCOLOGY_AMT
);
run;




/*Merge all part of merged Medicare dataset using Merged_pardD_event dataset left join others*/

proc sql;
        create table Merged_Medicare_1 as
        select Merged_pardD_event.*, Merged_part_B_carrier.*
        from Merged_pardD_event left join Merged_part_B_carrier
        on Merged_pardD_event.BENE_ID = Merged_part_B_carrier.BENE_ID;
quit;

proc sql;
        create table Merged_Medicare_2 as
        select Merged_Medicare_1.*, Merged_Home_Health_Claims_Base_Claim.*
        from Merged_Medicare_1 left join Merged_Home_Health_Claims_Base_Claim
        on Merged_Medicare_1.BENE_ID = Merged_Home_Health_Claims_Base_Claim.BENE_ID;
quit;

proc sql;
        create table Merged_Medicare_3 as
        select Merged_Medicare_2.*, Merged_Master_Beneficiary_Summary_File_AB_Enrollment.*
        from Merged_Medicare_2 left join Merged_Master_Beneficiary_Summary_File_AB_Enrollment
        on Merged_Medicare_2.BENE_ID = Merged_Master_Beneficiary_Summary_File_AB_Enrollment.BENE_ID;
quit;

proc sql;
        create table Merged_Medicare_4 as
        select Merged_Medicare_3.*, Merged_Master_Beneficiary_Summary_File_Cost_and_Use.*
        from Merged_Medicare_3 left join Merged_Master_Beneficiary_Summary_File_Cost_and_Use
        on Merged_Medicare_3.BENE_ID = Merged_Master_Beneficiary_Summary_File_Cost_and_Use.BENE_ID;
quit;

proc sql;
        create table Merged_Medicare_5 as
        select Merged_Medicare_4.*, Merged_Master_Beneficiary_Summary_File_NDI.*
        from Merged_Medicare_4 left join Merged_Master_Beneficiary_Summary_File_NDI
        on Merged_Medicare_4.BENE_ID = Merged_Master_Beneficiary_Summary_File_NDI.BENE_ID;
quit;

proc sql;
        create table Merged_Medicare as
        select Merged_Medicare_5.*, Merged_Medpar.*
        from Merged_Medicare_5 left join Merged_Medpar
        on Merged_Medicare_5.BENE_ID = Merged_Medpar.BENE_ID;
quit;

/*Save merged data set as csv file*/
proc export data=WORK.Merged_Medicare
    outfile='Merged_Medicare.csv'
    dbms=csv
    replace;
run;



/*Merge merged Medicare with AMA master file by npi*/

/*First please upload AMA master file into SAS WORD Library, and name it as 'AMA_master'*/

/*This step will drop rows that 'PRSCRBR_ID_QLFYR_CD' != '01' from the Merged_Medicare dataset.*/

/*And change column 'PRSCRBR_ID' to name 'npi' in the dataset Medicare_delete_without_npi*/

DATA Medicare_delete_without_npi;
    SET Merged_Medicare(rename= (PRSCRBR_ID = npi));
    IF (PRSCRBR_ID_QLFYR_CD ^= '01') THEN DELETE;
RUN;

/*Then we will merge Medicare_delete_without_npi dataset with AMA_master dataset*/

/*inner join Medicare with AMA master by npi*/

proc sql;
        create table Merged_Medicare_with_AMA as
        select Medicare_delete_without_npi.*, AMA_master.*
        from Medicare_delete_without_npi inner join AMA_master
        on Malpractice.npi = Merged_Medicare_with_AMA.npi;
quit;

/*Add variable Target to the Malpractice dataset*/
data Malpractice;
        set Malpractice;
        Target = 1;
run;


/*Merge the above merged file with Malpractice dataset*/
proc sql;
        create table Merged_all as
        select Merged_Medicare_with_AMA.*, Malpractice.*
        from Merged_Medicare_with_AMA left join Malpractice
        on Malpractice.npi = Merged_Medicare_with_AMA.npi;
quit;

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

/*Get all physicians in FL*/
proc sql;
        create table physicians_FL as
        select Merged_all.*
        from Merged_all
        where (Target = 1 or (Target = 0 and MailState = 'FL'));
quit;
