function stack = function_PatternGenerator2D(PatternName,Setup)
% Generate 2D ptterns for DMD alignment
% The code is developed by Yi Xue, 4/3/2024
switch PatternName
    case 'blank'
        stack = uint8(255*ones(Setup.DMD.LY, Setup.DMD.LX));
    case 'random'
        Margin = (Setup.DMD.LY-Setup.DMD.LX)/2;
        N = round(Setup.DMD.LX / Setup.W / 2);
        B = zeros(N, N, 'uint8');
        rng('shuffle');
        idx = randperm(N^2, round(N^2*Setup.Sparsity));
        B(idx) = 255;
        B1 = padarray(B, [Margin/(2*Setup.W),0],0,'both');
        stack = imresize(B1, [Setup.DMD.LY, Setup.DMD.LX],'nearest'); 
end
stack = 255-stack;