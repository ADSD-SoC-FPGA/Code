%-------------------------------------------------------------------------
% Description:  Matlab function that computes the same result as
%               my_component2.vhd
%--------------------------------------------------------------------------
% This file is used in the book: Advanced Digital System Design using 
% System-on-Chip Field Programmable Gate Arrays
% An Integrated Hardware/Software Approach
% by Ross K. Snider
%-------------------------------------------------------------------------
% Author:       Ross K. Snider
% Company:      Montana State University
% Create Date:  January 20, 2021
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
function z = my_component2(x,addresses,rom)
% This function computes the same result as my_component2.vhd with the
% exception of the latency.  The latency is handled in my_verification2.m
% Inputs:   x is input1 and assumed to be a fixted-point array
%           addresses is input2 and assumed to be a fixted-point array
%           rom is the array from ROM.mat
% Output:   z is the result of the computation similar to what is performed
%           in my_component2.vhd

verbose = 0;  % set to one to display result values (used for debudgging)
              % useful when comparing signals in the ModelSim Wave window

W1 = x.WordLength;
F1 = x.FractionLength;

% my_rom_address specification (signal output, must match ROM)
W3 = 12;   % wordlength (MY_ROM_Q_W, not used to create vectors)
F3 = W3-1; % number of fractional bits (MY_ROM_Q_F, not used to create vectors)
S3 = 0;    % signedness (not used to create vectors)

%--------------------------------
% ROM lookup
%--------------------------------
for i=1:length(addresses)
    rom_values(i) = rom(addresses(i)+1);
end

%--------------------------------
% ROM latency = 2
%--------------------------------
f = fi(0,S3,W3,F3);
rom_values = [f f rom_values];  % align (shift) vectors to account for latency


%--------------------------------
% input latency
%--------------------------------
f = fi(0,0,W1,F1);
delayed_input = [f f x];  % align input vectors


for i=1:length(x)
    m1 = delayed_input(i);
    m2 = rom_values(i);
    result = m1 * m2;
    result_bit_string = result.bin;
    % perform the same signal slicing as in my_component2.vhd to trim the result
    left_trim_length = result.WordLength-result.FractionLength-(W1-F1);
    result_bit_string(1:left_trim_length) = [];
    result_bit_string(end-F3+1:end) = [];
    f.bin = result_bit_string; % put it back into the appropriate sized fixed-point object
    output = f;
    z(i)  = output;  % collect the results
    if verbose == 1  
        disp(['i = ' num2str(i) '  ---------------------------------'])
        disp(['delayed_input = ' m1.hex ' = ' m1.bin ' = ' num2str(m1)])
        disp(['rom_value     = ' m2.hex ' = ' m2.bin ' = ' num2str(m2)])
        disp(['result        = ' result.hex ' = ' result.bin ' = ' num2str(result)])
        disp(['result        = ' output.hex ' = ' output.bin ' = ' num2str(output)])
    end
end


end

