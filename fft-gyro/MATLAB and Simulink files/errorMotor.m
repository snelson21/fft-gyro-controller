function out = errorMotor(id)
    if ((id & 1)==1) 
        out = 'Input voltage error';
    elseif ((id & 2)==2) 
        out = 'Angle limit error';
    elseif ((id & 4)==4)
        out = 'Overheating error';
    elseif ((id & 8)==8) 
        out = 'Range error';
    elseif ((id & 16)==16)
        out = 'Checksum error';
    elseif ((id & 32)==32) 
        out = 'Overload error';
    elseif ((id & 64)==64) 
        out = 'Instruction error';
    else
        out = ' ';
    end
    nop=1;
end