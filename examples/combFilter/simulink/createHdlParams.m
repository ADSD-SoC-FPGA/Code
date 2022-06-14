% SPDX-License-Identifier: MIT
% Copyright (c) 2022 Ross K. Snider.  All rights reserved.
%--------------------------------------------------------------------------
% Description:  Matlab Function to create/set HDL parameters for a
%               Simulink model. 
%--------------------------------------------------------------------------
% Author:       Ross K. Snider
% Company:      Montana State University
% Create Date:  April 5, 2022
% Revision:     1.0
% License: MIT  (opensource.org/licenses/MIT)
%--------------------------------------------------------------------------
function hdlParams = createHdlParams(modelParams)
% Input is the modelParams struct from createModelParams()
% Output is the hdlParams struct containing HDL related information.

%--------------------------------------------------------------------------
% Speed of FPGA Clock that we will connect to in the FPGA fabric
%--------------------------------------------------------------------------
FPGA_clock_frequency = 98304000;  % Clock frequency in Hz

%--------------------------------------------------------------------------
% Compute the HDL Coder Oversampling factor
% https://www.mathworks.com/help/hdlcoder/ug/oversampling-factor.html
% https://www.mathworks.com/help/hdlcoder/ug/generating-a-global-oversampling-clock.html
%--------------------------------------------------------------------------
oversampling = FPGA_clock_frequency/modelParams.audio.sampleFrequency;
if mod(oversampling,1) == 0  % check if it is an integer
    hdlParams.clockOversamplingFactor = oversampling;
else
    % Note the Simulink Diagnostic Viewer doesn't provide the stack trace
    % so we need to provide the location where this error is coming from
    % if there is an error.
    st = dbstack;
    disp(['Error in ' st.name]);
    error('Error: The clock oversampling factor must be an integer.')
end
% Set the oversampling factor in the Model Settings (Ctrl+E)
% Located at \HDL Code Generation\Global Settings\Clock settings
% Note: we can't use a variable name so we have to explicitly
% set it with hdlset_param().
hdlset_param(gcs,'Oversampling',hdlParams.clockOversamplingFactor)




