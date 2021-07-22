%-------------------------------------------------------------------------
% Description:  Matlab function the generates waveform from 
%               Fourier coefficients
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
function [t,s] = fourier_series_waveform(N)
% Input:   N is the number of Fourier coefficients to use.
% Output:  t is the time vector (for plotting)
%          s is the reconstucted signal from the Fourier coefficients

%------------------------------------------------------------------------
% Solution Parameters
%------------------------------------------------------------------------
Fs  = 500;         % sampling frequency (resolution of generated waveform)
Ts  = 1/Fs;        % sampling period
To  = 5;           % fundamental period is 5 seconds
Fo  = 1/To;        % fundamental frequency
dur = 3*To;        % duration of waveform to plot
f   = 0:Fo:N*Fo;   % generate the harmonic frequencies.
t   = -To:Ts:2*To; % generate the time samples 
k   = 1:N;         % the k values (coefficient index)

%--------------------------------------------------------------------------
% Segment 1: Term 1 : Create the waveform using the sin(2*pi/6*t)
% coefficients derived over interval [0 3]
%--------------------------------------------------------------------------
co1 = 18/(5*pi);
ck1 = (90*(1 + exp(-1j*6/5*pi*k)))./(pi*(25 - 36*k.^2));
ck_segment1_term1=[co1 ck1];
y1 = fliplr(sumexp(f,ck_segment1_term1,Fs,dur));

%--------------------------------------------------------------------------
% Segment 1: Term 2 : Create the waveform using the sin(2*pi*8*t) 
% coefficients derived over interval [0 3]
%--------------------------------------------------------------------------
co2 = 0;
ck2 = (20/pi)*(1 - exp(-1j*6/5*pi*k))./(1600 - k.^2);
if ( 40 <= N )
    ck2(40) = - 3*1j/10;  % handle the 0/0 case when k=40
end
ck_segment1_term2=[co2 ck2];
y2 = fliplr(sumexp(f,ck_segment1_term2,Fs,dur));

%--------------------------------------------------------------------------
% Segment 2: Create the waveform using the exp(at+b) coefficients derived   
% over interval [3 4]
%--------------------------------------------------------------------------
a = log(1)-log(4);
b = log(4) - 3*a;
co3 = (exp(4*a+b)-exp(3*a+b))/(5*a);
ck3 = (2./(5*a-1j*2*pi*k)).*(exp((a-1j*2*pi*k/5)*4 + b) - exp((a-1j*2*pi*k/5)*3 + b));
ck_segment2 = [co3 ck3];
y3 = fliplr(sumexp(f,ck_segment2,Fs,dur));

%--------------------------------------------------------------------------
% Segment 3: Create the waveform using the coefficients derived over
% interval [4 5] for a constant value of 3
%--------------------------------------------------------------------------
co4 = 3/5;
ck4 = (-6./(1j*2*pi*k)).*(1 - exp(-1j*8/5*pi*k));
ck_segment3 =[co4 ck4];
y4 = fliplr(sumexp(f,ck_segment3,Fs,dur));

%--------------------------------------------------------------------------
% Combine all the segment waveforms
%--------------------------------------------------------------------------
s = y1+y2+y3+y4;

