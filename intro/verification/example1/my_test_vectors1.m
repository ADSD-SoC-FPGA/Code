%-------------------------------------------------------------------------
% Description:  Matlab script that creates test vectors for 
%               verification that are written to file input.txt
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

Nvectors = 10;          % number of test vectors to create
Component_latency = 3;  % Add enough zeros to flush component pipeline
W = 16;  % wordlength of my_input 
F = 0;   % we don't care about fraction bits so setting to zero
S = 0;   % we don't care about sign bit so setting to unsigned

%--------------------------------------------------------
% Open file input.txt in write mode
%--------------------------------------------------------
fid = fopen('input.txt','w');

%---------------------------------------------------------
% Input coverage is a random selection over input range
% (Don't forget edge cases when using random coverage)
%---------------------------------------------------------
rng('shuffle','twister');         % 'shuffle' seeds the random number generator with the current time so each randi call is different;  'twister' uses the Mersenne Twister algorithm 
r = randi([0 2^W-1],1,Nvectors);  % select from a uniform integer distribution over all possible integers

%--------------------------------------------------------
% Write the binary strings to file
%--------------------------------------------------------
for i=1:Nvectors
    f = fi(r(i),S,W,F);
    fprintf(fid,'%s\n',f.bin);
end

%--------------------------------------------------------
% Write enough zeros to flush component pipeline
%--------------------------------------------------------
for i=1:Component_latency + 5  % being extra generous with the zeros
    f = fi(0,S,W,F);
    fprintf(fid,'%s\n',f.bin);
end

%------------------------------------
% Close File
%------------------------------------
fclose(fid);
