function [FileLocation, FileExists, UserFileName] = InputConfig1(InputRelPath)

% -------------------------------------------------------------------------
% SwanVLM

% Version 6 (EXPORT)
% April 2020, Joan Ignasi Fontova(965420)

% Version 5 (EXPORT)
% April 2009
% Copyright (C) 2008, 2009 Chris Walton (368404)

% InputConfig.m: Prompts the user for the input file-name, and then checks
% if it exists.
% -------------------------------------------------------------------------

UserFileName = input('Vertical Geometry Configuration File Name: ', 's');
FileLocation = [InputRelPath UserFileName '.xls'];

if exist(FileLocation, 'file') == 2
    FileExists = 1;
else
    FileExists = 0;
end

end