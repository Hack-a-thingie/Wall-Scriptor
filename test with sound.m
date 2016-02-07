%% Importing wav files
clear
newData = importdata('stereo test - Jie.wav');
vars = fieldnames(newData);
for i = 1:length(vars)
    assignin('base', vars{i}, newData.(vars{i}));
end
s1=data(:,1);
newData = importdata('stereo test - Lee.wav');
vars = fieldnames(newData);
for i = 1:length(vars)
    assignin('base', vars{i}, newData.(vars{i}));
end
s2=data(:,1);
clear data i newData vars 

%% Clipping sounds
tf=200000;
t=(1:tf)/fs;
[~,i1]=max(s1(211200:211900));
s1=s1(311200+i1-1:311200+i1-1+tf-1);
[~,i2]=max(s2(164600:166400));
s2=s2(264600+i2-1:264600+i2-1+tf-1);
plot(t,s1,t,s2+1)

%% selecting real data (?)
c=conv(ones(1000,1),abs(s1).^2)/1000;
c=c(500:length(c)-500);
s1=s1.*(c>1E-5);
s2=s2.*(c>1E-5);
plot(t,s1,t,s2+1)

%% Estimating angle
c=34000; % Speed of sound in cm/s
d=20; % distance between sensors

% Choosing how many points to sample
N=5000;
DT=floor(tf/N);
tdiff12=zeros(1,N);
for time=1:N
    f1=fft(s1((time-1)*DT+1:time*DT));
    f2=fft(s2((time-1)*DT+1:time*DT));
    R12=ifft(f1.*conj(f2));
    [~,in12]=max(R12);
    tdiff12(time)=(in12-1 -DT*(in12>DT/2));
end
% with 2 sensors we can find the angle of the source
% https://en.wikipedia.org/wiki/Acoustic_source_localization
alpha1=asin(c*tdiff12/d);

% plot(1:N,tdiff12,1:N,s1(((1:N)-1)*DT+1)+31)

plot(alpha1)