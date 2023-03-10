% SPDX-License-Identifier: MIT
% Copyright (c) 2022 Ross K. Snider  All rights reserved.
%--------------------------------------------------------------------------
% Description:  Matlab Function to create the frequency domain filters
%               for the FFTAnalysisSynthesis  Simulink model. 
%--------------------------------------------------------------------------
% Authors:      Ross K. Snider
% Company:      Montana State University
% Create Date:  May 19, 2022
% Revision:     1.0
% License: MIT  (opensource.org/licenses/MIT)
%--------------------------------------------------------------------------
function modelParams = createFFTFilters(modelParams)

modelParams.fftROMDataType = numerictype(1,16,8);
%----------------------------------------------------------------------------
% Filter 1 - Low Pass (filterSelect=0)
%----------------------------------------------------------------------------
modelParams.lowPassCutoff      = 4000;  % frequency in Hz
modelParams.lowPassIndex       = floor(modelParams.lowPassCutoff / modelParams.audio.sampleFrequency * modelParams.fft.size) + 1;  % the +1 is to convert from the FFT bin array that is zero offset to a Matlab array that is 1 offset
modelParams.fftGainsF1Real     = zeros(modelParams.fft.sizeHalf,1);  % start by zeroing the entire array
modelParams.fftGainsF1Real(1:modelParams.lowPassIndex)  = ones(modelParams.lowPassIndex,1);
modelParams.fftGainsF1Imag     = zeros(modelParams.fft.sizeHalf,1);  % zero imaginary part
modelParams.fftGainsF1Real     = fi(modelParams.fftGainsF1Real,modelParams.fftROMDataType);
modelParams.fftGainsF1Imag     = fi(modelParams.fftGainsF1Imag,modelParams.fftROMDataType);

%----------------------------------------------------------------------------
% Filter 2 - Band Pass (filterSelect=1)
%----------------------------------------------------------------------------
modelParams.bandPassCutoffLow  = 4000;  % frequency in Hz
modelParams.bandPassCutoffHigh = 8000;  % frequency in Hz
modelParams.bandPassIndexLow   = ceil(modelParams.bandPassCutoffLow / modelParams.audio.sampleFrequency * modelParams.fft.size) + 1;  % Note: The FFT bin indexing assumes the first bin index number of zero.  Matlab starts arrays with index 1.  Thus we need to add get the right frequency bin.
modelParams.bandPassIndexHigh  = floor(modelParams.bandPassCutoffHigh / modelParams.audio.sampleFrequency *modelParams.fft.size)+ 1;
modelParams.fftGainsF2Real     = zeros(modelParams.fft.sizeHalf,1);  % start by zeroing array
modelParams.fftGainsF2Real(modelParams.bandPassIndexLow:modelParams.bandPassIndexHigh)  = ones(modelParams.bandPassIndexHigh-modelParams.bandPassIndexLow+1,1);
modelParams.fftGainsF2Imag     = zeros(modelParams.fft.sizeHalf,1);  % zero imaginary part
modelParams.fftGainsF2Real     = fi(modelParams.fftGainsF2Real,modelParams.fftROMDataType);
modelParams.fftGainsF2Imag     = fi(modelParams.fftGainsF2Imag,modelParams.fftROMDataType);

%----------------------------------------------------------------------------
% Filter 3 - High Pass (filterSelect=2)
%----------------------------------------------------------------------------
modelParams.highPassCutoff     = 8000;  % frequency in Hz
modelParams.highPassIndex      = ceil(modelParams.highPassCutoff / modelParams.audio.sampleFrequency * modelParams.fft.size) + 1;
modelParams.fftGainsF3Real     = zeros(modelParams.fft.sizeHalf,1);  % start by zeroing array
modelParams.fftGainsF3Real(modelParams.highPassIndex:end)  = ones(modelParams.fft.sizeHalf - modelParams.highPassIndex + 1, 1);
modelParams.fftGainsF3Imag     = zeros(modelParams.fft.sizeHalf,1);  % zero imaginary part
modelParams.fftGainsF3Real     = fi(modelParams.fftGainsF3Real,modelParams.fftROMDataType);
modelParams.fftGainsF3Imag     = fi(modelParams.fftGainsF3Imag,modelParams.fftROMDataType);

%----------------------------------------------------------------------------
% Filter 4 - All Pass (filterSelect=3)
%----------------------------------------------------------------------------
modelParams.fftGainsF4Real     = ones(modelParams.fft.sizeHalf,1);
modelParams.fftGainsF4Imag     = zeros(modelParams.fft.sizeHalf,1);  % zero imaginary part
modelParams.fftGainsF4Real     = fi(modelParams.fftGainsF4Real,modelParams.fftROMDataType);
modelParams.fftGainsF4Imag     = fi(modelParams.fftGainsF4Imag,modelParams.fftROMDataType);

end

