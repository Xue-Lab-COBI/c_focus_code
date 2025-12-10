function [Iafter] = function_imgprocess_removeGrid_step2(Ibefore, NumSubregion, edgewidth, sigma)
%remove the grid artifact due to subregion correction
%   Detailed explanation goes here
% [M1, N1] = size(Ibefore_raw);
% [Ux, Uy] = meshgrid(1:M1, 1:N1);
% [Vx, Vy] = meshgrid(linspace(1,M1,4*M1), linspace(1, N1, 4*N1));
% Ibefore = interp2(Ux, Uy, Ibefore_raw, Vx, Vy);
[M, ~] = size(Ibefore);
Iafter = Ibefore;

FilterRect = zeros(1, M);
FilterRect(M/2-sigma:M/2+sigma) = 1;

for jj=1:size(Iafter,3)
    I2d = Ibefore(:,:,jj);
    ImageCell = mat2cell(I2d, ones(1,NumSubregion)*M/NumSubregion, M, 1);
    for kk = 1:NumSubregion
        if kk+1<=NumSubregion
%             A1 = mean(ImageCell{kk, 1}(end-edgewidth:end,:),'all');
%             B1 = mean(ImageCell{kk+1, 1}(1:edgewidth+1,:),'all');
%             ImageCell{kk+1, 1} = ImageCell{kk+1, 1}/B1*A1;
            ratio = mean(ImageCell{kk, 1}(end-edgewidth:end,:),1)./mean(ImageCell{kk+1, 1}(1:edgewidth+1,:),1);
            Fr = fftshift(fft(ratio));
            Fr_filtered = Fr.*FilterRect;
            ratio_filtered = abs(ifft(Fr_filtered));
            ImageCell{kk+1, 1} = ImageCell{kk+1,1}.*repmat(abs(ratio_filtered), M/NumSubregion,1);
        end
    end
    Iafter(:,:,jj) = cell2mat(ImageCell);
end
% Iafterfinal = Iafter(1:4:end, 1:4:end);
end