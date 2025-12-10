function [xk, loss] = function_FISTA(x0, h, Yc, opt)
%FISTA algorithm with sparse or TV regularizer. 
% The code is developed by Yi Xue. 

%   x0: initial guess of x0
%   h: transmission matrix
%   yc: measurement, could be 2D
%   max_iter: iteration number
%   stepsize: step size of gradient descent
%   reg: str, name of regularizer, could be 'TV' or 'sparse'
%   thres: thresholding value of regularizer, try to use 0.5 as default.

h_T=conj(h');
xk=x0;
tk=1;%initial tk
u=xk;
Nx = round(sqrt(numel(x0)));
    for i=1:opt.max_iter
        Uk=u;
        residue=h*Uk-Yc;
        gradf = h_T*residue;
        Uk1 = Uk - opt.stepsize*gradf;
        switch opt.reg
            case 'TV'
                Uk12D=reshape(Uk1,[Nx,Nx]);
                K=4*Uk12D-circshift(Uk12D,1,1)-circshift(Uk12D,1,2)-circshift(Uk12D,-1,1)-circshift(Uk12D,-1,2);
                xk1=wthresh(Uk1-opt.alpha*K(:),'s',opt.thresTV);
            case 'sparse'
                xk1=wthresh(Uk1,'s',opt.thresS);
                xk1(xk1<0)=0;
            case 'combo'
                if i < round(opt.max_iter/2)
                    Uk12D=reshape(Uk1,[Nx,Nx]);
                    K=2*Uk12D-circshift(Uk12D,1,1)-circshift(Uk12D,1,2);
                    xk1=wthresh(Uk1-opt.alpha*K(:),'s',opt.thresTV);
                else
                    xk1=wthresh(Uk1,'s',opt.thresS);
                    xk1(xk1<0)=0;
                end
        end
        tk1=1+sqrt(1+4*tk^2)/2;
        u=xk1+(tk-1)/tk1*(xk1-xk);
        xk=xk1;
        if i==1
            loss=sqrt(sum((h*xk-Yc).^2))+opt.L2reg*sum(abs(xk(:)));
        else
            loss=cat(1,loss,sqrt(sum((h*xk-Yc).^2))+opt.L2reg*sum(abs(xk(:))));
        end
        if i>2 && loss(end)>loss(end-1)
            disp('cost increase');
            break;
        end
        if nnz(xk)==0
            disp('xk is all zero');
            break;
        end        
    end
end

