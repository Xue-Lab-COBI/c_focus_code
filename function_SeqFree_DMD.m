function [Setup]=function_SeqFree_DMD(Setup, sequenceid)
Setup.DMD.alp_returnvalue=0;
Setup.DMD.alp_returnvalue = calllib('DMD', 'AlpSeqFree', Setup.DMD.deviceid, sequenceid);
    if Setup.DMD.alp_returnvalue~=0
        disp(['Error free sequenceid' num2str(sequenceid) '!']);
        Setup.DMD.alp_returnvalue=0;
    else
        disp(['Successfully free sequenceid ' num2str(sequenceid) '!']);
    end
end