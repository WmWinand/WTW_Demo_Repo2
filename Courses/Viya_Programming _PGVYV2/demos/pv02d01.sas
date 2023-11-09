***************************;
* Demo: Accessing Caslibs *;
***************************;

libname pvbase base "<insert path to data folder>";
cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");
caslib _all_ list;

libname casuser cas caslib=casuser;

caslib _all_ assign;
