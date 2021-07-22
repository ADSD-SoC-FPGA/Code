%-------------------------------------------------------------------------
% Description:  Script that plots the true waveform as a template
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

alpha = 0.4;
color = [0 1 0 alpha];
To = 5;
%--------------------------------
% Segment 1 
%--------------------------------
t1=0:1/100:3;
w11=3*sin(2*pi*(1/6)*t1);
w12=0.5*sin(2*pi*8*t1);
w13 = w11+w12;
h=plot(t1,w13,'g'); hold on
set(h,'LineWidth',3.0,'Color',color)
h=plot(t1-To,w13,'g'); hold on
set(h,'LineWidth',3.0,'Color',color)
h=plot(t1+To,w13,'g'); hold on
set(h,'LineWidth',3.0,'Color',color)
plot(t1,w11,'g:')
plot(t1-To,w11,'g:')
plot(t1+To,w11,'g:')

%--------------------------------
% Segment 2
%--------------------------------
t2 = 3:1/100:4;
a = log(1)-log(4);
b = log(4) - 3*a;
w2 = exp(a*t2+b);
h=plot(t2,w2,'g');
set(h,'LineWidth',3.0,'Color',color)
h=plot(t2-To,w2,'g');
set(h,'LineWidth',3.0,'Color',color)
h=plot(t2+To,w2,'g');
set(h,'LineWidth',3.0,'Color',color)

%--------------------------------
% Segment 3
%--------------------------------
t4 = 4:1/100:5;
w4 = ones(size(t4))*3;
h=plot(t4,w4,'g');
set(h,'LineWidth',3.0,'Color',color)
h=plot(t4-To,w4,'g');
set(h,'LineWidth',3.0,'Color',color)
h=plot(t4+To,w4,'g');
set(h,'LineWidth',3.0,'Color',color)

%--------------------------------
% Dotted Lines
%--------------------------------
for kv=-1:1
    offset = kv*To;
    plot([0 5]+offset,[-1 -1],'g:')
    plot([0 5]+offset,[0 0],'g:')
    plot([0 5]+offset,[1 1],'g:')
    plot([0 5]+offset,[2 2],'g:')
    plot([0 5]+offset,[3 3],'g:')
    plot([0 5]+offset,[4 4],'g:')
    plot([1 1]+offset,[-2 5],'g:')
    plot([2 2]+offset,[-2 5],'g:')
    plot([3 3]+offset,[-2 5],'g:')
    plot([4 4]+offset,[-2 5],'g:')
    plot([3 3]+offset,[0 4],'g')
    plot([4 4]+offset,[1 3],'g')
    plot([5 5]+offset,[0 3],'g')
end

axis([-To 2*To -0.5 4.5])

%h=title('Waveform Template (T_o = 5 seconds)')
%set(h,'FontSize',18)
h=xlabel('Time (seconds)');
set(h,'FontSize',18)
set(gca,'FontSize',18)
set(gcf,'Position',[1362 537 1306 760])  % this is a monitor dependent position 


