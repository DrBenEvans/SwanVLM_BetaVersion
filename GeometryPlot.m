function GeometryPlot(geo,meo,result,result2,env,env2)

figure
hold on
t1=plot3(meo.ActualPanelMatrix(:,1),meo.ActualPanelMatrix(:,3),meo.ActualPanelMatrix(:,2),'xg');
t2=scatter3(env.CofG(1), env.CofG(2), env.CofG(3),100,'rx','LineWidth',2);
t3=scatter3(env.CofG(1), env.CofG(2), env.CofG(3),100,'ro','LineWidth',2);
t4=scatter3(result.AeroCentre(1), result.AeroCentre(2), result.AeroCentre(3),100,'y+','LineWidth',2);
t5=scatter3(result.AeroCentre(1), result.AeroCentre(2), result.AeroCentre(3),100,'yo','LineWidth',2);
r1=plot3(geo.ActualPanelMatrix(:,1),geo.ActualPanelMatrix(:,2),geo.ActualPanelMatrix(:,3),'xg');
r2=scatter3(env2.CofG(1), env2.CofG(2), env2.CofG(3),100,'rx','LineWidth',2);
r3=scatter3(env2.CofG(1), env2.CofG(2), env2.CofG(3),100,'ro','LineWidth',2);
r4=scatter3(result2.AeroCentre(1), result2.AeroCentre(2), result2.AeroCentre(3),100,'b+','LineWidth',2);
r5=scatter3(result2.AeroCentre(1), result2.AeroCentre(2), result2.AeroCentre(3),100,'bo','LineWidth',2);
view([-30 60])
grid minor
axis equal

% Label Plots
set(get(get(t1,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend
set(get(get(t3,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend
set(get(get(t5,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend

% Label Plots
set(get(get(r1,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend
set(get(get(r2,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend
set(get(get(r3,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend
set(get(get(r5,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend

legend('Centre of Gravity', 'Yaw Aerodynamic Centre','Pitch Aerodynamic Centre', 'Location', 'Best')

title('Mesh for Geometry Plot')
xlabel('Wing x co-ordinate')
ylabel('Wing y co-ordinate')
zlabel('Wing z co-ordinate')
hold off

% Result coeff's plotting...
figure
subplot(2,1,1)
plot(result2.AlphaGeo,result2.CLift)
title(sprintf('CL vs Alpha_G_e_o for file: %s', geo.UserFileName))
xlabel('Alpha_G_e_o (Deg)')
ylabel('C_L')

subplot(2,1,2)
plot(result2.AlphaGeo,result2.CDrag)
title('C_D vs Alpha_G_e_o')
xlabel('Alpha_G_e_o (Deg)')
ylabel('C_D')

figure
subplot(2,1,1)
plot(result.AlphaGeo,result.CLift)
title(sprintf('CL vs Alpha_G_e_o for file: %s', meo.UserFileName))
xlabel('Alpha_G_e_o (Deg)')
ylabel('C_L')

subplot(2,1,2)
plot(result.AlphaGeo,result.CDrag)
title('C_D vs Alpha_G_e_o')
xlabel('Alpha_G_e_o (Deg)')
ylabel('C_D')

end



