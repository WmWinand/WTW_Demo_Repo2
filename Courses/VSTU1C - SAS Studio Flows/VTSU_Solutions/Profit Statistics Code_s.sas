ods noproctitle;
ods graphics / imagemap=on;

proc means data=ORION.INTERNET_ORDERS chartype mean min max median sum 
		vardef=df qmethod=os maxdec=2 printalltypes;
	var Profit;
	class Product_Line Customer_Group;
	output out=WORK.profit_stats mean=min=max=median=sum= / autoname;
run;

proc univariate data=ORION.INTERNET_ORDERS vardef=df noprint;
	var Profit;
	class Product_Line Customer_Group;
	histogram Profit;
run;