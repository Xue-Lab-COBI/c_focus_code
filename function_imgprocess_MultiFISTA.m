function [Icorrect4] = function_imgprocess_MultiFISTA(Icorrect,NumSubregion)
% Remove period pattern and subregion boarders
% The code is developed by Yi Xue, 4/3/2024
opt.T = 1.4;
opt.r = 43;
opt.edgewidth = 1;
opt.sigma = 4;  

Icorrect2 = function_imgprocess_notchfilter(Icorrect, opt.r, opt.T);
Icorrect3 = function_imgprocess_removeGrid_step1(Icorrect2, NumSubregion, opt.edgewidth);
Icorrect4 = function_imgprocess_removeGrid_step2(Icorrect3, NumSubregion, opt.edgewidth, opt.sigma);
figure();imagesc(Icorrect4);axis image;colormap('gray');colorbar;drawnow;
end