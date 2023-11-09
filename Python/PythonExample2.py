input table = 'sashelp.class'
output table = 'work.class_transposed'

dfin = SAS.sd2df(input_table)
print("input data shape is:"dfin.shape)
dfout = dfin.transpose()

# use row 0 for column names
dfout.columns=dfout.iloc[0]
# remove row 0
dfout=dfout[1:]

print("output data shape is:",dfout.shape)
SASdf2sd(dfout, output_table)