*  Check the file extension to verify that it is a CSV file;

data _null_;
length filename $1024;
filename = htmlencode(strip("&_WEBIN_FILENAME"));
call symputx('_WEBIN_FILENAME', filename);
if (upcase("&_WEBIN_FILEEXT") ne 'CSV') then do;
  rc = dosubl('ods all close;');
  file _webout;
  put '<!DOCTYPE html>';
  put '<html lang="en">';
  put '<head><title>Program Error</title></head>';
  put '<body role="main">';
  put '<h1>ERROR: Uploaded file "' filename +(-1) '" is not a CSV file.</h1>';
  put '</body>';
  put '</html>';
  abort cancel;
end;
run;

*  Create a FILEREF for the uploaded file;

filename upload filesrvc parenturi="&SYS_JES_JOB_URI" 
  name="&_WEBIN_FILENAME" 
  contenttype="&_WEBIN_CONTENT_TYPE";

*  Set options to support non-SAS name;

options validvarname=any validmemname=extend;

*  Import the uploaded CSV file;

proc import datafile=upload
  out=work.mydata
  dbms=csv
  replace;
  getnames=yes;
run; quit;

title 'First 10 Records of Uploaded File ' """&_WEBIN_FILENAME""";
footnote link="&_WEBIN_FILEURI/content" 'Click here to download file';

proc print data=work.mydata(obs=10)
  style(header)=[just=center]
  style(column)=[verticalalign=middle]; 
run; quit;