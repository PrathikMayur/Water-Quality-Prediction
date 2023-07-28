***********************************;
*** Begin Scoring Code for Neural;
***********************************;
DROP _DM_BAD _EPS _NOCL_ _MAX_ _MAXP_ _SUM_ _NTRIALS;
 _DM_BAD = 0;
 _NOCL_ = .;
 _MAX_ = .;
 _MAXP_ = .;
 _SUM_ = .;
 _NTRIALS = .;
 _EPS =                1E-10;
LENGTH _WARN_ $4 
;
      label S_Chloramines = 'Standard: Chloramines' ;

      label S_Conductivity = 'Standard: Conductivity' ;

      label S_Hardness = 'Standard: Hardness' ;

      label S_Organic_carbon = 'Standard: Organic_carbon' ;

      label S_Solids = 'Standard: Solids' ;

      label S_Sulfate = 'Standard: Sulfate' ;

      label S_Trihalomethanes = 'Standard: Trihalomethanes' ;

      label S_Turbidity = 'Standard: Turbidity' ;

      label S_ph = 'Standard: ph' ;

      label H1x1_1 = 'Hidden: H1x1_=1' ;

      label H1x1_2 = 'Hidden: H1x1_=2' ;

      label H1x2_1 = 'Hidden: H1x2_=1' ;

      label H1x2_2 = 'Hidden: H1x2_=2' ;

      label H1x3_1 = 'Hidden: H1x3_=1' ;

      label H1x3_2 = 'Hidden: H1x3_=2' ;

      label H1x4_1 = 'Hidden: H1x4_=1' ;

      label H1x4_2 = 'Hidden: H1x4_=2' ;

      label H1x5_1 = 'Hidden: H1x5_=1' ;

      label H1x5_2 = 'Hidden: H1x5_=2' ;

      label H1x6_1 = 'Hidden: H1x6_=1' ;

      label H1x6_2 = 'Hidden: H1x6_=2' ;

      label H1x7_1 = 'Hidden: H1x7_=1' ;

      label H1x7_2 = 'Hidden: H1x7_=2' ;

      label I_Potability = 'Into: Potability' ;

      label U_Potability = 'Unnormalized Into: Potability' ;

      label P_Potability1 = 'Predicted: Potability=1' ;

      label P_Potability0 = 'Predicted: Potability=0' ;

      label  _WARN_ = "Warnings"; 

*** *************************;
*** Checking missing input Interval
*** *************************;

IF NMISS(
   Chloramines , 
   Conductivity , 
   Hardness , 
   Organic_carbon , 
   Solids , 
   Sulfate , 
   Trihalomethanes , 
   Turbidity , 
   ph   ) THEN DO;
   SUBSTR(_WARN_, 1, 1) = 'M';

   _DM_BAD = 1;
END;
*** *************************;
*** Writing the Node interval ;
*** *************************;
IF _DM_BAD EQ 0 THEN DO;
   S_Chloramines  =       -4.50501005342 +     0.63251720603908 * Chloramines
         ;
   S_Conductivity  =    -5.29911207208008 +     0.01240338503285 * 
        Conductivity ;
   S_Hardness  =    -5.89430747868857 +     0.02998075066667 * Hardness ;
   S_Organic_carbon  =    -4.33219612398808 +     0.30177389076335 * 
        Organic_carbon ;
   S_Solids  =    -2.48400518319212 +     0.00011225770067 * Solids ;
   S_Sulfate  =     -9.1431889354417 +      0.0274039209176 * Sulfate ;
   S_Trihalomethanes  =    -4.26353453862192 +     0.06428666289583 * 
        Trihalomethanes ;
   S_Turbidity  =    -5.11095692403985 +      1.2880737915681 * Turbidity ;
   S_ph  =    -4.83822436523827 +     0.68203205125917 * ph ;
