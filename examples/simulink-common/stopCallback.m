% stopCallback
%
% This script calls user-defined scripts that verify the simulation and
% play the output audio signal. The script runs after the simulation stops.
% This is called in the StopFcn callback found in Model Explorer.
%
% The user-defined scripts are:
% - verifySimulation
% - playOutput
% These scripts are expected to be in the same directory as the Simulink
% model.

% SPDX-License-Identifier: MIT
% Copyright 2022 Trevor Vannoy

if simParams.verifySimulation
    verifySimulationPath = [fileparts(which(bdroot)) filesep 'verifySimulation.m'];
    
    if exist(verifySimulationPath, 'file')
        verifySimulation
    else
        warning(['stopCallback: Simulation verification is on but the ' ...
            'verification script was not found at:\n%s'], verifySimulationPath);
    end
end

if simParams.playOutput
    playOutputPath = [fileparts(which(bdroot)) filesep 'playOutput.m'];
    
    if exist(playOutputPath, 'file')
        playOutput
    else
        warning(['stopCallback: Play output in on but the playback ' ...
            'script was not found at:\n%s'], playOutputPath);
    end
end
            