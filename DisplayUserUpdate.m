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
                fprintf('\nReading Configuration...\n');
            case 2
                fprintf('\b COMPLETE\n');
                fprintf('Generating Mesh...\n');
            case 3
                fprintf('\b COMPLETE\n');
                fprintf('Generating Influence Matrix/Alpha Sweeping\n');
            case 4
                fprintf('\b COMPLETE\n');
                fprintf('Post Processing...\n')
            case 6
                fprintf('\nFile does not exist!\n\n');
            case 7
                fprintf('\b COMPLETE\n');
        end

    case 2
        switch varargin{1}
            case 5
                disp(sprintf('Task complete. Results saved in %s', varargin{2}));
        end
end

end