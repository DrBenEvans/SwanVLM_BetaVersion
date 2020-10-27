function [meo] = MeshGenerate4(FileName, meo)

% -------------------------------------------------------------------------
% SwanVLM

% Version 6 (EXPORT)
% April 2020, Joan Ignasi Fontova(965420)

% Version 5 (EXPORT)
% April 2009
% Copyright (C) 2008, 2009 Chris Walton (368404)

% MeshGenerate3.m: Constructs a series of meshes for the processor based on
% the excel input file.

% Inline Functions: ExcelConfigRead, SectionCoOrds, Profile2CamberPoints,
% hdrload, NACAGen
% -------------------------------------------------------------------------


%**********************MESHING OPTIONS HERE**********************
chordwise_panels = meo.chordwisepanels;
spanwise_panels = round(meo.totalpanels/meo.chordwisepanels);
%****************************************************************

% Load configuration from excel file using function ExcelConfigRead
[RefPoint, RootProfile, RootChord, TipProfile, TipChord, Span, Sweep, Dihedral, GeoProps, RootIncidence, TipIncidence, Mirrored, Inverted] = ExcelConfigRead(FileName);

% Set initial variables values
meo.PanelCount = 0;
meo.ReferencePanelMatrix = [];
BoundPanelLoopCount = 1;
RefPanelLoopCount = 1;
ActPanelLoopCount = 1;


