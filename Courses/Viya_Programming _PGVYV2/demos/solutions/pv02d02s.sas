******************************************;
* Demo: Defining a New Caslib - SOLUTION *;
******************************************;

cas mysession;

/*****************************************************************************/
/*  Create a CAS library (myCaslib) for the specified path ("/filePath/")    */ 
/*****************************************************************************/

caslib pvcas path="/home/student/Courses/PGVY01/data" libref=pvcas;

proc casutil;
    list files;
quit;

caslib pvcas clear;



