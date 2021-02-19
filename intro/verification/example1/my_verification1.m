%-------------------------------------------------------------------------
% Description:  Matlab script that performs verification on 
%               my_component.vhd after it has been simulated using ModelSim
%               running my_component_tb.vhd and where simulation results
%               have been written to output.txt
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
clear all  % clear all workspace variables
close all  % close all figure windows

%-----------------------------------------------------------------------
% These parameters need to match the settings in my_test_vectors1.m
%-----------------------------------------------------------------------
Nvectors = 10;  % number of test vectors created
Component_latency = 3;  % the latency of the component being tested
W = 16;  % wordlength
F = 0;   % number of fractional bits
S = 0;   % signedness

%--------------------------------------------------------
% Read in the test vectors from file input.txt
%--------------------------------------------------------
disp('------------------------------------------')
disp('Reading in values from file input.txt')
fid1 = fopen('input.txt','r');
line_in = fgetl(fid1);  % read the first line in the file
a = fi(0,S,W,F);   % interpret the bit string appropriately by creating a fixed-point object with appropriate parameters
index = 1;
while ischar(line_in)
    a.bin = line_in; % push the binary string into the fixed-point object where it will be interpreted with the given S (sign), W (word length), and F (frational bits) values
    test_vectors(index) = a;  % save this fixed-point object
    disp([num2str(index) ' : ' line_in ' = ' num2str(a)]) % display what we are reading in (comment out if there a lot of test vectors)
    index = index + 1;
    line_in = fgetl(fid1);
end
fclose(fid1);

%--------------------------------------------------------
% std_logic possible values
%--------------------------------------------------------
% 'U': uninitialized. This signal hasn't been set yet.
% 'X': unknown. Impossible to determine this value/result.
% '0': logic 0
% '1': logic 1
% 'Z': High Impedance
% 'W': Weak signal, can't tell if it should be 0 or 1.
% 'L': Weak signal that should probably go to 0
% 'H': Weak signal that should probably go to 1
% '-': Don't care.
stdchar = 'UXZWLH-'; % create a list of all non-binary std_logic characters we will ignore non-binary strings when reading output.txt

%---------------------------------------------------------------
% Read in the simulation result vectors from file output.txt
%---------------------------------------------------------------
disp('------------------------------------------')
disp('Reading in values from file output.txt')
fid2 = fopen('output.txt','r');
line_in = fgetl(fid2);  % read first line in file
a = fi(0,S,W,F);  % interpret the bit string appropriately by creating a fixed-point object with appropriate parameters
index = 1;
while ischar(line_in)
    % check if the input string contains any std_logic characters other than the binary characters
    s = 0;
    for i=1:7
        s = s + contains(line_in,stdchar(i));  % check line_in for each non-binary std_logic value contains() will return 1 if it finds such a value
    end
    if s == 0  % s will be zero if line_in contains only 0s or 1s, which means we have a valid string that we can convert
        a.bin = line_in;  % convert binary string to fixed-point
        vhdl_vectors(index) = a;        
        disp([num2str(index) ' : ' line_in ' = ' num2str(a)])
        index = index + 1;
    else
        disp([num2str(index) ' : ' line_in ' ~~ Ignoring line since it contains non-binary std_logic characters'])
    end
    line_in = fgetl(fid2);
end
fclose(fid2);

%--------------------------------------------------------
% Run test vectors through my_fxpt_function
%--------------------------------------------------------
matlab_vectors = my_component1(test_vectors);

%--------------------------------------------------------
% Compare matlab_vectors to vhdl_vectors
%--------------------------------------------------------
disp('------------------------------------------')
disp('Performing Verification')
index_offset = 0;  % set the alignment offset if needed (initial output.txt values might be valid and not ignored if they contain only binary characters)
error_flag = 0;
for i=1:Nvectors
    x = matlab_vectors(i);
    y = vhdl_vectors(i + index_offset);
    if strcmp(x.bin,y.bin) == 0
        a = test_vectors(i);
        disp(['    -------------------------------------------'])
        disp(['    Verification Error Occurred for Test vector ' num2str(a) ' = ' a.bin '(index = ' num2str(i) ')'])
        disp(['    Matlab vector = ' x.bin ' = ' num2str(x)])
        disp(['    VHDL vector   = ' y.bin ' = ' num2str(y)])
        error_flag = 1;
    end
end

disp(' ')
if error_flag == 0
    disp('   Verification Succeeded!')
else
    disp('   ******* Verification Failed *******')
end


