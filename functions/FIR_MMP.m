function W = FIR_MMP(Apara,L,p,predict_step)
%function W = MMP(Aparameters,L,p)
%Implement the procedure to produce the multirate model based predictor.
%Reference 'Multirate Forward-model Disturbance Observer for Feedback
%Regulation beyond Nyquist Frequency, Xu chen and Hui Xiao, systems &
%control letters, 2016'
%==========================================================================
%Apara: model coefficients of disturbance. 
%   Apara=[1 a1 a2 ... an] such that A(z-1)= 1+a1*z-1+...+am*z-n, and 
%   A(z-1)*d[n]=0
%L is the division parameter.
%W is a matrix containing the predictor parameters.
%  W(i,:)=[w_i_0, w_i_1, ..., w_i_m-1], i=1,2,3...,L-1
%p means p+1 slow sampled points will be used for prediction
%  if p<m-1, there is no exact sulution, gives the least square solution
%     instead.
%  if p=m-1, unique solution exist.
%  if p>m-1, infinite solution exist, gives the minimum norm solution.
%==========================================================================
%==========================================================================
% Copyright (c) 2019 Hui Xiao
%==========================================================================
%Created 10-12-2016
%Modified by Hui Xiao, add p argument. 11-3-2016
if Apara(1)~=1
    error('the first coefficient must be 1');
end
m = length(Apara)-1;
if nargin == 2
    p = m-1;
    predict_step = 0;
elseif nargin == 3
    if p<m-1
        warning('no solution exist, gives an approximate solution instead')
    elseif p>m-1
        disp('infinite solution exist, gives the minimum norm solution');
    end
    predict_step = 0;
elseif nargin ~= 4
    error('number of argument incorrect')
end

function W = W_prd1(Mk_s)
    %calculate W based on inverse and mapping, works for unique
    %solution case
    if rank(Mk_s.B)~=length(Mk_s.B)
        error('Mk is singular');
    end
    f=Mk_s.B\Mk_s.b2;
    W=-Mk_s.A*f+Mk_s.b1;
end
function W = W_prd2(Mk_s)
    %calculate W based on pesudoinverse method, works for infinite
    %solution case
    W = pinv(Mk_s.B*pinv(Mk_s.A))*(Mk_s.B*pinv(Mk_s.A)*Mk_s.b1-Mk_s.b2);
end

if(L>1)
    W = zeros(L-1+predict_step,p+1);
    if p == m-1  %unique solution case
        for k = 1:(L-1+predict_step)
            [~,Mk_s]=Mk_prd(Apara,L,k,p);
            W(k,:) = (W_prd1(Mk_s))';
        end
    else
        for k = 1:(L-1+predict_step)
            [~,Mk_s]=Mk_prd(Apara,L,k,p);
            W(k,:) = (W_prd2(Mk_s))';
        end
    end
elseif(L==1)
    W = 0;
else
    error('invalid L')
end
end