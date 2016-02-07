%% Signal generation
clear
clf
tf=3; % motion time in seconds
f=60; % frequency of the signal in Hz
c=500; % Speed of sound in cm/s

n=ceil(10*tf*f); % number of samples, 10 per period
t=linspace(0,tf,n); % time
signoise=0.4;
signal=(1+signoise*rand(1,n)).*sin(2*pi*f*t); % signal with amplitude 1

x0=-30;y0=100;
p=[ x0*(1-2*t/tf) ; y0*(1+0.1*sin(2*pi*t/tf))]; % positions of source: straight line
d1=[-10 ; 0]; % position of sensor 1 in cm
d2=[0 ; 0]; % position of sensor 2 in cm
d3=[10 ; 0]; % position of sensor 2 in cm

t1 = t+sqrt(sum((p-repmat(d1,1,n)).^2,1))/c; % time at which the signal gets received by s1
t2 = t+sqrt(sum((p-repmat(d2,1,n)).^2,1))/c; % time at which the signal gets received by s2
t3 = t+sqrt(sum((p-repmat(d3,1,n)).^2,1))/c; % time at which the signal gets received by s3

s1 = signal./sqrt(2*pi*sqrt(sum((p-repmat(d1,1,n)).^2,1))); % signal with amplitude attenuation
s2 = signal./sqrt(2*pi*sqrt(sum((p-repmat(d2,1,n)).^2,1))); % signal with amplitude attenuation
s3 = signal./sqrt(2*pi*sqrt(sum((p-repmat(d3,1,n)).^2,1))); % signal with amplitude attenuation

plot(t1,s1,t2,s2,t3,s3)
%plot(t2,signal)

%% Position from signals: method 1, maxima from 3 sensors
% finding times at signal maxima
tmax1=t1(circshift(signal,[0,-1])<signal & signal>circshift(signal,[0,1]));
tmax2=t2(circshift(signal,[0,-1])<signal & signal>circshift(signal,[0,1]));
tmax3=t3(circshift(signal,[0,-1])<signal & signal>circshift(signal,[0,1]));

% with 2 sensors we can find the angle of the source
% https://en.wikipedia.org/wiki/Acoustic_source_localization
alpha1=asin(c*(tmax1-tmax2)/norm(d2-d1));
alpha2=asin(c*(tmax2-tmax3)/norm(d3-d2));

% with 2 angles we have the position
% https://en.wikipedia.org/wiki/Triangulation
d=norm((d2+d1)/2-(d3+d2)/2)*cos(alpha1).*cos(alpha2)./sin(alpha1-alpha2);
p_est=repmat((d2+d1)/2,1,length(d)) +[ d.*tan(alpha1) ; d];

scatter(p_est(1,:),p_est(2,:)) % estimated position
hold on
scatter(p(1,1:floor(n/length(d)):end),p(2,1:floor(n/length(d)):end)) % actual position
hold off
axis([x0 -x0 0 max(p(2,:))+10])


%% Position from signals: method 2, amplitude and maxima from 2 sensors
% finding times at signal maxima
tmax1=t1(circshift(signal,[0,-1])<signal & signal>circshift(signal,[0,1]));
tmax3=t3(circshift(signal,[0,-1])<signal & signal>circshift(signal,[0,1]));
% finding amplitudes at signal maxima
a1=s1(circshift(signal,[0,-1])<signal & signal>circshift(signal,[0,1]));
a3=s3(circshift(signal,[0,-1])<signal & signal>circshift(signal,[0,1]));

% with 2 amplitudes and time delay we have the distances
% Ampl(R)=Ampl(0)/sqrt(2*pi*R) AND R3=R1+c*(tmax3-tmax1)
r3=c*(tmax3-tmax1)./(1-a3.^2./a1.^2);
r1=r3-c*(tmax3-tmax1);

% with all the distances we have the angles and position
% https://en.wikipedia.org/wiki/Solution_of_triangles#Three_sides_given_.28SSS.29
alpha=acos((r3.^2+norm(d3-d1)^2-r1.^2)./(2*norm(d3-d1)*r3));
p_est=repmat(d3,1,length(r1)) +[-r3.*cos(alpha) ; r3.*sin(alpha)];

