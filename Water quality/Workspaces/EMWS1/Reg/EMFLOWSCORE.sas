*************************************;
*** begin scoring code for regression;
*************************************;

length _WARN_ $4;
label _WARN_ = 'Warnings' ;

length I_Potability $ 12;
label I_Potability = 'Into: Potability' ;
*** Target Values;
array REGDRF [2] $12 _temporary_ ('1' '0' );
label U_Potability = 'Unnormalized Into: Potability' ;
format U_Potability BEST12.;
*** Unnormalized target values;
ARRAY REGDRU[2]  _TEMPORARY_ (1 0);

*** Generate dummy variables for Potability ;
drop _Y ;
label F_Potability = 'From: Potability' ;
length F_Potability $ 12;
F_Potability = put( Potability , BEST12. );
%DMNORMIP( F_Potability )
if missing( Potability ) then do;
   _Y = .;
end;
else do;
   if F_Potability = '0'  then do;
      _Y = 1;
   end;
   else if F_Potability = '1'  then do;
      _Y = 0;
   end;
   else do;
      _Y = .;
   end;
end;

drop _DM_BAD;
_DM_BAD=0;

*** Check Chloramines for missing values ;
if missing( Chloramines ) then do;
   substr(_warn_,1,1) = 'M';
   _DM_BAD = 1;
end;

*** Check Conductivity for missing values ;
if missing( Conductivity ) then do;
   substr(_warn_,1,1) = 'M';
   _DM_BAD = 1;
end;

*** Check Hardness for missing values ;
if missing( Hardness ) then do;
   substr(_warn_,1,1) = 'M';
   _DM_BAD = 1;
end;

*** Check Organic_carbon for missing values ;
if missing( Organic_carbon ) then do;
   substr(_warn_,1,1) = 'M';
   _DM_BAD = 1;
end;

*** Check Solids for missing values ;
if missing( Solids ) then do;
   substr(_warn_,1,1) = 'M';
   _DM_BAD = 1;
end;

*** Check Sulfate for missing values ;
if missing( Sulfate ) then do;
   substr(_warn_,1,1) = 'M';
   _DM_BAD = 1;
end;

*** Check Trihalomethanes for missing values ;
if missing( Trihalomethanes ) then do;
   substr(_warn_,1,1) = 'M';
   _DM_BAD = 1;
end;

*** Check Turbidity for missing values ;
if missing( Turbidity ) then do;
   substr(_warn_,1,1) = 'M';
   _DM_BAD = 1;
end;

*** Check ph for missing values ;
if missing( ph ) then do;
   substr(_warn_,1,1) = 'M';
   _DM_BAD = 1;
end;
*** If missing inputs, use averages;
if _DM_BAD > 0 then do;
   _P0 = 0.3898434517;
   _P1 = 0.6101565483;
   goto REGDR1;
end;

*** Compute Linear Predictor;
drop _TEMP;
drop _LP0;
_LP0 = 0;

***  Effect: Chloramines ;
_TEMP = Chloramines ;
_LP0 = _LP0 + (    0.02839429840643 * _TEMP);

***  Effect: Conductivity ;
_TEMP = Conductivity ;
_LP0 = _LP0 + (   -0.00044444602101 * _TEMP);

***  Effect: Hardness ;
_TEMP = Hardness ;
_LP0 = _LP0 + (   -0.00105324742473 * _TEMP);

***  Effect: Organic_carbon ;
_TEMP = Organic_carbon ;
_LP0 = _LP0 + (    -0.0183600892244 * _TEMP);

***  Effect: Solids ;
_TEMP = Solids ;
_LP0 = _LP0 + (  9.9833578171954E-6 * _TEMP);

***  Effect: Sulfate ;
_TEMP = Sulfate ;
_LP0 = _LP0 + (   -0.00059373655903 * _TEMP);

***  Effect: Trihalomethanes ;
_TEMP = Trihalomethanes ;
_LP0 = _LP0 + (    0.00155871475481 * _TEMP);

***  Effect: Turbidity ;
_TEMP = Turbidity ;
_LP0 = _LP0 + (    0.01310504094638 * _TEMP);

***  Effect: ph ;
_TEMP = ph ;
_LP0 = _LP0 + (    0.00748162935382 * _TEMP);

*** Naive Posterior Probabilities;
drop _MAXP _IY _P0 _P1;
_TEMP =    -0.22280784293283 + _LP0;
if (_TEMP < 0) then do;
   _TEMP = exp(_TEMP);
   _P0 = _TEMP / (1 + _TEMP);
end;
else _P0 = 1 / (1 + exp(-_TEMP));
_P1 = 1.0 - _P0;

REGDR1:

*** Residuals;
if (_Y = .) then do;
   R_Potability1 = .;
   R_Potability0 = .;
end;
else do;
    label R_Potability1 = 'Residual: Potability=1' ;
    label R_Potability0 = 'Residual: Potability=0' ;
   R_Potability1 = - _P0;
   R_Potability0 = - _P1;
   select( _Y );
      when (0)  R_Potability1 = R_Potability1 + 1;
      when (1)  R_Potability0 = R_Potability0 + 1;
   end;
end;

*** Posterior Probabilities and Predicted Level;
label P_Potability1 = 'Predicted: Potability=1' ;
label P_Potability0 = 'Predicted: Potability=0' ;
P_Potability1 = _P0;
_MAXP = _P0;
_IY = 1;
P_Potability0 = _P1;
if (_P1 >  _MAXP + 1E-8) then do;
   _MAXP = _P1;
   _IY = 2;
end;
I_Potability = REGDRF[_IY];
U_Potability = REGDRU[_IY];

*************************************;
***** end scoring code for regression;
*************************************;
