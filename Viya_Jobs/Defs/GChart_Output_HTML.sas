%global _ODSSTYLE
        _OUTPUT_TYPE;

*  Specify the ODS style and graphic output format;

ods listing style=&_ODSSTYLE;

goptions gsfname=_webout gsfmode=replace device=&_OUTPUT_TYPE;

*  Create the graphic output;

proc gchart data=sashelp.class; vbar age / discrete; run; quit;