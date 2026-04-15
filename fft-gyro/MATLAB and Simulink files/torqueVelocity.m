function magnitude= torqueVelocity(Type,id)

magnitude= 0;
if id ~= 0
    Bwo =bitand(id,uint16(1024));
    if (Bwo==1024)
         %fprintf(' CW ')
         Direction ='CW';
    elseif (Bwo==0)
         %fprintf(' CCW ')
         Direction ='CCW';
    else
        nop=1;
    end
else
    %fprintf('No Direction  ')
    Direction ='No Direction';
end

magnitude =  bitand(id,uint16(1023));
fprintf([ Type  ' '  num2str(double(magnitude)*0.1)   ' %% ' Direction '  \n']);
% disp([ Type  ' Magnitued: ' num2str(magnitude*0.1) ]);
out=1;
end