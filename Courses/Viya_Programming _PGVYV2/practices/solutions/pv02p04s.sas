************************;
* Practice #4 SOLUTION *;
************************;

/* Part a. */
proc casutil;
	droptable casdata="sales" quiet;
	load casdata="sales.sas7bdat" incaslib="casuser" 
	     outcaslib="casuser" casout="sales";
quit;	     
             
/* Parts b.-d. */
proc casutil;
    save casdata="sales" incaslib="casuser" outcaslib="casuser"
	     casout="sales_hd";
	droptable casdata="sales" quiet;
	list tables;
	list files;
quit;