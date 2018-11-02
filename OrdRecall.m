function [ABCD] = OrdRecall(i, PanelMatrix)

% -------------------------------------------------------------------------
% SwanVLM
% Version 5 (EXPORT)
% April 2009
% Copyright (C) 2008, 2009 Chris Walton (368404)

% OrdRecall.m: Recalls the corner point co-ordinates from a specified mesh
% matrix.
% -------------------------------------------------------------------------

% Uses assumption that each panel will fill out 4 co-ordinate points into
% the Panel Matrix
ABCD(1:4,1:3) = PanelMatrix(((i-1)*4)+1:((i-1)*4)+4,:);
end