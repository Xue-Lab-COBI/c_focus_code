function [Data,sequenceid] = function_StoreAndProjectionAndScan(Setup, Nframe, stack)
% When running the DMD in a secondary mode, store image stack, generate
% cycle clock, and project the image stack while reading PMT inputs,
% preprocessing of PMT data
%   Yi Xue 8-3-23
Setup.NumOfFrames = Nframe;
[Data.Output, Setup] = function_makeCycleClockGMscan(Setup);
CurrentProjMode=function_ProjInquire_DMD(Setup);
if CurrentProjMode == 2302 % DMD projector is in the secondary mode, sub-region correction
    [Setup,sequenceid] = function_StoreImages_DMD(Setup, stack);
    [Setup] = function_StartProj_DMD(Setup, sequenceid);
end
disp("Scanning starts!");
RawMeasurement = readwrite(Setup.Daq, Data.Output); %raw voltage read from Analog input
disp("Scanning is completed !");

Data.t = RawMeasurement.Time;
Data.Raw = RawMeasurement.Dev1_ai0;
clear RawMeasurement
figure(1000); plot(Data.t(2*Setup.Daq.Rate+1:end),Data.Raw(2*Setup.Daq.Rate+1:end));drawnow;
LaserOnMask = Data.Output(:,4);
if CurrentProjMode == 2301
    LaserOnMask(end) = 1;
end
Data1 = nonzeros(Data.Raw.*LaserOnMask); %Output(:,4) laser
DataBG = mean(nonzeros(Data.Raw.*(1-LaserOnMask)));
DataBG_std = std(nonzeros(Data.Raw.*(1-LaserOnMask)));
Data2 = Data1;
if DataBG+DataBG_std>0
    Data2(Data2<(DataBG+DataBG_std))=0;
else
    Data2 = Data1-DataBG;
end
[~,ind] = findpeaks(-Data2);
Data3 = Data2;
Data3(ind) = (Data2(ind+1)+Data2(ind-1))/2;
Data4 = reshape(Data3, [length(Data3)/(Setup.Xpixel*Setup.Ypixel),Setup.Xpixel*Setup.Ypixel]);
C = sum(Data4,1);
D = reshape(C,Setup.Xpixel, Setup.Ypixel);
Data.Image = D;
Data.Image(:,2:2:end) = flipud(D(:,2:2:end));
figure(981);imagesc(Data.Image);axis image;colorbar;
end