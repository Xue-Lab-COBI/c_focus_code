function [VoltageOffset, peakVal] = function_FindTargets(I2d, N, NumSubregion)
% find local targets for scattering correction from point-scanning 2P image
%   Yi Xue, 4/3/2024
%   Iraw: point-scanning 2D image
%   N: the number of targets, N<=NumSubregion^2, N could be 1. 
%   NumSubregion: the number of subregions (3x3, 4x4, 5x5...) along one
%   dimention
I2d = medfilt2(I2d, [3, 3]);

blksizes = diff(round(linspace(1, size(I2d,1)+1, NumSubregion+1)));
ImageCell = mat2cell(I2d, blksizes, blksizes, 1);
peakVal = zeros(NumSubregion^2, 1);
for ii = 1:NumSubregion
    for jj =1:NumSubregion
        [peakVal((ii-1)*NumSubregion+jj), ~] = max(ImageCell{jj, ii}, [], 'all');
    end
end

[~, ~, IndB] = intersect(peakVal, I2d, 'stable');
[temp1, temp2] = ind2sub(size(I2d), IndB);
VoltageOffset = [temp1, temp2];
end