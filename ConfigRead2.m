function [env2, meo] = ConfigRead2(FileName, meo)

% -------------------------------------------------------------------------
% SwanVLM
% Version 5 (EXPORT)
% April 2009
% Copyright (C) 2008, 2009 Chris Walton (368404)

% ConfigRead.m: Reads enviromental and meshing tabs from input excel file.
% -------------------------------------------------------------------------

% Open user's excel file with xlsread and read the enviroment (second) tab
[num,str]=xlsread(FileName, 2);

% Process numerical data into variables
env2.rho = num(1);
env2.V = num(2);
env2.AlphaMin = num(3);
env2.AlphaMax = num(4);
env2.AlphaStep = num(5);
env2.beta = num(6);
env2.CofG = [num(8) num(9) num(10)];

% Repeat for the mesh tab
[num,str]=xlsread(FileName, 3);
meo.chordwisepanels = num(1);
meo.totalpanels = num(2);
end