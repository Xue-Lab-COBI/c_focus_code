function [ProjMode]=function_ProjInquire_DMD(Setup)
Setup.DMD.alp_returnvalue=0;
Setup.DMD.inquiretype=int32(2300);
[Setup.DMD.alp_returnvalue, ProjMode] = calllib('DMD', 'AlpProjInquire', ...
    Setup.DMD.deviceid, Setup.DMD.inquiretype, uservarptr);
 if Setup.DMD.alp_returnvalue~=0
        disp('Error inquiring projection mode!');
        Setup.DMD.alp_returnvalue=0;
 end
end