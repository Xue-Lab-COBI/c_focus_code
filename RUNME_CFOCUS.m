% Project images with the DMD
clear;close all;clc
%% Initialize NI DAQ, PI stage, and DMD
Setup = function_initializeNIDaq();
Setup = function_initializePIstage(Setup);
Setup = function_initializeRotationStage(Setup);
Setup = function_initializeDMD(Setup);
%% Reference PI stage
% reference
Setup.PIdevice.FRF ( Setup.PIaxis );  % find reference (for E-712: only working with stages in which no absolute sensor is installed)                     
disp ( 'Stage is referencing')
% wait for referencing to finish
while(0 ~= Setup.PIdevice.qFRF ( Setup.PIaxis ) == 0 )                        
    pause(0.1);           
    fprintf('.');
end     
disp ( 'Referencing complete')
%% move stage
Z0 = 6.8; %initial position unit [mm], top position is 7 mm
targetPosition = Setup.PIposition.minimumPosition + Z0;
Setup.PIdevice.MOV (Setup.PIaxis, targetPosition);
while(0 ~= Setup.PIdevice.IsMoving () )
    pause ( 0.1 );
    fprintf('.');
end
%% move rotation stage to set the laser power
Setup.RotTimeout_val = 60000;
Setup.RotStage.Home(Setup.RotTimeout_val);
Setup.RotInit = 78; % rotation stage 78 degree = 0 mW
Setup.OffsetRotPosition = Setup.RotInit-(-pi/2+0.7208)/0.06972; %the constant is from curve fitting of LUT
%% measure max power
Setup.MaxPower = 100;
%% Adjust input laser power
CurrentPower = 1; %[mW]
CurrentRotPosition = (asin((CurrentPower/Setup.MaxPower-0.5)*2)+0.7208)/0.06972+Setup.OffsetRotPosition;
Setup.RotStage.MoveTo(CurrentRotPosition, Setup.RotTimeout_val);
%% set scanning parameters
%Thorlabs scanner specifications: https://www.thorlabs.com/newgrouppage9.cfm?objectgroup_id=3770
Setup.Xmax = 0.3; %maximum voltage for galvo scanner x [V], 1V~=420um FOV
Setup.Ymax = 0.3; %maximum voltage for galvo scanner y [V]
Setup.Xpixel = 288; %number of pixels of the image in x
Setup.Ypixel = 288; %number of pixels of the image in y
Setup.VoltageX = cat(2,linspace(-Setup.Xmax,Setup.Xmax,Setup.Xpixel),linspace(Setup.Xmax,-Setup.Xmax,Setup.Xpixel));
Setup.VoltageY = linspace(-Setup.Ymax, Setup.Ymax, Setup.Ypixel);
Setup.ScanRate = 4000; 
Setup.PMTgain = 1000; % 0-1000, corresponding to voltage 0.5V-1V
Setup.Interval = 0.1*10^(-3); % [seconds] Waiting time between sequential DMD frames, only used if DMD patterns change during scanning
Setup.ExposureTime = 1/Setup.ScanRate; % [seconds]
%% Take 3D stack without correction
%project a blank mask
stack1 = function_PatternGenerator2D('blank', Setup);
ScanType = '3DStack';
Zinit = 6.88;%0.052
dZ = 0.01;%mm
Zstep = 93;

InitPower = 1;
PowerThreshold = 60;
Ls = 0.17; %scattering length, mouse brain 0.156
% 
DataSaveWO.Image = zeros(Setup.Xpixel, Setup.Ypixel,Zstep);
switch ScanType
    case 'OneFrame'
        Z0 = Zinit; %initial position unit [mm]
        targetPosition = Setup.PIposition.minimumPosition + Z0;
        Setup.PIdevice.MOV (Setup.PIaxis, targetPosition);

        Setup.NumOfFrames = 1; 
        Data = function_StoreAndProjectionAndScan(Setup,Setup.NumOfFrames, Pattern1);
        DataSaveWO.Image = Data.Image;
        figure();imagesc(DataSaveWO.Image);colorbar;axis image;
    case '3DStack'
        for q = 1:Zstep
            Z0 = Zinit-(q-1)*dZ; %initial position unit [mm]
            targetPosition = Setup.PIposition.minimumPosition + Z0;
            Setup.PIdevice.MOV (Setup.PIaxis, targetPosition);
            while(0 ~= Setup.PIdevice.IsMoving () )
                pause ( 0.1 );
                fprintf('.');
            end
            
            Setup.NumOfFrames = 1; %NumOfFrame = 1, run DMD in the primary mode. Otherwise, size(Pattern,3)
            Data = function_StoreAndProjectionAndScan(Setup,Setup.NumOfFrames, Pattern1);

            if CurrentPower < PowerThreshold
                CurrentPower = min(InitPower/(exp(-(q-1)*dZ/Ls)), PowerThreshold);
                CurrentRotPosition = (asin((CurrentPower/Setup.MaxPower-0.5)*2)+0.7208)/0.06972+Setup.OffsetRotPosition;
                Setup.RotStage.MoveTo(CurrentRotPosition, Setup.RotTimeout_val);
                disp(['Current Power :' num2str(CurrentPower)]);
            end
            DataSaveWO.Image(:,:,q) = Data.Image;
            disp(q);
        end
        disp('Image stack is completed !');
        figure();imshow3D(DataSaveWO.Image);axis image;
