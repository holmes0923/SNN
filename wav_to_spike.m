function fire_time = wav_to_spike(wav_name)
% parameter
trim=0.1;
win_size=512;
resolution=100;
n_count=400;
wav_name='zero.wav';
% read the wav file
[data,Fs,bits]=wavread(wav_name);

% if the sound is multi-channel
col=size(data,2);
if(col>1)
    tmpdata=sum(data,2);
else
    tmpdata=data;
end

% normalise to -1~1
tmpdata=tmpdata./max(abs(tmpdata));

% trim quietness at begin & end.
% trim=0.1
left_d=1;right_d=length(tmpdata);
while tmpdata(left_d)<trim
    left_d=left_d+1;
end
while abs(tmpdata(right_d))<trim
    right_d=right_d-1;
end
sample=tmpdata(left_d:right_d);
plot(1:length(sample),sample);
% STFT
overlap=ceil(win_size-length(sample)/(2*resolution));
[S,F,T,P]=spectrogram(sample,win_size,overlap,798,Fs);

surf(1000*T,F,10*log10(abs(P)));
axis tight;
view(0,90);
shading interp;
xlabel('time(ms)');
ylabel('frequency(Hz)');
title('Spectrogram');
colorbar;

threshold=(max(max(P))-min(min(P)))*0.0002+min(min(P));
spike_time=(P>threshold);

surf(1000*T,F,abs(spike_time));
view(0,90);
shading interp;
axis tight;
xlabel('time(ms)');
ylabel('frequency(Hz)');
title('Spectrogram');
 
[r,c]=size(spike_time);
XZ=[];
YZ=[];
for i=1:r
    for j=1:c
       if spike_time(i,j)==1
         XZ=[XZ,i];
         YZ=[YZ,j];
       end
    end
end
 plot(YZ,XZ,'k.','MarkerSize',1)

min_delay=3;
a=floor(c*min_delay/100);
for i=1:r
    for j=1:c
        if spike_time(i,j)==1
            for k=1:a
            spike_time(i,j+k)=0;
            end
            j=j+k;
        end
    end
end
A=spike_time(1:r,1:c);
% B=flipdim((A==0),1);
% imshow(B);

XZ=[];
YZ=[];
for i=1:r
    for j=1:c
       if spike_time(i,j)==1
         XZ=[XZ,i];
         YZ=[YZ,j];
       end
    end
end
 plot(YZ,XZ,'k.','MarkerSize',1)
 xlabel('time(ms)');
 ylabel('input neuron');
 
% surf(1:187,1:400,abs(A));
% view(0,90);
% shading interp;
% axis tight;
% colormapeditor

min_f=0.5;max_f=199.5;
X=min_f:(max_f-min_f)/(c-1):max_f;
for i=1:r
    fire_time(i,:)=A(i,:).*X;
end

end

