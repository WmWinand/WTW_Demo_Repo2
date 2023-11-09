%let path=/enable01-export/enable01-aks/homes/T.Winand@sas.com;
libname sql "&path/Data";


/* EXAMPLE #1:  OVERWRITE AND EXISTING TABLE WITH SQL and FEDSQL */
proc sql;
  create table test(col1 char(5), col2 int);
  insert into test values ('high', 5);
quit;

proc sql;
  create table test(col1 char(5), col2 int);
  insert into test values ('high', 5);
quit;

proc fedsql;
   create table test(col1 char(5), col2 int);
   insert into test  values ('high', 5);
quit;

proc fedsql;
   drop table test force;
   create table test(col1 char(5), col2 int);
   insert into test  values ('high', 5);
quit;



/* EXAMPLE #2:  DEFINING SAS FORMATS, INFORMATS, AND LABELS WHEN CREATING A TABLE */
proc sql;
   create table countriesA
     (
      Name char(35) format=$35. informat=$35. label="Name",
      Capital char(35) format=$35. informat=$35. label="Capital",
      Population num format=comma15. informat=comma15. label="Population",
      Area num format=comma10. informat=comma10. label="Area",
      Continent char(30) format=$30. informat=$30. label="Continent",
      UNDate num format=year4. label="UNDate"
  );
quit;

proc fedsql;
   drop table countriesB force;
   create table countriesB
     (
      Name char(35) having format $35. informat $35. label 'Name',
      Capital char(35) having format $35. informat $35. label 'Capital',
      Population double having format comma15. informat comma15. label 'Population',
      Area double having format comma10. informat comma10. label 'Area',
      Continent char(30) having format $30. informat $30. label 'Continent',
      UNDate double having format year4. label 'UNDate'
  );
quit;


/* EXAMPLE #3:  INSERTING VALUES INTO A TABLE */
proc sql;
   insert into CountriesA
           values ('Afghanistan', 'Kabul', 17070323, 251825, 'Asia', 1946)
           values ('Albania', 'Tirane', 3407400, 11100, 'Europe', 1955)
           values ('Algeria', 'Algiers', 28171132, 919595, 'Africa', 1962)
           values ('Andorra', 'Andorra la Vella', 64634, 200, 'Europe', 1993);
quit;

proc fedsql;
   insert into CountriesB values ('Afghanistan', 'Kabul', 17070323, 251825,'Asia', 1946);
   insert into CountriesB values ('Albania', 'Tirane', 3407400, 11100,'Europe', 1955);
   insert into CountriesB values ('Algeria', 'Algiers', 28171132, 919595,'Africa', 1962);
   insert into CountriesB values ('Andorra', 'Andorra la Vella', 64634, 200,'Europe', 1993);
quit;

proc fedsql;
   drop table NewCountriesB force;
   create table NewCountriesB 
     (
      Name char(35) having format $35. informat $35. label 'Name',
      Capital char(35) having format $35. informat $35. label 'Capital',
      Population double having format comma15. informat comma15. label 'Population',
      Area double having format comma10. informat comma10. label 'Area',
      Continent char(30) having format $30. informat $30. label 'Continent',
      UNDate double having format year4. label 'UNDate'
  );
  
   title "World's Largest Countries";

   insert into NewCountriesB 
     select * from CountriesB
     where population >= 13000000;
   select * from NewCountriesB;
quit;

proc fedsql;
	title "World's Largest Countries";
	create table NewCountriesB_2 as select * from CountriesB where 
		population >=13000000;
	select * from NewCountriesB_2;
quit;


/* EXAMPLE 4: GROUP BY REMERGE QUERY */
proc sql;
   title 'oldest Employee of Each Gender';
   select *
     from sql.payroll
     group by gender
     having birth=min(birth);
quit;  

proc fedsql;
   title 'Earliest Birthdate by Gender';
   select Gender, min(Birth) from sql.payroll;
   group by Gender;
quit;

proc fedsql;
   title 'Oldest Employee of Each Gender';
  select
    p.IdNumber, p.Gender, p.Jobcode, p.Salary, p.Birth, p.Hired 
  from 
    (
     select Gender, min(Birth) as min_birth
     from sql.payroll 
     group by Gender 
     ) as t 
   inner join sql.payroll as p on p.Gender=t.gender and p.Birth=t.min_birth;
quit;





cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");
libname mycas cas caslib=casuser;

/* LOAD CUSTOMERS DATASET TO CAS USING PROC CASUTIL */
proc casutil;
	load data=test outcaslib='casuser'
	casout="test1" replace;
quit;

proc fedsql sessref=mySession;
  create table test2 {options replace=true} as
  select * from test1;
quit;




/* SPECIFYING SAS FORMATS AND LABELS IN A QUERY EXPRESSION */

proc fedsql;
  title 'Bonus Information';
   select IdNumber as "IdNumber", 
        put(Salary,dollar8.) as "Salary",
        put(Salary*.025, dollar8.) as "Bonus"
  from sql.payroll limit 10;
quit;

cas mySession terminate;