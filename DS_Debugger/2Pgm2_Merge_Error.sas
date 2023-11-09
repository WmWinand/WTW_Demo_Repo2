proc sort data=dataprep.demog;
  by patient;
run;

proc sort data=vitals_1;
  by patient;
run;

data vitals_2;
  merge dataprep.demog vitals_1;
  by patient;

  weight = weight / 2.2;
run;
