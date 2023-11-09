data vitals_1 (drop = _SBP _DBP);
  set dataprep.vitals;

  if visit=1 then
    do;
    _SBP=.;
	_DBP=.;
	end;

  retain _SBP _DBP;

  if not missing(SBP) then
    _SBP = SBP;
  else if missing(SBP) then
    SBP=_SBP;

  if not missing(DBP) then
    _DBP = DBP;
  else if missing(DBP) then
    DBP=_DBP;

run;
