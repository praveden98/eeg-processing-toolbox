classdef PWelch < eegtoolkit.featextraction.PSDExtractionBase
%Computes the psd using the welch method
%Usage:
%   session = eegtoolkit.util.Session();
%   session.loadSubject(1);
%   pwt = ssveptolkit.transform.PWelchTransformer(session.trials);
%Specify the channel to be used (default = 126)
%   pwt.channel = 150;
%Specify the number of seconds to be used (default = 0, use all signal)
%   pwt.seconds = 3;
%Specify the nfft parameter (default = 512, computes 257 features)
%   pwt.nfft = 512;
%Transform the signal
%   pwt.transform();
    properties (Access = public)
        channel;
        seconds;
        nfft;
        win_len;
        over_len;
        avgTime;
    end
    
    methods (Access = public)
        function PW = PWelch(seconds, channel, nfft, win_len, over_len)
            PW.seconds = 0;
            PW.channel = 1;
            PW.nfft = 512;
            PW.win_len = [];
            PW.over_len = [];
            PW.trials = {};
            if nargin > 0
                PW.seconds = seconds;
            end
            if nargin > 1
                PW.channel = channel;
            end
            if nargin > 2
                PW.nfft = nfft;
            end
            if nargin > 3
                PW.win_len = win_len;
            end
            if nargin > 4
                PW.over_len = over_len;
            end
        end
        
        function extract(PW)
            if length(PW.nfft)==1
                numFeatures = PW.nfft/2+1;
            else
                numFeatures = length(PW.nfft);
            end
            numTrials = length(PW.trials);
            instances = zeros(numTrials, numFeatures);
            labels = zeros(numTrials,1);
            tic;
            for i=1:numTrials
                if length(PW.seconds) == 1
                    numsamples = PW.trials{i}.samplingRate * PW.seconds;
                    if(numsamples == 0)
                        y = PW.trials{i}.signal(PW.channel,:);
                    else
                        y = PW.trials{i}.signal(PW.channel, 1:numsamples);
                    end
                elseif length(PW.seconds) == 2
                    sampleA = PW.trials{i}.samplingRate*PW.seconds(1) +1;
                    sampleB = PW.trials{i}.samplingRate*PW.seconds(2);
                    y = PW.trials{i}.signal(PW.channel, sampleA:sampleB);
                else 
                    error('invalid seconds parameter');
                end
                if length(PW.nfft>1)
                    [pxx, pff]=pwelch(y,PW.win_len,PW.over_len*PW.win_len,PW.nfft,PW.trials{i}.samplingRate);
                else
                    [pxx, pff]=pwelch(y,PW.win_len,PW.over_len*PW.win_len,PW.nfft,PW.trials{i}.samplingRate,'onesided');
                end
                instances(i,:) = pxx;
                labels(i,1) = floor(PW.trials{i}.label);
            end
            total = toc;
            PW.avgTime = total/numTrials;
            PW.instanceSet = eegtoolkit.util.InstanceSet(instances, labels);
            PW.pff = pff;
        end
        
        function configInfo = getConfigInfo(PW)
            if length(PW.nfft)>1
                configInfo = sprintf('PWelch\tchannel:%d\tseconds:%d\t freq range:%.3f to %.3f',PW.channel,PW.seconds,PW.nfft(1),PW.nfft(end));
            else
                configInfo = sprintf('PWelch\tchannel:%d\tseconds:%d\tnfft:%d',PW.channel,PW.seconds,PW.nfft);
            end
        end
        
        function time = getTime(PW)
            time = PW.avgTime;
        end
    end
   
end

