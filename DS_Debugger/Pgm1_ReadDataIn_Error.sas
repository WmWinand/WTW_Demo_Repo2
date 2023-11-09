data WORK.DISCGOLF;
  format datetime datetime18.; 
  infile '/home/sasdemo/WTW_Examples/Data1/discgolf_fixed.txt';
  input @3 datetime datetime16. @20 player $char16. @45 course $char15. hole1-hole9;
  if course NOT EQ 'SAS' then delete;
run;