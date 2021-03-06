function [env, geo] = ConfigRead(FileName, geo)

% -------------------------------------------------------------------------
% SwanVLM

% Version 6 (EXPORT)
% April 2020, Joan Ignasi Fontova(965420)

% Version 5 (EXPORT)
% April 2009
% Copyright (C) 2008, 2009 Chris Walton (368404)

% ConfigRead.m: Reads enviromental and meshing tabs from input excel file.
% -------------------------------------------------------------------------

% Open user's excel file with xlsread and read the enviroment (second) tab
[num,str]=xlsread(FileName, 2);

% Process numerical data into variables
env.rho = num(1);
env.V = num(2);
env.AlphaMin = num(3);
env.AlphaMax = num(4);
env.AlphaStep = num(5);
env.beta = num(6);
env.CofG = [num(8) num(9) num(10)];

% Repeat for the mesh tab
[num,str]=xlsread(FileName, 3);
geo.chordwisepanels = num(1);
geo.totalpanels = num(2);
end