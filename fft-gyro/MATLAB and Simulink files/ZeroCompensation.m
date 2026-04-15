function DataOut = ZeroCompensation(Data,ZeroRel)

Data_aux= Data-ZeroRel;
if Data_aux<0
    DataOut = 360 + Data_aux;    
else
    DataOut = Data_aux;
end
end