function [Setup,sequenceid] = function_feed_DMD(Setup, stack)
% The code is developed by Yi Xue, 4/3/2024
% stack: 1280x800xframes binary data
Setup.DMD.alp_returnvalue=0;
if size(stack,1)~=Setup.DMD.LY || size(stack,2)~=Setup.DMD.LX
    stack = permute(stack, [2 1 3]);
end
%allocate sequences
bitdepth=1;
picnum=size(stack,3);
sequenceid = uint32(0);
sequenceidptr = libpointer('uint32Ptr', sequenceid);
[Setup.DMD.alp_returnvalue, sequenceid] = calllib('DMD', 'AlpSeqAlloc', ...
    Setup.DMD.deviceid, bitdepth, picnum, sequenceidptr);
if Setup.DMD.alp_returnvalue~=0
    disp('Error allocate sequence!');
    Setup.DMD.alp_returnvalue=0;
end
if isempty(Setup.DMD.sequenceid)
    Setup.DMD.sequenceid=sequenceid;
else
    Setup.DMD.sequenceid=cat(1,Setup.DMD.sequenceid,sequenceid);
end
    
%% load frames
userarrayptr = libpointer('voidPtr', stack);%userarray: image to upload to DMD, 2560x1600 unit8 type 2D matrix
picoffset=0;
picload=size(stack,3);
Setup.DMD.alp_returnvalue = calllib('DMD', 'AlpSeqPut', Setup.DMD.deviceid, ...
    sequenceid, picoffset, picload, userarrayptr);
if Setup.DMD.alp_returnvalue~=0
    disp('Error load sequence!');
    Setup.DMD.alp_returnvalue=0;
else
    disp([num2str(picload) ' frames loaded!']);
end

%% Repeat sequence
Setup.DMD.alp_returevalue = calllib('DMD','AlpSeqControl',Setup.DMD.deviceid,...
    sequenceid, Setup.DMD.SequenceControl.RepeatMode,...
    Setup.DMD.SequenceControl.RepeatModeValue);
if Setup.DMD.alp_returnvalue~=0
    disp('Error repeat sequence!');
    Setup.DMD.alp_returnvalue=0;
end
%% bitplane
Setup.DMD.alp_returevalue = calllib('DMD','AlpSeqControl',Setup.DMD.deviceid,...
   sequenceid, Setup.DMD.SequenceControl.BitplaneMode,...
    Setup.DMD.SequenceControl.BitplaneModeValue);
if Setup.DMD.alp_returnvalue~=0
    disp('Error setting bitplane!');
    Setup.DMD.alp_returnvalue=0;
end

%% check current projection mode and start projection
uservar = int32(0);
uservarptr = libpointer('int32Ptr', uservar);
Setup.DMD.inquiretype=int32(2300);
[Setup.DMD.alp_returnvalue, ProjMode] = calllib('DMD', 'AlpProjInquire', ...
    Setup.DMD.deviceid, Setup.DMD.inquiretype, uservarptr);
if Setup.DMD.alp_returnvalue~=0
    disp('Error inquire sequence!');
    Setup.DMD.alp_returnvalue=0;
else
    if ProjMode==2302 %slave
        Setup.DMD.alp_returnvalue = calllib('DMD', 'AlpProjStart', ...
        Setup.DMD.deviceid, sequenceid);
        if Setup.DMD.alp_returnvalue~=0
            disp('Error start constant display!');
            Setup.DMD.alp_returnvalue=0;
        end
    else
        Setup.DMD.alp_returnvalue = calllib('DMD', 'AlpProjStartCont', ...
        Setup.DMD.deviceid, sequenceid);
        if Setup.DMD.alp_returnvalue~=0
            disp('Error start constant display!');
            Setup.DMD.alp_returnvalue=0;
        end
    end
end
end

