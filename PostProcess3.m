function [result] = PostProcess3(env, geo, gamma, result, LocationOption)

% -------------------------------------------------------------------------
% SwanVLM

% Version 6 (EXPORT)
% April 2020, Joan Ignasi Fontova(965420)

% Version 5 (EXPORT)
% April 2009
% Copyright (C) 2008, 2009 Chris Walton (368404)

% PostProcess.m: Performs post-processing of gamma (vortex strength) values

% Inline Functions: FindAeroCentre
% -------------------------------------------------------------------------

switch LocationOption
    case 'InAlphaLoop'       
        % -----------------------------------------------------------------
        % Converts vortex strength gamma into engineering units (e.g. Coeff
        % of Lift)
        % -----------------------------------------------------------------

        % Pre-populate matrix of panel lift and area
        PanelLift = zeros(length(gamma.total),1);
        PanelDrag = zeros(length(gamma.total),1);
        Panel_Area = zeros(length(gamma.total),1);

        % Loop to take gamma value for each panel and output lift
        % and drag
        for i = 1:length(gamma.total)
            % Calculate lift and drag values and store in PanelLift
            PanelLift(i,1) = env.rho*env.V*gamma.total(i,1)*PanelTool(i, geo.ReferencePanelMatrix, 'Span');
            PanelDrag(i,1) = env.rho*gamma.w_ind(i,1)*gamma.total(i,1)*PanelTool(i, geo.ReferencePanelMatrix, 'Span');
        end

        % Add up all panel lift and areas
        TotalLift = sum(PanelLift);
        TotalDrag = sum(PanelDrag);

        % Store results
        Q = 0.5*env.rho*env.V^2;
        result.CDrag(end+1) = TotalDrag/(Q*geo.S_ref);
        result.CLift(end+1) = TotalLift/(Q*geo.S_ref);
        result.AlphaGeo(end+1) = env.alpha*(180/pi);
        result.w_ind(end+1) = sum(gamma.w_ind);

    case 'PostAlphaLoop'
        % -----------------------------------------------------------------
        % Finds AoA such that downwash == 0 and then back calculates
        % induced AoA and corresponding CL
        % -----------------------------------------------------------------

        % Generate straight line fit of geometric alpha vs w_ind
        w_ind_linefit = polyfit(result.AlphaGeo,result.w_ind,1);
        
        % Use previous result to find y=0 intercept on x-axis, and thus
        % find the induced alpha
        alpha_i = -w_ind_linefit(2)/w_ind_linefit(1);
        
        % Subtract induced alpha from geo alpha to give effective alpha
        result.AlphaEff = result.AlphaGeo + alpha_i;
        
        % Generate straight line fit of effective alpha and CL, and use
        % result to generate new values for alpha eff vs CL
        liftcurve = polyfit(result.AlphaEff,result.CLift,1);
        result.CLiftEff = (result.AlphaGeo*liftcurve(1))+liftcurve(2);
        
    case 'FinalProcessing'
        % -----------------------------------------------------------------
        % Finds remaining variables such as CL_Alpha, CL_Alpha=0, K and
        % aerodynamic centre
        % -----------------------------------------------------------------
        
        % Find CL_Alpha = 0 and CL_Alpha using straight line fit of
        % geometric alpha and CL
        CL_linefit = polyfit(result.AlphaGeo,result.CLift,1);
        result.CL_Alpha = CL_linefit(1);
        result.CL_Alpha_0 = CL_linefit(2);
        
        % Find K (ind. drag equation coeff) using same technique
        K_linefit = polyfit(result.CLift.^2,result.CDrag,1);
        result.K = K_linefit(1);
        
        % Find the aerodynamic centre by calling FindAeroCentre
        [AeroCentre] = FindAeroCentre(geo,env,result);
        
        % Non-dimensionalise results and return
        result.StaticMargin = 100*((AeroCentre(1)-env.CofG(1))/geo.c_ref);
        result.CM_Alpha = result.CL_Alpha*((env.CofG(1)-AeroCentre(1))/geo.c_ref);
        result.AeroCentre = AeroCentre;
end
end

function [AeroCentre] = FindAeroCentre(geo,env,result)
% -----------------------------------------------------------------
% Function to find the aerodynamic centre of the configuration.
% (i.e. physical point at which Cm is independant of alpha)
% -----------------------------------------------------------------

% Find the size of result.gamma (aka number of panels and number of AoA
% points)
[m n] = size(result.gamma);

% Determine panel force points (i.e. collocation points on panels - Same routine as HSHOE_Panel)
for i = 1:m
    [P_xyz] = OrdRecall(i, geo.ActualPanelMatrix);
    CollocPoints(i,1:3) = (P_xyz(4,:)+((P_xyz(1,:)-P_xyz(4,:))./4))+(0.5*((P_xyz(3,:)+((P_xyz(2,:)-P_xyz(3,:))./4))-(P_xyz(4,:)+((P_xyz(1,:)-P_xyz(4,:))./4))));
end

% To find the aerodynamic centre we;
%   -Choose four arbitary points spaced out in the x-plane
%   -Determine the dCm/dalpha for each of these points
%   -Apply a straight fit to X-station versus dCm/dalpha
%   -Use the coefficients of the straight line to determine the x-axis
%   intercept for y=0, (i.e. the X-station for which dCm/dlpha=0)
X = linspace(0,1,4);
dMoment = [];
for k = 1:4
    for i = 1:n
        for j = 1:m
            PanelForce = env.rho*env.V*result.gamma(j,i)*PanelTool(j, geo.ActualPanelMatrix, 'Span');
            Moments(j) = (X(k)-CollocPoints(j,1))*PanelForce;
        end
        SumMoment(i) = sum(Moments);
    end
    dMoment(k,:) = polyfit(result.AlphaGeo,SumMoment,1);
end
MomentFit = polyfit(X',dMoment(:,1),1);
AeroCentre = [-MomentFit(2)/MomentFit(1) 0 0];
end