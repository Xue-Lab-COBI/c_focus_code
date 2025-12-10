function [Output_final, Setup] = function_makeCycleClockGMscan(varargin)
% Trigger signals to synchronize hardware during scanning
% The code is developed by Yi Xue, 4/3/2024

Setup = varargin{1};
%   Output: DAQ output voltage to 7 channels: ao0 (galvo x), ao1 (galvo y), ao2 (PM gain), 
% P0.0 (laser), P0.1 (DMD), P0.8 (PMT trigger), 
NT = floor(Setup.Daq.Rate/Setup.ScanRate*2);
temp = repmat(Setup.VoltageX,NT/2,1);
Output_galvo = temp(:);
Output(:,1) = repmat(Output_galvo, Setup.Ypixel/2,1); %galvo x
N = length(Output_galvo)/2;
temp = repmat(Setup.VoltageY, N, 1);
Output(:,2) = temp(:); %galvo y

if Setup.NumOfFrames ==1 % DMD projector is in the secondary mode, sub-region correction
    Output(:,3) = Setup.PMTgain/1000*0.5+0.5; % PMT gain
    Output(:,4) = 1; %Laser
    Output(:,5) = 1; %DMD runs in master mode
%     Setup.DMD.illuminatetime =  nnz(Output(:,5))/Setup.Daq.Rate*10^6;
    PrepareTime = zeros(Setup.Daq.Rate*2,5);
    PrepareTime(:,3) = Setup.PMTgain/1000*0.5+0.5; % PMT gain;
    PrepareTime(end-2000:end,5) = 1;
    Output_final = cat(1, PrepareTime, Output);
    Output_final(:,6) = 1;
else
    O1 = reshape(Output,size(Output,1)/Setup.NumOfFrames, Setup.NumOfFrames,2);
    O2 = ones(size(Output,1)/Setup.NumOfFrames, Setup.NumOfFrames);
    O2_1 = padarray(O2, Setup.Interval*Setup.Daq.Rate, 'both');
    O1_1 = padarray(O1,Setup.Interval*Setup.Daq.Rate,'replicate','both');
    O3 = ones(round(size(Output,1)/Setup.NumOfFrames+round(Setup.Interval*Setup.Daq.Rate*0.2)), Setup.NumOfFrames);
    O3_1 = padarray(O3, round(Setup.Interval*Setup.Daq.Rate*0.9), 'both');
    clear Output
    Output(:,1:2) = reshape(O1_1, numel(O1_1)/2,2);
    Output(:,3) = Setup.PMTgain/1000*0.5+0.5; % PMT gain
    Output(:,4) = O2_1(:);
    Output(:,5) = O3_1(:);
    Setup.DMD.illuminatetime =  nnz(O3_1(:,1))/Setup.Daq.Rate*10^6;
    PrepareTime = zeros(Setup.Daq.Rate*2,5);
    PrepareTime(:,3) = Setup.PMTgain/1000*0.5+0.5; % PMT gain;
    Output_final = cat(1, PrepareTime, Output);
    Output_final(:,6) = 1;
end
%To clean up and make usre all lasers are off 
Output_final(end,:)=0;
end

