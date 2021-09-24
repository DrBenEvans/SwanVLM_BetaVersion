function SwanVLM
clc; close ALL; clear;
% -------------------------------------------------------------------------
% SwanVLM
% Version 7 (EXPORT)
% April 2021, Yash Sooriyakanthan (970070)

% Version 6 (EXPORT)
% April 2020, Joan Ignasi Fontova(965420)

% Version 5 (EXPORT)
% April 2009
% Copyright (C) 2008, 2009 Chris Walton (368404)

% SwanVLM.m: Central file from which all major functions are called.
% -------------------------------------------------------------------------
Splash

disp('[1] Single Horizontal Lifting Surface')
disp('(use this option to produce a spanwise lift distribution plot on a single wing)')
disp(' ')
disp('[2] Multiple Horizontal Lifting Surfaces')
disp('(use this option to study the pitch stability of a configuration of multiple horizontal surfaces)')
disp(' ')
disp('[3] Vertical Aerodynamic Surfaces Only')
disp('(use this option to study directional stability characteristics only)')
disp(' ')
disp('[4] Full aircraft configuration')
disp('(use this option to study the combined pitch and directional stability properties of a configuration)')
disp(' ')

option=input('Selection(1-4):');
if option==1
%    UserResponse = input('\n Does the configuration have horizontal aerodynamic surfaces?\n[Y/N]: ', 's');
%    if UserResponse == 'Y' || UserResponse == 'y'
         HorizontalAerodynamicSurfaces1
%    end
elseif option==2
%    UserResponse = input('\n Does the configuration have horizontal aerodynamic surfaces?\n[Y/N]: ', 's');
%    if UserResponse == 'Y' || UserResponse == 'y'
         HorizontalAerodynamicSurfaces2
%    end
elseif option==3
%    UserResponse = input('\n Does the configuration have vertical aerodynamic surfaces?\n[Y/N]: ', 's');
%    if UserResponse == 'Y' || UserResponse == 'y'
        VerticalAerodynamicSurfaces
%    end
elseif option==4
%    UserResponse = input('\n Does the configuration have horizontal aerodynamic surfaces?\n[Y/N]: ', 's');
%    if UserResponse == 'Y' || UserResponse == 'y'
         HorizontalAerodynamicSurfaces
%    end

end

disp('Modelling Completed')

        
  
end