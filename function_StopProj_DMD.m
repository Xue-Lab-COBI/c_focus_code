function [Setup]=function_StopProj_DMD(Setup)
Setup.DMD.alp_returnvalue=0;
Setup.DMD.alp_returnvalue = calllib('DMD', 'AlpProjHalt', Setup.DMD.deviceid);
    if Setup.DMD.alp_returnvalue~=0
        disp('Error stop projection!');
        Setup.DMD.alp_returnvalue=0;
    else
        disp('Stop projecting!');
    end
end

