****************************************************************;
******             DECISION TREE SCORING CODE             ******;
****************************************************************;
 
******         LENGTHS OF NEW CHARACTER VARIABLES         ******;
LENGTH F_Potability  $   12;
LENGTH I_Potability  $   12;
LENGTH _WARN_  $    4;
 
******              LABELS FOR NEW VARIABLES              ******;
label _NODE_ = 'Node' ;
label _LEAF_ = 'Leaf' ;
label P_Potability0 = 'Predicted: Potability=0' ;
label P_Potability1 = 'Predicted: Potability=1' ;
label Q_Potability0 = 'Unadjusted P: Potability=0' ;
label Q_Potability1 = 'Unadjusted P: Potability=1' ;
label R_Potability0 = 'Residual: Potability=0' ;
label R_Potability1 = 'Residual: Potability=1' ;
label F_Potability = 'From: Potability' ;
label I_Potability = 'Into: Potability' ;
label U_Potability = 'Unnormalized Into: Potability' ;
label _WARN_ = 'Warnings' ;
 
 
******      TEMPORARY VARIABLES FOR FORMATTED VALUES      ******;
LENGTH _ARBFMT_12 $     12; DROP _ARBFMT_12;
_ARBFMT_12 = ' '; /* Initialize to avoid warning. */
 
 
_ARBFMT_12 = PUT( Potability , BEST12.);
 %DMNORMCP( _ARBFMT_12, F_Potability );
 
******             ASSIGN OBSERVATION TO NODE             ******;
IF  NOT MISSING(Sulfate ) AND
  Sulfate  <     286.444334038812 THEN DO;
  IF  NOT MISSING(ph ) AND
        7.19333774685046 <= ph  THEN DO;
    IF  NOT MISSING(Turbidity ) AND
      Turbidity  <     3.15461617527314 THEN DO;
      _NODE_  =                   10;
      _LEAF_  =                    6;
      P_Potability0  =               0.5625;
      P_Potability1  =               0.4375;
      Q_Potability0  =               0.5625;
      Q_Potability1  =               0.4375;
      I_Potability  = '0' ;
      U_Potability  =                    0;
      END;
    ELSE DO;
      _NODE_  =                   11;
      _LEAF_  =                    7;
      P_Potability0  =     0.12162162162162;
      P_Potability1  =     0.87837837837837;
      Q_Potability0  =     0.12162162162162;
      Q_Potability1  =     0.87837837837837;
      I_Potability  = '1' ;
      U_Potability  =                    1;
      END;
    END;
  ELSE DO;
    IF  NOT MISSING(Solids ) AND
      Solids  <     19398.8450390458 THEN DO;
      IF  NOT MISSING(Organic_carbon ) AND
        Organic_carbon  <     10.7148897100055 THEN DO;
        _NODE_  =                   16;
        _LEAF_  =                    1;
        P_Potability0  =     0.42857142857142;
        P_Potability1  =     0.57142857142857;
        Q_Potability0  =     0.42857142857142;
        Q_Potability1  =     0.57142857142857;
        I_Potability  = '1' ;
        U_Potability  =                    1;
        END;
      ELSE DO;
        _NODE_  =                   17;
        _LEAF_  =                    2;
        P_Potability0  =     0.89130434782608;
        P_Potability1  =     0.10869565217391;
        Q_Potability0  =     0.89130434782608;
        Q_Potability1  =     0.10869565217391;
        I_Potability  = '0' ;
        U_Potability  =                    0;
        END;
      END;
    ELSE DO;
      IF  NOT MISSING(Hardness ) AND
        Hardness  <     193.974365294055 THEN DO;
        IF  NOT MISSING(ph ) AND
          ph  <     5.40697519851934 THEN DO;
          _NODE_  =                   24;
          _LEAF_  =                    3;
          P_Potability0  =     0.83333333333333;
          P_Potability1  =     0.16666666666666;
          Q_Potability0  =     0.83333333333333;
          Q_Potability1  =     0.16666666666666;
          I_Potability  = '0' ;
          U_Potability  =                    0;
          END;
        ELSE DO;
          _NODE_  =                   25;
          _LEAF_  =                    4;
          P_Potability0  =     0.14285714285714;
          P_Potability1  =     0.85714285714285;
          Q_Potability0  =     0.14285714285714;
          Q_Potability1  =     0.85714285714285;
          I_Potability  = '1' ;
          U_Potability  =                    1;
          END;
        END;
      ELSE DO;
        _NODE_  =                   19;
        _LEAF_  =                    5;
        P_Potability0  =                  0.6;
        P_Potability1  =                  0.4;
        Q_Potability0  =                  0.6;
        Q_Potability1  =                  0.4;
        I_Potability  = '0' ;
        U_Potability  =                    0;
        END;
      END;
    END;
  END;
