function y= DisplayInformation(SystemData, SystemMode)
if strcmp(SystemMode,'Motor')
    out = errorMotor(SystemData(1,:));  
    fprintf(['Error: ' num2str(SystemData(1,:))  out '  \n']);    %disp(['Error: ' num2str(ErrorM1)  out ]);
    torqueVelocity('Torque:   ', SystemData(2,:));
    torqueVelocity('Velocity: ' , SystemData(3,:));
    fprintf(['Position:  ' num2str(SystemData(4,:))  ' º degrees ' '  \n']);  %disp(['Position: ' num2str(PositionM1*0.29) ]);
    fprintf(['Voltage:   ' num2str(SystemData(5,:)) ' volts ' '  \n']);  %disp(['Voltage: ' num2str(VoltageM1/10) ]);
    fprintf(['Temperature: ' num2str(SystemData(6,:)) ' º C ' '  \n']); %disp(['Temperature: ' num2str(TemperatureM1) ]);   
elseif strcmp(SystemMode,'Encoder')
    fprintf(['Position: ' num2str(SystemData) ' º degrees ' '  \n']);    %disp(['Error: ' num2str(ErrorM1)  out ]);
end
 y=1;
end