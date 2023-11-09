/* IF LINE "SELECT CUSTOMERS" IS REMOVED, ALL DATSETS IN LIBRARY WILL BE CONVERTED */

libname inlib cvp '/home/sasdemo/WTW_Examples/Data';
libname outlib '/home/sasdemo/WTW_Examples/Data2' outencoding='UTF-8';

proc copy noclone in=inlib out=outlib;
  select customers;
run;