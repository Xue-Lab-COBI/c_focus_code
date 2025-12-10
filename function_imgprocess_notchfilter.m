function [Iafter] = function_imgprocess_notchfilter(Ibefore, r, T)
%remove periodic pattern
%   Detailed explanation goes here
Iafter = Ibefore;
R = 5;
M = size(Ibefore,1);
for jj=1:size(Iafter, 3)
I1=Ibefore(:,:,jj);
FI = fftshift(fft2(I1));
FIamp = log(abs(FI));
% figure(3);imagesc(FIamp);axis image;
[xx, yy] = meshgrid(-M/2+1:M/2);
P= xx.^2+yy.^2>r^2;
% P2= xx.^2+yy.^2<(M/2-R)^2;
P2=1;

Threshold = mean(mean(FIamp(1:20,1:20)))*T;
Mask = imbinarize(FIamp, Threshold).*P.*P2;
% figure(4);imagesc(Mask);axis image;

[rows,cols,~] = find(Mask);
FIafter = FI;

for ii = 1:numel(rows)
    if cols(ii)-R<0
        FIafter(rows(ii), cols(ii)) = (FI(rows(ii)+R, cols(ii)+R)+FI(rows(ii)-R, cols(ii)+R))/2;
    elseif cols(ii)+R>size(FIafter,2)
        FIafter(rows(ii), cols(ii)) = (FI(rows(ii)-R, cols(ii)-R)+FI(rows(ii)+R, cols(ii)-R))/2;
    elseif rows(ii)-R<0
        FIafter(rows(ii), cols(ii)) = (FI(rows(ii)+R, cols(ii)-R)+FI(rows(ii)+R, cols(ii)+R))/2;
    elseif rows(ii)+R>size(FIafter,1)
        FIafter(rows(ii), cols(ii)) = (FI(rows(ii)-R, cols(ii)-R)+FI(rows(ii)-R, cols(ii)+R))/2;
    else
        FIafter(rows(ii), cols(ii)) = (FI(rows(ii)-R, cols(ii)-R)+FI(rows(ii)+R, cols(ii)-R)...
            +FI(rows(ii)+R, cols(ii)+R)+FI(rows(ii)-R, cols(ii)+R))/4;
    end
end
% figure(5);imagesc(log(abs(FIafter)));axis image;
%
Iafter(:,:,jj) = abs(ifft2(FIafter));
end
end