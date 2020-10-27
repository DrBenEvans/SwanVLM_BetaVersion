function MeshTest

% -------------------------------------------------------------------------
% SwanVLM

% Version 6 (EXPORT)
% April 2020, Joan Ignasi Fontova(965420)

% Version 5 (EXPORT)
% April 2009
% Copyright (C) 2008, 2009 Chris Walton (368404)

% MeshTest.m: Genereates a preview plot of a geometry file.
% -------------------------------------------------------------------------

% Enviroment Variables
InputRelPath = 'Input/';

% Ask user for input filename
[filename] = InputConfig(InputRelPath);

% Read enviroment setup
[env, geo] = ConfigRead(filename);

% Generate Mesh
[geo] = MeshGenerate3(filename, geo);

% Plot Co-Ord Matrix
plot3(geo.ActualPanelMatrix(:,1),geo.ActualPanelMatrix(:,2),geo.ActualPanelMatrix(:,3),'xb')
end