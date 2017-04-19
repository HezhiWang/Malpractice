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
run;

/*Concatenating all Part B Carrier Base Claim data set from 2006 to 2012*/
proc sql;
select catt(libname,'.',memname)
into :alldata separated by ' '
from dictionary.tables
where libname = 'IN028516' and prxmatch('/^BCARCLMSJ.*/', memname) > 0;
quit;

%put The names of the files to concatenate are: &alldata;


data Merged_part_B_carrier_raw;
set &alldata;
run;

data Merged_part_B_carrier;
set Merged_part_B_carrier_raw(keep = BENE_ID CLM_FROM_DT CLM_THRU_DT CLM_PMT_AMT RFR_PHYSN_UPIN RFR_PHYSN_NPI NCH_CLM_PRVDR_PMT_AMT NCH_CLM_BENE_PMT_AMT CARR_CLM_RFRNG_PIN_NUM RFR_PHYSN_UPIN RFR_PHYSN_NPI DOB_DT GNDR_CD BENE_RACE_CD BENE_CNTY_CD BENE_STATE_CD);
run;

proc DELETE data = Merged_part_B_carrier_raw;run;


proc sql;
        create table Merged_Medicare_1 as
        select Merged_pardD_event.*, Merged_part_B_carrier.*
        from Merged_pardD_event left join Merged_part_B_carrier
        on Merged_pardD_event.BENE_ID = Merged_part_B_carrier.BENE_ID;
quit;

proc DELETE data = Merged_pardD_event;run;
proc DELETE data = Merged_part_B_carrier;run;
/*Concatenating all Home Health Assessment data set from 2006 to 2012*/

/*Concatenating all Home Health Claims Base Claim data set from 2006 to 2012*/
proc sql;
select catt(libname,'.',memname)
into :alldata separated by ' '
from dictionary.tables
where libname = 'IN028516' and prxmatch('/^HHACLMSJ.*/', memname) > 0;
quit;

%put The names of the files to concatenate are: &alldata;


data Merged_Home_Base_Claim_raw;
set &alldata;
run;

data Merged_Home_Base_Claim;
set Merged_Home_Base_Claim_raw(keep = BENE_ID CLM_FROM_DT CLM_THRU_DT AT_PHYSN_UPIN AT_PHYSN_NPI OP_PHYSN_UPIN OP_PHYSN_NPI OT_PHYSN_UPIN OT_PHYSN_NPI CLM_TOT_CHRG_AMT CLM_ADMSN_DT CLM_IP_ADMSN_TYPE_CD ADMTG_DGNS_CD PRNCPAL_DGNS_CD FST_DGNS_E_CD DOB_DT GNDR_CD BENE_RACE_CD BENE_CNTY_CD BENE_STATE_CD);
run;

proc DELETE data = Merged_Home_Base_Claim_raw;run;

proc sql;
        create table Merged_Medicare_2 as
        select Merged_Medicare_1.*, Merged_Home_Base_Claim.*
        from Merged_Medicare_1 left join Merged_Home_Base_Claim
        on Merged_Medicare_1.BENE_ID = Merged_Home_Base_Claim.BENE_ID;
quit;

proc DELETE data = Merged_Home_Base_Claim;run;
proc DELETE data = Merged_Medicare_1;run;

/*Concatenating all Master Beneficiary Summary File AB Enrollment data set from 2006 to 2012*/
proc sql;
select catt(libname,'.',memname)
into :alldata separated by ' '
from dictionary.tables
where libname = 'IN028516' and prxmatch('/^MBSF_AB.*/', memname) > 0;
quit;

%put The names of the files to concatenate are: &alldata;


data Merged_Beneficiary_AB_raw;
set &alldata; 
run;

data Merged_Beneficiary_AB; 
set Merged_Beneficiary_AB_raw(keep = BENE_ID STATE_CODE BENE_COUNTY_CD BENE_AGE_AT_END_REF_YR BENE_VALID_DEATH_DT_SW NDI_DEATH_DT BENE_SEX_IDENT_CD BENE_RACE_CD);
run;

proc DELETE data = Merged_Beneficiary_AB_raw;run;

