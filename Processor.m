function [gamma] = Processor(env, geo, gamma)
% -------------------------------------------------------------------------
% SwanVLM
% Version 5 (EXPORT)
% April 2009
% Copyright (C) 2008, 2009 Chris Walton (368404)

% Processor.m: Generates 'Right Hand Side' of the system of equations, i.e.
% generates boundary conditions from the 3D geometry, and then solves using
% MATLAB's backslash operator.
% -------------------------------------------------------------------------

% Pre-allocate RHS
RHS = zeros(geo.PanelCount, 1);

% Dynamic pressure
Q = env.V;

% Scans through all panels and sets boundary cond's
for i = 1:geo.PanelCount    
    % Find normal vector to panel
    normal = PanelTool(i, geo.ReferencePanelMatrix, 'Normal');
    
    % Determine panel orientation to freestream
    ProcAlpha = PanelTool(i, geo.BoundaryPanelMatrix, 'Alpha')+env.alpha;
    ProcBeta = -PanelTool(i, geo.BoundaryPanelMatrix, 'Beta')+env.beta;
    
    % RHS(i,1) = dot(normal./norm(normal), Q*[cos(ProcAlpha)*cos(ProcBeta), -sin(ProcBeta), sin(ProcAlpha)*cos(ProcBeta)]);
    % More efficient form of the above equation used to determine panel
    % tangential flow
    RHS(i,1) = sum(conj(normal./norm(normal)).*(Q*[cos(ProcAlpha)*cos(ProcBeta), -sin(ProcBeta), sin(ProcAlpha)*cos(ProcBeta)]));
end

% Solve full gamma matrix
gamma.total = gamma.Influence_Coeffs_a\RHS;
% Generate induced downwash matrix
gamma.w_ind = gamma.Influence_Coeffs_b*gamma.total;
end