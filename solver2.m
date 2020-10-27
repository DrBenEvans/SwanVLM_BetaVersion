function [result2, gamma2] = solver2(env2, meo, gamma2)

% -------------------------------------------------------------------------
% SwanVLM
% Version 5 (EXPORT)
% April 2009
% Copyright (C) 2008, 2009 Chris Walton (368404)

% solver.m: Draws together the processor and post-processor to solve gamma
% for each specified angle of attack.
% -------------------------------------------------------------------------


% Initialise the result struct variables
result2.CLift = [];
result2.CDrag = [];
result2.AlphaGeo = [];
result2.w_ind = [];
result2.gamma = [];

% Generate a row matrix of alpha's to solve for
gamma2.AlphaRange = env2.AlphaMin:env2.AlphaStep:env2.AlphaMax;

% Call Processor and Post-Processor for each alpha
for i = 1:length(gamma2.AlphaRange)
    % Convert alpha to rad's and set
    env2.alpha = (pi/180)*(gamma2.AlphaRange(i));

    % Call the Processor
    [gamma2] = Processor(env2, meo, gamma2);

    % Call the Post-Processor
    [result2] = PostProcess3(env2, meo, gamma2, result2, 'InAlphaLoop');
    
    % Store each set of result for gamma (vortex strength)
    result2.gamma(:,i) = gamma2.total(:,1);
end


% Call final post-processing routines
[result2] = PostProcess3(env2, meo, gamma2, result2, 'PostAlphaLoop');
[result2] = PostProcess3(env2, meo, gamma2, result2, 'FinalProcessing');