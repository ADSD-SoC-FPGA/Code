% SPDX-License-Identifier: MIT
% Copyright (c) 2022 Trevor Vannoy, Ross K. Snider  All rights reserved.
%--------------------------------------------------------------------------
% Description:  Matlab Function to create/set Simulation parameters for a
%               Simulink model simulation
%--------------------------------------------------------------------------
% Authors:      Ross K. Snider, Trevor Vannoy
% Company:      Montana State University
% Create Date:  April 5, 2022
% Revision:     1.0
% License: MIT  (opensource.org/licenses/MIT)
%--------------------------------------------------------------------------
function simParams = createSimParams(modelParams)

%--------------------------------------------------------------------------
% Audio file for simulation
%--------------------------------------------------------------------------
filename = 'bluesSampleCleanShort.wav';
desiredFs = modelParams.audio.sampleFrequency;  % desired sample rate
desiredCh = 'left';  % desired channel
desiredNt = modelParams.audio.dataType;  % desired data type (Numeric type)
simParams.audioIn = getAudio(filename, desiredFs, desiredCh, desiredNt);

%--------------------------------------------------------------------------
% Simulation Parameters
%--------------------------------------------------------------------------
simParams.verifySimulation = false;  
simParams.playOutput       = false;
simParams.stopTime         = 0.01; % seconds (long times will take long to simulate)

%--------------------------------------------------------------------------
% Model Parameters for simulation
%--------------------------------------------------------------------------
passthrough = 0;  % set value and data type from model parameters
simParams.passthrough = fi(passthrough,modelParams.passthrough.dataType);

filterSelect = 1;  % set value and data type from model parameters
simParams.filterSelect = fi(filterSelect,modelParams.filterSelect.dataType);
