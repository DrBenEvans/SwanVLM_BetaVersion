function HorizontalAerodynamicSurfaces
% Set input file path
InputRelPath = 'Input/';


% Ask user for input filename
[filename, FileExists, geo.UserFileName] = InputConfig(InputRelPath);
if FileExists ~= 1
    DisplayUserUpdate(6)
    return
else
    DisplayUserUpdate(1)
    
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

% Would you like to get some graphs?
UserResponse = input('\nWould you like to get some graphs?\nN.B. Computer/MATLAB must be left to run undisturbed while animation is generated\n[Y/N]: ', 's');
if UserResponse == 'Y' || UserResponse == 'y'
    MakePictures3(result,geo,env,gamma)
end


% Vertical Aerodynamic Surfaces
%UserResponse = input('\n Does the configuration has vertical aerodynamic surfaces?\n[Y/N]: ', 's');
%if UserResponse == 'Y' || UserResponse == 'y'
    VerticalAerodynamicSurfaces1(geo,result,env)
%end

end