% Mesh Generation Loop
for i = 1:max(GeoProps(:,1))

    % Total panel counting logic
    if isempty(meo.ReferencePanelMatrix) == 1
        LenPanelMatrix1 = 4;
    else
        LenPanelMatrix1 = length(meo.ReferencePanelMatrix);
    end

    % Reading data from excel derived arrays on a section by section
    % basis
    for j = 1:GeoProps(i,2)
        % If first section of a wing, set ref point, root profile and root chord from excel file...
        if j == 1
            SectionRefPoint = RefPoint(i,:);
            SectionRootProfile = char(RootProfile{i});
            SectionRootChord = RootChord(i);
            SectionRootIncidence = RootIncidence(i);
        end
        
        % Otherwise take properties from tip of preceeding wing section...
        if j > 1
            SectionRootProfile = char(TipProfile{i,j-1});
            SectionRootChord = TipChord(i,j-1);
            SectionRootIncidence = TipIncidence(i,j-1);
        end

        % Set the remaining section variables
        SectionTipProfile = char(TipProfile{i,j});
        SectionTipChord = TipChord(i,j);
        SectionSpan = Span(i,j);
        SectionSweep = Sweep(i,j);
        SectionDihedral = Dihedral(i,j);
        SectionTipIncidence = TipIncidence(i,j);
      
        % ********START Boundary Panel Matrix Generation********
        % Determine if root or tip profiles are NACA 4-digit (i.e. nxxxx)
        if SectionRootProfile(1) == 'n' && isnumeric(str2double(SectionRootProfile(2:5))) == 1 && isnan(str2double(SectionRootProfile(2:5))) == 0
            NACASwitchRoot = 1;
        else
            NACASwitchRoot = 0;
        end

        if SectionTipProfile(1) == 'n' && isnumeric(str2double(SectionTipProfile(2:5))) == 1 && isnan(str2double(SectionTipProfile(2:5))) == 0
            NACASwitchTip = 1;
        else
            NACASwitchTip = 0;
        end

        % Call SectionCoOrds to generate co-ords from recalled data
        [TempSectionCoOrds, ScalingRatio] = SectionCoOrds(SectionRefPoint, SectionRootProfile, SectionRootChord, SectionTipProfile, SectionTipChord, SectionSpan, SectionSweep, SectionDihedral, chordwise_panels, spanwise_panels, NACASwitchRoot, NACASwitchTip,SectionRootIncidence,SectionTipIncidence,1,1);
        meo.b_ref = SectionSpan(1) * ScalingRatio;

        % Section position correction from using values from previous loop - Ensures that the sections line up
        % correctly
        DeltaRef = TempSectionCoOrds(1,:) - SectionRefPoint;
        [A B] = size(TempSectionCoOrds);
        DeltaRefMatrix = ones(A, B);
        DeltaRefMatrix = [DeltaRefMatrix(:,1).*DeltaRef(1) DeltaRefMatrix(:,2).*DeltaRef(2) DeltaRefMatrix(:,3).*DeltaRef(3)];
        TempSectionCoOrds = TempSectionCoOrds - DeltaRefMatrix;

        % Take generated section co-ordinates and store into global matrix of co-ords
        for k = 1:chordwise_panels
            for l = 1:spanwise_panels
                A = TempSectionCoOrds((((k-1)*(spanwise_panels+1))+1)+(l-1), :);
                B = TempSectionCoOrds((((k-1)*(spanwise_panels+1))+1)+(l), :);
                C = TempSectionCoOrds((((k)*(spanwise_panels+1))+1)+(l), :);
                D = TempSectionCoOrds((((k)*(spanwise_panels+1))+1)+(l-1), :);

                meo.BoundaryPanelMatrix(BoundPanelLoopCount,:) = A;
                meo.BoundaryPanelMatrix(BoundPanelLoopCount+1,:) = B;
                meo.BoundaryPanelMatrix(BoundPanelLoopCount+2,:) = C;
                meo.BoundaryPanelMatrix(BoundPanelLoopCount+3,:) = D;

                % Increment matrix position pointer up for next loop
                BoundPanelLoopCount = BoundPanelLoopCount + 4;
            end
        end
        % ********END Boundary Panel Matrix Generation********



        % ********START Reference Panel Matrix Generation********
        [TempSectionCoOrds, ScalingRatio] = SectionCoOrds(SectionRefPoint, 'flat', SectionRootChord, 'flat', SectionTipChord, SectionSpan, 0, SectionDihedral, chordwise_panels, spanwise_panels, 0, 0,SectionRootIncidence,SectionTipIncidence,1,1);

        % Section position correction - Ensures that the sections line up
        % correctly
        DeltaRef = TempSectionCoOrds(1,:) - SectionRefPoint;

        [A B] = size(TempSectionCoOrds);
        DeltaRefMatrix = ones(A, B);
        DeltaRefMatrix = [DeltaRefMatrix(:,1).*DeltaRef(1) DeltaRefMatrix(:,2).*DeltaRef(2) DeltaRefMatrix(:,3).*DeltaRef(3)];

        % Apply position correction to section co-ords
        TempSectionCoOrds = TempSectionCoOrds - DeltaRefMatrix;

        % Take generated section co-ordinates and store into global matrix of co-ords
        for k = 1:chordwise_panels
            for l = 1:spanwise_panels
                A = TempSectionCoOrds((((k-1)*(spanwise_panels+1))+1)+(l-1), :);
                B = TempSectionCoOrds((((k-1)*(spanwise_panels+1))+1)+(l), :);
                C = TempSectionCoOrds((((k)*(spanwise_panels+1))+1)+(l), :);
                D = TempSectionCoOrds((((k)*(spanwise_panels+1))+1)+(l-1), :);

                meo.ReferencePanelMatrix(RefPanelLoopCount,:) = A;
                meo.ReferencePanelMatrix(RefPanelLoopCount+1,:) = B;
                meo.ReferencePanelMatrix(RefPanelLoopCount+2,:) = C;
                meo.ReferencePanelMatrix(RefPanelLoopCount+3,:) = D;

                % Increment matrix position pointer up for next loop
                RefPanelLoopCount = RefPanelLoopCount + 4;
            end
        end
        % END ***Reference Panel Matrix Generation***
        
        
        
        % ********START Actual Panel Matrix Generation********
        [TempSectionCoOrds, ScalingRatio] = SectionCoOrds(SectionRefPoint, SectionRootProfile, SectionRootChord, SectionTipProfile, SectionTipChord, SectionSpan, SectionSweep, SectionDihedral, chordwise_panels, spanwise_panels, NACASwitchRoot, NACASwitchTip,SectionRootIncidence,SectionTipIncidence,0,0);
        
        if (i == 1) && (j == 1)
            meo.c_ref = SectionRootChord;
        end
        
        % Section position correction - Ensures that the sections line up
        % correctly
        DeltaRef = TempSectionCoOrds(1,:) - SectionRefPoint;

        [A B] = size(TempSectionCoOrds);
        DeltaRefMatrix = ones(A, B);
        DeltaRefMatrix = [DeltaRefMatrix(:,1).*DeltaRef(1) DeltaRefMatrix(:,2).*DeltaRef(2) DeltaRefMatrix(:,3).*DeltaRef(3)];

        % Apply position correction to section co-ords
        TempSectionCoOrds = TempSectionCoOrds - DeltaRefMatrix;

        % Take generated section co-ordinates and store into global matrix of co-ords
        for k = 1:chordwise_panels
            for l = 1:spanwise_panels
                A = TempSectionCoOrds((((k-1)*(spanwise_panels+1))+1)+(l-1), :);
                B = TempSectionCoOrds((((k-1)*(spanwise_panels+1))+1)+(l), :);
                C = TempSectionCoOrds((((k)*(spanwise_panels+1))+1)+(l), :);
                D = TempSectionCoOrds((((k)*(spanwise_panels+1))+1)+(l-1), :);

                meo.ActualPanelMatrix(ActPanelLoopCount,:) = A;
                meo.ActualPanelMatrix(ActPanelLoopCount+1,:) = B;
                meo.ActualPanelMatrix(ActPanelLoopCount+2,:) = C;
                meo.ActualPanelMatrix(ActPanelLoopCount+3,:) = D;

                % Increment matrix position pointer up for next loop
                ActPanelLoopCount = ActPanelLoopCount + 4;
            end
        end
        % ********END Actual Panel Matrix Generation********
        
        

        % Take leading edge tip co-ords, and store as reference point for next
        % section
        SectionRefPoint = TempSectionCoOrds(spanwise_panels+1,:);

        % Increment total panel counter
        meo.PanelCount = meo.PanelCount + (spanwise_panels*chordwise_panels);
    end

    % Update Wing Panel Address Matrix
    LenPanelMatrix2 = length(meo.ReferencePanelMatrix);
    meo.PanelWingAddress(i,1) = i;
    if i == 1
        meo.PanelWingAddress(i,2) = (LenPanelMatrix1/4);
    else
        meo.PanelWingAddress(i,2) = (LenPanelMatrix1/4)+1;
    end
    meo.PanelWingAddress(i,3) = LenPanelMatrix2/4;
    
