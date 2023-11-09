proc cas;
    lib="cs";
    tbl="heart_raw";
    upload path="&path/data/cas/"||tbl||".sashdat",
           casOut={caslib=lib,
                   name=tbl,
                   replace=True};
quit;
