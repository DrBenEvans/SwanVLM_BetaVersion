function [FileLocation, FileExists, UserFileName] = InputConfig(InputRelPath)

% -------------------------------------------------------------------------
% SwanVLM
% Version 5 (EXPORT)
% April 2009
% Copyright (C) 2008, 2009 Chris Walton (368404)

% InputConfig.m: Prompts the user for the input file-name, and then checks
% if it exists.
% -------------------------------------------------------------------------

UserFileName = input('Geometry Configuration File Name: ', 's');
FileLocation = [InputRelPath UserFileName '.xls'];

if exist(FileLocation, 'file') == 2
    FileExists = 1;
else
    FileExists = 0;
end

end