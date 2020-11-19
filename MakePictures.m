function MakePictures(result,geo,env,gamma)

% -------------------------------------------------------------------------
% SwanVLM

% Version 6 (EXPORT)
% April 2020, Joan Ignasi Fontova(965420)

% Version 5 (EXPORT)
% April 2009
% Copyright (C) 2008, 2009 Chris Walton (368404)

% MakePictures.m: Generates a graphical set of results based on the
% calculated values for gamma.

% Inline Functions: AnimateWing, GammaPlot3
% -------------------------------------------------------------------------


% Call AnimateWing to make nice GIF
AnimateWing(result,geo,env,gamma);
fprintf('\nGIF animation generated\n');

% Generate a plot of the geometry mesh and then add the CofG and Aero
% Centre points on
figure
hold on
h1=plot3(geo.ActualPanelMatrix(:,1),geo.ActualPanelMatrix(:,2),geo.ActualPanelMatrix(:,3),'xg');
h2=scatter3(env.CofG(1), env.CofG(2), env.CofG(3),100,'rx','LineWidth',2);
h3=scatter3(env.CofG(1), env.CofG(2), env.CofG(3),100,'ro','LineWidth',2);
h4=scatter3(result.AeroCentre(1), result.AeroCentre(2), result.AeroCentre(3),100,'b+','LineWidth',2);
h5=scatter3(result.AeroCentre(1), result.AeroCentre(2), result.AeroCentre(3),100,'bo','LineWidth',2);
view([-30 60])
grid on
axis equal

