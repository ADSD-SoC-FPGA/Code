%--------------------------------------------------------------------------
% Description:  Matlab function that creates a Memory Intialization File
%               (.mif) with the address and value radix set as binary
%
%               function mif_gen(filename,array,memory_size)
%
%               Inputs:   filename: The name of the .mif file.  The .mif 
%                         suffix will be added.
%                       
%                         array: An array of fixed-point objects where
%                         the binary strings of these values will be
%                         written. The length of the array must match
%                         memory_size(1)
%
%                         memory_size:  memory_size = [x y], which is a 
%                         two element vector where x specifies the size 
%                         of the memory in the number of memory words 
%                         and y specifies the length of each memory word 
%                         in the number of bits in the word.
%
%                         comments: a character array of strings that will
%                         be written after each memory word.  Not required.
%                         The character array must have as many rows as 
%                         memory words.
%
%--------------------------------------------------------------------------
% Author:       Ross K. Snider
% Company:      Montana State University
% Create Date:  February, 2021
%--------------------------------------------------------------------------
% Copyright (c) 2021 Ross K. Snider.
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
function mif_gen(filename,array,memory_size,comments)

%-----------------------------------------------------------
% Check for consistency
%-----------------------------------------------------------
if length(array) ~= memory_size(1) 
   error('Length of array passed to mif_gen() does not match memory size') 
end
if rem(memory_size(1),log2(memory_size(1))) ~= 0
    error('Length of Memory should be a power of 2')
end
a = array(1);
if a.WordLength ~= memory_size(2)
    error('Word length of array does not match memory size') 
end

%------------------------------------
% Create the .mif file 
%------------------------------------
fid = fopen([filename '.mif'],'w');

%------------------------------------
% Write File Header
%------------------------------------
line = ['DEPTH = ' num2str(memory_size(1)) ';']; fprintf(fid,'%s\n',line); % The size of memory in words
line = ['WIDTH = ' num2str(memory_size(2)) ';']; fprintf(fid,'%s\n',line); % The size of the word in bits
line = ['ADDRESS_RADIX = BIN;']; fprintf(fid,'%s\n',line); % The radix for address values
line = ['DATA_RADIX = BIN;']; fprintf(fid,'%s\n',line); % The radix for data values
line = ['CONTENT']; fprintf(fid,'%s\n',line); 
line = ['BEGIN']; fprintf(fid,'%s\n',line);  % start of (address : data) pairs

%------------------------------------
% Write Memory Data with comments
%------------------------------------
address_bits = log2(memory_size(1));
for index = 1:memory_size(1)
    address = fi(index-1,0,address_bits,0);
    a = array(index);
    line = [address.bin ' : ' a.bin];
    if nargin <= 3
        line = [line '  -- array(' num2str(index) ') = ' num2str(array(index)) ];
    else
        line = [line comments(index,:)];
    end
    fprintf(fid,'%s\n',line);
end

%------------------------------------
% Write File End
%------------------------------------
line = ['END;'];  
fprintf(fid,'%s\n',line);  

%------------------------------------
% Close File
%------------------------------------
fclose(fid);

