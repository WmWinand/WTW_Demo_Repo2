*  Declare input parameters;

%global MAKE
        TYPE;

/* %let MAKE = Ford; */
/* %let TYPE = Truck; */

*  Subset the data based on prompt selections;

proc sql;
  create table work.cars as
  select make, type, model, enginesize, horsepower, msrp
  from sashelp.cars
  where (make eq "&MAKE") and         
        (type eq "&TYPE")
  order by enginesize, model, msrp;
quit;  

title 'Data Based on Prompt Selections';

proc report data=work.cars;
  column ('Prompt Selections' make type) model enginesize horsepower msrp;
  define make--type / order;
  define enginesize / format=4.1;
run; quit;