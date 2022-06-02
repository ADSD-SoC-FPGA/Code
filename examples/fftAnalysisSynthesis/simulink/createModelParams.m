% SPDX-License-Identifier: MIT
% Copyright (c) 2022 Ross K. Snider  All rights reserved.
%--------------------------------------------------------------------------
% Description:  Matlab Function to create/set model parameters for the
%               FFT Analysis Synthesis Simulink model 
%--------------------------------------------------------------------------
% Authors:      Ross K. Snider
% Company:      Montana State University
% Create Date:  May 19, 2022
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
modelParams.audio.dataType = numerictype(modelParams.audio.signed, ...
                                         modelParams.audio.wordLength, ... 
                                         modelParams.audio.fractionLength);
modelParams.audio.sampleFrequency = 48000; % sample rate (Hz)
modelParams.audio.samplePeriod    = 1/modelParams.audio.sampleFrequency;

%--------------------------------------------------------------------------
% FFT size
% Note: Changing modelParams.fft.frame_shift from fft size divided by four 
% implies substantial architectural changes
%--------------------------------------------------------------------------
modelParams.fft.size              = 128;     % length (size) of fft
modelParams.fft.Nbits             = log2(modelParams.fft.size);
modelParams.fft.size_half         = modelParams.fft.size/2;
modelParams.fft.frame_shift       = modelParams.fft.size/4;  
modelParams.fft.frame_shift_Nbits = log2(modelParams.fft.frame_shift);

%--------------------------------------------------------------------------
% Dual port dual rate memory for circular buffering fft 
%--------------------------------------------------------------------------
modelParams.dpram1.size         = modelParams.fft.size*2;  % number of words 
modelParams.dpram1.address_size = log2(modelParams.dpram1.size);
modelParams.dpram1.init         = modelParams.dpram1.size-10;

%--------------------------------------------------------------------------
% Upsampling factor for FFT processing, i.e. how much faster the fast 
% (system) clock must be to complete a FFT within the time of 
% modelParams.fft.frame_shif number of samples
%--------------------------------------------------------------------------
modelParams.system.upsample_Factor = modelParams.fft.size/modelParams.fft.frame_shift * 32;  

%--------------------------------------------------------------------------
% Setup the FFT filters (lookup tables)
%--------------------------------------------------------------------------
modelParams = createFFTFilters(modelParams);

%--------------------------------------------------------------------------
% Control Parameters that will be set in registers (Data Types)
% Note: the actual values are set in createSimParams.m
%--------------------------------------------------------------------------
modelParams.passthrough.wordLength     = 1;
modelParams.passthrough.fractionLength = 0;
modelParams.passthrough.signed         = false; 
modelParams.passthrough.dataType = numerictype(modelParams.passthrough.signed, ...
                                   modelParams.passthrough.wordLength, ... 
                                   modelParams.passthrough.fractionLength);

modelParams.filterSelect.wordLength     = 2;
modelParams.filterSelect.fractionLength = 0;
modelParams.filterSelect.signed         = false; 
modelParams.filterSelect.dataType = numerictype(modelParams.filterSelect.signed, ...
                                   modelParams.filterSelect.wordLength, ... 
                                   modelParams.filterSelect.fractionLength);



