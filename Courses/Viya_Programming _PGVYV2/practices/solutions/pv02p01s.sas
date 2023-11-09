************************;
* Practice #1 SOLUTION *;
************************;

/*****************************************************************************/
/*  Load file from a client location ("pathToClientFile") into the specified */
/*  caslib ("myCaslib") and save it as "tableNameForLoadedFile".             */
/*****************************************************************************/

/* Parts a.-b. */
proc casutil;
	load file="/home/student/Courses/PGVY01/data/copy-to-casuser/products.xlsx" 
	outcaslib="casuser" casout="products";
quit;

/*****************************************************************************/
/*  Load SAS data set from a Base engine library (library.tableName) into    */
/*  the specified caslib ("myCaslib") and save as "targetTableName".         */
/*****************************************************************************/

/* Part c.-d. */
proc casutil;
	load data=pvbase.qtr_sales outcaslib="casuser"
	casout="qsales";
quit;

/* Part e. */
proc casutil;
	list tables;
quit;




