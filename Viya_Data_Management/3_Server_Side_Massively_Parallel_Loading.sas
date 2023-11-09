/* PERFORM A PARALLEL LOAD OF A PARQUET FILE */

cas mySession sessopts=(metrics=true) ;

options msglevel=i ;

/* CASLIB DNFS data source accessible from CAS controller AND CAS workers */
/* commented since its pre-defined */
/*
caslib DM_DNFS description="OS Directory accessible from every CAS Node (Controller+Workers)"
   datasource=(srctype="dnfs") path="/gelcontent/data/NFS/" subdirs global ;
*/

libname DM_DNFS cas caslib="DM_DNFS" ;

/* List source files and target tables */
proc casutil incaslib="DM_DNFS" ;
   list files ;
   list tables ;
quit ;

/* Load the order_fact.parquet file in CAS in parallel */
/* Drop the CAS table before in case it exists */
/* List target tables */
proc casutil incaslib="DM_DNFS" outcaslib="DM_DNFS" ;
   droptable casdata="parquet_order_fact" quiet ;
   load casdata="order_fact.parquet" casout="parquet_order_fact" ;
   list tables ;
quit ;



/* PERFORM A PARALLEL LOAD OF MULTIPLE CSV FILES */

/* Load multiple CSV files in CAS in parallel */
/* Files are located in a sub-directory named multicsv,
   hence the casdata value */
/* CSV files are not directly named in the program,
   but they MUST have the csv extension */
proc casutil ;
   load casdata="multicsv" incaslib="DM_DNFS" outcaslib="DM_DNFS"
        casout="combined_csvs" replace
        importOptions=(fileType="csv",multiFile=true,
                       showFullpath=true,recurse=false) ;
quit ;


cas mySession terminate ;



