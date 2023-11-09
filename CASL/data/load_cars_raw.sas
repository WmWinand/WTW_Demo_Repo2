proc cas;
    lib="cs";
    tbl="cars_raw";
    upload path="&path/data/my_data/"||tbl||".sas7bdat",
           casOut={caslib=lib,
                   name=tbl,
                   replace=True};
quit;
