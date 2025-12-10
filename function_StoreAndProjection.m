function [Data, sequenceid] = function_StoreAndProjection(Setup, Nframe, stack, repeatSequence, sequenceid)
% When running the DMD in a secondary mode, store image stack, generate
% cycle clock, and project the image stack while reading PMT inputs,
% preprocessing of PMT data
%   Yi Xue 8-3-23
Setup.NumOfFrames = Nframe;
[~,Data.Output,~] = function_makeCycleClock(Setup);
Setup.DMD.illuminatetime = Setup.ExposureTime*(1-Setup.Interval)*10^6;% [us]
if repeatSequence == false
    [Setup,sequenceid] = function_StoreImages_DMD(Setup, stack);
end
[Setup, sequenceid] = function_StartProj_DMD(Setup, sequenceid);
disp("Scanning starts!")
inScanData = readwrite(Setup.Daq, Data.Output); %raw voltage read from Analog input
disp("Scanning is completed !");
Data.Raw = inScanData.Dev1_ai0;
Data.t = inScanData.Time;
clear inScanData
Data.Y = function_ProcessPMTdata(Data,Nframe);
Data.Y_norm = (Data.Y - min(Data.Y))/max(Data.Y - min(Data.Y));
Data.Ystd = std(Data.Y);
Data.Ymean = mean(Data.Y);
figure(546);subplot(3,1,1);plot(Data.t,Data.Raw);
hold on; plot(Data.t,Data.Output);hold off;
title('raw measurements');
subplot(3,1,2);plot(Data.t(2*Setup.Daq.Rate+1:end),Data.Raw(2*Setup.Daq.Rate+1:end));
subplot(3,1,3);plot(Data.Y);title(['Y mean ' num2str(Data.Ymean,'%.2f') ', std ' num2str(Data.Ystd,'%.2f')]);
end