end

% If wing is mirrored, generate mirror image (zx plane)
% Simply reads panel co-ords and appends them to each of the three
% matricies, as follows; [x y z] = [x -y z]
[m n] = size(Mirrored);
for i = 1:m
    if Mirrored(i) == 1
        StartPanel = meo.PanelWingAddress(i,2);
        EndPanel = meo.PanelWingAddress(i,3);
        meo.PanelWingAddress(i,4) = (length(meo.ReferencePanelMatrix)/4)+1;
        for j = StartPanel:EndPanel
            [ABCD] = OrdRecall(j, meo.ReferencePanelMatrix);
            ABCD(:,2) = -ABCD(:,2);
            meo.ReferencePanelMatrix(end+1,:) = ABCD(1,:);
            meo.ReferencePanelMatrix(end+1,:) = ABCD(2,:);
            meo.ReferencePanelMatrix(end+1,:) = ABCD(3,:);
            meo.ReferencePanelMatrix(end+1,:) = ABCD(4,:);

            [ABCD] = OrdRecall(j, meo.BoundaryPanelMatrix);
            ABCD(:,2) = -ABCD(:,2);
            meo.BoundaryPanelMatrix(end+1,:) = ABCD(1,:);
            meo.BoundaryPanelMatrix(end+1,:) = ABCD(2,:);
            meo.BoundaryPanelMatrix(end+1,:) = ABCD(3,:);
            meo.BoundaryPanelMatrix(end+1,:) = ABCD(4,:);
            
            [ABCD] = OrdRecall(j, meo.ActualPanelMatrix2);
            ABCD(:,2) = -ABCD(:,2);
            meo.ActualPanelMatrix(end+1,:) = ABCD(1,:);
            meo.ActualPanelMatrix(end+1,:) = ABCD(2,:);
            meo.ActualPanelMatrix(end+1,:) = ABCD(3,:);
            meo.ActualPanelMatrix(end+1,:) = ABCD(4,:);
            
            meo.PanelCount = meo.PanelCount+1;
        end
        meo.PanelWingAddress(i,5) = (length(meo.ReferencePanelMatrix)/4);
    end
end

% Determine S_ref
meo.S_ref = 0;
for i = meo.PanelWingAddress(1,2):meo.PanelWingAddress(1,3)
    meo.S_ref = meo.S_ref + PanelTool(i,meo.ReferencePanelMatrix, 'Area');
