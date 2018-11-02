function [gamma] = GenerateInfCoeff2(geo)

% -------------------------------------------------------------------------
% SwanVLM
% Version 5 (EXPORT)
% April 2009
% Copyright (C) 2008, 2009 Chris Walton (368404)

% GenerateInfCoeff2.m: Using the input geometry, this function generates a
% matrix of influence coefficients.

% Inline Functions: HSHOE_Panel, VORTXL3
% -------------------------------------------------------------------------


% Pre-allocate influence co-effs matrix
gamma.Influence_Coeffs_a = zeros(geo.PanelCount);
gamma.Influence_Coeffs_b = zeros(geo.PanelCount);

% Set infinite wake distance
InfDist = 6*geo.b_ref;

for i = 1:geo.PanelCount
    % Find panel normal
    normal = PanelTool(i, geo.ReferencePanelMatrix, 'Normal');
    
    for j = 1:geo.PanelCount
        % Call HSHOE_Panel to find induced velocity at collocation point
        % for a unit strength horseshoe vortex
        Vp = HSHOE_Panel(i, j, 1, geo.ReferencePanelMatrix, InfDist);

        % Find dot product of induced velocity and normal vector, and
        % record as influence co-eff
        gamma.Influence_Coeffs_a(i,j) = sum(conj(normal./norm(normal)).*Vp(1,:));
        gamma.Influence_Coeffs_b(i,j) = sum(conj(normal./norm(normal)).*Vp(2,:));
        
        % Above lines are a more efficicent case of the following;
        % gamma.Influence_Coeffs_a(i,j) = dot(normal./norm(normal), Vp(1,:));
        % gamma.Influence_Coeffs_b(i,j) = dot(normal./norm(normal), Vp(2,:));
    end

    % Update user-progress
    if isequal(i/((geo.PanelCount)/10), round(i/((geo.PanelCount)/10))) == 1
        disp(sprintf('\b.'));
    end

end

end

function [Vp] = HSHOE_Panel(i, k, Gamma, FlatPanelMatrix, InfDist)

% -------------------------------------------------------------------------
% HSHOE_Panel: Determines co-ordinate points of a horse-shoe vortex and
% collocation point on a panel, and then calls VORTXL3 to determine induced
% velocity.
% -------------------------------------------------------------------------

% Draw xyz co-ords for collocation panel-corners from FlatPanelMatrix
[P_xyz] = OrdRecall(i, FlatPanelMatrix);

% Repeat for horshoe source-panel
[HS_xyz] = OrdRecall(k, FlatPanelMatrix);

% Calculate position P (collocation point) with respect to panel corners
P = (P_xyz(4,:)+((P_xyz(1,:)-P_xyz(4,:))./4))+(0.5*((P_xyz(3,:)+((P_xyz(2,:)-P_xyz(3,:))./4))-(P_xyz(4,:)+((P_xyz(1,:)-P_xyz(4,:))./4))));

% Calculate co-ords for each segment of horseshoe vortex.
% A to B, 'infinite' vortex
% B to C, bound vortex
% C to D, 'infinite' vortex
B = HS_xyz(1,:)+((HS_xyz(4,:)-HS_xyz(1,:))./4);
C = HS_xyz(2,:)+((HS_xyz(3,:)-HS_xyz(2,:))./4);
A = [InfDist HS_xyz(4,2) HS_xyz(4,3)];
D = [InfDist HS_xyz(3,2) HS_xyz(3,3)];

% If Co-Ords exist in the -y plane, 'mirror' the horseshoe co-ords
% Ensures correct vortex influence signs
if C(2) < 0 && D(2) < 0
    TempSwap = [A;B;C;D];
    A = TempSwap(4,:);
    B = TempSwap(3,:);
    C = TempSwap(2,:);
    D = TempSwap(1,:);
end

% Call VORTXL to find induced velocity of each horseshoe vortex element
TempVp(1,:) = VORTXL3(P, A, B, Gamma);
TempVp(2,:) = VORTXL3(P, B, C, Gamma);
TempVp(3,:) = VORTXL3(P, C, D, Gamma);

% Provide full velocity, and induced (i.e. that due to trailing
% vorticies only) velocities
Vp(1,:) = sum(TempVp);
Vp(2,:) = TempVp(1,:)+TempVp(3,:);
end

function Vp = VORTXL3(P, A, B, Gamma)

% -------------------------------------------------------------------------
% VORTXL3: Given the start and end points of a vortex filament (A,B),
% calcuates velocity induced at point P.
% -------------------------------------------------------------------------

% Determine vortex vectors
r0 = A-B;
r1 = (P-A)';
r2 = (P-B)';

% Find cross-product of r1 and r2 (more efficient than using cross(r1,r2))
crossr1r2 = [r1(2,:).*r2(3,:)-r1(3,:).*r2(2,:)
     r1(3,:).*r2(1,:)-r1(1,:).*r2(3,:)
     r1(1,:).*r2(2,:)-r1(2,:).*r2(1,:)]';
 
% Following formula is used with a more 'MATLAB computationally efficient'
% form (avoids using built in dot product function)
% Vp = (Gamma/(4*pi))*(cross(r1,r2)/norm(cross(r1,r2))^2)*dot(r0,((r1/norm(r1))-(r2/norm(r2))))
Vp = ((Gamma/(4*pi))*(crossr1r2/norm(crossr1r2)^2)*sum(conj(r0).*((r1'/norm(r1'))-(r2'/norm(r2')))));
end