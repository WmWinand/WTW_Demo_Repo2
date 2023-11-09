*************************;
* Lesson 2, Practice #4 *;
*************************;

proc casutil;
	droptable casdata="sales" quiet;
	load casdata="sales.sas7bdat" incaslib="casuser" 
	     outcaslib="casuser" casout="sales";
quit;	     
             
