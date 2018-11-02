function SwanVLM

% -------------------------------------------------------------------------
% SwanVLM
% Version 6 (EXPORT)
% September 2017
% Copyright (C) 2008, 2009 Chris Walton (368404)

% SwanVLM.m: Central file from which all major functions are called.
% -------------------------------------------------------------------------

% Set input file path
InputRelPath = 'Input/';

% Display splash-screen
Splash

% Ask user for input filename
[filename, FileExists, geo.UserFileName] = InputConfig(InputRelPath);
if FileExists ~= 1
    DisplayUserUpdate(6)
    return
else 
    DisplayUserUpdate(1)
end

% Start runtime stopwatch
tic

% Read enviroment setup
[env, geo] = ConfigRead(filename, geo);
DisplayUserUpdate(2)

% Generate Mesh
[geo] = MeshGenerate3(filename, geo);
DisplayUserUpdate(3)

% Generate Inf. Coeff. Matrix
[gamma] = GenerateInfCoeff2(geo);

% Run solution for alpha's
[result, gamma] = solver(env, geo, gamma);
DisplayUserUpdate(4)

% Save result
	SaveResults(filename, result,geo)
DisplayUserUpdate(7)

% Stop runtime stopwawtch
toc

% Inform user
DisplayUserUpdate(5, filename)

% Make nice pictures?
UserResponse = input('\nWould you like to make some nice pictures?\nN.B. Computer/MATLAB must be left to run undisturbed while animation is generated\n[Y/N]: ', 's');
if UserResponse == 'Y' || UserResponse == 'y'
    MakePictures(result,geo,env,gamma)
end

% Return struct's to MATLAB workspace
 assignin('base','result',result);
 assignin('base','geo',geo);
 assignin('base','gamma',gamma);
 assignin('base','env',env);
end