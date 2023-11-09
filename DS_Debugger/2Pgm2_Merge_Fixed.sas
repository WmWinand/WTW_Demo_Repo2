proc sort data=dataprep.demog;
  by patient;
run;

proc sort data=vitals_1;
  by patient;
run;

data vitals_2;
  merge dataprep.demog (rename=(weight=weight_lbs)) vitals_1;
  by patient;

  weight = weight_lbs / 2.2;
run;
