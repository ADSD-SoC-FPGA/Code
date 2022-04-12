% SPDX-License-Identifier: MIT
% Copyright (c) 2022 Trevor Vannoy, Ross K. Snider  All rights reserved.
%--------------------------------------------------------------------------
% Description:  Matlab Function to create/set model parameters for a
%               Simulink model. 
%--------------------------------------------------------------------------
% Authors:      Ross K. Snider, Trevor Vannoy
% Company:      Montana State University
% Create Date:  April 5, 2022
% Revision:     1.0
% License: MIT  (opensource.org/licenses/MIT)
%--------------------------------------------------------------------------
function modelParams = createModelParams()

%--------------------------------------------------------------------------
% audio signal path in model
%--------------------------------------------------------------------------
modelParams.audio.wordLength      = 24;     % word size of audio signal
modelParams.audio.fractionLength  = 23;     % fraction size of audio signal
modelParams.audio.signed          = true;   % audio is a signed signal type
modelParams.audio.sampleFrequency = 48000; % sample rate (Hz)
modelParams.audio.samplePeriod    = 1/modelParams.audio.sampleFrequency;

%--------------------------------------------------------------------------
% Control Parameters that will be set in registers (Data Types)
% Note: the actual values are set in createSimParams.m
%--------------------------------------------------------------------------
modelParams.delayM.wordLength     = 16;
modelParams.delayM.fractionLength = 0;
modelParams.delayM.signed         = false; 

modelParams.b0.wordLength     = 16;
modelParams.b0.fractionLength = 16;
modelParams.b0.signed         = true; 

modelParams.bM.wordLength     = 16;
modelParams.bM.fractionLength = 16;
modelParams.bM.signed         = true; 

modelParams.wetDryMix.wordLength     = 16;
modelParams.wetDryMix.fractionLength = 16;
modelParams.wetDryMix.signed         = false; 

modelParams.dpramAddressSize = 16;


mod