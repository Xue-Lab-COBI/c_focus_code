function [Iafter] = function_imgprocess_removeGrid_step1(Ibefore, NumSubregion, edgewidth)
%remove the grid artifact due to subregion correction
%   Detailed explanation goes here
% [M1, N1] = size(Ibefore_raw);
% [Ux, Uy] = meshgrid(1:M1, 1:N1);
% [Vx, Vy] = meshgrid(linspace(1,M1,4*M1), linspace(1, N1, 4*N1));
% Ibefore = interp2(Ux, Uy, Ibefore_raw, Vx, Vy);

Iafter = Ibefore;
for jj=1:size(Iafter,3)
    I2d = Ibefore(:,:,jj);
    blksizes = diff(round(linspace(1, size(Ibefore,1)+1, NumSubregion+1)));
    ImageCell = mat2cell(I2d, blksizes, blksizes, 1);
     for kk = 1:NumSubregion
        for qq = 1:NumSubregion
            if qq+1<=NumSubregion
                A1 = mean(ImageCell{kk,qq}(:,end-edgewidth:end),'all');
                B1 = mean(ImageCell{kk,qq+1}(:,1:edgewidth+1),'all');
                ImageCell{kk,qq+1} = ImageCell{kk,qq+1}/B1*A1;
            end
        end
     end
     Iafter1 = cell2mat(ImageCell);
end
for jj=1:size(Iafter,3)
    I2d = Ibefore(:,:,jj);
    blksizes = diff(round(linspace(1, size(Ibefore,1)+1, NumSubregion+1)));
    ImageCell = mat2cell(I2d, blksizes, blksizes, 1);
     for kk = NumSubregion:-1:1
        for qq = NumSubregion:-1:1
            if qq-1>=1
                A1 = mean(ImageCell{kk,qq}(:,1:edgewidth+1),'all');
                B1 = mean(ImageCell{kk,qq-1}(:,end-edgewidth:end),'all');
                ImageCell{kk,qq-1} = ImageCell{kk,qq-1}/B1*A1;
            end
        end
     end
     Iafter2 = cell2mat(ImageCell);
end
Iafter = (Iafter1+Iafter2)/2;
% Iafterfinal = Iafter(1:4:end, 1:4:end);
end