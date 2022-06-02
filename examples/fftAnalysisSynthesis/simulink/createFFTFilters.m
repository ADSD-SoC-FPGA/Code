function modelParams = createFFTFilters(modelParams)

%----------------------------------------------------------------------------
% Filter 1 - Low Pass
%----------------------------------------------------------------------------
modelParams.low_pass_cutoff = 4000;  % frequency in Hz
modelParams.low_pass_index = ceil(modelParams.low_pass_cutoff / modelParams.audio.sampleFrequency * modelParams.fft.size) + 1;  % the +1 is to convert from the FFT bin array that is zero offset to a Matlab array that is 1 offset
modelParams.fft_gains_1_real = zeros(modelParams.fft.size_half,1);  % start by zeroing array
modelParams.fft_gains_1_real(1:modelParams.low_pass_index)  = ones(modelParams.low_pass_index,1);
modelParams.fft_gains_1_imag  = zeros(modelParams.fft.size_half,1);  % zero imaginary part
modelParams.latency_threshold1 = sum(modelParams.fft_gains_1_real)/modelParams.fft.size;

%----------------------------------------------------------------------------
% Filter 2 - Band Pass
%----------------------------------------------------------------------------
modelParams.band_pass_cutoff_low  = 4000;  % frequency in Hz
modelParams.band_pass_cutoff_high = 8000;  % frequency in Hz
modelParams.band_pass_index_low  = floor(modelParams.band_pass_cutoff_low / modelParams.audio.sampleFrequency * modelParams.fft.size) + 1;  % Note: The FFT bin indexing assumes the first bin index number of zero.  Matlab starts arrays with index 1.  Thus we need to add get the right frequency bin.
modelParams.band_pass_index_high = ceil(modelParams.band_pass_cutoff_high / modelParams.audio.sampleFrequency *modelParams.fft.size)+ 1;
modelParams.fft_gains_2_real = zeros(modelParams.fft.size_half,1);  % start by zeroing array
modelParams.fft_gains_2_real(modelParams.band_pass_index_low:modelParams.band_pass_index_high)  = ones(modelParams.band_pass_index_high-modelParams.band_pass_index_low+1,1);
modelParams.fft_gains_2_imag  = zeros(modelParams.fft.size_half,1);  % zero imaginary part
modelParams.latency_threshold2 = sum(modelParams.fft_gains_2_real)/modelParams.fft.size;

%----------------------------------------------------------------------------
% Filter 3 - High Pass
%----------------------------------------------------------------------------
modelParams.high_pass_cutoff = 8000;  % frequency in Hz
modelParams.high_pass_index = floor(modelParams.high_pass_cutoff / modelParams.audio.sampleFrequency * modelParams.fft.size) + 1;
modelParams.fft_gains_3_real = zeros(modelParams.fft.size_half,1);  % start by zeroing array
modelParams.fft_gains_3_real(modelParams.high_pass_index:end)  = ones(modelParams.fft.size_half - modelParams.high_pass_index + 1, 1);
modelParams.fft_gains_3_imag  = zeros(modelParams.fft.size_half,1);  % zero imaginary part
modelParams.latency_threshold3 = sum(modelParams.fft_gains_3_real)/modelParams.fft.size;

%----------------------------------------------------------------------------
% Filter 4 - All Pass
%----------------------------------------------------------------------------
modelParams.fft_gains_4_real = ones(modelParams.fft.size_half,1);
modelParams.fft_gains_4_imag  = zeros(modelParams.fft.size_half,1);  % zero imaginary part
modelParams.latency_threshold4 = sum(modelParams.fft_gains_4_real)/modelParams.fft.size;


end