end
%% load beam profile on the DMD and random patterns
load('RandomPatterns.mat');% random patterns
load('BeamProfile.mat');% beam profile
%% Generate xy map identify offset voltage
NT = floor(Setup.Daq.Rate/Setup.ScanRate);
temp = repmat(Setup.VoltageX(1:Setup.Xpixel),NT,1);
Output_galvo = temp(:);
Data2 = repmat(Output_galvo, Setup.Ypixel,1);
Data3 = reshape(Data2, [length(Data2)/(Setup.Xpixel*Setup.Ypixel),Setup.Xpixel*Setup.Ypixel]);
XvoltageImage = reshape(mean(Data3,1),Setup.Xpixel, Setup.Ypixel);
N = length(Output_galvo)/2;
temp = repmat(Setup.VoltageY, N, 1);
Data2 = temp(:); %galvo y
Data3 = reshape(Data2, [length(Data2)/(Setup.Xpixel*Setup.Ypixel),Setup.Xpixel*Setup.Ypixel]);
YvoltageImage = reshape(mean(Data3,1),Setup.Xpixel, Setup.Ypixel);
%% C-FOCUS correction
DMDPatternType = 'MultiFISTA' ; 
IcaliAll = 2.5e10;%DMD output-to-input power ratio in terms of MATLAB value
Setup.Interval = 0.1*10^(-3); % [seconds] Waiting time between sequential frames 
Setup.ExposureTime = 0.5*10^(-3); % [seconds], Total imaging time per frame, sum of laser on time and interval time
failflag = 0;
InitialSet = 1;
kskip = 0;

FrameNum = 1; 
binsize = 20;
iter = 1;
Z0 = Zinit-(FrameNum-1)*dZ; % manually select
targetPosition = Setup.PIposition.minimumPosition + Z0;
Setup.PIdevice.MOV (Setup.PIaxis, targetPosition);
while(0 ~= Setup.PIdevice.IsMoving () )
    pause ( 0.1 );
    fprintf('.');
end

%check DMD projection mode, set to secondary
CurrentProjMode=function_ProjInquire_DMD(Setup);
if CurrentProjMode ~= 2302 %not in the secondary mode
    Setup =function_StopProj_DMD(Setup);
    Setup = function_DMDProjMode(Setup,'secondary');
end

