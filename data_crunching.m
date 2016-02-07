clear
clf
% Importing data
[pid,t,s1,s2,s3]=import_arduino_data('data4.csv');
% pid is the packet ID
% t is the time in microsecond
% s123 are the signals
Np=max(pid); % Number of packets
Ns=sum(pid==0); % Number of samples in each packet
t0=t(((1:Np)-1)*Ns+1); % Time of first sample for each packet

% centering signals at zero
s1=(s1-mean(s1));
s2=(s2-mean(s2));
s3=(s3-mean(s3));
% normalizing signal
s1=s1/max(abs(s1));
s2=s2/max(abs(s2));
s3=s3/max(abs(s3));

figure(1)
plot(t,s1,t,s2,t,s3)
%plot(t,abs(s1),t,abs(s2),t,abs(s3))

%% Going through signals
rind=[];
c=0;
for time=1:Np
    % interpolating
    indx=(time-1)*Ns+1+5:time*Ns;
    %    [time, sum(abs(s1(indx))),sum(abs(s2(indx))),sum(abs(s3(indx)))]
    %    [time, norm(s1(indx)),norm(s2(indx)),norm(s3(indx))]
    if sum(abs(s1(indx)))>3
        c=c+1;
        rind(c)=time;
        
        plot(t(indx),s1(indx),t(indx),s2(indx),t(indx),s3(indx))
        drawnow
        %pause(1)
        time
    end
end


%% Estimating distances
% constants in the problem
c=3500 *10^-4; % speed of sound in m/s => cm/microsec
d12=10; % distance between sensors
d23=10; % distance between sensors
k=4; % skip first few points
dt=100; % estimated time between measuring s1 and s2

% tdiff12=zeros(1,Np);
% tdiff23=zeros(1,Np);
tdiff12=zeros(1,length(rind));
tdiff23=zeros(1,length(rind));
c=0;
for time=rind
    c=c+1;
    % interpolating
    tt=linspace(t((time-1)*Ns+1+k),t(time*Ns),2*Ns);
    ss1=spline(t((time-1)*Ns+1+k:time*Ns),s1((time-1)*Ns+1+k:time*Ns),tt);
    ss2=spline(t((time-1)*Ns+1+k:time*Ns)+dt,s2((time-1)*Ns+1+k:time*Ns),tt);
    ss3=spline(t((time-1)*Ns+1+k:time*Ns)+2*dt,s3((time-1)*Ns+1+k:time*Ns),tt);
    
    f1=fft(ss1);
    f2=fft(ss2);
    f3=fft(ss3);
    R12=ifft(f1.*conj(f2));
    R23=ifft(f2.*conj(f3));
    [~,in12]=max(R12);
    [~,in23]=max(R23);
    tdiff12(c)=(tt(2)-tt(1))*(in12-1 -length(tt)*(in12>length(tt)/2));
    tdiff23(c)=-(tt(2)-tt(1))*(in23-1 -length(tt)*(in23>length(tt)/2));
end

% alpha1=asin(c*tdiff12/d12);
% alpha2=asin(c*tdiff23/d23);
alpha1=asin(tdiff12/544);
alpha2=asin(tdiff23/544);

% with 2 angles we have the position
% https://en.wikipedia.org/wiki/Triangulation
d=(d12/2+d23/2)*cos(alpha1).*cos(alpha2)./sin(alpha1-alpha2);
p_est=[d.*tan(alpha1) ; d];

scatter(p_est(1,:),p_est(2,:)) % estimated position