scatter(p_est(1,:),p_est(2,:)) % estimated position
hold on
scatter(p(1,1:floor(n/length(d)):end),p(2,1:floor(n/length(d)):end)) % actual position
hold off
axis([x0 -x0 0 max(p(2,:))+10])


%% Estimating position with noisy signals from TOF with cross-correlation
% Adding independent noise to signals
noise=0.1;
s1 = (1+noise*(rand(1,n)-0.5)).*signal./sqrt(2*pi*sqrt(sum((p-repmat(d1,1,n)).^2,1)));
s2 = (1+noise*(rand(1,n)-0.5)).*signal./sqrt(2*pi*sqrt(sum((p-repmat(d2,1,n)).^2,1)));
s3 = (1+noise*(rand(1,n)-0.5)).*signal./sqrt(2*pi*sqrt(sum((p-repmat(d3,1,n)).^2,1)));

% setting a common time
tt=max([t1(1),t2(2),t3(3)]):(t(2)-t(1))/100:min([t1(end),t2(end),t3(end)]);
ss1=max(-max(s1), min(max(s1),spline(t1,s1,tt)));
ss2=max(-max(s2), min(max(s2),spline(t2,s2,tt)));
ss3=max(-max(s3), min(max(s3),spline(t3,s3,tt)));

% Choosing how many points to sample
N=tf*10;
DT=floor(length(tt)/N);
tdiff12=zeros(1,N);
tdiff23=zeros(1,N);
for time=1:N
    R12=xcorr(ss1((time-1)*DT+1:time*DT),ss2((time-1)*DT+1:time*DT));
    R23=xcorr(ss2((time-1)*DT+1:time*DT),ss3((time-1)*DT+1:time*DT));
    [~,in12]=max(R12);
    [~,in23]=max(R23);
    tdiff12(time)=(tt(2)-tt(1))*(in12-DT-1);
    tdiff23(time)=(tt(2)-tt(1))*(in23-DT-1);
end
% with 2 sensors we can find the angle of the source
% https://en.wikipedia.org/wiki/Acoustic_source_localization
alpha1=asin(c*tdiff12/norm(d2-d1));
alpha2=asin(c*tdiff23/norm(d3-d2));

% with 2 angles we have the position
% https://en.wikipedia.org/wiki/Triangulation
d=norm((d2+d1)/2-(d3+d2)/2)*cos(alpha1).*cos(alpha2)./sin(alpha1-alpha2);
p_est=repmat((d2+d1)/2,1,length(d)) +[ d.*tan(alpha1) ; d];

scatter(p_est(1,:),p_est(2,:)) % estimated position
hold on
scatter(p(1,1:floor(n/length(d)):end),p(2,1:floor(n/length(d)):end)) % actual position
hold off
axis([x0 -x0 0 max(p(2,:))+10])

%% Estimating position with noisy signals from TOF with FFT
% Adding independent noise to signals
noise=0.;
s1 = (1+noise*(rand(1,n)-0.5)).*signal./sqrt(2*pi*sqrt(sum((p-repmat(d1,1,n)).^2,1)));
s2 = (1+noise*(rand(1,n)-0.5)).*signal./sqrt(2*pi*sqrt(sum((p-repmat(d2,1,n)).^2,1)));
s3 = (1+noise*(rand(1,n)-0.5)).*signal./sqrt(2*pi*sqrt(sum((p-repmat(d3,1,n)).^2,1)));

% setting a common time
tt=max([t1(1),t2(2),t3(3)]):(t(2)-t(1))/100:min([t1(end),t2(end),t3(end)]);
ss1=max(-max(s1), min(max(s1),spline(t1,s1,tt)));
ss2=max(-max(s2), min(max(s2),spline(t2,s2,tt)));
ss3=max(-max(s3), min(max(s3),spline(t3,s3,tt)));
% Choosing how many points to sample
N=tf*5;
DT=floor(length(tt)/N);
tdiff12=zeros(1,N);
tdiff23=zeros(1,N);
for time=1:N
    f1=fft(ss1((time-1)*DT+1:time*DT));
    f2=fft(ss2((time-1)*DT+1:time*DT));
    f3=fft(ss3((time-1)*DT+1:time*DT));
    R12=ifft(f1.*conj(f2));
    R23=ifft(f2.*conj(f3));
    [~,in12]=max(R12);
    [~,in23]=max(R23);
    tdiff12(time)=(tt(2)-tt(1))*(in12-1 -DT*(in12>DT/2));
    tdiff23(time)=(tt(2)-tt(1))*(in23-1 -DT*(in23>DT/2));
