*------------------------------------------------------------*;
* AutoNeural: Create decision matrix;
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
data EM_AutoNeural;
set EMWS1.Stat_TRAIN(keep=
Chloramines Conductivity Hardness Organic_carbon Potability Solids Sulfate
Trihalomethanes Turbidity ph );
run;
*------------------------------------------------------------* ;
* AutoNeural: DMDBClass Macro ;
*------------------------------------------------------------* ;
%macro DMDBClass;
    Potability(DESC)
%mend DMDBClass;
*------------------------------------------------------------* ;
* AutoNeural: DMDBVar Macro ;
*------------------------------------------------------------* ;
%macro DMDBVar;
    Chloramines Conductivity Hardness Organic_carbon Solids Sulfate
   Trihalomethanes Turbidity ph
%mend DMDBVar;
*------------------------------------------------------------*;
* AutoNeural: Create DMDB;
*------------------------------------------------------------*;
proc dmdb batch data=WORK.EM_AutoNeural
dmdbcat=WORK.AutoNeural_DMDB
maxlevel = 513
;
class %DMDBClass;
var %DMDBVar;
target
Potability
;
run;
quit;
*------------------------------------------------------------* ;
* AutoNeural: Interval Inputs Macro ;
*------------------------------------------------------------* ;
%macro INTINPUTS;
    Chloramines Conductivity Hardness Organic_carbon Solids Sulfate
   Trihalomethanes Turbidity ph
%mend INTINPUTS;
*------------------------------------------------------------* ;
* AutoNeural: Binary Inputs Macro ;
*------------------------------------------------------------* ;
%macro BININPUTS;

%mend BININPUTS;
*------------------------------------------------------------* ;
* AutoNeural: Nominal Inputs Macro ;
*------------------------------------------------------------* ;
%macro NOMINPUTS;

%mend NOMINPUTS;
*------------------------------------------------------------* ;
* AutoNeural: Ordinal Inputs Macro ;
*------------------------------------------------------------* ;
%macro ORDINPUTS;

