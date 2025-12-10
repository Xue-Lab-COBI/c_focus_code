function [Setup, Pattern] = function_GenerateSubregionMask(Setup,NumSubregion, VoltageOffset, stackSub)
%The code is developed by Yi Xue, 4/3/2024
%   Generate the full stack of masks for DMD projection

A = ones(round(Setup.Xpixel/NumSubregion),1);
[Xgrid, Ygrid] = meshgrid(A*[round(Setup.Xpixel/(2*NumSubregion)):round(Setup.Xpixel/NumSubregion):round(Setup.Xpixel*(1-1/(2*NumSubregion)))]);
D = zeros(Setup.Xpixel*Setup.Ypixel,size(VoltageOffset,1));
for k = 1:size(VoltageOffset,1)
    temp = [Xgrid(:)-VoltageOffset(k,2),Ygrid(:)-VoltageOffset(k, 1)];
    D (:,k) = sum(temp.^2,2);
end
[~, SubClusterInd] = min(D, [], 2);
Setup.SubClusterInd = reshape(SubClusterInd, Setup.Xpixel, Setup.Ypixel);
Pattern = zeros(Setup.DMD.LY,Setup.DMD.LX, Setup.Xpixel*NumSubregion, 'uint8');
for k = 1:Setup.Xpixel
    for p = 1:NumSubregion
        subind = Setup.SubClusterInd((p-1)*round(Setup.Xpixel/NumSubregion)+round(Setup.Xpixel/(NumSubregion*2)),k);
        if rem(k, 2) == 1 %odd colume
            Pattern(:,:,NumSubregion*(k-1)+p) = stackSub(:,:,subind);
        else
            Pattern(:,:,NumSubregion*(k-1)+NumSubregion-p+1) = stackSub(:,:,subind);
        end
    end
end
end