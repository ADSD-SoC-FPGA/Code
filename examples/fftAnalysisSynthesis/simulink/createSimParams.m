% SPDX-License-Identifier: MIT
% Copyright (c) 2022 Ross K. Snider  All rights reserved.
%--------------------------------------------------------------------------
% Description:  Matlab Function to create/set Simulation parameters for a
%               Simulink model simulation
%--------------------------------------------------------------------------
% Authors:      Ross K. Snider
% Company:      Montana State University
% Create Date:  June 8, 2022
% Revision:     1.0
% License: MIT  (opensource.org/licenses/MIT)
%--------------------------------------------------------------------------
function simParams = createSimParams(modelParams)


%--------------------------------------------------------------------------
% Simulation Parameters
%--------------------------------------------------------------------------
simParams.signalSelect     = 2;      % Input signal (see options below)
simParams.verifySimulation = false;  
simParams.playOutput       = false;
simParams.stopTime         = 0.1; % seconds (long signal times can take a long time to simulate)

%--------------------------------------------------------------------------
% Model Parameters for simulation
%--------------------------------------------------------------------------
passthrough = 0;  % set value and data type from model parameters
simParams.passthrough = fi(passthrough,modelParams.passthrough.dataType);

filterSelect = 1;  % set value [0 3] and data type from model parameters
simParams.filterSelect = fi(filterSelect,modelParams.filterSelect.dataType);


%--------------------------------------------------------------------------
% Audio file or test signals for simulation
% Choice of signal determined by simParams.signalSelect
%   simParams.signalSelect = 1  -> Audio file
%   simParams.signalSelect = 2  -> Sinewave
%   simParams.signalSelect = 3  -> Impulse
%   simParams.signalSelect = 4  -> Chirp
%--------------------------------------------------------------------------

switch simParams.signalSelect
    case 1  % Audio file
        filename = 'bluesSampleCleanShort.wav';
        desiredFs = modelParams.audio.sampleFrequency;  % desired sample rate
        desiredCh = 'left';  % desired channel
        desiredNt = modelParams.audio.dataType;  % desired data type (Numeric type)
        simParams.audioIn = getAudio(filename, desiredFs, desiredCh, desiredNt);

    case 2  % Sinewave
        desiredTs = modelParams.audio.samplePeriod;  % desired sample period
        desiredSinewaveFrequency = 3000;  % desired frequency (Hz)
        desiredDuration  = simParams.stopTime;   % desired duration (seconds)
        t = 0:desiredTs:desiredDuration;
        simParams.audioIn = fi(cos(2*pi*desiredSinewaveFrequency*t), modelParams.audio.dataType);

    case 3  % Impulse
        desiredFs = modelParams.audio.sampleFrequency;  % desired sample rate
        desiredDuration  = simParams.stopTime;   % desired duration (seconds)
        desiredImpulseLocation = 60;  % sample number of where to set the impulse
        impulseSignal = zeros(1,desiredDuration*desiredFs);
        impulseSignal(desiredImpulseLocation) = 0.9;
        simParams.audioIn = fi(impulseSignal, modelParams.audio.dataType);

    case 4  % Chirp
        desiredFs = modelParams.audio.sampleFrequency;  % desired sample rate
        desiredTs = modelParams.audio.samplePeriod;  % desired sample period
        desiredDuration  = simParams.stopTime;   % desired duration (seconds)
        t = 0:desiredTs:desiredDuration;
        simParams.audioIn = fi(chirp(t,0,max(t),desiredFs/2), modelParams.audio.dataType);

    otherwise
        error('Unknown simParams.signalSelect value')
end




