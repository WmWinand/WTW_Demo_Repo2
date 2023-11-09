/* view all available caslibs */
proc cas;
  table.caslibInfo;
quit;

/* explore casuser caslib */
proc cas;
  lib="casuser";
  table.fileInfo / caslib=lib;
  table.tableInfo / caslib=lib;
quit;

/* manually add a caslib */
proc cas;
  table.caslibInfo;

  table.addCaslib / 
      name="my_data",
      path="/mnt/viya-share/homes/T.Winand@sas.com/Data",
      description="Newly added caslib";

  table.caslibInfo;
quit;

/* explore the new caslib */
proc cas;
  lib="my_data";
  table.fileInfo / caslib=lib;
quit;