% Label Plots
set(get(get(h1,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend
set(get(get(h3,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend
set(get(get(h5,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend

legend('Centre of Gravity', 'Aerodynamic Centre', 'Location', 'Best')

title(sprintf('Mesh for Geometry File: %s', geo.UserFileName))
xlabel('Wing x co-ordinate')
ylabel('Wing x co-ordinate')
zlabel('Wing x co-ordinate')
hold off

% Result coeff's plotting...
figure
subplot(2,1,1)
plot(result.AlphaGeo,result.CLift)
title(sprintf('CL vs Alpha_G_e_o for file: %s', geo.UserFileName))
xlabel('Alpha_G_e_o (Deg)')
ylabel('C_L')

subplot(2,1,2)
plot(result.AlphaGeo,result.CDrag)
title('C_D vs Alpha_G_e_o')
xlabel('Alpha_G_e_o (Deg)')
ylabel('C_D')
end


function [M] = AnimateWing(result,geo,env,gamma)
% -------------------------------------------------------------------------
% AnimateWing: Calls GammaPlot3 to generate a series of consistent 'surf'
% plots and collates into a *.gif file.
% -------------------------------------------------------------------------

% Find size of result.gamma (i.e. number of panels and number of alpha's
% solved for)
[m n] = size(result.gamma);

% Find the locations and values of the minimum and maximum values for gamma in the
% global panel matrix
[ValMin, GammaMinLoc] = min(min(result.gamma));
[ValMax, GammaMaxLoc] = max(max(result.gamma));
[MinI,MinJ]=ind2sub(size(result.gamma),find(result.gamma==ValMin));
[MaxI,MaxJ]=ind2sub(size(result.gamma),find(result.gamma==ValMax));

% Set the colour bar legend to give consistency for all plots
cmin = (env.rho*env.V*ValMin*PanelTool(MinJ, geo.ReferencePanelMatrix, 'Span'))/PanelTool(MinJ, geo.ReferencePanelMatrix, 'Area');
cmax = (env.rho*env.V*ValMax*PanelTool(MaxJ, geo.ReferencePanelMatrix, 'Span'))/PanelTool(MaxJ, geo.ReferencePanelMatrix, 'Area');


% Call GammaPlot3 to generate a 'surf' figure for each value of alpha
for i = 1:n
    [M(i) winsize] = GammaPlot3(result.gamma(:,i), geo, env, cmin, cmax, gamma.AlphaRange(i));
    if i ==1
        [im,map] = rgb2ind(M(1,1).cdata,256,'nodither');
    end
    im(:,:,1,i) = rgb2ind(M(1,i).cdata,map,'nodither');
end

% Set the filename of the animation as a day/time stamp
giffilename = char({strcat('Input/',geo.UserFileName,datestr(now,30),'.gif')});

% Write the surf figures to a gif
imwrite(im,map,giffilename,'DelayTime',2,'LoopCount',inf);
end

function [M, winsize] = GammaPlot3(gamma, geo, env, cmin, cmax, AlphaGeo)

% -------------------------------------------------------------------------
% GammaPlot3: Given input parameters, generates a 'surf' figure from the
% gamma struct.
% -------------------------------------------------------------------------

% Keep MATLAB drawing on to one figure
figure(50)
hold on

% For each wing, cycle through the panels and generate surf figures for
% each
for wings = 1:max(geo.PanelWingAddress(:,1))
    StartPanel = geo.PanelWingAddress(wings,2);
    EndPanel = geo.PanelWingAddress(wings,3);

    SurfPlotPoints = [];
    PanelPx = [];
    for i = StartPanel:EndPanel
        PanelPx(i) = (env.rho*env.V*gamma(i,1)*PanelTool(i, geo.ReferencePanelMatrix, 'Span'))/PanelTool(i, geo.ReferencePanelMatrix, 'Area');
        [P_xyz] = OrdRecall(i, geo.ActualPanelMatrix);
        SurfPlotPoints(end+1,:) = (P_xyz(4,:)+((P_xyz(1,:)-P_xyz(4,:))./4))+(0.5*((P_xyz(3,:)+((P_xyz(2,:)-P_xyz(3,:))./4))-(P_xyz(4,:)+((P_xyz(1,:)-P_xyz(4,:))./4))));
    end

    % This code block generates a properly formed mesh based on the panel
    % collocation [xyz] points and corresponding values of gamma
    x=SurfPlotPoints(:,1);
    y=SurfPlotPoints(:,2);
    z=SurfPlotPoints(:,3);
    % If a finer interpolated meshing is required, edit the following intervals
    x_edge=[floor(min(x)):0.01:ceil(max(x))];
    y_edge=[floor(min(y)):0.01:ceil(max(y))];
    % Generate mesh grids and plot
    [X,Y]=meshgrid(x_edge,y_edge);
    Z=griddata(x,y,z,X,Y);
    C=griddata(x,y,PanelPx(StartPanel:EndPanel),X,Y);
    surf(X,Y,Z,C)
end

% Set display options, add labelling, etc
shading interp
caxis([cmin cmax])
grid on
view([-30 60])
title(sprintf('Pressure Distribution for Geometry File: %s \n Alpha = %d', geo.UserFileName,AlphaGeo))
xlabel('x-station')
ylabel('y-station')
zlabel('z-station')
axis equal
colorbar
ylabel(colorbar,'\DeltaP (Pa)')

% Fix the window size and position to give consistent rendering
winsize = get(figure(50),'Position');
winsize(1:2) = [0 0];

% Record figure window image to struct 'M'
M = getframe(figure(50),winsize);

hold off


[a,b]=size(C);
lift=zeros(a,1);
for iy=1:a
    area=0.0;
    for ix=1:b
        if(isnan(C(iy,ix))==0)
            lift(iy)=(lift(iy)+C(iy,ix)*X(1,2)*Y(2,1));
            area=area+X(1,2)*Y(2,1);    
        end
    end
    lift(iy)=lift(iy)/X(1,2);

    
end


%C(isnan(C))=0;

%D = C ~= 0;

%S=sum(D,2);

%T=S*X(1,2);
%N=T.';

%lift2=lift*N;

 
figure(70)
plot(Y(:,1),lift)
hold on
xlabel('Wingspan [m]')
ylabel('Lift per unit span [N/m]')
title('Spanwise Lift Distribution')
grid minor

end