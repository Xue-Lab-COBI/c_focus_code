function [ UT, Output_final,Subclock ] = function_makeCycleClock(varargin)
% Generate the trigger signals to synchronize hardwares
% The code is developed by Yi Xue, 4/3/2024

Setup = varargin{1};
%   Output: DAQ output voltage to 7 channels: ao0 (galvo x), ao1 (galvo y), ao2 (PM gain), 
% P0.0 (laser), P0.1 (DMD), P0.8 (PMT trigger), 
NT = floor(Setup.Daq.Rate*Setup.ExposureTime);
UT = linspace(0,1,NT);
Subclock = repmat(UT, 1, Setup.NumOfFrames);
Output = zeros(NT*Setup.NumOfFrames,6); 
Output(:,5) = double(Subclock>=Setup.Interval/Setup.ExposureTime); % DMD
Output(:,4) = double(Subclock>=1.5*Setup.Interval/Setup.ExposureTime);% laser, turn on laser after DMD
Output(:,6) = 1; % trigger for PMT, 5V
Output(:,3) = Setup.PMTgain/1000*0.5+0.5; 
Output(:,1) = 0+Setup.Xoffset;
Output(:,2) = 0+Setup.Yoffset;
PrepareTime = zeros(Setup.Daq.Rate*2,5);
PrepareTime(:,3) = Setup.PMTgain/1000*0.5+0.5;
PrepareTime(:,6) = 1;
Output_final = cat(1, PrepareTime, Output);
%To clean up and make usre all lasers are off 
Output_final(end,:)=0;

end