%mend ORDINPUTS;
* set printing options;
;
options linesize = 80;
options pagesize = 6000;
options nonumber;
options nocenter;
options nodate;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_autonet_title  , NOQUOTE))";
*;
*------------------------------------------------------------*;
* Autoneural: search / SINGLE LAYER;
;
*------------------------------------------------------------*;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Direct connection;
;
*------------------------------------------------------------*;
connect interval Potability;
*;
netoptions ranscale = 1;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 1 SINGLE LAYER trial # 1 : DIRECT : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=1800 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 1 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 1 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
%sysfunc(sasmsg(sashelp.dmine, starthistory_note , NOQUOTE));
data EMWS1.AutoNeural_HISTORY;
length _func_ _status_ _step_ $16;
label _func_ = "%sysfunc(sasmsg(sashelp.dmine, rpt_function_vlabel  , NOQUOTE))";
label _status_ = "%sysfunc(sasmsg(sashelp.dmine, rpt_status_vlabel  , NOQUOTE))";
label _iter_ = "%sysfunc(sasmsg(sashelp.dmine, rpt_iteration_vlabel  , NOQUOTE))";
label _step_ = "%sysfunc(sasmsg(sashelp.dmine, rpt_step_vlabel  , NOQUOTE))";
_func_ = '';
_status_ = '';
_step_ = 'SINGLE LAYER 1';
set
_anfit(where=(_name_ eq 'OVERALL' and _iter_ eq 0))
;
run;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=TANH;
connect interval H1x1_;
connect H1x1_ Potability;
*;
netoptions ranscale = 1;
*;
initial
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 1 SINGLE LAYER trial # 2 : TANH : ))";
prelim 8 outest=_anpre pretime=112 preiter=8
tech = Default
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 1 SINGLE LAYER trial # 2 : TANH : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=900 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 3 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 3 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
*;
netoptions ranscale = 1;
*;
initial
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 1 SINGLE LAYER trial # 3 : NORMAL : ))";
prelim 8 outest=_anpre pretime=112 preiter=8
tech = Default
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 1 SINGLE LAYER trial # 3 : NORMAL : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=899 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 7 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 7 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=SINE;
connect interval H1x1_;
connect H1x1_ Potability;
*;
netoptions ranscale = 1;
*;
initial
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 1 SINGLE LAYER trial # 4 : SINE : ))";
prelim 8 outest=_anpre pretime=112 preiter=8
tech = Default
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 1 SINGLE LAYER trial # 4 : SINE : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=899 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 1 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 1 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Direct connection;
;
*------------------------------------------------------------*;
connect interval Potability;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 2 SINGLE LAYER trial # 1 : DIRECT : ))";
prelim 8 outest=_anpre pretime=112 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 2 SINGLE LAYER trial # 1 : DIRECT : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=899 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 0 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 0 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=TANH;
connect interval H1x2_;
connect H1x2_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 2 SINGLE LAYER trial # 2 : TANH : ))";
prelim 8 outest=_anpre pretime=112 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 2 SINGLE LAYER trial # 2 : TANH : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=899 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 6 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 6 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=GAUSS;
connect interval H1x2_;
connect H1x2_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 2 SINGLE LAYER trial # 3 : NORMAL : ))";
prelim 8 outest=_anpre pretime=112 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 2 SINGLE LAYER trial # 3 : NORMAL : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=898 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 7 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 7 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 2 SINGLE LAYER trial # 4 : SINE : ))";
prelim 8 outest=_anpre pretime=112 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 2 SINGLE LAYER trial # 4 : SINE : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=898 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 8 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 8 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Direct connection;
;
*------------------------------------------------------------*;
connect interval Potability;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 3 SINGLE LAYER trial # 1 : DIRECT : ))";
prelim 8 outest=_anpre pretime=112 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 3 SINGLE LAYER trial # 1 : DIRECT : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=898 maxiter=12
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 8 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 8 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=TANH;
connect interval H1x3_;
connect H1x3_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 3 SINGLE LAYER trial # 2 : TANH : ))";
prelim 8 outest=_anpre pretime=112 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 3 SINGLE LAYER trial # 2 : TANH : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=898 maxiter=12
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 8 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 8 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 3 SINGLE LAYER trial # 3 : NORMAL : ))";
prelim 8 outest=_anpre pretime=112 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 3 SINGLE LAYER trial # 3 : NORMAL : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=897 maxiter=12
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 5 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 5 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=SINE;
connect interval H1x3_;
connect H1x3_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 3 SINGLE LAYER trial # 4 : SINE : ))";
prelim 8 outest=_anpre pretime=112 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 3 SINGLE LAYER trial # 4 : SINE : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=897 maxiter=12
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 12 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 12 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Direct connection;
;
*------------------------------------------------------------*;
connect interval Potability;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 4 SINGLE LAYER trial # 1 : DIRECT : ))";
prelim 8 outest=_anpre pretime=112 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 4 SINGLE LAYER trial # 1 : DIRECT : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=896 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 3 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 3 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=TANH;
connect interval H1x4_;
connect H1x4_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 4 SINGLE LAYER trial # 2 : TANH : ))";
prelim 8 outest=_anpre pretime=112 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 4 SINGLE LAYER trial # 2 : TANH : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=896 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 1 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 1 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=GAUSS;
connect interval H1x4_;
connect H1x4_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 4 SINGLE LAYER trial # 3 : NORMAL : ))";
prelim 8 outest=_anpre pretime=111 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 4 SINGLE LAYER trial # 3 : NORMAL : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=895 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 8 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 8 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=SINE;
connect interval H1x4_;
connect H1x4_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 4 SINGLE LAYER trial # 4 : SINE : ))";
prelim 8 outest=_anpre pretime=111 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 4 SINGLE LAYER trial # 4 : SINE : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=894 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 5 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 5 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Direct connection;
;
*------------------------------------------------------------*;
connect interval Potability;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=SINE;
connect interval H1x4_;
connect H1x4_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 5 SINGLE LAYER trial # 1 : DIRECT : ))";
prelim 8 outest=_anpre pretime=111 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 5 SINGLE LAYER trial # 1 : DIRECT : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=894 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 0 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 0 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=SINE;
connect interval H1x4_;
connect H1x4_ Potability;
Hidden 2 / id = H1x5_ act=TANH;
connect interval H1x5_;
connect H1x5_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 5 SINGLE LAYER trial # 2 : TANH : ))";
prelim 8 outest=_anpre pretime=111 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 5 SINGLE LAYER trial # 2 : TANH : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=894 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 0 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 0 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=SINE;
connect interval H1x4_;
connect H1x4_ Potability;
Hidden 2 / id = H1x5_ act=GAUSS;
connect interval H1x5_;
connect H1x5_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 5 SINGLE LAYER trial # 3 : NORMAL : ))";
prelim 8 outest=_anpre pretime=111 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 5 SINGLE LAYER trial # 3 : NORMAL : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=893 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 5 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 5 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=SINE;
connect interval H1x4_;
connect H1x4_ Potability;
Hidden 2 / id = H1x5_ act=SINE;
connect interval H1x5_;
connect H1x5_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 5 SINGLE LAYER trial # 4 : SINE : ))";
prelim 8 outest=_anpre pretime=111 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 5 SINGLE LAYER trial # 4 : SINE : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=893 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 5 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 5 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Direct connection;
;
*------------------------------------------------------------*;
connect interval Potability;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=SINE;
connect interval H1x4_;
connect H1x4_ Potability;
Hidden 2 / id = H1x5_ act=SINE;
connect interval H1x5_;
connect H1x5_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 6 SINGLE LAYER trial # 1 : DIRECT : ))";
prelim 8 outest=_anpre pretime=111 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 6 SINGLE LAYER trial # 1 : DIRECT : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=893 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 4 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 4 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=SINE;
connect interval H1x4_;
connect H1x4_ Potability;
Hidden 2 / id = H1x5_ act=SINE;
connect interval H1x5_;
connect H1x5_ Potability;
Hidden 2 / id = H1x6_ act=TANH;
connect interval H1x6_;
connect H1x6_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 6 SINGLE LAYER trial # 2 : TANH : ))";
prelim 8 outest=_anpre pretime=111 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 6 SINGLE LAYER trial # 2 : TANH : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=893 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 1 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 1 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=SINE;
connect interval H1x4_;
connect H1x4_ Potability;
Hidden 2 / id = H1x5_ act=SINE;
connect interval H1x5_;
connect H1x5_ Potability;
Hidden 2 / id = H1x6_ act=GAUSS;
connect interval H1x6_;
connect H1x6_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 6 SINGLE LAYER trial # 3 : NORMAL : ))";
prelim 8 outest=_anpre pretime=111 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 6 SINGLE LAYER trial # 3 : NORMAL : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=893 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 3 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 3 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=SINE;
connect interval H1x4_;
connect H1x4_ Potability;
Hidden 2 / id = H1x5_ act=SINE;
connect interval H1x5_;
connect H1x5_ Potability;
Hidden 2 / id = H1x6_ act=SINE;
connect interval H1x6_;
connect H1x6_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 6 SINGLE LAYER trial # 4 : SINE : ))";
prelim 8 outest=_anpre pretime=111 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 6 SINGLE LAYER trial # 4 : SINE : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=892 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 6 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 6 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Direct connection;
;
*------------------------------------------------------------*;
connect interval Potability;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=SINE;
connect interval H1x4_;
connect H1x4_ Potability;
Hidden 2 / id = H1x5_ act=SINE;
connect interval H1x5_;
connect H1x5_ Potability;
Hidden 2 / id = H1x6_ act=SINE;
connect interval H1x6_;
connect H1x6_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 7 SINGLE LAYER trial # 1 : DIRECT : ))";
prelim 8 outest=_anpre pretime=111 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 7 SINGLE LAYER trial # 1 : DIRECT : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=892 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 0 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 0 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=SINE;
connect interval H1x4_;
connect H1x4_ Potability;
Hidden 2 / id = H1x5_ act=SINE;
connect interval H1x5_;
connect H1x5_ Potability;
Hidden 2 / id = H1x6_ act=SINE;
connect interval H1x6_;
connect H1x6_ Potability;
Hidden 2 / id = H1x7_ act=TANH;
connect interval H1x7_;
connect H1x7_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 7 SINGLE LAYER trial # 2 : TANH : ))";
prelim 8 outest=_anpre pretime=111 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 7 SINGLE LAYER trial # 2 : TANH : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=892 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 8 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 8 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=SINE;
connect interval H1x4_;
connect H1x4_ Potability;
Hidden 2 / id = H1x5_ act=SINE;
connect interval H1x5_;
connect H1x5_ Potability;
Hidden 2 / id = H1x6_ act=SINE;
connect interval H1x6_;
connect H1x6_ Potability;
Hidden 2 / id = H1x7_ act=GAUSS;
connect interval H1x7_;
connect H1x7_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 7 SINGLE LAYER trial # 3 : NORMAL : ))";
prelim 8 outest=_anpre pretime=111 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 7 SINGLE LAYER trial # 3 : NORMAL : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=892 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 0 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 0 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=SINE;
connect interval H1x4_;
connect H1x4_ Potability;
Hidden 2 / id = H1x5_ act=SINE;
connect interval H1x5_;
connect H1x5_ Potability;
Hidden 2 / id = H1x6_ act=SINE;
connect interval H1x6_;
connect H1x6_ Potability;
Hidden 2 / id = H1x7_ act=SINE;
connect interval H1x7_;
connect H1x7_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 7 SINGLE LAYER trial # 4 : SINE : ))";
prelim 8 outest=_anpre pretime=111 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 7 SINGLE LAYER trial # 4 : SINE : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=891 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 2 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 2 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Direct connection;
;
*------------------------------------------------------------*;
connect interval Potability;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=SINE;
connect interval H1x4_;
connect H1x4_ Potability;
Hidden 2 / id = H1x5_ act=SINE;
connect interval H1x5_;
connect H1x5_ Potability;
Hidden 2 / id = H1x6_ act=SINE;
connect interval H1x6_;
connect H1x6_ Potability;
Hidden 2 / id = H1x7_ act=SINE;
connect interval H1x7_;
connect H1x7_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 8 SINGLE LAYER trial # 1 : DIRECT : ))";
prelim 8 outest=_anpre pretime=111 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 8 SINGLE LAYER trial # 1 : DIRECT : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=891 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 7 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 7 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=SINE;
connect interval H1x4_;
connect H1x4_ Potability;
Hidden 2 / id = H1x5_ act=SINE;
connect interval H1x5_;
connect H1x5_ Potability;
Hidden 2 / id = H1x6_ act=SINE;
connect interval H1x6_;
connect H1x6_ Potability;
Hidden 2 / id = H1x7_ act=SINE;
connect interval H1x7_;
connect H1x7_ Potability;
Hidden 2 / id = H1x8_ act=TANH;
connect interval H1x8_;
connect H1x8_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 8 SINGLE LAYER trial # 2 : TANH : ))";
prelim 8 outest=_anpre pretime=111 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 8 SINGLE LAYER trial # 2 : TANH : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=891 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 2 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 2 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=SINE;
connect interval H1x4_;
connect H1x4_ Potability;
Hidden 2 / id = H1x5_ act=SINE;
connect interval H1x5_;
connect H1x5_ Potability;
Hidden 2 / id = H1x6_ act=SINE;
connect interval H1x6_;
connect H1x6_ Potability;
Hidden 2 / id = H1x7_ act=SINE;
connect interval H1x7_;
connect H1x7_ Potability;
Hidden 2 / id = H1x8_ act=GAUSS;
connect interval H1x8_;
connect H1x8_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 8 SINGLE LAYER trial # 3 : NORMAL : ))";
prelim 8 outest=_anpre pretime=111 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 8 SINGLE LAYER trial # 3 : NORMAL : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=891 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 3 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 3 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=SINE;
connect interval H1x4_;
connect H1x4_ Potability;
Hidden 2 / id = H1x5_ act=SINE;
connect interval H1x5_;
connect H1x5_ Potability;
Hidden 2 / id = H1x6_ act=SINE;
connect interval H1x6_;
connect H1x6_ Potability;
Hidden 2 / id = H1x7_ act=SINE;
connect interval H1x7_;
connect H1x7_ Potability;
Hidden 2 / id = H1x8_ act=SINE;
connect interval H1x8_;
connect H1x8_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Search # 8 SINGLE LAYER trial # 4 : SINE : ))";
prelim 8 outest=_anpre pretime=111 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Search # 8 SINGLE LAYER trial # 4 : SINE : ))";
train estiter=1 outest=_anest outfit=_anfit maxtime=890 maxiter=8
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 8 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 8 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=SINE;
connect interval H1x4_;
connect H1x4_ Potability;
Hidden 2 / id = H1x5_ act=SINE;
connect interval H1x5_;
connect H1x5_ Potability;
Hidden 2 / id = H1x6_ act=SINE;
connect interval H1x6_;
connect H1x6_ Potability;
Hidden 2 / id = H1x7_ act=SINE;
connect interval H1x7_;
connect H1x7_ Potability;
*;
netoptions ranscale = 1;
*;
initial
inest = EMWS1.AutoNeural_ESTDS bylabel;
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_prelim_title  ,NOQUOTE, Final Training))";
prelim 8 outest=_anpre pretime=111 preiter=8
tech = Default
inest = EMWS1.AutoNeural_ESTDS bylabel
;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_train_title  ,NOQUOTE, Final Training))";
train estiter=1 outest=_anest outfit=_anfit maxtime=890 maxiter=5
tech = Default;
;
run;
*;
proc print data=_anfit(where=(_name_ eq 'OVERALL')) noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
*------------------------------------------------------------*;
* Extract best iteration;
;
*------------------------------------------------------------*;
%global _iter;
data _null_;
set _anfit(where=(_NAME_ eq 'OVERALL'));
retain _min 1e+64;
if _MISC_ < _min then do;
_min = _MISC_;
call symput('_iter',put(_ITER_, 6.));
end;
run;
*;
data EMWS1.AutoNeural_ESTDS;
set _anest;
if _ITER_ eq 2 then do;
output;
stop;
end;
run;
*;
data EMWS1.AutoNeural_OUTFIT;
set _anfit;
if _ITER_ eq 2 and _NAME_ eq "OVERALL" then do;
output;
stop;
end;
run;
*;
title9 " ";
title10 "%sysfunc(sasmsg(sashelp.dmine, rpt_selectediteration_title  , NOQUOTE, _MISC_))";
proc print data=EMWS1.AutoNeural_OUTFIT noobs;
var _iter_ _aic_ _averr_ _misc_
;
run;
title9;
title10;
*------------------------------------------------------------*;
* AutoNeural Final Network;
;
*------------------------------------------------------------*;
*;
proc neural data=EM_AutoNeural dmdbcat=WORK.AutoNeural_DMDB
;
*;
nloptions noprint;
performance alldetails noutilfile;
input %INTINPUTS / level=interval id=interval;
target Potability / level=NOMINAL id=Potability
;
*------------------------------------------------------------*;
* Layer #1;
;
*------------------------------------------------------------*;
Hidden 2 / id = H1x1_ act=GAUSS;
connect interval H1x1_;
connect H1x1_ Potability;
Hidden 2 / id = H1x2_ act=SINE;
connect interval H1x2_;
connect H1x2_ Potability;
Hidden 2 / id = H1x3_ act=GAUSS;
connect interval H1x3_;
connect H1x3_ Potability;
Hidden 2 / id = H1x4_ act=SINE;
connect interval H1x4_;
connect H1x4_ Potability;
Hidden 2 / id = H1x5_ act=SINE;
connect interval H1x5_;
connect H1x5_ Potability;
Hidden 2 / id = H1x6_ act=SINE;
connect interval H1x6_;
connect H1x6_ Potability;
Hidden 2 / id = H1x7_ act=SINE;
connect interval H1x7_;
connect H1x7_ Potability;
*;
initial inest= EMWS1.AutoNeural_ESTDS bylabel;
train tech=none;
code file="C:\Users\sbattina\Desktop\Water quality\Workspaces\EMWS1\AutoNeural\SCORECODE.sas"
group=AutoNeural
;
;
code file="C:\Users\sbattina\Desktop\Water quality\Workspaces\EMWS1\AutoNeural\RESIDUALSCORECODE.sas"
group=AutoNeural
residual
;
;
score data=EMWS1.Stat_TRAIN out=_NULL_
outfit=WORK.FIT1
role=TRAIN
outkey=EMWS1.AutoNeural_OUTKEY;
score data=EMWS1.Stat_TEST out=_NULL_
outfit=WORK.FIT2
role=TEST
outkey=EMWS1.AutoNeural_OUTKEY;
run;
data EMWS1.AutoNeural_OUTFIT;
merge WORK.FIT1 WORK.FIT2;
run;
*------------------------------------------------------------*;
* Generate Weights Plotting data set;
*------------------------------------------------------------*;
data tempweight ( drop = _tech_ _decay_ _seed_ _nobj_ _obj_ _objerr_ _averr_ _p_num_ where= (_type_ eq "PARMS"));
set EMWS1.AutoNeural_ESTDS;
run;
proc sort;
by _name_;
run;
proc transpose data=tempweight out=EMWS1.AutoNeural_WEIGHTS;
by _name_;
run;
data EMWS1.AutoNeural_WEIGHTS;
set EMWS1.AutoNeural_WEIGHTS;
FROM = ktrim(kleft(kscan(_LABEL_, 1, '-->')));
TO = ktrim(kleft(kscan(_LABEL_, 2, '>')));
WEIGHT = COL1;
if (TO eq '') or (FROM eq '') then delete;
label _LABEL_ ="%sysfunc(sasmsg(sashelp.dmine, meta_label_vlabel  , NOQUOTE))" FROM = "%sysfunc(sasmsg(sashelp.dmine, rpt_from_vlabel  , NOQUOTE))" TO = "%sysfunc(sasmsg(sashelp.dmine, rpt_into_vlabel  , NOQUOTE))" WEIGHT =
   "%sysfunc(sasmsg(sashelp.dmine, rpt_weight_vlabel  , NOQUOTE))";
keep FROM TO WEIGHT _LABEL_;
run;
* restore printing options;
;
title10;
options linesize=256;
options pagesize=999;
options nonumber;
options nocenter;
options nodate;
*;
