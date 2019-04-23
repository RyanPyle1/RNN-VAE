% RNN Climate Learning e.g. copy procedure from paper
% https://arxiv.org/pdf/1710.07313v1.pdf
% To be used on VAE generated visual (video) data

% update rule : r(t+dt) = tanh(Ar(t) + Win u(t))
% v(t+dt) = Wout(r(t+dt),P), P are our params, often Wout = P*r

% min_t ||Wout(P,r) - target||^2  + Beta*||P||^2

% For prediction, change u(t) to v(t) - e.g. feed output back in

% This verion for taking in VAE data, making predictions

close all
clear all

load logvarout.csv
load muout.csv

numentries = 1000;
entrydim = 3;

muout = reshape(muout,[entrydim,1000]);
logvarout = reshape(logvarout,[entrydim,1000]);

if (false)
   plot(muout(1,:))
   hold on
   plot(muout(2,:))
   plot(muout(3,:))
   
   figure
   plot(logvarout(1,:))
   hold on
   plot(logvarout(2,:))
   plot(logvarout(3,:))
end

Dr = 2000; % Reservoir size (num units)
T = 1000;
%T/dt = 5000; -> dt = .02
p = 1.45; % Spectral Radius, seems to need > 1.35
%p = 1.5;
d = 6; % average connectivity
B = .1;
sigma = .1; %?

r = rand(Dr,1)*2 - 1;
rstore = r;

oneaug = true;
showall = true;

% Rand J
J = sprand(Dr,Dr,.02);
J = full(J);
J(J~=0) = J(J~=0) - .5;

% Randn J
J = sprandn(Dr,Dr,.02);
J = full(J);

% sum(J~=0)
% mean(ans) -> approx 6
J = J.*p./(max(abs(eigs(J))));
W1 = randn(entrydim,Dr);
W2 = randn(entrydim,Dr);
%Win = randn(Dr,3);
%Win = rand(Dr,3)*2-1;
Win = randn(Dr,2*entrydim).*sigma; % gives sigma = .1?
z1 = zeros(T,entrydim);
z2 = zeros(T,entrydim);

if (oneaug)
    R = zeros(T,Dr+1);
    R2 = zeros(T,Dr+1);
else
    R = zeros(T,Dr);
    R2 = zeros(T,Dr);
end
for i = 1:(T-1)
    if (mod(i,100)==0)
       i /(T)
    end
    
    u = [muout(:,i);logvarout(:,i)]; % feed in current
    
    r = tanh(J*r +  Win*u);
    
    z1(i,:) = [muout(:,i+1)]; % target is next 
    z2(i,:) = [logvarout(:,i+1)];
    if (oneaug)
        R(i,:) = [r;1]';
    else
        R(i,:) = [r'];
    end
    
end
% https://en.wikipedia.org/wiki/Ordinary_least_squares
% Optimization : 300 * 5000 inputs = X
% 3*5000 outputs = z
% X'*(300;3) = z'
% But we are using rhat not r, so we really doing 2 seperate optimizations
% R*w1 = z1'
% Rhat*w2 = z2'
% Solutions = inv(R'R)R'z
% so need to generate R, Rhat, z1, z2

% Regularization
if (B>0)
   if (oneaug)
   z1 = [z1;zeros(Dr+1,entrydim)];
   z2 = [z2;zeros(Dr+1,entrydim)];
   R = [R;eye(Dr+1)]; 
   else
   z1 = [z1;zeros(Dr,entrydim)];
   z2 = [z2;zeros(Dr,entrydim)];
   R = [R;eye(Dr)];     
   end
end

%W = inv(R'*R)*R'*z1;
%W1 = W(:,1)';
%W2 = W(:,2)';
%W3 = (inv(Rhat'*Rhat)*Rhat'*z2)';
W1 = pinv(R)*z1;
W2 = pinv(R)*z2;
%W1v2 = inv(R'*R)*R'*z1; # equal, not an issue with computation

% Generated W1 and W2 appear poor. Try another way?
% Idea : choose random element to update
% Perturb in a direction, continue while helpful, repeat
%error1 = sum((R*W1(:,1) - z1(:,1)).^2);
%changes = 0;
%for x = 1:10000
%   update = randi(1000 + 1*(oneaug));
%   epsi = rand()*.05 - .025;
%   W1new = W1;
%   W1new(update,1) = W1new(update,1) + epsi;
%   errornew = sum((R*W1new(:,1) - z1(:,1)).^2);
%   while (errornew < error1)
%      changes = changes + 1;
%      W1 = W1new;
%      error1 = errornew;
%      W1new(update,1) = W1new(update,1) + epsi;
%      errornew = sum((R*W1new(:,1) - z1(:,1)).^2);
%   end
%end


% Redo as validation
%r = rand(Dr,1)*2 - 1; % Poor performance
r = rstore;
for i = 1:(T-1)
    if (mod(i,100)==0)
       i /(T)
    end
    
    u = [muout(:,i);logvarout(:,i)]; % feed in current
    
    r = tanh(J*r +  Win*u);
    
    if (oneaug)
        logvar = W2'*[r;1];
        mu = W1'*[r;1];
    else
        logvar = W2'*r;
        mu = W1'*r;
    end
    
    if (oneaug)
        R2(i,:) = [r;1]';
    else
        R2(i,:) = [r'];
    end
    
    
    xi(i) = muout(1,i+1);
    xouti(i) = mu(1);
    mupred(:,i) = mu;
    logvarpred(:,i) = logvar;
end
figure
plot(xi)
hold on
plot(xouti,'r')

% Testing : extend simulation past training time, see results
for i = (T):2*(T)    
    if (i == (T))
        u = [muout(:,i);logvarout(:,i)]; % teacher forcing, works well
    else
        u = [mu;logvar]; % true feedback
    end
    
    r = tanh(J*r +  Win*u);
    
    if (oneaug)
        logvar = W2'*[r;1];
        mu = W1'*[r;1];
    else
        logvar = W2'*r;
        mu = W1'*r;
    end
    
    xouti(i) = mu(1);
    mupred(:,i) = mu;
    logvarpred(:,i) = logvar;
end
figure
plot(xi)
hold on
plot(xouti,'r')

if (showall)
figure
plot(muout(1,:))
hold on
plot(mupred(1,:))

figure
plot(muout(2,:))
hold on
plot(mupred(2,:))

figure
plot(muout(3,:))
hold on
plot(mupred(3,:))

figure
plot(logvarout(1,:))
hold on
plot(logvarpred(1,:))

figure
plot(logvarout(2,:))
hold on
plot(logvarpred(2,:))

figure
plot(logvarout(3,:))
hold on
plot(logvarpred(3,:))

%sum((muout(1,T-1)-mupred(1,T-1)).^2)
%sum((muout(1,T-1)-mupred(1,T-1)-.5).^2)
    
end

%figure
%plot(xouti(T : 2*T))

if (false) % write predictions, see what they look like
mupred = mupred(:,T+1:2*T);
logvarpred = logvarpred(:,T+1:2*T);
mupred = reshape(mupred,[1,3000]);
logvarpred = reshape(logvarpred,[1,3000]);
csvwrite('mupred.csv',mupred)
csvwrite('logvarpred.csv',logvarpred)
end