cas mySession;

libname casuser cas;

/* CREATE FAKE DATA */
data casuser.products;
   call streaminit(0);
	do i=1 to 6000000;  *<--adjust as many rows as you want*;
		x=rand('uniform');
		if x<.10 then Product="A";
			else if x<.30 then Product="B";
			else if x<.60 then Product="C";
			else Product="D"; 
		Quantity=round(rand('uniform',1,100));
		output;
	end;
	drop x i;
run;

proc print data=casuser.products(obs=10) noobs;
run;



/*The scenario this is meant to solve is that the company decided that this table
  is going to constantly grow so it is being placed in viya as a CAS table. All
  analysts pull from this table. you are using this CAS table for a specific report.
  My thought is the data is not big enough to see a huge difference between compute and CAs,
  however, showing the data transfer of CAS is important.*/

/*CLEAN UP SOLUTIONS - Maybe add formats/order by so everything is consistent*/

/**************************************************************************************/
/* SOLUTION 1 - PROC SQL - RUNNING AGAINST A CAS TABLE - PROCESSING ON COMPUTE SERVER */
/**************************************************************************************/
proc sql;
   select Product, 
       sum(Quantity) as TotalQuantity,
       calculated TotalQuantity / (select sum(Quantity) 
                                   from casuser.products) as TotalPct
	from casuser.products
	group by Product;
quit;


/******************************************************************************/
/* SOLUTION 2 - PROC FEDSQL - RUNNING AGAINST A CAS TABLE - PROCESSING IN CAS */
/******************************************************************************/

proc fedsql sessref=mySession;
select Product, 
       sum(Quantity) as TotalQuantity,
       sum(Quantity) / (select sum(Quantity) 
                                   from casuser.products) as TotalPct
	from casuser.products
	group by Product;
quit;


/***********************************************************************************************/
/* SOLUTION 3 - CAS ACTION FEDSQL.execDirect - RUNNING AGAINST A CAS TABLE - PROCESSING IN CAS */
/***********************************************************************************************/
 
proc cas;
	builtins.loadActionSet / actionSet="fedSQL";
	simple.summary /
		table={name="products", caslib="casuser", groupBy="Product"},
      inputs="Quantity",
		subSet="SUM",
		casout={name="productsSummary", caslib="casuser", replace=TRUE};
	fedSql.execDirect / 
	   query="select Product, 
	                _SUM_ as TotalQuantity, 
	                _SUM_ / (select sum(_SUM_) from productsSummary) as TotalPct
	          from productsSummary";
quit;


cas mySession terminate;