END;
ELSE DO;
   IF MISSING( Chloramines ) THEN S_Chloramines  = . ;
   ELSE S_Chloramines  =       -4.50501005342 +     0.63251720603908 * 
        Chloramines ;
   IF MISSING( Conductivity ) THEN S_Conductivity  = . ;
   ELSE S_Conductivity  =    -5.29911207208008 +     0.01240338503285 * 
        Conductivity ;
   IF MISSING( Hardness ) THEN S_Hardness  = . ;
   ELSE S_Hardness  =    -5.89430747868857 +     0.02998075066667 * Hardness ;
   IF MISSING( Organic_carbon ) THEN S_Organic_carbon  = . ;
   ELSE S_Organic_carbon  =    -4.33219612398808 +     0.30177389076335 * 
        Organic_carbon ;
   IF MISSING( Solids ) THEN S_Solids  = . ;
   ELSE S_Solids  =    -2.48400518319212 +     0.00011225770067 * Solids ;
   IF MISSING( Sulfate ) THEN S_Sulfate  = . ;
   ELSE S_Sulfate  =     -9.1431889354417 +      0.0274039209176 * Sulfate ;
   IF MISSING( Trihalomethanes ) THEN S_Trihalomethanes  = . ;
   ELSE S_Trihalomethanes  =    -4.26353453862192 +     0.06428666289583 * 
        Trihalomethanes ;
   IF MISSING( Turbidity ) THEN S_Turbidity  = . ;
   ELSE S_Turbidity  =    -5.11095692403985 +      1.2880737915681 * Turbidity
         ;
   IF MISSING( ph ) THEN S_ph  = . ;
   ELSE S_ph  =    -4.83822436523827 +     0.68203205125917 * ph ;
END;
*** *************************;
*** Writing the Node H1x1_ ;
*** *************************;
IF _DM_BAD EQ 0 THEN DO;
   H1x1_1  =     0.30566584424554 * S_Chloramines  +     0.00697213016021 * 
        S_Conductivity  +    -0.21607438384485 * S_Hardness
          +     0.06070409334702 * S_Organic_carbon  +     0.02768428981262 * 
        S_Solids  +    -0.43079761704576 * S_Sulfate
          +    -0.00804218166386 * S_Trihalomethanes
          +      0.0056896368004 * S_Turbidity  +    -0.69905265567003 * S_ph
         ;
   H1x1_2  =     0.13735174060756 * S_Chloramines  +     0.02272028661413 * 
        S_Conductivity  +    -0.04206657597558 * S_Hardness
          +    -0.00513949286183 * S_Organic_carbon  +     0.17668589482904 * 
        S_Solids  +    -0.32885104695148 * S_Sulfate
          +     0.04299401471423 * S_Trihalomethanes
          +     0.00003193477054 * S_Turbidity  +     0.25063485303802 * S_ph
         ;
   H1x1_1  =     0.03879969432714 + H1x1_1 ;
   H1x1_2  =     -0.0142219537924 + H1x1_2 ;
   DROP _EXP_BAR;
   _EXP_BAR=50;
   H1x1_1  = EXP(MIN(-0.5 * H1x1_1 **2, _EXP_BAR));
   H1x1_2  = EXP(MIN(-0.5 * H1x1_2 **2, _EXP_BAR));
END;
ELSE DO;
   H1x1_1  = .;
   H1x1_2  = .;
END;
*** *************************;
*** Writing the Node H1x2_ ;
*** *************************;
IF _DM_BAD EQ 0 THEN DO;
   H1x2_1  =    -10.8582752552974 * S_Chloramines  +    -5.44023315917551 * 
        S_Conductivity  +     5.49116419942359 * S_Hardness
          +     5.06543759261539 * S_Organic_carbon  +     5.60665807792817 * 
        S_Solids  +    -9.72975380170336 * S_Sulfate
          +    -18.2068760199956 * S_Trihalomethanes
          +     16.4060319656996 * S_Turbidity  +     3.22126771279103 * S_ph
         ;
   H1x2_2  =     -17.929209620989 * S_Chloramines  +     5.97477018623226 * 
        S_Conductivity  +    -5.42035469986481 * S_Hardness
          +     -12.674919781521 * S_Organic_carbon  +    -18.7245577199557 * 
        S_Solids  +     0.23033147663462 * S_Sulfate
          +     1.19583080995008 * S_Trihalomethanes
          +       5.619264548855 * S_Turbidity  +     7.43972448145806 * S_ph
         ;
   H1x2_1  =    -30.3976702956707 + H1x2_1 ;
   H1x2_2  =     7.81804167237333 + H1x2_2 ;
   H1x2_1  = SIN(H1x2_1 );
   H1x2_2  = SIN(H1x2_2 );
END;
ELSE DO;
   H1x2_1  = .;
   H1x2_2  = .;
