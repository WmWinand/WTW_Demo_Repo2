data disc_golf (drop=i);
	format datetime datetime18. date date9.;
	infile 'c:\users\joflyn\desktop\sgf\discgolf.csv' dsd dlm=',' firstobs=2;
	input datetime :datetime18. name :$25. course :$20. hole1 :1. hole2 :1. hole3 :1. hole4 :1. hole5 :1. hole6 :1. hole7 :1. hole8 :1. hole9 :1.;
	/* Subset data to only games played at SAS Course */

	if course not eq "SAS" then delete;
	date = datepart(datetime);
	/* Compute Round Score */
	array holes {*} hole1-hole9;
	score = sum(of holes[*]);

	if _N_ eq 1 then do;
		alltimelow = score;
		RecordHolder = name;
	end;	
	/* Update All Time Low */
	if (alltimelow > score) then do;
		alltimelow = score;
		RecordHolder = name;
	end;

	retain alltimelow RecordHolder lowset;
run;

data weather;
	format date date9.;
	infile 'c:\users\joflyn\desktop\sgf\weather.txt' dsd dlm='09'x;
	input date :yymmdd10. High :2. Low :2. Avg :4. Dep :5. HDD :2. CDD :2. Precip :$4. Snow :$3. SnowDepth :$1.;
	format Precipitation 6.3;
	if Precip eq "T" then Precipitation = 0.01;
	else Precipitation = input(precip, 6.3);
run;

data disc_golf_weather(drop=date i dayavg) day_avg (keep=date high Precipitation dayavg) ;
	merge disc_golf(in=played_dg) weather;
	by date;

	if (played_dg eq 0) then
		delete;

	array holes {*} hole1-hole9;

	if (first.date) then do;
		dayavg = score;
	end;

	dayavg = mean(dayavg, score);

	if (last.date) then do;
		output day_avg;
	end;

	retain dayavg;
run;


proc sort data=work.disc_golf;
by name;
run;

data mental_toughness(keep=name score_after_birdie score_after_bogie mentally_weak ms);
format hole1 dollar10.;
set work.disc_golf;
by name;
array holes {*} hole1-hole9;

if first.name then do;
	total_player_birdies = 0;
	total_player_bogies = 0;
	total_player_score_after_birdie = 0;
	total_player_score_after_bogie = 0;
end;

/* If previous game was on the same date AND they birdied 9, we count hole 1 as the next hole */
last_played_date = lag1(date);
if last_played_date eq date then do;
	nineth_hole = lag1(hole9);
	if nineth_hole < 3 then do;
		total_player_birdies = total_player_birdies + 1;
		total_player_score_after_birdie = total_player_score_after_birdie + nineth_hole;
	end;
	if nineth_hole > 3 then do;
		total_player_bogies = total_player_bogies + 1;
		total_player_score_after_bogie = total_player_score_after_bogie + nineth_hole;
	end;
end;

do i = 1 to dim(holes)-1;
	if holes[i] < 3 then do;
		total_player_birdies = total_player_birdies + 1;
		total_player_score_after_birdie = total_player_score_after_birdie + holes[i+1];
	end;
	if holes[i] > 3 then do;
		total_player_bogies = total_player_bogies + 1;
		total_player_score_after_bogie = total_player_score_after_bogie + holes[i+1];
	end;
end;

if last.name then do;
	score_after_birdie = total_player_score_after_birdie / total_player_birdies;
	score_after_bogie = total_player_score_after_bogie / total_player_bogies;
	ms = score_after_bogie - score_after_birdie;
	if (ms) > 0 then mentally_weak = "Y";
	else mentally_weak = "N";
	output;
end;

retain total_player_birdies total_player_bogies total_player_score_after_birdie total_player_score_after_bogie;
run;
