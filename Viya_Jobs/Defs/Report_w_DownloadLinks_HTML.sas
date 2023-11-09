*  Close all open destinations;

ods _all_ close;

options nodate nonumber;

*  Declare input parameter;

%global _ODSSTYLE;

*  Define the escape character for ODS inline formatting;

ods escapechar='^';

*  Create a format for the student gender;

proc format;
  value $gender 'F' = 'Female'
                'M' = 'Male';
run; quit;

*  Prepare the data;

proc sql;
  create view work.class as
  select name label   = 'Name',
         sex  label   = 'Gender' format=$gender.,
         age  label   = 'Age',
         height label = 'Height',
         weight label = 'Weight'
  from sashelp.class
  order by sex;
quit;

*  Create an ODS document with the report results;

title1 'The CLASS Table';
footnote;

ods document name=work.mydoc(write);

proc print data=work.class noobs n label;
  by sex;
  var name age height weight;
run; quit;

ods document close;

*  Create the Excel XML and PDF output and associate with the job;

filename f_xlxp filesrvc parenturi="&SYS_JES_JOB_URI" 
  name='Class.xml' 
  contenttype='application/vnd.ms-excel'
  contentdisp='attachment; filename="Class.xml"';

filename f_pdf filesrvc parenturi="&SYS_JES_JOB_URI" 
  name='Class.pdf' 
  contenttype='application/pdf';

ods pdf file=f_pdf style=&_ODSSTYLE;

ods tagsets.ExcelXP file=f_xlxp style=&_ODSSTYLE
  options(embedded_titles='yes'
          suppress_bylines='yes'
          sheet_name='#byval(sex) Students'
          print_header='&C&A');

proc document name=work.mydoc;
  replay;
run; quit;

ods pdf close;
ods tagsets.ExcelXP close;

*  Create download links;

%let EXCEL_LINK=%bquote(<a href=""&_FILESRVC_F_XLXP_URI/content"" 
   target=""_SASDLResults"">Excel</a>);

%let PDF_LINK=%bquote(<a href=""&_FILESRVC_F_PDF_URI/content"" target=""_SASDLResults"">PDF</a>);

*  Create the HTML output for display in the Web browser;

filename f_htm filesrvc parenturi="&SYS_JES_JOB_URI"
  name='_webout.htm';

ods html5 file=f_htm style=&_ODSSTYLE 
  text="<span>^{style systemtitle &EXCEL_LINK^{nbspace 3
  &PDF_LINK}</span>";

proc document name=work.mydoc;
  replay;
run; quit;

ods html5 close;