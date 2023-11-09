*****************;
* Activity 2.04 *;
*****************;

cas mySession terminate;
cas mySession;

caslib myCaslib path="<insertpath>" libref=myCaslib;

proc casutil;
    list files;
quit;

caslib myCaslib clear;
 









