function [env, geo] = ConfigRead(FileName, geo)

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
env.H = num(1);
env.rho = num(2);
env.T = num(3);
env.nju = num(4);
env.Re = num(5); % Reynolds number
env.M = num(6);
env.V = num(7);
env.AlphaMin = num(8);
env.AlphaMax =  num(9);
env.AlphaStep = num(10);
env.beta = num(11);
env.CofG = [num(12) num(13) num(14)];

% Repeat for the mesh tab
[num,str]=xlsread(FileName, 3);
geo.chordwisepanels = num(1);
geo.totalpanels = num(2);
end