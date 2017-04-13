FILENAME REFFILE '/sas/vrdc/users/dch070/files/_uploads/ama-master.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.AMA_master;
	GETNAMES=YES;
RUN;

FILENAME REFFILE '/sas/vrdc/users/dch070/files/_uploads/malpractice.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.Malpractice;
	GETNAMES=YES;
RUN;
