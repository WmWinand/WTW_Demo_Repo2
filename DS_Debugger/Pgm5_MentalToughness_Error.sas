proc sort data=dataprep.discgolf;
  by player;
  run;

data mental_toughness /* (keep=player avg_score_after_birdie avg_score_after_bogey mentally_weak) */;
  set dataprep.discgolf;
  by player;
  array holes (*) hole1-hole9;

  /* INITIALIZE VARIABLES */
  if first.player then
  do;
    birdie_count = 0;
	bogey_count = 0;
	total_score_after_birdie = 0;
	total_score_after_bogey = 0;
  end;

  /* LOOP THROUGH HOLES 1-8 */
  do i = 1 to dim(holes)-1;
    if holes[i] < 3 then
	do;
	  birdie_count = birdie_count + 1;
	  total_score_after_birdie = total_score_after_birdie  + holes[i];
	end;
	if holes[i] > 3 then
	do;
	  bogey_count = bogey_count + 1;
	  total_score_after_bogey = total_score_after_bogey  + holes[i+1];
	end;
  end;

  /* CALCULATE MENTAL TOUGHNESS SCORE FOR PLAYER */
  if last.player then
  do;
    avg_score_after_birdie = total_score_after_birdie / birdie_count;
    avg_score_after_bogey = total_score_after_bogey / bogey_count;
	ms = avg_score_after_bobey - avg_score_after_birdie;
	if (ms) > 0 then mentally_weak = "Y";
	  else mentally_weak = "N";
	output;
  end;

  /* RETAIN TOTALS FOR PLAYER */
  retain birdie_count bogey_count total_score_after_birdie total_score_after_bogey;

run;
