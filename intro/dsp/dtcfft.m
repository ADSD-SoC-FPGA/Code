% SPDX-License-Identifier: MIT
% Copyright (c) 2022 Ross K. Snider.  All rights reserved.
%-------------------------------------------------------------------------
% Description:  dtcfft = Discrete Time Continuous Frequency 
%                        Fourier Transform  
%                        "Continuous Frequency" means arbitrary frequencies
%                        with double precision.
%
% Function: y = dtcfft(signal,fs,freqs)
%
%                   inputs:
%                   signal = signal vector that contains signal samples
%                   fs     = sample rate of signal
%                   freqs  = vector of frequencies at which to evaluate the 
%                            Fourier Transform. Frequencies must be <= fs/2
%                   output: y = result vector of complex values
%
%--------------------------------------------------------------------------
% This file is used in the book: Advanced Digital System Design using 
% System-on-Chip Field Programmable Gate Arrays
% An Integrated Hardware/Software Approach
% by Ross K. Snider
%-------------------------------------------------------------------------
% Author:       Ross K. Snider
% Company:      Montana State University
% Create Date:  Feb 4, 2022
% Revision:     1.0
% License:      License: MIT  (opensource.org/licenses/MIT)
%-------------------------------------------------------------------------
function y = dtcfft(signal,fs,freqs)

if max(freqs) > fs/2  % 
    error(['A frequency in input vector freqs is greater than half the sampling rate, i.e. ' num2str(max(freqs)) ' > ' num2str(fs/2)])
end

Npoints = length(signal); % signal length
ts = ((1:Npoints)-1)/fs;  % signal sample times
Nf = length(freqs);
y = zeros(1,Nf);
for i=1:Nf
    f = freqs(i);
    cy = cos(2*pi*f*ts);     % cosine function
    sy = sin(2*pi*f*ts);     % sine function
    pcos = signal(:).*cy(:); % real axis projection
    pcos_sum = sum(pcos);    % real axis summation
    psin = signal(:).*sy(:); % imaginary axis projection
    psin_sum = sum(psin);    % imaginary axis summation
    y(i) = pcos_sum + 1i*psin_sum;
end

end
