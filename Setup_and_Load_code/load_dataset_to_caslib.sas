/* SET MACRO VARIABLES: PATH TO SOURCE DATA, DESTINATION CASLIB, & NAME OF TABLE TO LOAD */
/* CHANGE VALUES AS NEEDED */
%let datapath=/greenmonthly-export/ssemonthly/homes/T.Winand@sas.com/Data;
%let tblname=readmissions;


/* START CAS SESSION */
cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");


/* SET LIBNAME FOR SOURCE DATA TO LOAD AND SET CAS ENGINE LIBRARY FOR DESTINATION CASLIB */
libname mydata "&datapath";
libname casuser cas caslib="casuser";

/* CHECK IF CAS TABLE ALREADY EXISTS - IF IT DOES DROP FROM MEMORY */
%if %sysfunc(exist(casuser.readmissions)) %then %do;
  proc casutil;
    droptable incaslib="casuser" casdata="readmissions";
  run;
%end;

/* LOAD XLS FILE TO CAS USING PROC CASUTIL */
proc casutil;
    load file="&datapath/Readmissions_FullData_202201_06.xlsx"
    casout='readmissions'
    outcaslib='casuser'
    importoptions=(filetype='excel' getnames=true)
    replace;

    list tables;
quit; 

data casuser.readmissions;
  set casuser.readmissions;
/*    label age_years="Patient Age in Years"; */
/*    label adm_date_time="Date Patient Admitted"; */
/*    label disch_date_time="Date Patient Discharged"; */
/*    label disch_loc_id="Hospital Id that Discharged Patient"; */
/*    label disch_loc_name="Hospital Name that Discharged Patient"; */
/*    label hsp_account_id="Hospital ID"; */
/*    label pat_enc_csn_id="Patient Contact Serial Number"; */
/*    label pat_id="Patient ID"; */
/*    label disch_dept_id="Department ID that Discharged Patient"; */
/*    label disch_dept_name="Department Name that Discharged Patient"; */
/*    label disch_disp="Discharge Code"; */
/*    label disch_dest="Discharge Destination"; */
/*    label atnd_prov_id="Attending Provider ID"; */
/*    label atnd_prov_name="Attending Provider Name"; */
/*    label billing_prov_id="Billing Provider ID"; */
/*    label billing_prov_name="Billing Provider Name"; */
/*    label drg_name="Diagnosis Group Name"; */
/*    label mpi_id="Master Patient Index"; */
/*    label ip_type_name="???"; */
/*    label lvef_range="Left Ventricular Ejection Fraction Range"; */
/*    label coded_hospital_icd_10="ICD Diagnosis Code"; */
/*    label coded_hospital_dx_name="Coded Hospital Diagnosis of Patient"; */
/*    label medicare_financial_class="Medicare Financial Class"; */
/*    label code_group="Diagnosis Code Group"; */
/*    label count_meds="Count of Different Medications Prescribed"; */
/*    label pharm_consult_complete="Pharmacy Consultation Complete"; */
/*    label pharm_consult_ordered="Pharmacy Consultation Ordered"; */
/*    label card_consult_complete="Card Consultation Complete"; */
/*    label card_consult_ordered="Card Consultation Ordered"; */
/*    label readmit_hsp_account_id="Account ID of Readmitting Hospital"; */
/*    label readmit_pat_enc_csn_id="Readmit Patient Contact Serial Number"; */
/*    label readmit_mrn_loc="Readmit Medical Record Number Loaction"; */
/*    label readmit_adm_time="Admission Date of Readmitted Patient" */
/*    label readmit_disch_date="Discharge Date of Readmitted Patient"; */
/*    label readmit_disch_loc_id="Hospital ID where Patient Readmitted"; */
/*    label readmit_disch_loc_name="Hospital Name where Patient Readmitted"; */
/*    label readmit_disch_dept_id="Department ID where Patient Readmitted"; */
/*    label readmit_disch_dept_name="Department Name where Patient Readmitted"; */
/*    label readmit_disch_disp="Readmit Discharge Code"; */
/*    label readmit_disch_dest="Readmit Discharge Destination"; */
/*    label readmit_atnd_prov_id="Readmit Attending Provider ID"; */
/*    label readmit_atnd_prov_name="Readmit Attending Provider Name"; */
/*    label readmit_billing_prov_id="Readmit Billing Provider ID"; */
/*    label readmit_biling_prov_name="Readmit Billing Provider Name"; */
/*    label readmit_drg_name="Readmit Diagnosis Group Name"; */
/*    label readmit_mpi_id="Master Patient Index"; */
/*    label readmit_ip_type_name="???"; */
/*    label readmit_coded_hospital_icd_10="Readmit ICD-10 Diagnosis Code"; */
/*    label readmit_coded_hospital_dx_name="Coded Hospital Diagnosis of Readmitted Patient"; */
/*    label readmit_medicare_financial_class="Readmit Medicare Financial Class"; */
/*    label readmit_code_group="Readmit Diagnosis Code Group"; */

   AGE_YEARS_NUM = input(AGE_YEARS, 8.);
   COUNTMEDS_NUM = input(COUNTMEDS, 8.);
   if readmit_hsp_account_id = "NULL"
     then readmit_flg = 0;
   else
     readmit_flg = 1;

/*    label age_years_num="Patient Age in Years (num)"; */
/*    label countmeds_num="Number of Medications"; */
/*    label readmit_flg="Patient Readmitted Flag"; */

run;

/* LOAD DATASET INTO CASLIB AND PROMOTE */
/* proc casutil; */
/*   load data=mydata.&tblname outcaslib="&mycaslib" casout="&tblname" promote; */
/*   list tables incaslib="&mycaslib";   */
/* quit; */

proc contents data=casuser.readmissions;
run;

/* LIST FIRST 10 ROWS TO VALIDATE */
proc print data=casuser.readmissions (obs=10);
run;

proc casutil;
  promote casdata="readmissions" incaslib="casuser" outcaslib="casuser";
quit;

/* proc casutil; */
/*   save casdata=readmissions casout=casuser replace; */
/* quit; */

/* TERMINATE CAS SESSION */
cas mySession terminate;
