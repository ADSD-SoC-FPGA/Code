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
simParams.playOutput       = true;
simParams.stopTime         = 5; % seconds

%--------------------------------------------------------------------------
% Model Parameters for simulation
%--------------------------------------------------------------------------
delayM = 24000;  % set value and data type from model parameters
simParams.delayM = fi(delayM,modelParams.delayM.dataType);

b0 = 0.9;  % set value and data type from model parameters
simParams.b0= fi(b0,modelParams.b0.dataType);

bM = 0.5;  % set value and data type from model parameters
simParams.bM= fi(bM,modelParams.bM.dataType);

wetDryMix = 0.5; % set value and data type from model parameters
simParams.wetDryMix= fi(wetDryMix,modelParams.wetDryMix.dataType);



