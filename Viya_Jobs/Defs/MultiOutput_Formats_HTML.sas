*  Declare input parameter;

%global DATASET;

%macro setup;

%local ERRORTEXT RC;

%*  Verify that a valid data set was specified;

%if (%qcmpres(&DATASET) eq ) 
  %then %let ERRORTEXT=ERROR: You must specify a data set.;
  %else %if not %sysfunc(exist(&DATASET))
    %then %let ERRORTEXT=ERROR: Data set ""%sysfunc(htmlencode(&DATASET))""
 not found.;

%if (%bquote(&ERRORTEXT) ne ) %then %do;

  %*  Close the currently open destination and write message to the browser;

  ods _all_ close;
  
  %let RC=%sysfunc(fdelete(_webout));

  filename _webout filesrvc parenturi="&SYS_JES_JOB_URI" 
    name='_webout.htm';

  title;

  ods html5 file=_webout
    text="&ERRORTEXT";
  ods html5 close;

  data _null_;
  abort cancel;
  run;
%end;

%mend setup;

%SETUP

title "%sysfunc(htmlencode(%qupcase(&DATASET))) Table in
  %sysfunc(htmlencode(%qupcase(&_ODSDEST))) Format";

proc print data=&DATASET noobs label n; run; quit;