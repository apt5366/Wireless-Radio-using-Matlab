input_file= fopen('input.txt','rt');
input_matrix= dlmread('input.txt');
fclose(input_file);


parent_AP=zeros(input_matrix(2),5*1000000);
for i=1:input_matrix(2)
    str=sprintf('AP%d.txt',i);
    parent_AP(i,:)=dlmread(str);
end

AP=zeros(5*1000000,input_matrix(2));
AP=parent_AP.';


%creating the frequency array

N=5*1000000;
sample_freq=1000000;
delta_f=sample_freq/N;

freq_list=zeros(N,1);
for i=0:N-1 
    freq_list(i+1)=i*delta_f;
end
%frequency_list created
%now we check if the elements are > sample_freq/2
for i=1:N
    if(freq_list(i)>(sample_freq/2))
        freq_list(i)=freq_list(i)-sample_freq;
    end
end

% Now we take fft of each AP
FFT_AP=zeros(5*1000000,input_matrix(2));
for i=1:input_matrix(2)
    FFT_AP(:,i)=fft(AP(:,i));
end


Indexes= zeros(input_matrix(2),1);
for i=1:input_matrix(2)
    [m,Indexes(i)]=max(abs(FFT_AP(:,i)));
end


Doppler_Shifts=zeros(input_matrix(2),1);

for i=1:input_matrix(2)
    Doppler_Shifts(i)= freq_list(Indexes(i));
end


Velocities=zeros(input_matrix(2),1);

for i=1:input_matrix(2)
    Velocities(i)=(Doppler_Shifts(i)*3*10^(8))/(5.8*10^(9));
end


%get the 3d coordinate fr each ap relatvie to user
A=zeros(input_matrix(2),3);

for i=1: size(A,1)
    A(i,:)=(input_matrix(i+2,:)-input_matrix(1,:))/(norm(input_matrix(i+2,:)-input_matrix(1,:)));
end

%now construct the velocity vecotr
b=zeros(input_matrix(2),1);


for i = 1:input_matrix(2)
    b(i)=Velocities(i);
end


x=zeros(3,1);

x=A\b


