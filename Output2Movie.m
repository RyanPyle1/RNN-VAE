% Take output from predictive VAE (1 or more images) 
% and turn it into a gif/movie
% needs movie2gif

cd 'C:\Users\ryanp\data\synth'

A = imread('predicted.png');
A = rgb2gray(A);
B = imread('predicted2.png');
B = rgb2gray(B);
C = imread('predicted3.png');
C = rgb2gray(C);

% Assumption : 1-2-3
%              4-5
nx = 8;
ny = 7;
n = 50; 
deadspace = 2; % each 'image' has a 2 pixel buffer, including start/end

size = 28; % 28x28 patches

ntotal = 3; % 3 seperate sets of above

data = zeros(size,size,ntotal*n);

numframes=ntotal*n;

fsize=13;
msize=6;

fig1=figure(1);

set(gcf,'Position',[563   292   600/2*2*1.5  500/2*2*1.5]) % x y width height

winsize = get(fig1,'Position');
winsize(1:2) = [0 0];
gifdat=moviein(numframes,fig1,winsize);

for i = 1:nx
    for j = 1:ny
        num  = (j-1)*nx + i;
        if (num<=n)
            xstart = deadspace+(i-1)*(size+deadspace);
            ystart = deadspace+(j-1)*(size+deadspace);
            %image(A(xstart+1:xstart+28;ystart+1:ystart+28));
            data(:,:,num) = A(ystart+1:ystart+size,xstart+1:xstart+size);
        end
    end
end
%image(data(:,:,1))
%colormap(gray)
for i = 1:nx
    for j = 1:ny
        num  = (j-1)*nx + i;
        num = num+50;
        if (num<=n+50)
            xstart = deadspace+(i-1)*(size+deadspace);
            ystart = deadspace+(j-1)*(size+deadspace);
            %image(A(xstart+1:xstart+28;ystart+1:ystart+28));
            data(:,:,num) = B(ystart+1:ystart+size,xstart+1:xstart+size);
        end
    end
end

for i = 1:nx
    for j = 1:ny
        num  = (j-1)*nx + i;
        num = num+100;
        if (num<=n+100)
            xstart = deadspace+(i-1)*(size+deadspace);
            ystart = deadspace+(j-1)*(size+deadspace);
            %image(A(xstart+1:xstart+28;ystart+1:ystart+28));
            data(:,:,num) = C(ystart+1:ystart+size,xstart+1:xstart+size);
        end
    end
end

for i=1:numframes
    figure(1);
    set(gcf,'Color',[1 1 1])
    image(data(:,:,i))
    colormap(gray)
    %axis([-1.1 1.1 -1.1 .9])

    set(gcf,'Color',[1 1 1])
  
    gifdat(:,i)=getframe(fig1,winsize);
    
end

%gifdat=[gifdat(:,1:ipause) repmat(gifdat(:,ipause),1,40) gifdat(:,ipause:end)];

movie2gif(gifdat, 'Predicted.gif','LoopCount',Inf, 'DelayTime', 1/12)