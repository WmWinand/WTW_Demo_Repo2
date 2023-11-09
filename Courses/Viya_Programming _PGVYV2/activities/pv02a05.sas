*****************;
* Activity 2.05 *;
*****************;

%let path=<insertpath>;

libname pvbase "&path";
caslib pvcas path="&path" libref=pvcas;

proc contents data=pvbase._all_ nods;
run;

proc contents data=pvcas._all_ nods;
run;

caslib pvcas clear;