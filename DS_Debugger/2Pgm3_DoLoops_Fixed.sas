proc sort data=vitals_2;
  by patient;
run;

data vitals_3 (drop=n total);
  do n = 1 by 1 until (last.patient);
    set vitals_2;
	by patient;
	total = sum(total, SBP);
  end;

  mean_sbp = total/n;

  do until (last.patient);
    set vitals_2;
	by patient;
	output;
  end;

run;