&myfiles_root./_uploads


filename csv1 "&myfiles_root./_uploads/ama-master.csv" lrecl=256;
data AMA_master;
 infile csv1 dlm=',' dsd truncover;
run;


filename csv2 "&myfiles_root./_uploads/malpractice.csv" lrecl=256;
data Malpractice;
 infile csv2 dlm=',' dsd truncover;
run;