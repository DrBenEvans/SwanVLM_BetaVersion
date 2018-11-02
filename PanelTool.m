function [output] = PanelTool(i, PanelMatrix, Option)

% -------------------------------------------------------------------------
% SwanVLM
% Version 5 (EXPORT)
% April 2009
% Copyright (C) 2008, 2009 Chris Walton (368404)

% PanelTool.m:  Provides a series of standard panel inspection routines;
%               Span: Span of a panel.
%               Alpha: Gradient of a panel in the xz plane.
%               Area: Area of a panel.
%               Beta: Gradient of a panel in the xy-plane.
%               Normal: Determines a normal vector to the panel.
% -------------------------------------------------------------------------

[ABCD] = OrdRecall(i, PanelMatrix);

switch Option
    case 'Span'
        output = sqrt( sum((ABCD(2,:) - ABCD(1,:)).*(ABCD(2,:) - ABCD(1,:))) );

    case 'Alpha'
        PanelVector = ABCD(4,:) - ABCD(1,:);
        output = -PanelVector(3)/PanelVector(1);

    case 'Area'
        output = sqrt(sum((ABCD(1,:)-ABCD(2,:)).*(ABCD(1,:)-ABCD(2,:))))*sqrt(sum((ABCD(1,:)-ABCD(4,:)).*(ABCD(1,:)-ABCD(4,:))));
        
    case 'Beta'
        output = atan((ABCD(2,1)-ABCD(1,1))/(ABCD(2,2)-ABCD(1,2)));

    case 'Normal'
        if min(ABCD(:,2)) < 0
            output = -cross(ABCD(1,:) - ABCD(2,:), ABCD(4,:) - ABCD(1,:));
        else
            output = -cross(ABCD(2,:) - ABCD(1,:), ABCD(4,:) - ABCD(1,:));
        end
end

end