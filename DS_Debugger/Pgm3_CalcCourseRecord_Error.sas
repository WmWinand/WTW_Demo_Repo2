data DATAPREP.DISCGOLF;
  format datetime datetime18.; 
  infile 'C:\MyDemos\EG\EG_debugger\discgolf_fixed.txt';
  input @3 datetime datetime16. @20 player $char16. @46 course $char15. hole1-hole9;
  if course NOT EQ 'SAS' then delete;

  /* COMPUTE ROUND SCORE */
  array holes {*} hole1-hole9;
  round_score = 0;
  do i = 1 to dim(holes);
    round_score = round_score + holes[i];
  end;

  if _n_ = 1 then
  do;
    course_record = round_score;
	record_holder = player;
  end;

  if (course_record > round_score) then
  do;
    course_record = round_score;
	record_player = player;
  end;

  retain course_record record_holder;
run;


run;