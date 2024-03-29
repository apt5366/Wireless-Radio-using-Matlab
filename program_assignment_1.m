x=zeros(3000,1);
fileID_1= fopen('input.txt','r');
fileID_2= fopen('preamble.txt','rt');
formatSpec = '%f';
input= fscanf(fileID_1,formatSpec);%input file read
fclose(fileID_1);
preamble=textscan(fileID_2,formatSpec); %preamble file read, of size 50
preamble=cell2mat(preamble);
fclose(fileID_2);
t=0:0.01:30; % time array incrementing by 0.01 seconds
f=20; % carrier frequency
format long;

%DownConvertion
i_array=zeros(3000,1);
for i=1:3000
    i_array(i)=input(i)*cos(2*pi*f*t(i));
end

q_array=zeros(3000,1);
for i=1:3000
    q_array(i)=input(i)*sin(2*pi*f*t(i));
end

%Filter 
FFT_i_array= fft(i_array);
FFT_q_array= fft(q_array);
N=3000;
sample_freq=100;
delta_f=sample_freq/N;

freq_list=zeros(3000,1);
for i=0:2999
    freq_list(i+1)=i*delta_f;
end
%frequency_list created

%now we check if the elements are > sample_freq/2
for i=1:3000
    if(freq_list(i)>(sample_freq/2))
        freq_list(i)=freq_list(i)-sample_freq;
    end
end

%now check which |values| are bigger than 5.1
indexes_to_zero_in_i_and_q=zeros(3000,1);
for i=1:3000
    if(abs(freq_list(i))>5.1)
        indexes_to_zero_in_i_and_q(i)=1;
    end
end

%now making these indexes zero in fft_i and fft_q

for i=1:3000
    if(indexes_to_zero_in_i_and_q(i)==1)
        FFT_i_array(i)=0;
        FFT_q_array(i)=0;
    end
end

IFFT_i_array=2*ifft(FFT_i_array);
IFFT_q_array=2*ifft(FFT_q_array);


% IFFT_i_array=2*pinv(FFT_i_array);
% IFFT_q_array=2*pinv(FFT_q_array);

%find the real part of each
real_i= real(IFFT_i_array);
real_j= real(IFFT_q_array);

%filtering done, now attempting downsampling
downsampled_i=zeros(300,1);
downsampled_q=zeros(300,1);

j=1;
for i=1:300 %,j=1:10:3000
    downsampled_i(i)=real_i(j);
    downsampled_q(i)=real_j(j);
    j=j+10;
    if j>3000
        break;
    end
end

signal=zeros(300,1);
for x=1:300
    signal(x)=downsampled_i(x)+1i*downsampled_q(x);
end

%signal = I+iQ, created 

% Now correlation ->

correlated_signal=zeros(250,1);
%product=zeros(250,1);
temp=zeros(250,1);
result=0;

for q=1:251
    result=0;
    %fprintf('run for q : %i',q)
    s=q;
    %fprintf('with starting s : %i',s)
    
    for r=1:50 %,s=q:1:(q+49)
        %fprintf('run for r : %i',r)
        
        product=preamble(r)*signal(s);
        result=result+abs(product);
        s=s+1; %s gets incremented by one
        
        if s>(q+49)
            %fprintf('with ending s : %i',s)
            break;
        end
    end
    temp(q)=result;
end

% cor = zeros(250,1);
% for i=1:250
%         
%         sliced_signal = signal(i:i+50-1);
%         cor(i) = sum(abs(sliced_signal.*preamble));
%        
% end
% 
% [maxval,iStart] = max(cor);
%     iStart = iStart + 50;
%     

max_of_temp=max(temp);
index_of_max=find(temp==max_of_temp)+50; %adding 50 to account for preamble elements


for i=1:300
    if i<index_of_max
        correlated_signal(i)=0;
    else
        correlated_signal(i)=signal(i); 
    end
end


%Demodulation

grid=zeros(16,1);

grid(1)=3+3*1i;
grid(2)=1+3*1i;
grid(3)=-1+3*1i;
grid(4)=-3+3*1i;
grid(5)=3+1*1i;
grid(6)=1+1*1i;
grid(7)=-1+1*1i;
grid(8)=-3+1*1i;
grid(9)=3-1*1i;
grid(10)=1-1*1i;
grid(11)=-1-1*1i;
grid(12)=-3-1*1i;
grid(13)=3-3*1i;
grid(14)=1-3*1i;
grid(15)=-1-3*1i;
grid(16)=-3-3*1i;

%now the corresponding ascii value
% grid_ascii=string(16,1);
% 
% grid_ascii(1)="0000";
% grid_ascii(2)="0001";
% grid_ascii(3)="0011";
% grid_ascii(4)="0010";
% grid_ascii(5)="0100";
% grid_ascii(6)="0101";
% grid_ascii(7)="0111";
% grid_ascii(8)="0110";
% grid_ascii(9)="1100";
% grid_ascii(10)="1101";
% grid_ascii(11)="1111";
% grid_ascii(12)="1110";
% grid_ascii(13)="1000";
% grid_ascii(14)="1001";
% grid_ascii(15)="1011";
% grid_ascii(16)="1010";



%
grid_ascii=["0000";"0001";"0011";"0010";"0100";"0101";"0111";"0110" ;"1100";"1101";"1111";"1110";"1000";"1001";"1011"; "1010"];
%

%Now the demodulation part
% ascii_output=zeros(300,1);
ascii_output=strings([300,1]);

% for i=1:300
%     min_length=0; % minimum length
%     min_index=0; % index of minimum length
%     if i>=index_of_max
%         temp=0;
%         min_length=sqrt((correlated_signal(i)*correlated_signal(i))+(grid(1)*grid(1)));
%         min_index=1;
%         for j=2:16
%             temp=sqrt((correlated_signal(i)*correlated_signal(i))+(grid(j)*grid(j))); % temp will also come out as the distance betw the two complex numbers
%             if temp<min_length
%                 min_length=temp;   % This loops through the grid array and finds the closest complex number (in distance) to correlated_signal(i)
%                 min_index=j;
%             end
%         end
%         
%         ascii_output(i)=grid_ascii(min_index); % assigns the closest ASCII value to the corresponding correlated_signal element 
%     end
%     
% end


for i=1:300
    min_length=0; % minimum length
    min_index=0; % index of minimum length
    if i>=index_of_max
        temp=0;
        min_length=norm(correlated_signal(i)-grid(1));
        min_index=1;
        for j=2:16
            temp=norm(correlated_signal(i)-grid(j));% temp will also come out as the distance betw the two complex numbers
            if temp<min_length
                min_length=temp;   % This loops through the grid array and finds the closest complex number (in distance) to correlated_signal(i)
                min_index=j;
            end
        end
        
        ascii_output(i)=grid_ascii(min_index); % assigns the closest ASCII value to the corresponding correlated_signal element 
    end
    
end

    
%ASCII to text

final_string_output="";

for i=index_of_max:2:300
    text_in_ascii=ascii_output(i)+ascii_output(i+1);
    final_string_output=final_string_output+char(bin2dec(text_in_ascii));
    %fprintf('%i: %s',i-index_of_max,final_string_output)
end

fprintf('%s ',final_string_output)