end

% Apply correction to S_ref for mirrored surfaces
if Mirrored(1) == 1
    meo.S_ref = meo.S_ref*2;
end

end

function [RefPoint, RootProfile, RootChord, TipProfile, TipChord, SectionSpan, SectionSweep, SectionDihedral, GeoProps, RootIncidence, TipIncidence, Mirrored, Inverted] = ExcelConfigRead(FileName)

% -------------------------------------------------------------------------
% ExcelConfigRead: Reads through the geometry tab of the input excel file
% and stores section properties in a consistent form.
% -------------------------------------------------------------------------

% Load excel file
[num,str]=xlsread(FileName, 1);

% Determine size of read numeric data
[A B] = size(num);

% Recover Reference Points
for i = 1:A
    if num(i,2) == 1
        % xyz Root Ref Point
        RefPoint(num(i,1),1) = num(i,3);  % x
        RefPoint(num(i,1),2) = num(i,4);  % y
        RefPoint(num(i,1),3) = num(i,5);  % z

        % Root Profile String
        RootProfile{num(i,1)} = str(2+i,6);

        % Root Chord
        RootChord(num(i,1),1) = num(i,7);

        % Root Incidence Angle
        RootIncidence(num(i,1),1) = num(i,13);

        % Mirrored in xz plane
        Mirrored(num(i,1),1) = num(i,15);

        % Invert profile
        Inverted(num(i,1),1) = num(i,16);
    end

    % Collect all other items with [wing,section] indexing
    TipProfile{num(i,1),num(i,2)} = str(2+i,8);
    TipChord(num(i,1),num(i,2)) = num(i,9);
    TipIncidence(num(i,1),num(i,2)) = num(i,14);
    SectionSpan(num(i,1),num(i,2)) = num(i,10);
    SectionSweep(num(i,1),num(i,2)) = num(i,11);
    SectionDihedral(num(i,1),num(i,2)) = num(i,12);

    % Determine number of wings, and how many sections each wing has
    if i < A
        if num(i,1) < num(i+1,1)
            GeoProps(num(i,1),1) = num(i,1);
            GeoProps(num(i,1),2) = num(i,2);
        end
    end

    if i == A
        GeoProps(num(i,1),1) = num(i,1);
        GeoProps(num(i,1),2) = num(i,2);
    end

end

end

function [Section_CoOrds, ScalingRatio] = SectionCoOrds(RefPoint, RootProfile, RootChord, TipProfile, TipChord, Span, Sweep, Dihedral, chordwise_panels, spanwise_panels, NACASwitchRoot, NACASwitchTip, RootIncidence, TipIncidence, ScaleSwitch, TaperSwitch)

% -------------------------------------------------------------------------
% SectionCoOrds: Generates the co-ordinates of a wing cross-section, either
% from an input DAT file or based on a NACA 4-digit input.
% -------------------------------------------------------------------------

% ******************
% If required, the section is scaled such that it has a unit length chord
if ScaleSwitch == 1
    ScalingRatio = 1/RootChord;

    RootChord = RootChord*ScalingRatio;
    TipChord = TipChord*ScalingRatio;
    Span = Span*ScalingRatio;
else
    ScalingRatio = 1;
end

if TaperSwitch == 1
    if RootChord ~= TipChord
        RootChord = (RootChord+TipChord)/2;
        TipChord = (RootChord+TipChord)/2;
    end
end
% ******************


% ******************
% Call Profile2CamberPoints and generate root co-ords
if NACASwitchRoot == 1
    TempRootCoOrds = NACAGen(RootProfile, (chordwise_panels+1), RootChord, RootIncidence);
else
    TempRootCoOrds = Profile2CamberPoints(RootProfile, (chordwise_panels+1), RootChord, RootIncidence);
end

% Move root profile in xyz space to root reference point
for i = 1:(chordwise_panels+1)
    RootCoOrds(i,1) = RefPoint(1) + TempRootCoOrds(i,1);
    RootCoOrds(i,2) = RefPoint(2);
    RootCoOrds(i,3) = RefPoint(3) + TempRootCoOrds(i,2);
end
% ******************

% ******************
% Generate tip co-ords
if NACASwitchTip == 1
    TempTipCoOrds = NACAGen(TipProfile, (chordwise_panels+1), RootChord, TipIncidence);
