&myfiles_root./_uploads


filename csv "&myfiles_root./_uploads/ama-master.csv" lrecl=256;

data AMA_master;
 infile csv dlm=',' dsd truncover;
run;

ilename csv "&myfiles_root./_uploads/malpractice.csv" lrecl=256;

data  Malpractice;
 infile csv dlm=',' dsd truncover;
run;