END;
*** *************************;
*** Writing the Node H1x3_ ;
*** *************************;
IF _DM_BAD EQ 0 THEN DO;
   H1x3_1  =    -29.8319375668184 * S_Chloramines  +    -14.6637084397608 * 
        S_Conductivity  +     8.38697524843319 * S_Hardness
          +    -18.6962632086841 * S_Organic_carbon  +    -27.3760861784481 * 
        S_Solids  +    -33.8124550161727 * S_Sulfate
          +    -3.17726266957316 * S_Trihalomethanes
          +    -20.8575529871582 * S_Turbidity  +      36.244331986755 * S_ph
         ;
   H1x3_2  =    -0.98214658974595 * S_Chloramines  +    -44.8893594169288 * 
        S_Conductivity  +     15.7699099671158 * S_Hardness
          +     15.9897184952728 * S_Organic_carbon  +    -12.1994298196191 * 
        S_Solids  +    -45.1239391953836 * S_Sulfate
          +     12.1390131759306 * S_Trihalomethanes
          +     70.0780886576125 * S_Turbidity  +    -38.0439211725387 * S_ph
         ;
   H1x3_1  =     28.0808168440928 + H1x3_1 ;
   H1x3_2  =    -41.6561990119554 + H1x3_2 ;
   DROP _EXP_BAR;
   _EXP_BAR=50;
   H1x3_1  = EXP(MIN(-0.5 * H1x3_1 **2, _EXP_BAR));
   H1x3_2  = EXP(MIN(-0.5 * H1x3_2 **2, _EXP_BAR));
END;
ELSE DO;
   H1x3_1  = .;
   H1x3_2  = .;
END;
*** *************************;
*** Writing the Node H1x4_ ;
*** *************************;
IF _DM_BAD EQ 0 THEN DO;
   H1x4_1  =     -0.4895313564878 * S_Chloramines  +    -1.30077445401824 * 
        S_Conductivity  +    -1.37668293829408 * S_Hardness
          +    -0.07361250868998 * S_Organic_carbon  +     1.07662468496905 * 
        S_Solids  +    -1.16819946555324 * S_Sulfate
          +    -0.49275012803992 * S_Trihalomethanes
          +    -0.08932543338359 * S_Turbidity  +     1.78292924362903 * S_ph
         ;
   H1x4_2  =    -5.74081871862257 * S_Chloramines  +    -2.37497473971408 * 
        S_Conductivity  +    -2.29524819796702 * S_Hardness
          +    -1.18511199591828 * S_Organic_carbon  +     2.36789153228033 * 
        S_Solids  +     1.24290111257494 * S_Sulfate
          +    -1.08773495288838 * S_Trihalomethanes
          +    -0.60827427169626 * S_Turbidity  +     0.86970015137544 * S_ph
         ;
   H1x4_1  =    -1.39227851278481 + H1x4_1 ;
   H1x4_2  =    -0.55505874052035 + H1x4_2 ;
   H1x4_1  = SIN(H1x4_1 );
   H1x4_2  = SIN(H1x4_2 );
END;
ELSE DO;
   H1x4_1  = .;
   H1x4_2  = .;
END;
*** *************************;
*** Writing the Node H1x5_ ;
*** *************************;
IF _DM_BAD EQ 0 THEN DO;
   H1x5_1  =     0.02487647203243 * S_Chloramines  +    -0.07580407146762 * 
        S_Conductivity  +      1.1889162334913 * S_Hardness
          +     0.08855493769155 * S_Organic_carbon  +     0.22349389703179 * 
        S_Solids  +     0.77296191115693 * S_Sulfate
          +     0.02498668375593 * S_Trihalomethanes
          +     0.07758883572789 * S_Turbidity  +      0.2369161561557 * S_ph
         ;
   H1x5_2  =    -0.22448425298349 * S_Chloramines  +     0.21348548533168 * 
        S_Conductivity  +     -1.6308631402476 * S_Hardness
          +    -0.00306809656382 * S_Organic_carbon  +    -0.98978895688609 * 
        S_Solids  +      0.2247345950194 * S_Sulfate
          +    -0.13026831526856 * S_Trihalomethanes
          +     0.03750251589647 * S_Turbidity  +    -0.20419786037287 * S_ph
         ;
   H1x5_1  =     1.37562233822892 + H1x5_1 ;
   H1x5_2  =     1.88631071576307 + H1x5_2 ;
   H1x5_1  = SIN(H1x5_1 );
   H1x5_2  = SIN(H1x5_2 );
END;
ELSE DO;
   H1x5_1  = .;
   H1x5_2  = .;
END;
*** *************************;
*** Writing the Node H1x6_ ;
*** *************************;
IF _DM_BAD EQ 0 THEN DO;
   H1x6_1  =    -0.57596451457791 * S_Chloramines  +     0.14803229371721 * 
        S_Conductivity  +     0.92921963538853 * S_Hardness
          +      1.4243915866025 * S_Organic_carbon  +    -0.01106149285001 * 
        S_Solids  +     0.24286481326619 * S_Sulfate
          +     0.94508673996891 * S_Trihalomethanes
          +    -0.66334612103173 * S_Turbidity  +      1.6041315406508 * S_ph
         ;
   H1x6_2  =    -0.50991823878896 * S_Chloramines  +    -0.25084522275926 * 
        S_Conductivity  +    -0.64360405044316 * S_Hardness
          +    -0.16643326586752 * S_Organic_carbon  +     0.64962381782358 * 
        S_Solids  +     0.32296903562387 * S_Sulfate
          +     0.70870426558059 * S_Trihalomethanes
          +     -1.9940952433579 * S_Turbidity  +     -0.7389766943498 * S_ph
         ;
   H1x6_1  =      0.2466495368036 + H1x6_1 ;
   H1x6_2  =    -0.17959320346156 + H1x6_2 ;
   H1x6_1  = SIN(H1x6_1 );
   H1x6_2  = SIN(H1x6_2 );
