cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");

libname myCasLib cas caslib="casuser";

data myCasLib.iris;
  set sashelp.iris;
run;

proc casutil;
  load data=sashelp.cars outcaslib="casuser" casout="cars";
run;

proc cas;
  fnc;
run;

proc cas;
  functionlist;
run;

proc cas;
  function FtoC(temp);
    Celsius = (5/9*(temp-32));
    Return (Celsius);
  end func;

  tempF = {30 35 31 29};
  do n over tempF;
    Celsius = FtoC(n);
    Print put(Celsius, best6.2);
  end;
run;

proc cas;
  %include "/home/sasdemo/WTW_Examples/CASL Examples/FtoC.sas";

  tempF = {30 35 31 29};
  do n over tempF;
    Celsius = FtoC(n);
    Print put(Celsius, best6.2);
  end;
run;

proc cas;
  loadactionset "simple";
  simple.correlation /
    inputs={"SepalLength", "SepalWidth"},
    pairWithInput={"PetalLength", "PetalWidth"},
    table={name="iris"};
run;
quit;

proc corr data=myCasLib.iris;
  var sepallength sepalwidth;
  with petallength petalwidth;
run;

proc cas;
  fedsql.execdirect /
    query="create table cars_usa1 as
           select * from cars
           where origin = 'USA'";
run;

proc fedsql sessref=mySession;
  create table cars_usa as
  select * from cars
    where origin='USA';
run;

cas mySession terminate;

