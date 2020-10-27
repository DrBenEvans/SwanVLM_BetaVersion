function SaveResults1(filename, result2, geo2)

% -------------------------------------------------------------------------
% SwanVLM
% Version 5 (EXPORT)
% April 2009
% Copyright (C) 2008, 2009 Chris Walton (368404)

% SaveResults.m: Writes all generated values to an appended tab in the
% input excel file.
% -------------------------------------------------------------------------

% Generate matrix of cells containing all results
Timestamp = now;
SaveMatrix(1,1) = {strcat('Results for run completed on: ', datestr(Timestamp))};
SaveMatrix(2,1) = {'Alpha_Geo (Deg)'};
SaveMatrix(2,2) = {'Alpha_Effective (Deg)'};
SaveMatrix(2,3) = {'CL'};
SaveMatrix(2,4) = {'CD'};
for i = 1:length(result2.AlphaGeo')
    SaveMatrix(2+i,1) = {result2.AlphaGeo(i)};
    SaveMatrix(2+i,2) = {result2.AlphaEff(i)};
    SaveMatrix(2+i,3) = {result2.CLift(i)};
    SaveMatrix(2+i,4) = {result2.CDrag(i)};
end

SaveMatrix(end+2,1) = {'CL_Alpha=0'};
SaveMatrix(end,2) = {result2.CL_Alpha_0};
SaveMatrix(end+1,1) = {'CL_Alpha'};
SaveMatrix(end,2) = {result2.CL_Alpha};
SaveMatrix(end+1,1) = {'K'};
SaveMatrix(end,2) = {result2.K};
SaveMatrix(end+2,1) = {'Aero. Centre'};
SaveMatrix(end,2) = {[num2str(result2.AeroCentre(1)), ', ',num2str(result2.AeroCentre(2)),', ', num2str(result2.AeroCentre(3))]};
SaveMatrix(end+1,1) = {'CM_Alpha'};
SaveMatrix(end,2) = {result2.CM_Alpha};
SaveMatrix(end+1,1) = {'Static Margin'};
SaveMatrix(end,2) = {result2.StaticMargin};
SaveMatrix(end,3) = {'%'};
SaveMatrix(end+2,1) = {'Ref. Chord'};
SaveMatrix(end,2) = {geo2.c_ref};
SaveMatrix(end+1,1) = {'Ref. Area'};
SaveMatrix(end,2) = {geo2.S_ref};

% Send SaveMatrix to workspace
assignin('base','SwanVLM_Results',SaveMatrix);

% Name the sheet as 'Result' followed by an ISO date/time stamp
SheetName = {strcat('Result-',datestr(Timestamp,30))};

% Turn warnings off and save the sheet to the original input excel file
warning off all
xlswrite(filename, SaveMatrix, char(SheetName))

end