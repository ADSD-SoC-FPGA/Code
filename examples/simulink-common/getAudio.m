% SPDX-License-Identifier: MIT
% Copyright (c) 2022 Ross K. Snider.  All rights reserved.
%--------------------------------------------------------------------------
% Description:  Matlab Function to get audio with desired conversions
%--------------------------------------------------------------------------
% Author:       Ross K. Snider
% Company:      Montana State University
% Create Date:  May 19, 2022
% Revision:     1.0
% License: MIT  (opensource.org/licenses/MIT)
%--------------------------------------------------------------------------
function audio4 = getAudio(filename, desiredFs, desiredCh, desiredNt)
%--------------------------------------------------------------------------
% Inputs:  filename:   filename with path if needed
%          desiredFs:  The desired sample frequency (Fs)
%          desiredCh:  The desired channel(s) 
%                      'left', 'right', 'stereo' or 
%                       array of channel numbers for multichannel file
%          desiredNt:  The desired numerictype (Nt) 
% Only one input argument needs to be supplied, but input arguments need 
% to be in the following order if there are more than one.
%          Argument 1 = filename
%          Argument 2 = desiredFs
%          Argument 3 = desiredCh
%          Argument 4 = desiredNt
%--------------------------------------------------------------------------

%-----------------------------------------
% Get audio file
%-----------------------------------------
[audio1, fileFs] = audioread(filename);
if nargin == 1
    audio4=audio1;
    return;
end

%-----------------------------------------
% Convert to desired sample rate
%-----------------------------------------
if nargin >= 2
    audio2 = resample(audio1, desiredFs, fileFs);
    if nargin == 2
        audio4=audio2;
        return;
    end
end

%-----------------------------------------
% Get requested channels
%-----------------------------------------
if nargin >= 3
    fileInfo = audioinfo(filename);
    if ischar(desiredCh)
        if strcmpi(desiredCh,'left')
            audio3 = audio2(:,1);
        elseif strcmpi(desiredCh,'right')
            if fileInfo.NumChannels < 2
                error('Audio file has only one audio channel.')
            end
            audio3 = audio2(:,2);
        elseif strcmpi(desiredCh,'stereo')
            if fileInfo.NumChannels < 2
                error('Audio file has only one audio channel')
            end
            audio3 = audio2(:,1:2);
        else
            error('desiredCh string unknown')
        end
    elseif isnumeric(desiredCh)
        if max(desiredCh) > fileInfo.NumChannels
            error('desiredCh value out of range')
        end
        audio3 = audio2(:,desiredCh);
    end
    if nargin == 3
        audio4=audio3;
        return;
    end
end

%-----------------------------------------
% Convert to desired data type
%-----------------------------------------
if nargin == 4
    audio4 = fi(audio3,desiredNt);
end

end

