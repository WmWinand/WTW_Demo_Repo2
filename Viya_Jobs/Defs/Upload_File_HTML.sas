*  Create a data set with information about the upload;

data work.upload_info;

length varname $25 value $1024 description $256;

varname     = '_WEBIN_CONTENT_LENGTH';
value       = symget('_WEBIN_CONTENT_LENGTH');
description = 'Specifies the size of the file that was uploaded in bytes 
   (supplied automatically by the Web browser).';
output;

varname     = '_WEBIN_CONTENT_TYPE';
value       = resolve(symget('_WEBIN_CONTENT_TYPE'));
description = 'Specifies the content type that corresponds to the file that was uploaded 
   (supplied automatically by the Web browser).';
output;

varname     = '_WEBIN_FILE_COUNT';
value       = symget('_WEBIN_FILE_COUNT');
description = 'Specifies the number of files that were uploaded.';
output;

varname     = '_WEBIN_FILEEXT';
value       = resolve(symget('_WEBIN_FILEEXT'));
description = 'Specifies the extension of the file that was uploaded.';
output;

varname     = '_WEBIN_FILENAME';
value       = resolve(symget('_WEBIN_FILENAME'));
description = 'Specifies the name and original location of the file that was uploaded.';
output;

varname     = '_WEBIN_FILEURI';
value       = resolve(symget('_WEBIN_FILEURI'));
description = 'Specifies the URI of the location of the uploaded file';
output;

varname     = '_WEBIN_NAME';
value       = resolve(symget('_WEBIN_NAME'));
description = 'Specifies the value that corresponds to the NAME attribute of the INPUT tag.';
output;

label varname     = 'Variable Name'
      value       = 'Value'
      description = 'Description';

run;

title 'SAS Macro Variables Generated for Uploaded File '
      """&_WEBIN_FILENAME""";
footnote link="&_WEBIN_FILEURI/content" 'Click here to download file';

proc print data=work.upload_info 
  label 
  style(header)=[just=center]
  style(column)=[verticalalign=middle]; 
run; quit;