%-------------------------------------------------------------------------
% Description:  Matlab script that creates test vectors for 
%               verification that are written to files 
%               input1.txt and input2.txt
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

Nvectors = 10;  % number of test vectors to create
Component_latency = 5;  % (includes MY_DELAY)
% my_input specification
W1 = 16;  % wordlength (MY_WORD_W)
F1 = 8;   % number of fractional bits (MY_WORD_F, not used to create vectors)
S1 = 0;   % signedness
% my_rom_address specification (address input, must match ROM address input)
W2 = 8;   % wordlength (MY_ROM_A_W)
F2 = 0;   % number of fractional bits  (not used to create vectors)
S2 = 0;   % signedness

%--------------------------------------------------------
% Open input files 
%--------------------------------------------------------
fid1 = fopen('input1.txt','w');  % input signals
fid2 = fopen('input2.txt','w');  % ROM addresses

%---------------------------------------------------------
% Input coverage is a random selection over input range
% Don't forget edge cases in random coverage
%---------------------------------------------------------
rng('shuffle','twister');  % 'shuffle' seeds the random number generator with the current time so each randi call is different;  'twister' uses the Mersenne Twister algorithm 
r1 = randi([0 2^W1-1],1,Nvectors);  % select from a uniform distribution
r2 = randi([0 2^W2-1],1,Nvectors);  % select from a uniform distribution

simulation_time = 0;
%--------------------------------------------------------
% Write the binary strings to file
%--------------------------------------------------------
index = 1;
for i=1:Nvectors
    f1 = fi(r1(i),S1,W1,0);
    f2 = fi(r2(i),S2,W2,0);
    fprintf(fid1,'%s\n',f1.bin);
    fprintf(fid2,'%s\n',f2.bin);
    simulation_time = simulation_time + 20;
end

%--------------------------------------------------------
% Write enough zeros to flush component pipeline
%--------------------------------------------------------
for i=1:Component_latency + 5
    z1 = fi(0,S1,W1,0);
    z2 = fi(0,S2,W2,0);
    fprintf(fid1,'%s\n',z1.bin);
    fprintf(fid2,'%s\n',z2.bin);
    simulation_time = simulation_time + 20;
end

%------------------------------------
% Close File
%------------------------------------
fclose(fid1);
fclose(fid2);

disp(['Note: Set ModelSim Simulation time to at least ' num2str(simulation_time) ' ns'])