else
    TempTipCoOrds = Profile2CamberPoints(TipProfile, (chordwise_panels+1), TipChord, TipIncidence);
end

% Move tip profile in xyz space to tip reference point
for i = 1:(chordwise_panels+1)
    TipCoOrds(i,1) = TempTipCoOrds(i,1);
    TipCoOrds(i,2) = 0;
    TipCoOrds(i,3) = TempTipCoOrds(i,2);
end

% Slight fiddle to ensure that section tip profile is parallel to root
% profile following any wing sweep
TipPreSweep = -Sweep*(pi/180);
Rz = [cos(TipPreSweep) -sin(TipPreSweep) 0; sin(TipPreSweep) cos(TipPreSweep) 0; 0 0 1];

% Moves the tip profile to correct position for any sweep or dihedral
for i = 1:length(TipCoOrds)
    TipCoOrds(i,:) = (TipCoOrds(i,:)*Rz);
    TipCoOrds(i,2) = TipCoOrds(i,2)+Span;

    Dihedral = -Dihedral*(pi/180);
    Sweep = Sweep*(pi/180);
    Rx = [1 0 0; 0 cos(Dihedral) -sin(Dihedral); 0 sin(Dihedral) cos(Dihedral)];
    Rz = [cos(Sweep) -sin(Sweep) 0; sin(Sweep) cos(Sweep) 0; 0 0 1];
    TipCoOrds(i,:) = (TipCoOrds(i,:)*Rx);
    TipCoOrds(i,:) = (TipCoOrds(i,:)*Rz);

    TipCoOrds(i,1) = TipCoOrds(i,1) + RefPoint(1);
    TipCoOrds(i,2) = TipCoOrds(i,2) + RefPoint(2);
    TipCoOrds(i,3) = TipCoOrds(i,3) + RefPoint(3);

    TipCoOrds(i,1) = TipCoOrds(1,1) + TempTipCoOrds(i,1);
    TipCoOrds(i,2) = TipCoOrds(1,2);
    TipCoOrds(i,3) = TipCoOrds(1,3) + TempTipCoOrds(i,2);
end
% ******************

% ******************
% Generate points between root and tip profile co-ords
for i = 1:(chordwise_panels+1)
    for j = 1:(spanwise_panels+1)
        Section_CoOrds((((i-1)*(spanwise_panels+1))+j),:) = RootCoOrds(i,:)+((j-1)*((TipCoOrds(i,:)-RootCoOrds(i,:))/spanwise_panels));
    end
end
% ******************

end

function ProfileRead = Profile2CamberPoints(Profile, N_points, chord, theta)
% -------------------------------------------------------------------------
% Reads airfoil cross-section DAT file from airfoils folder and generates
% points on mean-camberline.
% -------------------------------------------------------------------------
switch Profile
    case('flat')
        % For the reference, a flat (Z=0) profile is generated
        ProfileRead(:,1) = linspace(0,chord,N_points)';
        ProfileRead(:,2) = 0;

    otherwise
        % Read profile from the airfoil library
        
        % Generate relative path and filename
        FileName = ['Input/Airfoils/' Profile '.dat'];

        % Call hdrload to read data from airfoil DAT file
        [h, d] = hdrload(FileName);

        % Read co-ord points into upper and lower surface arrays
        ProfileMatSize = size(d);

        % The loop reads through the numeric DAT file information,
        % seperating the cross-section into upper and lower surfaces
        SurfaceSwitch = 0;
        for i = 1:ProfileMatSize(1)
            if SurfaceSwitch == 0
                UpperSurface(i,:) = d(i,:);
            end

            if SurfaceSwitch == 1
                LowerSurface(i-a,:) = d(i,:);
            end

            if SurfaceSwitch == 0 && i >1 && d(i,1) > d(i-1,1)
                SurfaceSwitch = 1;
                a = i;
            end
        end

        % Re-arrange and tidy the input
        UpperSurface(end,:) = [];
        UpperSurface = flipud(UpperSurface);
        LowerSurface = vertcat([0 0], LowerSurface);

        % Remove any repeated entries
        [b, m, n] = unique(UpperSurface(:,1));
        [a b] = ind2sub(size(UpperSurface(:,1)),m);
        UpperSurface = UpperSurface(a,:);
        
        [b, m, n] = unique(LowerSurface(:,1));
        [a b] = ind2sub(size(LowerSurface(:,1)),m);
        LowerSurface = LowerSurface(a,:);

        % Fit cubic spline to upper and lower surfaces
        LowerSurfaceFit = interp1(chord*LowerSurface(:,1),LowerSurface(:,2),'PCHIP','pp');
        UpperSurfaceFit = interp1(chord*UpperSurface(:,1),UpperSurface(:,2),'PCHIP','pp');
        x = linspace(0,chord,N_points);
        
        % Generate points on upper and lower surfaces 
        LowerSurfacePoints = ppval(LowerSurfaceFit,x);
        UpperSurfacePoints = ppval(UpperSurfaceFit,x);

        % Generate a mean camberline of N points from upper and lower
        % surfaces
        for i = 1:N_points
            CamberPoint(i) = LowerSurfacePoints(i) + ((UpperSurfacePoints(i)-LowerSurfacePoints(i))/2);
        end

        % Translate/rotate camberline for twist requirement
        ProfileRead(:,1) = x';
        ProfileRead(:,2) = CamberPoint';
        theta = -theta*(pi/180);
        R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
        for i = 1:length(ProfileRead)
            ProfileRead(i,:) = R*[ProfileRead(i,1); ProfileRead(i,2)];
        end
