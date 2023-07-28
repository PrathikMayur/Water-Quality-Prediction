*------------------------------------------------------------*;
* Reg: Create decision matrix;
*------------------------------------------------------------*;
data WORK.Potability(label="Potability");
  length   Potability                       $  32
           COUNT                                8
           DATAPRIOR                            8
           TRAINPRIOR                           8
           DECPRIOR                             8
           DECISION1                            8
           DECISION2                            8
           ;

  label    COUNT="Level Counts"
           DATAPRIOR="Data Proportions"
           TRAINPRIOR="Training Proportions"
           DECPRIOR="Decision Priors"
           DECISION1="1"
           DECISION2="0"
           ;
Potability="1"; COUNT=1021; DATAPRIOR=0.38984345169912; TRAINPRIOR=0.38984345169912; DECPRIOR=.; DECISION1=1; DECISION2=0;
output;
Potability="0"; COUNT=1598; DATAPRIOR=0.61015654830087; TRAINPRIOR=0.61015654830087; DECPRIOR=.; DECISION1=0; DECISION2=1;
output;
;
run;
proc datasets lib=work nolist;
modify Potability(type=PROFIT label=Potability);
label DECISION1= '1';
label DECISION2= '0';
run;
quit;
data EM_DMREG / view=EM_DMREG;
set EMWS1.Stat_TRAIN(keep=
Chloramines Conductivity Hardness Organic_carbon Potability Solids Sulfate
Trihalomethanes Turbidity ph );
run;
*------------------------------------------------------------* ;
* Reg: DMDBClass Macro ;
*------------------------------------------------------------* ;
%macro DMDBClass;
    Potability(DESC)
%mend DMDBClass;
*------------------------------------------------------------* ;
* Reg: DMDBVar Macro ;
*------------------------------------------------------------* ;
%macro DMDBVar;
    Chloramines Conductivity Hardness Organic_carbon Solids Sulfate
   Trihalomethanes Turbidity ph
%mend DMDBVar;
*------------------------------------------------------------*;
* Reg: Create DMDB;
*------------------------------------------------------------*;
proc dmdb batch data=WORK.EM_DMREG
dmdbcat=WORK.Reg_DMDB
maxlevel = 513
;
class %DMDBClass;
var %DMDBVar;
target
Potability
;
run;
quit;
*------------------------------------------------------------*;
* Reg: Run DMREG procedure;
*------------------------------------------------------------*;
proc dmreg data=EM_DMREG dmdbcat=WORK.Reg_DMDB
outest = EMWS1.Reg_EMESTIMATE
outterms = EMWS1.Reg_OUTTERMS
outmap= EMWS1.Reg_MAPDS namelen=200
;
class
Potability
;
model Potability =
Chloramines
Conductivity
Hardness
Organic_carbon
Solids
Sulfate
Trihalomethanes
Turbidity
ph
/error=binomial link=LOGIT
coding=DEVIATION
nodesignprint
;
;
score data=EMWS1.Stat_TEST
out=_null_
outfit=EMWS1.Reg_FITTEST
role = TEST
;
code file="C:\Users\sbattina\Desktop\Water quality\Workspaces\EMWS1\Reg\EMPUBLISHSCORE.sas"
group=Reg
;
code file="C:\Users\sbattina\Desktop\Water quality\Workspaces\EMWS1\Reg\EMFLOWSCORE.sas"
group=Reg
residual
;
run;
quit;
