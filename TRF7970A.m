%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Kewen Pan
%TRF7970A EVM testing program for tag2
%6/May/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;clc;  %Clear
i=1;
j=0;
buffer=zeros(1,50);
delay_time=0.01;

dev_name = 'Silicon Labs CP210x USB to UART Bridge';
[~,res]=system('wmic path Win32_SerialPort');
ind = strfind(res,dev_name);
if (~isempty(ind))
    port_name = res(ind(1)+length(dev_name)+2:ind(1)+length(dev_name)+5);     
    fprintf('COM-port is %s\n',port_name);
    try
         
        s = serial(port_name);
        set(s,'BaudRate', 111700,'DataBits',8,'StopBits',1,'Parity','none','FlowControl','none','terminator','ETX' );
        
        s.ReadAsyncMode='continuous';
        s.Timeout=0.02
        s.InputBufferSize = 1024;
        
        s.OutputBufferSize = 1024; 
        
        fopen(s);
        fprintf('%s is opened\n',port_name);
    catch err
        fprintf('%s\n%s\n',err.identifier,err.message);
    end
else
    fprintf('COM-port is not find\n');
end


fprintf(port_name);
fprintf(' serial port open success!');
pause(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%s.status   %Serial port status check
%instrfind  %Specification
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(s,'%s','0108000304FF0000');%find evm broad
data=fscanf(s);
if strcmp(data(1),'T');
    fprintf('found TRF7970A\r');
   % pause(delay_time);
else
    fprintf('cannot found TRF7970A\r');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(s,'%s','010A0003041001210000');%register write request1
data=fscanf(s);
if strcmp(data(1),'R');
    fprintf('register1 write success\r');
   % pause(delay_time);
else
    fprintf('register write error1\r');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(s,'%s','010C00030410002101000000');%register write request2
data=fscanf(s);
if strcmp(data(1),'R');
    fprintf('register2 write success\r');
  %  pause(delay_time);
else
    fprintf('register write error2\r');
end   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(s,'%s','0109000304F0000000');%AGC Toggle
data=fscanf(s);
if strcmp(data(1),'A');
    fprintf('AGC toggle success\r');
  %  pause(delay_time);
else
    fprintf('AGC Toggle error\r');
end   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(s,'%s','0109000304F1FF0000');%AM PM Toggle
data=fscanf(s);
if strcmp(data(1),'A');
    fprintf('AM PM Toggle success\r');
 %   pause(delay_time);
else
    fprintf('AM PM Toggle error\r');
end 




while 1
    
    while 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        set(s,'terminator','ETX' );
        fprintf(s,'%s','010B000304140401000000');%ISO15693 Inventory Request
        data=fscanf(s); 
        if length(data)<35;
            fprintf('ISO15693 Inventory Request error\r');
        else
            fprintf('ISO15693 Inventory Request success\r');
            %   pause(delay_time);
            fprintf(data);
            break;
        end   
    end
%%%%%%%%%%%%%%%%%Basic configuration success%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%Write functional register%%%%%%%%%%%%%%%%%%%%
        fprintf(s,'%s','010F00030418402100010203800000');%Reg 00
        data=fscanf(s);
        d=data(17);
        if strcmp(data(17),']');
           fprintf('Reset failed\r');
           fprintf('Tag disconnected\r');
           %buffer=zeros(1,50);
           break;
        end   

    fprintf(s,'%s','010F00030418402100010203000000');%Reg 00
    data=fscanf(s);
    if strcmp(data(1),'R');
        fprintf('Reg00\r');
        fprintf(data,'\r');
    %    pause(delay_time);
        fprintf(data);
    else
        fprintf('Write reg 00 failed\r');
    end   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(s,'%s','010F00030418402101010100400000');%Reg01
    data=fscanf(s);
    if strcmp(data(1),'R');
        fprintf('Reg01\r');
        fprintf(data,'\r');
    %   pause(delay_time);
        fprintf(data);
    else
        fprintf('Write reg 01 failed\r');
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(s,'%s','010F00030418402102000000000000');%Reg02
    data=fscanf(s);
    if strcmp(data(1),'R');
        fprintf('Reg02\r');
        fprintf(data,'\r');
    %   pause(delay_time);
        fprintf(data);
    else
        fprintf('Write reg 02 failed\r');
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(s,'%s','010F00030418402103000000000000');%Reg03
    data=fscanf(s);
    if strcmp(data(1),'R');
        fprintf('Reg03\r');
        fprintf(data,'\r');
    %   pause(delay_time);
        fprintf(data);
    else
        fprintf('Write reg 03 failed\r');
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(s,'%s','010F00030418402104191919190000');%Reg04
    data=fscanf(s);
    if strcmp(data(1),'R');
        fprintf('Reg04\r');
        fprintf(data,'\r');
    %    pause(delay_time);
        fprintf(data);
    else
        fprintf('Write reg 04 failed\r');
    end
%%%%%%%%%%%%%%%%%%%%%%%Config finished%%%%%%%%%%%%%%%%%%%%%
   while 1
       set(s,'terminator',']' );
%%%%%%%%%%%%%%%%%%%%%%Start sample%%%%%%%%%%%%%%%%%%%%%%%%

   
        fprintf(s,'%s','010F00030418402100010203000000');%Reg 00
        data=fscanf(s);
         if strcmp(data(17),']');
                fprintf('Write reg 00 failed\r');
                 fprintf('Tag disconnected\r');
                 %buffer=zeros(1,50);
                break;
            end   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%Start reading%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(s,'%s','010B000304180020120000');%Read reg 0x12
    data=fscanf(s);
     if strcmp(data(19),']');
         fprintf('Read reg 0x12 failed\r');
            fprintf('Tag disconnected\r');
            
         break;
     end   
 
     if strcmp(data(18),'z');
         fprintf('Read reg 0x12 failed\r');
            fprintf('Tag disconnected\r');
            
         break;
     end   
     
   Stand_res=[data(23),data(24),data(21),data(22)];
   Sensor_res=[data(27),data(28),data(25),data(26)];
  
    Resistance=(hex2dec(Sensor_res)/hex2dec(Stand_res))*100;%cal sensor R
   % Temp=(3927)*exp( -0.07409*Resistance);%exp curve fitting
   if (Resistance>=100)&&(Resistance<=180)
    Temp=-2.5*Resistance+155+130+60+8;
    buffer=[buffer(2:end), buffer(1:1)];%left shift 1 bit
    buffer(50)=Temp;%push in
    plot(buffer,'Linewidth',3); 
    set(gca, 'FontWeight', 'bold', 'FontName','Calibri','FontSize',14)
    title('Graphene Based Yarn Temperature Sensor');
    ylabel('Temperature');
    xlabel('Time');
    grid on;
    drawnow;
    pause(0.5);
   end
  end

end
fclose(s);
delete(s);  
clear s  
%close all;  