end

end

function [CoOrds] = NACAGen(RootProfile, N_points, RootChord, theta)
% -------------------------------------------------------------------------
% NACAGen: Generates points on a NACA 4-digit camberline
% -------------------------------------------------------------------------

% Strip m and p values from input string
m_root = str2double(RootProfile(2))/100;
p_root = str2double(RootProfile(3))/10;

% Generate x-axis points
CoOrds(:,1) = linspace(0,RootChord,N_points);

% Use standard formulae to find camber line points for each x value
for i = 1:length(CoOrds)
    if CoOrds(i,1) <= p_root*RootChord
        CoOrds(i, 2) = (m_root/(p_root^2))*((2*p_root*(CoOrds(i,1)/RootChord))-((CoOrds(i,1)/RootChord)^2));
    end

    if CoOrds(i,1) > p_root*RootChord
        CoOrds(i, 2) = (m_root/((1-p_root)^2))*((1-(2*p_root))+(2*p_root*(CoOrds(i,1)/RootChord))-((CoOrds(i,1)/RootChord)^2));
    end
end

% Rotate camberline to account for any twist requirement
theta = -theta*(pi/180);
R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
for i = 1:length(CoOrds)
    CoOrds(i,:) = R*[CoOrds(i,1); CoOrds(i,2)];
end

end

function [header, data] = hdrload(file)
% -------------------------------------------------------------------------
% Reads a standard formatted DAT file. Used for recalling cross-section
% points from airfoil libary.

% Code downloaded from MathWorks site:
% http://www.mathworks.com/support/tech-notes/1400/1402.html
% Provided FoC, with no copyright or authorship assertions
% -------------------------------------------------------------------------

% Open the file.
fid = fopen(file);
if fid==-1
    error('Airfoil file not found or permission denied');
end

% Initialize loop variables
no_lines = 0;
max_line = 0;
ncols = 0;

% Finally, we initialize the data to [].
data = [];


% Start processing.
line = fgetl(fid);
if ~isstr(line)
    disp('Warning: airfoil file contains no header and no data')
end;
[data, ncols, errmsg, nxtindex] = sscanf(line, '%f');

while isempty(data)|(nxtindex==1)
    no_lines = no_lines+1;
    max_line = max([max_line, length(line)]);
    % Create unique variable to hold this line of text information.
    % Store the last-read line in this variable.
    eval(['line', num2str(no_lines), '=line;']);
    line = fgetl(fid);
    if ~isstr(line)
        disp('Warning: airfoil file contains no data')
        break
    end;
    [data, ncols, errmsg, nxtindex] = sscanf(line, '%f');
end % while


data = [data; fscanf(fid, '%f')];
fclose(fid);


header = setstr(' '*ones(no_lines, max_line));
for i = 1:no_lines
    varname = ['line' num2str(i)];

    if eval(['length(' varname ')~=0'])
        eval(['header(i, 1:length(' varname ')) = ' varname ';']);
    end
end % for

eval('data = reshape(data, ncols, length(data)/ncols)'';', '');
end