proc sql;
        create table Merged_Medicare_3 as
        select Merged_Medicare_2.*, Merged_Beneficiary_AB.*
        from Merged_Medicare_2 left join Merged_Beneficiary_AB
        on Merged_Medicare_2.BENE_ID = Merged_Beneficiary_AB.BENE_ID;
quit;

proc DELETE data = Merged_Beneficiary_AB;run;
proc DELETE data = Merged_Medicare_2;run;

/*Concatenating all Master Beneficiary Summary File Cost and Use data set from 2006 to 2012, we keep all columns as features*/

proc sql;
select catt(libname,'.',memname)
into :alldata separated by ' '
from dictionary.tables
where libname = 'IN028516' and prxmatch('/^MBSF_CU.*/', memname) > 0;
quit;

%put The names of the files to concatenate are: &alldata;


data Merged_Beneficiary_Cost_Use;
set &alldata;
run;

proc sql;
        create table Merged_Medicare_4 as
        select Merged_Medicare_3.*, Merged_Beneficiary_Cost_Use.*
        from Merged_Medicare_3 left join Merged_Beneficiary_Cost_Use
        on Merged_Medicare_3.BENE_ID = Merged_Beneficiary_Cost_Use.BENE_ID;
quit;

proc DELETE data = Merged_Medicare_3;run;
proc DELETE data = Merged_Beneficiary_Cost_Use;run;

/*Concatenating all MedPAR data set from 2006 to 2012*/
proc sql;
select catt(libname,'.',memname)
into :alldata separated by ' '
from dictionary.tables
where libname = 'IN028516' and prxmatch('/^MEDPAR.*/', memname) > 0;
quit;

%put The names of the files to concatenate are: &alldata;


data Merged_Medpar_raw;
set &alldata;
run;

data Merged_Medpar;
set Merged_Medpar_raw(keep = AGE_CNT SEX RACE MS_CD STATE_CD CNTY_CD GHOPDCD PPS_IND SSLSSNF FACLMCNT LOSCNT OUTLRDAY UTIL_DAY COIN_DAY LRD_USE COIN_AMT DED_AMT BLDDEDAM PRPAYAMT OUTLRAMT DISP_SHR IME_AMT DRGPRICE PASSTHRU PPS_CPTL IP_LOW_VOL_PYMT_AMT TOTCHRG CVRCHRG PMT_AMT ACMDTNS DPRTMNTL PRVTDAY SPRVTDAY WARDDAY ICARECNT CRNRYDAY PRVTAMT SPRVTAMT WARDAMT ICAREAMT CRNRYAMT OTHRAMT PHRMCAMT SUPLYAMT DME_AMT UDME_AMT PHYTHAMT OCPTLAMT SPCH_AMT INHLTAMT BLOODAMT BLDADMIN OROOMAMT LTHTRPSY CRDLGY ANSTHSA LAB_AMT RDLGYAMT MRI_AMT OPSRVC ER_AMT AMBLNC PROFFEES ORGNAMT ESRDSETG CLNC_AMT ICUINDCD CRNRY_CD PHRMCYCD TRNSPLNT ONCLGYSW DGNSTCSW THRPTCSW NUCLR_SW CTSCANSW IMGNG_SW OPSRVCCD ORGNCD DGNSCNT PRCDRSW PRCDRCNT PRCDTCNT PRCDRCD BLDFRNSH DSTNTNCD ESRD_CD TYPE_ADM INFRMTL_ENCTR_IND_SW PROD_RPLCMT_LIFECYC_SW CRED_RCVD_RPLCD_DVC_SW NEW_TCHNLGY_ADD_ON_AMT BASE_OPRTG_DRG_AMT OPRTG_HSP_AMT MDCL_SRGCL_GNRL_AMT TAKE_HOME_AMT INVSTGTNL_DVC_AMT RDLGY_ONCOLOGY_AMT
);
run;

proc DELETE data = Merged_Medpar_raw;run;

proc sql;
        create table Merged_Medicare as
        select Merged_Medicare_4.*, Merged_Medpar.*
        from Merged_Medicare_4 left join Merged_Medpar
        on Merged_Medicare_4.BENE_ID = Merged_Medpar.BENE_ID;
quit;

proc DELETE data = Merged_Medicare_4;run;
proc DELETE data = Merged_Medpar;run;

/*Save merged data set to SASUSER*/
data SASUSER.Merged_Medicare;
set Merged_Medicare;
run;

