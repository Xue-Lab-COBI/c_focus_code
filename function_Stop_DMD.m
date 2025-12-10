function [] = function_Stop_DMD(Setup)
%  The code is developed by Yi Xue, 4/3/2024
%  Stop the DMD
Setup.DMD.alp_returnvalue=0;
Setup.DMD.alp_returnvalue = calllib('DMD', 'AlpDevFree', Setup.DMD.deviceid);
if Setup.DMD.alp_returnvalue~=0
    disp('Error to stop DMD!');
else
    disp('DMD is stopped!');
end

end

