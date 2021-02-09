%-------------------------------------------------------------------------
% Description:  Matlab function that computes the same result as
%               my_component1.vhd
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
function y = my_component1(x)
% Input x is assumed to be a fixted-point object
% This function computes the same result as my_component1.vhd with the
% exception of the latency.  The latency is handled in my_verification1.m

%--------------------------------------------------------------------------
% Set the fimath properties to perform computations similar to the 
% VHDL code
%--------------------------------------------------------------------------
W = x.WordLength;       % Extract the word length W of input variable x
F = x.FractionLength;   % Extract the fraction length F of input variable x
Fm = fimath('RoundingMethod' ,'Floor',...
    'OverflowAction'         ,'Wrap',...
    'ProductMode'            ,'SpecifyPrecision',...
    'ProductWordLength'      ,W,...
    'ProductFractionLength'  ,F,...
    'SumMode'                ,'SpecifyPrecision',...
    'SumWordLength'          ,W,...
    'SumFractionLength'      ,F);
x.fimath = Fm;  % Apply these fimath properties to x

%--------------------------------------------------------------------------
% Without the Fm fimath properties being set, and specifically
% SumWordLength being set to W and applied to x, Matlab would automatically 
% set the word length of y to W+1, instead of W.
%--------------------------------------------------------------------------
y = x + 1; % perform the simple add 1 computation 

end
