function [Setup,sequenceid] = function_StoreImages_DMD(Setup, stack )
% The code is developed by Yi Xue, 2/2/2023
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

%load frames
userarrayptr = libpointer('voidPtr', stack);%userarray: image to upload to DMD, 2560x1600 unit8 type 2D matrix
picoffset=0;
picload=size(stack,3);
Setup.DMD.alp_returnvalue = calllib('DMD', 'AlpSeqPut', Setup.DMD.deviceid, ...
    sequenceid, picoffset, picload, userarrayptr);
if Setup.DMD.alp_returnvalue~=0
    disp('Error load sequence!');
    Setup.DMD.alp_returnvalue=0;
else
    disp(['Sequence#' num2str(sequenceid) ': ' num2str(picload) ' frames loaded!']);
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
%% sequence timing
disp(['current DMD illuminate time = ' num2str(Setup.DMD.illuminatetime) ' us.']);
picturetime=0;
triggerdelay=0;
triggerpulsewidth=Setup.DMD.illuminatetime+triggerdelay;
vddelay=0;
Setup.DMD.alp_returnvalue=calllib('DMD','AlpSeqTiming',Setup.DMD.deviceid,sequenceid,...
  Setup.DMD.illuminatetime, picturetime, triggerdelay, triggerpulsewidth, vddelay);
if Setup.DMD.alp_returnvalue~=0
    disp('Error setting sequence timing!');
    Setup.DMD.alp_returnvalue=0;
end
end

