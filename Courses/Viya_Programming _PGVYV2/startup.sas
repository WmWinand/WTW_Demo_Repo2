%let homedir=%sysget(HOME);

%let path=&homedir/PGVYV2_data;

libname pvbase "&path/data";
cas mySession sessopts=(caslib=casuser timeout=1800);
libname casuser cas;