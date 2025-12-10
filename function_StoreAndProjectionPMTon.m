function [DataSave, sequenceid] = function_StoreAndProjectionPMTon(Setup, Nframe, stack, repeatSequence, sequenceid)
% When running the DMD in a secondary mode, store image stack, generate
% cycle clock, and project the image stack while reading PMT inputs,
% preprocessing of PMT data
%   Yi Xue 8-3-23
Setup.NumOfFrames = Nframe;
[~,Data.Output,~] = function_makeCycleClock(Setup);
Data.Output(end,3) = Data.Output(end-1,3);
Data.Output(end,6) = Data.Output(end-1,6);
Setup.DMD.illuminatetime = (Setup.ExposureTime-Setup.Interval)*10^6;% [us]
if repeatSequence == false
    [Setup,sequenceid] = function_StoreImages_DMD(Setup, stack);
end
[Setup, sequenceid] = function_StartProj_DMD(Setup, sequenceid);
disp("Projection starts!")
inScanData = readwrite(Setup.Daq, Data.Output); %raw voltage read from Analog input
disp("Projection is completed !");
Data.Raw = inScanData.Dev1_ai0;
Data.t = inScanData.Time;
clear inScanData
DataSave.Y = function_ProcessPMTdata(Data,Nframe);
DataSave.Ystd = std(DataSave.Y);
DataSave.Ymean = mean(DataSave.Y);
figure(546);subplot(3,1,1);plot(Data.t,Data.Raw);
subplot(3,1,2);plot(Data.t(2*Setup.Daq.Rate+1:end),Data.Raw(2*Setup.Daq.Rate+1:end));
subplot(3,1,3);plot(DataSave.Y);title(['Y mean ' num2str(DataSave.Ymean,'%.2f') ', std ' num2str(DataSave.Ystd,'%.2f')]);
drawnow;
end