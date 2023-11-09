*********************************************************;
* Activity 3.01                                         *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

/* DATA step on Compute Server */
data _null_;
    put "Processed on " _threadid_= _nthreads_=;
run;

/* DATA step on CAS */
data _null_ / sessref="MySession";
    put "Processed on " _threadid_= _nthreads_=;
run;