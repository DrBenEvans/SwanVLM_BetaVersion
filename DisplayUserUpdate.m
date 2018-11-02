function DisplayUserUpdate(varargin)

% -------------------------------------------------------------------------
% SwanVLM
% Version 5 (EXPORT)
% April 2009
% Copyright (C) 2008, 2009 Chris Walton (368404)

% DisplayUserUpdate.m: A set of standard user update messages called during
% the program run.
% -------------------------------------------------------------------------

switch nargin
    case 1
        switch varargin{1}
            case 1
                disp(sprintf('\nReading Configuration...'));
            case 2
                disp(sprintf('\b COMPLETE'));
                disp(sprintf('Generating Mesh...'));
            case 3
                disp(sprintf('\b COMPLETE'));
                disp(sprintf('Generating Influence Matrix/Alpha Sweeping'));
            case 4
                disp(sprintf('\b COMPLETE'));
                disp(sprintf('Post Processing...'))
            case 6
                disp(sprintf('\nFile does not exist!\n'));
            case 7
                disp(sprintf('\b COMPLETE'));
        end

    case 2
        switch varargin{1}
            case 5
                disp(sprintf('Task complete. Results saved in %s', varargin{2}));
        end
end

end