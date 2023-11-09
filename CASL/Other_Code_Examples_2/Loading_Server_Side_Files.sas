/* explore the caslib */
proc cas;
  lib="casuser";
  table.fileinfo / caslib=lib;
  table.tableinfo / caslib=lib;
quit;

/* load a server-side SAS data set */
proc cas;
  lib = "casuser";
  table.loadTable / 
       path="cars_ford.csv", caslib=lib,
       casout={caslib=lib,
               name="cars_ford",
               replace=True
              };

        importOptions={fileType="CSV", getNames=True};

  table.tableInfo / caslib=lib;
quit; 

/* preview in-memory table */
proc cas;
  fordcarsTbl={name="cars_ford", caslib="casuser"};
  table.fetch / table=fordcarsTbl;
quit;

/* load server-side hdat file