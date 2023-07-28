if upcase(NAME) = "CHLORAMINES" then do;
ROLE = "INPUT";
end;
else 
if upcase(NAME) = "CONDUCTIVITY" then do;
ROLE = "INPUT";
end;
else 
if upcase(NAME) = "HARDNESS" then do;
ROLE = "INPUT";
end;
else 
if upcase(NAME) = "ORGANIC_CARBON" then do;
ROLE = "INPUT";
end;
else 
if upcase(NAME) = "PH" then do;
ROLE = "INPUT";
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
if upcase(NAME) = "SOLIDS" then do;
ROLE = "INPUT";
end;
else 
if upcase(NAME) = "SULFATE" then do;
ROLE = "INPUT";
end;
else 
if upcase(NAME) = "TRIHALOMETHANES" then do;
ROLE = "INPUT";
end;
else 
if upcase(NAME) = "TURBIDITY" then do;
ROLE = "INPUT";
end;
