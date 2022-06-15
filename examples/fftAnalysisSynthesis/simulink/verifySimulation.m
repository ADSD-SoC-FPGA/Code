% verifySimulation
%
% Verify the model's output

% SPDX-License-Identifier: MIT
% Copyright 2022 Ross Snider


%--------------------------------------------------------------------------
% Verification method depends on the input signal
%--------------------------------------------------------------------------
switch simParams.signalSelect
    %----------------------------------------------------------------------
    case 1  % Audio file
        % Not implemented. Typically more of a listening test.
        disp(['Warning: Verification for audio file not implemented.'])

    %----------------------------------------------------------------------
    case 2  % Sinewave
        latency_samples = 141;  % determined from Impulse test (case #3)
        % align the signals in time
        s1 = [zeros(1, latency_samples+1) double(simParams.audioIn(:)')];
        s2 = double(audioOut');
        s2 = s2/max(s2(:));  % normalize magnitude since we want any errors to be coming from waveform shape differences
        % select range to compare that ignores startup transients
        start_index = latency_samples*2;
        end_index   = length(s2);
        error_signal = abs(s1(start_index:end_index)-s2(start_index:end_index));
        maxError  = max(error_signal);
        precision = 2^(-modelParams.audio.fractionLength);
        % display popup message
        str1 = [' Maximum Sample Error = ' num2str(maxError) ];
        str1 = [str1 '\n \n Note: Least significant bit precision (' num2str(modelParams.audio.fractionLength) ' fractional bits) is ' num2str(precision)];
        helpdlg(sprintf(str1),'Verification Message: Sample Error')

        plotThis = true;
        if plotThis
            figure(1)
            subplot(3,1,1)
            plot(simParams.audioIn)
            subplot(3,1,2)
            plot(audioOut)
            subplot(3,1,3); hold off
            plot(s1,'g'); hold on
            plot(s2,'b');

            figure(2)
            subplot(2,1,1); hold off
            plot(s1,'g'); hold on
            plot(s2,'b');
            h=plot([start_index start_index],[-1.2 1.2],'r');
            set(h,'LineWidth',4)
            h=plot([end_index end_index],[-1.2 1.2],'r');
            set(h,'LineWidth',4)
            a = axis;
            a(3) = -1.2;
            a(4) = 1.2;
            axis(a)
            xlabel('Samples')
            ylabel('Amplitude')
            title('Output compared to time aligned (latency shifted) input')
            set(gca,'FontSize',20)

            subplot(2,1,2)
            hist(error_signal,50)
            xlabel('Absolute Error')
            ylabel('Count')
            title(['Histogram of sample errors (max error = ' num2str(maxError) ')'])
            set(gca,'FontSize',20)

        end

    %----------------------------------------------------------------------
    case 3  % Impulse
        [mv, input_index]  = max(simParams.audioIn);
        [mv, output_index] = max(audioOut);
        latency_samples = output_index - input_index;
        latency_msec    = latency_samples/modelParams.audio.sampleFrequency*1000;
        str1 = [' Latency of Impulse = ' num2str(latency_samples) ' samples = ' num2str(latency_msec) ' msec'];
        helpdlg(sprintf(str1),'Verification Message: Latency Measurement')

    %----------------------------------------------------------------------
    case 4  % Chirp
        Nfft = 2^ceil(log2(length(audioOut)));
        Nfft2 = Nfft/2;
        fft_out = fft(double(audioOut'),Nfft);        
        m = 20*log10(abs(fft_out(1:Nfft/2)));
        m = m - max(m); % normalize to zero dB
        fm=0:Nfft2-1;
        fm=fm/Nfft2 * modelParams.audio.sampleFrequency/2;
        figure(3)
        plot(fm,m)

    otherwise
        error('Unknown simParams.signalSelect value')
end





