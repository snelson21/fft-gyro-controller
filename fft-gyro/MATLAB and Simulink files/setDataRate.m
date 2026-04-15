function Arr = setDataRate(puerto_serial,Datarate)
%PAQUETE ESCRITURA 1
%Arr = uint8([1:32]);
coder.extrinsic('num2str');

Arr(1,1) =  122;
Arr(1,2) =  1;%50;
Arr(1,3) =  49; %CONFIG DATA RATE
Arr(1,4) =  Datarate;%DATA RATE

Arr(1,5) =  0;%Torque Enable  %1-7

Arr(1,6) =  0;%Set Torque Limit
Arr(1,7) =  0;
Arr(1,8) =  0;
Arr(1,9) =  0;
Arr(1,10) =  0; 
Arr(1,11) =  0;
Arr(1,12) =  0;

Arr(1,13) =  0; %Set Torque Max 
Arr(1,14) =  0;
Arr(1,15) =  0;
Arr(1,16) =  0;
Arr(1,17) =  0;
Arr(1,18) =  0;
Arr(1,19) =  0;

Arr(1,20) =  0;
Arr(1,21) =  0;
Arr(1,22) =  0;
Arr(1,23) =  0;
Arr(1,24) =  0;
Arr(1,25) =  0;
Arr(1,26) =  0;
Arr(1,27) =  0;
Arr(1,28) =  0;
Arr(1,29) =  0;
Arr(1,30) =  0;

Arr(1,31) =  1; %not used
Arr(1,32) =  123;

% SA=size(Arr,1);
% for sa=1:32
%     %fprintf(puerto_serial,'%c',Arr(sa,:));
% end
fprintf(puerto_serial,Arr); 
end