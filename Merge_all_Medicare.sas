data aa;
x = 1;y=2;
run;

data bb;
x=1;z=3;
run;

libname lib1 "/folders/myfolders/wangbadan";
data lib1.aa;
set aa;
data lib1.bb;
set bb;
run;


