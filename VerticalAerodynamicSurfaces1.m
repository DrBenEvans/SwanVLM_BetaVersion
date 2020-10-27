function VerticalAerodynamicSurfaces1(geo,result,env)


% Set input file path
InputRelPath = 'Input/';

% Ask user for input filename
[filename, FileExists, meo.UserFileName] = InputConfig1(InputRelPath);
if FileExists ~= 1
    DisplayUserUpdate(6)
    return
else
    DisplayUserUpdate(1)
end

tic

% Read enviroment setup
[env2, meo] = ConfigRead2(filename, meo);
DisplayUserUpdate(2)

% Generate Mesh
[meo] = MeshGenerate4(filename, meo);
DisplayUserUpdate(3)

% Generate Inf. Coeff. Matrix
[gamma2] = GenerateInfCoeff3(meo);

% Run solution for alpha's
[result2, gamma2] = solver2(env2, meo, gamma2);
DisplayUserUpdate(4)

% Save result
SaveResults1(filename, result2,meo)
DisplayUserUpdate(7)

% Stop runtime stopwawtch
toc

% Inform user
DisplayUserUpdate(5, filename)

% Make nice pictures?
UserResponse = input('\n Would you like to make some nice pictures?\nN.B. Computer/MATLAB must be left to run undisturbed while animation is generated\n[Y/N]: ', 's');
if UserResponse == 'Y' || UserResponse == 'y'
    MakePictures2(result2,meo,env2,gamma2)
end

% Make nice pictures?
UserResponse = input('\n Would you like to get the full geometry plot?\n[Y/N]: ', 's');
if UserResponse == 'Y' || UserResponse == 'y'
    GeometryPlot(geo,meo,result2,result,env,env2)
end

end