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
audioFile = 'Single Notes Clean Mono.wav'; % path/to/audio/file';
[audio, fileSampleRate] = audioread(audioFile);
simParams.testSignal = resample(audio, modelParams.audio.sampleFrequency, fileSampleRate);
simParams.testSignal = fi(simParams.testSignal, modelParams.audio.signed, ...
    modelParams.audio.wordLength, modelParams.audio.fractionLength);
%plot(simParams.testSignal)

%--------------------------------------------------------------------------
% Simulation Parameters
%--------------------------------------------------------------------------
simParams.verifySimulation = true;  
simParams.playOutput       = true;
simParams.stopTime         = 5; % seconds

%--------------------------------------------------------------------------
% Model Parameters for simulation
%--------------------------------------------------------------------------
delayM = 48000;  % set value and data type from model parameters
simParams.delayM = fi(delayM,modelParams.delayM.signed, ...
    modelParams.delayM.wordLength, modelParams.delayM.fractionLength);

b0 = 0.9;  % set value and data type from model parameters
simParams.b0 = fi(b0,modelParams.b0.signed, ...
    modelParams.b0.wordLength, modelParams.b0.fractionLength);

bM = 0.5;  % set value and data type from model parameters
simParams.bM = fi(bM,modelParams.bM.signed, ...
    modelParams.bM.wordLength, modelParams.bM.fractionLength);

wetDryMix = 0.5; % set value and data type from model parameters
simParams.wetDryMix = fi(wetDryMix,modelParams.wetDryMix.signed, ...
    modelParams.wetDryMix.wordLength, ...
    modelParams.wetDryMix.fractionLength);


