function MakePictures2(result2,meo,env2,gamma2)

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
AnimateWing2(result2,meo,env2,gamma2);
fprintf('\nGIF animation generated\n');

% Generate a plot of the geometry mesh and then add the CofG and Aero
% Centre points on
figure
hold on
h1=plot3(meo.ActualPanelMatrix(:,1),meo.ActualPanelMatrix(:,3),meo.ActualPanelMatrix(:,2),'xg');
h2=scatter3(env2.CofG(1), env2.CofG(2), env2.CofG(3),100,'rx','LineWidth',2);
h3=scatter3(env2.CofG(1), env2.CofG(2), env2.CofG(3),100,'ro','LineWidth',2);
h4=scatter3(result2.AeroCentre(1), result2.AeroCentre(2), result2.AeroCentre(3),100,'b+','LineWidth',2);
h5=scatter3(result2.AeroCentre(1), result2.AeroCentre(2), result2.AeroCentre(3),100,'bo','LineWidth',2);
view([-30 60])
grid on

% Label Plots
set(get(get(h1,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend
set(get(get(h3,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend
set(get(get(h5,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend

legend('Centre of Gravity', 'Aerodynamic Centre', 'Location', 'Best')

title(sprintf('Mesh for Geometry File: %s', meo.UserFileName))
xlabel('Wing x co-ordinate')
ylabel('Wing x co-ordinate')
zlabel('Wing x co-ordinate')
axis equal
hold off


% Result coeff's plotting...
figure(10)
subplot(3,1,3)
plot(result2.AlphaGeo,result2.CLift)
title(sprintf('C_{LatF} vs Beta for file: %s', meo.UserFileName))
xlabel('Beta (yaw angle) (Deg)')
ylabel('C_{LatF}')

%subplot(2,1,2)
%plot(result2.AlphaGeo,result2.CDrag)
%title('C_D vs Beta')
%xlabel('Beta (yaw angle) (Deg)')
%ylabel('C_D')
end


function [M] = AnimateWing2(result2,meo,env2,gamma2)
% -------------------------------------------------------------------------
% AnimateWing: Calls GammaPlot3 to generate a series of consistent 'surf'
% plots and collates into a *.gif file.
% -------------------------------------------------------------------------

% Find size of result.gamma (i.e. number of panels and number of alpha's
% solved for)
[m n] = size(result2.gamma);

% Find the locations and values of the minimum and maximum values for gamma in the
% global panel matrix
[ValMin, GammaMinLoc] = min(min(result2.gamma));
[ValMax, GammaMaxLoc] = max(max(result2.gamma));
[MinI,MinJ]=ind2sub(size(result2.gamma),find(result2.gamma==ValMin));
[MaxI,MaxJ]=ind2sub(size(result2.gamma),find(result2.gamma==ValMax));

% Set the colour bar legend to give consistency for all plots
cmin2 = (env2.rho*env2.V*ValMin*PanelTool(MinJ, meo.ReferencePanelMatrix, 'Span'))/PanelTool(MinJ, meo.ReferencePanelMatrix, 'Area');
cmax2 = (env2.rho*env2.V*ValMax*PanelTool(MaxJ, meo.ReferencePanelMatrix, 'Span'))/PanelTool(MaxJ, meo.ReferencePanelMatrix, 'Area');


% Call GammaPlot3 to generate a 'surf' figure for each value of alpha
for i = 1:n
    [M(i) winsize] = GammaPlot3(result2.gamma(:,i), meo, env2, cmin2, cmax2, gamma2.AlphaRange(i));
    if i ==1
        [im,map] = rgb2ind(M(1,1).cdata,256,'nodither');
    end
    im(:,:,1,i) = rgb2ind(M(1,i).cdata,map,'nodither');
end

% Set the filename of the animation as a day/time stamp
giffilename = char({strcat('Input/',meo.UserFileName,datestr(now,30),'.gif')});

% Write the surf figures to a gif
imwrite(im,map,giffilename,'DelayTime',2,'LoopCount',inf);
end

function [M2, winsize] = GammaPlot3(gamma2, meo, env2, cmin2, cmax2, AlphaGeo)

% -------------------------------------------------------------------------
% GammaPlot3: Given input parameters, generates a 'surf' figure from the
% gamma struct.
% -------------------------------------------------------------------------

% Keep MATLAB drawing on to one figure
figure(55)
hold on

% For each wing, cycle through the panels and generate surf figures for
% each
for wings = 1:max(meo.PanelWingAddress(:,1))
    StartPanel = meo.PanelWingAddress(wings,2);
    EndPanel = meo.PanelWingAddress(wings,3);

    SurfPlotPoints = [];
    PanelPx = [];
    for i = StartPanel:EndPanel
        PanelPx(i) = (env2.rho*env2.V*gamma2(i,1)*PanelTool(i, meo.ReferencePanelMatrix, 'Span'))/PanelTool(i, meo.ReferencePanelMatrix, 'Area');
        [P_xyz] = OrdRecall(i, meo.ActualPanelMatrix);
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
caxis([cmin2 cmax2])
grid on
view([-30 60])
title(sprintf('Pressure Distribution for Geometry File: %s \n Alpha = %d', meo.UserFileName,AlphaGeo))
xlabel('x-station')
ylabel('y-station')
zlabel('z-station')
colorbar
ylabel(colorbar,'\DeltaP (Pa)')

% Fix the window size and position to give consistent rendering
winsize = get(figure(55),'Position');
winsize(1:2) = [0 0];

% Record figure window image to struct 'M'
M2 = getframe(figure(55),winsize);

hold off


end