END;
ELSE DO;
   H1x6_1  = .;
   H1x6_2  = .;
END;
*** *************************;
*** Writing the Node H1x7_ ;
*** *************************;
IF _DM_BAD EQ 0 THEN DO;
   H1x7_1  =    -1.48931620938327 * S_Chloramines  +    -0.06210778364065 * 
        S_Conductivity  +    -0.45540063004509 * S_Hardness
          +     1.18273613290922 * S_Organic_carbon  +     0.53145660170001 * 
        S_Solids  +    -1.26595623688691 * S_Sulfate
          +    -0.52587193599153 * S_Trihalomethanes
          +     1.71950121421242 * S_Turbidity  +    -0.11112762812336 * S_ph
         ;
   H1x7_2  =    -1.59081444107573 * S_Chloramines  +    -1.72073531848156 * 
        S_Conductivity  +     0.72467157124386 * S_Hardness
          +    -0.45008766139459 * S_Organic_carbon  +    -2.44887358408966 * 
        S_Solids  +     0.35303384766824 * S_Sulfate
          +     0.18201328187995 * S_Trihalomethanes
          +    -1.05237310521511 * S_Turbidity  +    -1.19696541426209 * S_ph
         ;
   H1x7_1  =     0.18730806473325 + H1x7_1 ;
   H1x7_2  =     1.41807845901477 + H1x7_2 ;
   H1x7_1  = SIN(H1x7_1 );
   H1x7_2  = SIN(H1x7_2 );
END;
ELSE DO;
   H1x7_1  = .;
   H1x7_2  = .;
END;
*** *************************;
*** Writing the Node Potability ;
*** *************************;
IF _DM_BAD EQ 0 THEN DO;
   P_Potability1  =     2.82340382572424 * H1x1_1  +    -6.46934514602573 * 
        H1x1_2 ;
   P_Potability1  = P_Potability1  +     0.40016234070411 * H1x2_1
          +    -0.35263672214408 * H1x2_2 ;
   P_Potability1  = P_Potability1  +     2.25844590223664 * H1x3_1
          +     3.94243361914597 * H1x3_2 ;
   P_Potability1  = P_Potability1  +     0.45313267737495 * H1x4_1
          +    -0.31498802648577 * H1x4_2 ;
   P_Potability1  = P_Potability1  +    -0.97617345670524 * H1x5_1
          +      0.8754343950558 * H1x5_2 ;
   P_Potability1  = P_Potability1  +    -0.26235311495673 * H1x6_1
          +    -0.03661533907922 * H1x6_2 ;
   P_Potability1  = P_Potability1  +    -0.29415981318587 * H1x7_1
          +     0.04579476861137 * H1x7_2 ;
   P_Potability1  =     3.42147481165999 + P_Potability1 ;
   P_Potability0  = 0; 
   _MAX_ = MAX (P_Potability1 , P_Potability0 );
   _SUM_ = 0.; 
   P_Potability1  = EXP(P_Potability1  - _MAX_);
   _SUM_ = _SUM_ + P_Potability1 ;
   P_Potability0  = EXP(P_Potability0  - _MAX_);
   _SUM_ = _SUM_ + P_Potability0 ;
   P_Potability1  = P_Potability1  / _SUM_;
   P_Potability0  = P_Potability0  / _SUM_;
END;
ELSE DO;
   P_Potability1  = .;
   P_Potability0  = .;
END;
IF _DM_BAD EQ 1 THEN DO;
   P_Potability1  =     0.38984345169912;
   P_Potability0  =     0.61015654830087;
END;
*** *************************;
*** Writing the I_Potability  AND U_Potability ;
*** *************************;
_MAXP_ = P_Potability1 ;
I_Potability  = "1           " ;
U_Potability  =                    1;
IF( _MAXP_ LT P_Potability0  ) THEN DO; 
   _MAXP_ = P_Potability0 ;
   I_Potability  = "0           " ;
   U_Potability  =                    0;
END;
********************************;
*** End Scoring Code for Neural;
********************************;
