% Generate synthetic VAE data
% Size 28 * 28 , 0 to 1 values

gentype = 2;

if (gentype == 1)% random data for test
num_samples = 100;

data = zeros(28,28);

for i = 1:num_samples
    for j = 1:784
       data(j) = rand(); 
    end
    name = strcat('testdat',num2str(i),'.txt');
    %fid=fopen(name,'w');
    %fprintf(fid, '%f,', data);
    %fclose(fid);
    csvwrite(name,data(:)')
end
end

if (gentype == 2)% bouncing ball
num_samples = 1000;
dt = .1;
x = rand;
y = rand;
dx = rand-.5;
dy = rand-.5;
if (abs(dx)<.05)
    dx = .05* (((rand<.5)*2)-1);
end
if (abs(dy)<.05)
    dy = .05* (((rand<.5)*2)-1);
end
radius = .2;
data = zeros(28,28);
for t = 1:num_samples
   x=x+dx*dt;
   if (x>1)
       x = 2-x;
       dx = -dx;
   end
   if (x<0)
       x = -x;
       dx = -dx;
   end
   y=y+dy*dt;
   if (y>1)
       y = 2-y;
       dy = -dy;
   end
   if (y<0)
       y = -y;
       dy = -dy;
   end
   xt(t) = x;
   yt(t) = y;
   for i = 1:28       
        for j = 1:28
            dist = sqrt((x-(29-i)/29)^2 + (y-j/29)^2);
            data(i,j) = (1-dist/radius)*(dist<radius);
        end
        datat(:,:,t) = data;
   end
   numstr = num2str(t);
   zerstr = '000';
   zerstr = zerstr(1:4-length(numstr));
   name = strcat('testdat',zerstr,numstr,'.txt');
   csvwrite(name,data(:)')        
end
% Seems data is flipped (both x,y) from what I would think to what it sees.
% Probably not an issue for a ball.
end
if (false)
plot(xt)
hold on
plot(yt)

ts = 970;
tf = 980;
figure
plot(xt(ts:tf))
hold on
plot(yt(ts:tf))
for i = ts:tf
   figure
   surf(datat(:,:,i))
end

end
