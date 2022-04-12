% SPDX-License-Identifier: MIT
% Copyright (c) 2022 Trevor Vannoy, Ross K. Snider  All rights reserved.
%--------------------------------------------------------------------------
% Description:  Matlab Function initCallback.m
%       This scripts initializes 
%       1. The model variables and parameters via createModelParams()
%       2. The Simulation parameters via createSimParams()
%       3. The HDL Coder parameters via createHdlParams()
%
% This script runs before the simulation starts and during model 
% compilation. This script is called in the InitFcn callback 
% found in Model Explorer.
%--------------------------------------------------------------------------
% create/initialize the Simulink model parameters
modelParams = createModelParams();  

% create/set the Simulation parameters
simParams   = createSimParams(modelParams);

% create/set the HDL parameters
hdlParams   = createHdlParams(modelParams);


