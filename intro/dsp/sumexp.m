%-------------------------------------------------------------------------
% Description: Matlab function the generates waveform from 
%              Fourier coefficients using summation of complex exponentials
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
function s = sumexp(f,C,fs,dur)
% Inputs :  f = vector of harmonic frequencies;  typically f = 0:Fo:N*Fo;
%           C = vector of Fourier coefficients ck (complex); 
%               One for each frequency in f.
%           fs = sampling frequency in Hz (resolution of generated waveform)
%           dur = duration of signal in seconds
% Output : s = reconstructed signal from Fourier coefficients
s=real(C(:)'*(exp(1j*2*pi*f(:)*[0:(1/fs):dur])));
