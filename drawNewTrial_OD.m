function [t1,t2] = drawNewTrial_OD(dfrange,method,mu)

if strcmp(method,'uniform')
    % uniform
    f1 = 2*pi*rand();    % theta polar coordinate
    % ======================================
    
elseif strcmp(method,'unimodal')
    % gaussian uni-modal
            f1 = mu(1) + randn()*0.5;
     % ======================================

elseif strcmp(method,'bimodal')
    % gaussian bi-modal
    
    if rand>0.5
        f1 = mu(1) + randn()*0.5;
    else
        f1 = mu(2) + randn()*0.5;
    end
     % ======================================

elseif strcmp(method,'4modal')
    % gaussian 4-modal
    dice = rand();
    vec= [0 0.25 0.5 0.75];
    [~,b] =max(find(dice>vec));
    f1 = mu(b)+ randn()*0.005;
else
      % ======================================

    disp('not a valid sampling method')
end



df = rand*(dfrange(2)-dfrange(1))+dfrange(1);


if rand>.5
    f2 = f1 + df;
else
    f2 = f1 - df;
end

if rand>.5
    t1 = f1;
    t2 = f2;
else
    t2 = f1;
    t1 = f2;
end

t1 = mod(t1,2*pi);
t2 = mod(t2,2*pi);