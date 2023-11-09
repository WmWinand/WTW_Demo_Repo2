/* using a path */
proc cas;
  table.upload / 
       path="/mnt/viya-share/homes/T.Winand@sas.com/Data/sales.sas7bdat",
       casOut={name="sales",
               caslib="casuser",
               replace=TRUE};
  table.tableInfo / caslib="casuser";
  table.fetch / table="sales";
quit;

/* load a sas dataset in a sas library to CAS using proc casutil */
proc casutil;
  load data=sashelp.heart
      casout="heart"
      outcaslib="casuser"
      replace;
quit;

cas conn listhistory 3;

proc cas;
  table.tableInfo / caslib="casuser";
quit;

