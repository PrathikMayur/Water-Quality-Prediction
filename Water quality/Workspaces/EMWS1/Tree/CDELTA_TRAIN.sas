if upcase(NAME) = "CONDUCTIVITY" then do;
ROLE = "REJECTED";
end;
else 
if upcase(NAME) = "Q_POTABILITY0" then do;
ROLE = "ASSESS";
end;
else 
if upcase(NAME) = "Q_POTABILITY1" then do;
ROLE = "ASSESS";
end;
else 
if upcase(NAME) = "TRIHALOMETHANES" then do;
ROLE = "REJECTED";
end;
else 
if upcase(NAME) = "_NODE_" then do;
ROLE = "SEGMENT";
LEVEL = "NOMINAL";
end;