end
% with 2 sensors we can find the angle of the source
% https://en.wikipedia.org/wiki/Acoustic_source_localization
alpha1=asin(c*tdiff12/norm(d2-d1));
alpha2=asin(c*tdiff23/norm(d3-d2));

% with 2 angles we have the position
% https://en.wikipedia.org/wiki/Triangulation
d=norm((d2+d1)/2-(d3+d2)/2)*cos(alpha1).*cos(alpha2)./sin(alpha1-alpha2);
p_est=repmat((d2+d1)/2,1,length(d)) +[ d.*tan(alpha1) ; d];

scatter(p_est(1,:),p_est(2,:)) % estimated position
hold on
scatter(p(1,1:floor(n/length(d)):end),p(2,1:floor(n/length(d)):end)) % actual position

p_fit=smooth(p_est(1,:)',p_est(2,:)');
plot(p_est(1,:),p_fit)

hold off
axis([x0 -x0 0 max(p(2,:))+10])

%% Estimating position with noisy signals from TOF with whitened FFT
% Adding independent noise to signals
noise=0.2;
s1 = (1+noise*(rand(1,n)-0.5)).*signal./sqrt(2*pi*sqrt(sum((p-repmat(d1,1,n)).^2,1)));
s2 = (1+noise*(rand(1,n)-0.5)).*signal./sqrt(2*pi*sqrt(sum((p-repmat(d2,1,n)).^2,1)));
s3 = (1+noise*(rand(1,n)-0.5)).*signal./sqrt(2*pi*sqrt(sum((p-repmat(d3,1,n)).^2,1)));

% setting a common time
tt=max([t1(1),t2(2),t3(3)]):(t(2)-t(1))/100:min([t1(end),t2(end),t3(end)]);
ss1=max(-max(s1), min(max(s1),spline(t1,s1,tt)));
ss2=max(-max(s2), min(max(s2),spline(t2,s2,tt)));
ss3=max(-max(s3), min(max(s3),spline(t3,s3,tt)));
% Choosing how many points to sample
N=tf*10;
DT=floor(length(tt)/N);
tdiff12=zeros(1,N);
tdiff23=zeros(1,N);
for time=1:N
    f1=fft(ss1((time-1)*DT+1:time*DT));
    f2=fft(ss2((time-1)*DT+1:time*DT));
    f3=fft(ss3((time-1)*DT+1:time*DT));
    R12=ifft(angle(f1).*angle(-f2));
    R23=ifft(angle(f2).*angle(-f3));
    [~,in12]=max(R12);
    [~,in23]=max(R23);
    tdiff12(time)=(tt(2)-tt(1))*(in12-1 -DT*(in12>DT/2));
    tdiff23(time)=(tt(2)-tt(1))*(in23-1 -DT*(in23>DT/2));
end
% with 2 sensors we can find the angle of the source
% https://en.wikipedia.org/wiki/Acoustic_source_localization
alpha1=asin(c*tdiff12/norm(d2-d1));
alpha2=asin(c*tdiff23/norm(d3-d2));

% with 2 angles we have the position
% https://en.wikipedia.org/wiki/Triangulation
d=norm((d2+d1)/2-(d3+d2)/2)*cos(alpha1).*cos(alpha2)./sin(alpha1-alpha2);
p_est=repmat((d2+d1)/2,1,length(d)) +[ d.*tan(alpha1) ; d];

scatter(p_est(1,:),p_est(2,:)) % estimated position
hold on
scatter(p(1,1:floor(n/length(d)):end),p(2,1:floor(n/length(d)):end)) % actual position
hold off
axis([x0 -x0 0 max(p(2,:))+10])