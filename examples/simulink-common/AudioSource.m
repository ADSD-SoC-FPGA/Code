% AudioSource 
% This class represents an audio source for use with Autogen.

% SPDX-License-Identifier: MIT
% Copyright 2020 Audio Logic, Dylan Wickham
% Copyright 2022 Trevor Vannoy

classdef AudioSource < handle
    %AudioSource Represents an audio source for use with Autogen
    
    % TODO: add fixed-point datatype support (see original AudioSource.m in FrOST repo for inspiration).
    properties(SetAccess = private)
        Audio
        SampleRate
        NSamples
        NChannels
        Duration
    end
    
    methods
        function obj = AudioSource(audio, sampleRate)
        %AudioSource Initializes AudioSource with m x n audio input and
        % sample rate in hz, where m is the the number of samples and n is
        % the number of channels.
            obj.SampleRate = sampleRate;
            obj.Audio = audio;
            obj.NChannels = size(obj.Audio,2);
            obj.NSamples = size(obj.Audio,1);
            obj.Duration = obj.NSamples / obj.SampleRate;
        end
        function fxptAudio = toFixedPoint(obj, signed, wordLength, fractionLength)
            fxptAudio = fi(obj.Audio, signed, wordLength, fractionLength);
        end
    end

    methods(Static)
        function audioSource = fromFile(filepath, sampleRate)
            [audio, fileSampleRate] = audioread(filepath);

            resampledAudio = resample(audio, sampleRate, fileSampleRate);

            audioSource = AudioSource(resampledAudio, sampleRate);
        end
    end
end

