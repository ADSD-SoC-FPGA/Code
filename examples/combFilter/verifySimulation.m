% verifySimulation
%
% Verify the model's output

% SPDX-License-Identifier: MIT
% Copyright 2022 Trevor Vannoy

expected = delay(simParams.testSignal.audio, modelParams.delayTime, ...
    modelParams.feedback, modelParams.wetDryMix, config.sampleFrequency);

% Simulink's output has one extra sample at the end, so we ignore it.
if all(expected == audioOut(1:end-1,:), 'all')
    disp('verifySimulation: verification passed')
else
    warning('verifySimulation: verification failed');
end