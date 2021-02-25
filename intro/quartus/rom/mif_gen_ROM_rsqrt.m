%--------------------------------------------------------------------------
% Description:  Matlab script that creates a Memory Intialization File
%               (.mif) for the ROM lookup table used in creating the 
%               initial guess y0 to start Newtons Method for y = 1/sqrt(x);
%--------------------------------------------------------------------------
% Author:       Ross K. Snider
% Company:      Montana State University
% Create Date:  March 20, 2014
% Revision:     1.1 (Updated 2/25/2021)
%--------------------------------------------------------------------------
% Copyright (c) 2014 Ross K. Snider.
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
%--------------------------------------------------------------------------
clear all
close all

%--------------------------------------------------------------------------
% Newton's Method for y = 1/sqrt(x);
% Define F(y) = 1/(y^2) - x.
% Find F(y) = 0;
% Solution: y(k+1) = (y(k)*(3-x*y(k)^2))/2  where y0 is the initial guess
% The memory initialization file is used in the computation of y0
% Create lookup table for (x_beta)^(-3/2)
%--------------------------------------------------------------------------
Nbits_address       = 8;  % address size
Nbits_word_length   = 12; % size of word in memory (number of bits)
Nbits_word_fraction = Nbits_word_length-1;  % The number of fractional bits in result.  
Nwords              = 2^Nbits_address; % Number of words in memory
comments = [];
for i=0:(Nwords-1)  % Need to compute each memory entry (i.e. memory size)
    fa = fi(i,0,Nbits_address,0);  % fixed point object for address
    fa_bits = fa.bin;              % Memory Address as a binary string
    fb = fi(0, 0, Nbits_address+1, Nbits_address);  % Set number of bits for result, i.e. we are creating the value 1.address_bits
    fb.bin = ['1' fa_bits]; % set the value using the binary representation. The address is our input value 1 <= x_beta < 2  where the leading 1 has been added.
    a = fi(double(fb)^(-3/2),0,Nbits_word_length,Nbits_word_fraction);  % compute (x_beta)^(-3/2) and convert to fixed-point with the desired number of fraction bits 
    array(i+1) = a;
    comments   = char(comments, ['  -- ' num2str(i+1) ' : (' num2str(double(fb)) ')^(-3/2) = ' num2str(a)]);
end
comments(1,:)=[];  % get rid of initial blank line due to empty initial matrix

%-----------------------------------------
% create the .mif file using mif_gen()
%-----------------------------------------
filename    = 'ROM';
memory_size = [Nwords Nbits_word_length];
mif_gen(filename,array,memory_size,comments)

disp(['Writing to ' filename '.mif ' num2str(memory_size(1)) ' ' num2str(memory_size(2)) '-bit memory words' ])







