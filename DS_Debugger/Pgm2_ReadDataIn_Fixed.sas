data DATAPREP.DISCGOLF;
  format datetime datetime18.; 
  infile 'C:\MyDemos\EG\EG_debugger\discgolf_fixed.txt';
  input @3 datetime datetime16. @20 player $char16. @46 course $char15. hole1-hole9;
  if course NOT EQ 'SAS' then delete;
run;