switch DMDPatternType
    case 'SingleFISTA'
        NumTarget = 1;
        Setup.NumSubregion = 1; 
        [VoltageOffset,Val] = function_FindTargets(DataSaveWO.Image(:,:,FrameNum), NumTarget, Setup.NumSubregion);
        figure(983);
        imagesc(DataSaveWO.Image(:,:,FrameNum));axis image;hold on;scatter(VoltageOffset(:,2), VoltageOffset(:,1),'r'); hold off;colorbar;drawnow;
        
        %adjust power for random illumination
        CurrentPower = 60; %[mW]
        CurrentRotPosition = (asin((CurrentPower/Setup.MaxPower-0.5)*2)+0.7208)/0.06972+Setup.OffsetRotPosition;
        Setup.RotStage.MoveTo(CurrentRotPosition, Setup.RotTimeout_val);
        pause(1);

        Setup.Xoffset = XvoltageImage(VoltageOffset(1),VoltageOffset(2));
        Setup.Yoffset = YvoltageImage(VoltageOffset(1),VoltageOffset(2));
        DataSave.VoltageOffset = VoltageOffset;
        startpoint = 0;
        NframeFISTA = 3000; %number of measurements
        stackFISTA = stack(:,:,startpoint+1:startpoint+NframeFISTA);
        [DataRandom, sequenceid] = function_StoreAndProjection(Setup,NframeFISTA, stackFISTA, false, 0);
        Setup = function_SeqFree_DMD(Setup, sequenceid); %free ALP memory for the random pattern
        DataSave.Y = DataRandom.Y;

        %initialization x0 from direct sum
        stackB = B(:,:,startpoint+1:startpoint+NframeFISTA);
        [~,indpeaks] = sort(DataRandom.Y,'descend');
        x0 = rescale(sum(stackB(:,:,indpeaks(1:round(numel(DataRandom.Y)*0.1))),3), 0, 1);
        
        opt.alpha = 0.008;
        opt.max_iter = 1000;
        opt.stepsize = 2e-8;
        opt.reg = 'TV';
        opt.thresTV = 1e-5;
        opt.thresS = 1e-5;
        opt.L2reg = 0;
        r = reshape(rescale(double(stackB),0,1), size(B, 1)*size(B, 2), NframeFISTA);
        [xk, loss] = function_FISTA(x0(:), r', DataRandom.Y', opt);
        figure(347);plot(loss);set(gca, 'YScale', 'log'); grid on;title('loss');
        MaskB = reshape(xk,[size(B, 1), size(B, 2)]);
        MaskB = MaskB-min(MaskB, [],'all');
        [FinalMask, CorrectMask, failflag] = function_GenerateCorrectMaskFISTA(Setup, MaskB, Imap, IcaliAll);
        save([savepath 'SingleFISTA_' num2str(Z0) '_' num2str(NframeFISTA) 'measurement_' num2str(IcaliAll) '.mat'],'FinalMask','DataSave','-v7.3');
     
    case 'MultiFISTA'
        NumTarget = 64; %NumTarget<=NumSubregion^2
        NumSubregion = 8; %4x4 subregions
        [VoltageOffset,Val] = function_FindTargets(DataSaveWO.Image(:,:,FrameNum), NumTarget, NumSubregion);
        figure(983);
        imagesc(DataSaveWO.Image(:,:,FrameNum));axis image;hold on;scatter(VoltageOffset(:,2), VoltageOffset(:,1),'r'); hold off;colorbar;drawnow;
        
        Ind = cell(NumTarget,1);
        CellSize = binsize/(Setup.Xmax*419/Setup.Xpixel); %considered within the same cell
        for k = 1:size(VoltageOffset,1)
            EuDistance = sqrt((VoltageOffset(:,1) - VoltageOffset(k,1)).^2+(VoltageOffset(:,2) - VoltageOffset(k,2)).^2);    
            Ind{k} = find(EuDistance<CellSize & EuDistance~=0);
        end
        
        CurrentPower = 60; %[mW]
        CurrentRotPosition = (asin((CurrentPower/Setup.MaxPower-0.5)*2)+0.7208)/0.06972+Setup.OffsetRotPosition;
        Setup.RotStage.MoveTo(CurrentRotPosition, Setup.RotTimeout_val);
        tic
        DataRandomAll = cell(NumTarget,1);
        for k = 1:size(VoltageOffset,1)
            if ~isempty(Ind{k})
                if Val(k) ~= max(Val([k;Ind{k}]))
                    continue;
                end
            end
            Setup.Xoffset = XvoltageImage(VoltageOffset(k,1),VoltageOffset(k,2));
            Setup.Yoffset = YvoltageImage(VoltageOffset(k,1),VoltageOffset(k,2));
            if InitialSet == 1
                repeatSequence = false;
                sequenceid = 0; %store a new sequence
                startpoint = 0;
                NframeFISTA = 3000; %number of measurements
                stackFISTA = stack(:,:,startpoint+1:startpoint+NframeFISTA);
                DataRandomY = zeros(NumSubregion, NframeFISTA);
                stackB = B(:,:,startpoint+1:startpoint+NframeFISTA);
                r = reshape(rescale(double(stackB),0,1), size(B, 1)*size(B, 2), NframeFISTA);
                InitialSet = 0;
                [DataRandomAll{k}, sequenceid] = function_StoreAndProjectionPMTon(Setup,NframeFISTA, stackFISTA, repeatSequence, sequenceid);
                disp(['Completed ' num2str(k) '/' num2str(NumTarget)]);
            else
                repeatSequence = true;
                [DataRandomAll{k}, sequenceid] = function_StoreAndProjectionMultiROI(Setup,NframeFISTA, stackFISTA, repeatSequence, sequenceid);
                disp(['Completed ' num2str(k) '/' num2str(NumTarget)]);
            end
        end
        write(Setup.Daq, zeros(1,6));%turn off laser and PMT
        Setup =function_StopProj_DMD(Setup);
        Setup = function_SeqFree_DMD(Setup, sequenceid); %free ALP memory for the random pattern
        DataSave.Y = DataRandomAll;
        toc

        CurrentPower = 60; %[mW]
        CurrentRotPosition = (asin((CurrentPower/Setup.MaxPower-0.5)*2)+0.7208)/0.06972+Setup.OffsetRotPosition;
        Setup.RotStage.MoveTo(CurrentRotPosition, Setup.RotTimeout_val);
        tic
        disp('Start generating correction mask...');
        opt.alpha = 0.008;
        opt.max_iter = 1000;
        opt.stepsize = 2e-8;
        opt.reg = 'TV';
        opt.thresTV = 1e-5;
        opt.thresS = 1e-5;
        opt.L2reg = 0;
        stackSub = zeros(Setup.DMD.LY,Setup.DMD.LX, NumTarget,'uint8');
        Mask = zeros(Setup.DMD.LY,Setup.DMD.LX, NumTarget);
        failflag = false(NumTarget, 1);
        for k = 1:NumTarget
            if ~isempty(DataRandomAll{k})
                [~,indpeaks] = sort(DataRandomAll{k}.Y,'descend');
                x0 = rescale(sum(stackB(:,:,indpeaks(1:round(numel(DataRandomAll{k}.Y)*0.1))),3), 0, 1);
                [xk, loss] = function_FISTA(x0(:), r', DataRandomAll{k}.Y', opt);
                MaskB = reshape(xk,[size(B, 1), size(B, 2)]);
                MaskB = MaskB-min(MaskB, [],'all');
                [stackSub(:,:,k), Mask(:,:,k), failflag(k)] = function_GenerateCorrectMaskFISTA(Setup, MaskB, Imap, IcaliAll);
            end
        end
        for k = 1:NumTarget
            if isempty(DataRandomAll{k})
                LocalMax = max(Val([k;Ind{k}]));
                IndLocalMax = find(Val == LocalMax);
                if ~any(stackSub(:,:,IndLocalMax),'all') 
                    kskip = [kskip;k];
                    continue
                else
                    stackSub(:,:,k) = stackSub(:,:,IndLocalMax(1));
                end
            end
        end
        if any(kskip)
            for ii=2:numel(kskip)
                neighborRegion = intersect([kskip(ii)+NumSubregion-1:kskip(ii)+NumSubregion+1, ...
                        kskip(ii)-NumSubregion-1:kskip(ii)-NumSubregion+1, kskip(ii)-1, kskip(ii)+1], 1:NumTarget);
                tempind = unique([Ind{kskip(ii)};neighborRegion'],'stable');
                if any(stackSub(:,:,tempind),'all')
                   stackindtemp = ceil(find(stackSub(:,:,tempind),1)/(Setup.DMD.LY*Setup.DMD.LX));
                   stackSub(:,:,kskip(ii)) = stackSub(:,:,tempind(stackindtemp));
                elseif kskip(ii) == 1
                    stackSub(:,:,1)=stackSub(:,:,1+NumSubregion);
                else
                    disp(['Cannot generate substack #' num2str(kskip(ii))]);
                end
            end
        end
        toc
        [Setup, Pattern] = function_GenerateSubregionMask(Setup, NumSubregion, VoltageOffset, stackSub);
        disp('Completed generate subregion masks! Start scanning...');
        Setup.NumOfFrames = size(Pattern,3);
        Setup.ExposureTime = 1/Setup.ScanRate; % [seconds]
        CurrentProjMode=function_ProjInquire_DMD(Setup);
        if CurrentProjMode ~= 2302 
            Setup =function_StopProj_DMD(Setup);
            Setup = function_DMDProjMode(Setup,'secondary');
        end
        [Data, sequenceid] = function_StoreAndProjectionAndScan(Setup,Setup.NumOfFrames, Pattern);
        DataSave.RawImage = Data.Image;
        DataSave.VoltageOffset = VoltageOffset;
        DataSave.Image = function_imgprocess_MultiFISTA(DataSave.RawImage,NumSubregion);
        save([savepath '64SubregionFISTA_' num2str(Z0) '_iter' num2str(iter) '.mat'],'stackSub','DataSave','Ind','-v7.3');
        Setup =function_StopProj_DMD(Setup);
        Setup = function_SeqFree_DMD(Setup, sequenceid);
end
%% stop DMD, PI stage, and rotation stage
[Setup]=function_StopProj_DMD(Setup);
function_Stop_DMD(Setup);
switchOff = 0;
Setup.PIdevice.SVO ( Setup.PIaxis, switchOff ); % STAGE DROP TO MINIMUM!!! switch servo off
Setup.PIdevice.CloseConnection (); % close connection 
Setup.RotStage.StopPolling()
Setup.RotStage.Disconnect()