ELSE DO;
  IF  NOT MISSING(Sulfate ) AND
         363.46745680074 <= Sulfate  THEN DO;
    IF  NOT MISSING(ph ) AND
          7.79417057963898 <= ph  THEN DO;
      IF  NOT MISSING(Chloramines ) AND
            9.43085791478326 <= Chloramines  THEN DO;
        _NODE_  =                   23;
        _LEAF_  =                   12;
        P_Potability0  =     0.14285714285714;
        P_Potability1  =     0.85714285714285;
        Q_Potability0  =     0.14285714285714;
        Q_Potability1  =     0.85714285714285;
        I_Potability  = '1' ;
        U_Potability  =                    1;
        END;
      ELSE DO;
        _NODE_  =                   22;
        _LEAF_  =                   11;
        P_Potability0  =     0.82568807339449;
        P_Potability1  =      0.1743119266055;
        Q_Potability0  =     0.82568807339449;
        Q_Potability1  =      0.1743119266055;
        I_Potability  = '0' ;
        U_Potability  =                    0;
        END;
      END;
    ELSE DO;
      _NODE_  =                   14;
      _LEAF_  =                   10;
      P_Potability0  =     0.43567251461988;
      P_Potability1  =     0.56432748538011;
      Q_Potability0  =     0.43567251461988;
      Q_Potability1  =     0.56432748538011;
      I_Potability  = '1' ;
      U_Potability  =                    1;
      END;
    END;
  ELSE DO;
    IF  NOT MISSING(Hardness ) AND
      Hardness  <     101.118201096076 THEN DO;
      _NODE_  =                   12;
      _LEAF_  =                    8;
      P_Potability0  =                    0;
      P_Potability1  =                    1;
      Q_Potability0  =                    0;
      Q_Potability1  =                    1;
      I_Potability  = '1' ;
      U_Potability  =                    1;
      END;
    ELSE DO;
      _NODE_  =                   13;
      _LEAF_  =                    9;
      P_Potability0  =     0.65430809399477;
      P_Potability1  =     0.34569190600522;
      Q_Potability0  =     0.65430809399477;
      Q_Potability1  =     0.34569190600522;
      I_Potability  = '0' ;
      U_Potability  =                    0;
      END;
    END;
  END;
 
*****  RESIDUALS R_ *************;
IF  F_Potability  NE '0'
AND F_Potability  NE '1'  THEN DO;
        R_Potability0  = .;
        R_Potability1  = .;
 END;
 ELSE DO;
       R_Potability0  =  -P_Potability0 ;
       R_Potability1  =  -P_Potability1 ;
       SELECT( F_Potability  );
          WHEN( '0'  ) R_Potability0  = R_Potability0  +1;
          WHEN( '1'  ) R_Potability1  = R_Potability1  +1;
       END;
 END;
 
****************************************************************;
******          END OF DECISION TREE SCORING CODE         ******;
****************************************************************;
 
drop _LEAF_;
