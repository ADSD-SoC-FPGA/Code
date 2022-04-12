% Add the simulink model's directory to MATLAB's path
% This only matters when the Simulink model is opened up outside of MATLAB.
% However, it does allow us to change directories in MATLAB while the Simulink
% model is running, if we need to.
addpath(fileparts(which(bdroot)));