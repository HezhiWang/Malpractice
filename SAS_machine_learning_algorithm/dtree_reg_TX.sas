data DCH070SL.Merged_all_TX(drop = p_Target);
set DCH070SL.Merged_all_TX;
run;

data DCH070SL.Merged_all_TX_tree;
set DCH070SL.Merged_all_TX;
	%include '/sas/vrdc/users/dch070/files/_uploads/hpspldtree-code.sas';
run;

proc sql;
    create table DCH070SL.predict_TX_tree as
    select FIPSCounty, Year, sum(p_Target) as predict_sum
    from DCH070SL.Merged_all_TX_tree
    group by FIPSCounty, Year
    order by FIPSCounty, Year;
run;quit;

pro sql;
create table DCH070SL.predict_merge_tree as
select a.FIPSCounty, a.Year, a.predict_sum, b.count
from DCH070SL.predict_TX_tree as a
inner join 
DCH070SL.malpracticetx as b
on input(a.FIPSCounty,10.) = b.fips_char
and a.year = b.year;
run; quit;

data DCH070SL.predict_merge_tree;
set DCH070SL.predict_merge_tree;
error_per = (predict_sum - count) / count;
run;

proc means data=DCH070SL.predict_merge_tree n mean max min range std fw=8;
   var error_per;
run;
