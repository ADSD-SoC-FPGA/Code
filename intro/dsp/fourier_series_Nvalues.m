%-------------------------------------------------------------------------
% Description:  Script that generates signal reconstructions using 
%               different numbers of Fourier coefficients, i.e. N values
%--------------------------------------------------------------------------
% This file is used in the book: Advanced Digital System Design using 
% System-on-Chip Field Programmable Gate Arrays
% An Integrated Hardware/Software Approach
% by Ross K. Snider
%-------------------------------------------------------------------------
% Author:       Ross K. Snider
% Company:      Montana State University
% Create Date:  July 22, 2021
% Revision:     1.0
%-------------------------------------------------------------------------
% Copyright (c) 2021 Ross K. Snider
% All rights reserved. Redistribution and use in source and binary forms 
% are permitted provided that the above copyright notice and this paragraph 
% are duplicated in all such forms and that any documentation, advertising 
% materials, and other materials related to such distribution and use 
% acknowledge that the software was developed by Montana State University 
% (MSU).  The name of MSU may not be used to endorse or promote products 
% derived from this software without specific prior written permission.
% THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
% IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. 
%-------------------------------------------------------------------------
clear all
close all

figure(1)
%--------------------------------
% Example 1
%--------------------------------
N = 5;         % Choose the number of Fourier coefficients to use.
[t,s] = fourier_series_waveform(N);
subplot(3,1,1)
fourier_series_target_template;
plot(t,s,'b')
title(['Signal Reconstruction : N = ' num2str(N) ' Fourier Coefficients'])

%--------------------------------
% Example 2
%--------------------------------
N = 50;         % Choose the number of Fourier coefficients to use.
[t,s] = fourier_series_waveform(N);
subplot(3,1,2)
fourier_series_target_template;
plot(t,s,'b')
title(['Signal Reconstruction : N = ' num2str(N) ' Fourier Coefficients'])

%--------------------------------
% Example 2
%--------------------------------
N = 500;         % Choose the number of Fourier coefficients to use.
[t,s] = fourier_series_waveform(N);
subplot(3,1,3)
fourier_series_target_template;
plot(t,s,'b')
title(['Signal Reconstruction : N = ' num2str(N) ' Fourier Coefficients'])

%-----------------------------
% Save figure
%-----------------------------
saveas(gcf,'fourier_series_Nvalues.png')


