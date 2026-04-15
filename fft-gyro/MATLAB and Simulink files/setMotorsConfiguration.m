function y  = setMotorsConfiguration(puerto_serial,mode_m1,mode_m2,mode_m3,LedM1,LedM2,LedM3)
%Paquete de configuracion del motor.
%mode_m1=1 -> Wheel
%mode_m1=2 -> Joint

s.init = 122;   %0x7A   122
s.mode = 3;  %3 Significa configuracion de motor.
s.set_mode_m1 = 48 ;   %0x31 = 49 = char '1'
s.set_mode_m2 = 48 ;   %0x31 = 49 = char '1'
s.set_mode_m3 = 48 ;   %0x31 = 49 = char '1'
s.mode_m1 = 49 ;  %49 = char '1' Wheel   50 = char '2' Joint
s.mode_m2 = 49 ;  %49 = char '1' Wheel   50 = char '2' Joint
s.mode_m3 = 49 ;  %49 = char '1' Wheel   50 = char '2' Joint

if mode_m1~=0
    s.set_mode_m1 = 49 ;   %0x31 = 49 = char '1'
    if mode_m1==1 %Mode Wheel
        s.mode_m1 = 49 ;  %49 = char '1' Wheel 
    elseif mode_m1==2  
        s.mode_m1 = 50 ;  %50 = char '2' Joint
    end
end

if mode_m2~=0
    s.set_mode_m2 = 49 ;   %0x31 = 49 = char '1'
    if mode_m2==1 %Mode Wheel
        s.mode_m2 = 49 ;  %49 = char '1' Wheel  
    elseif mode_m2==2  
        s.mode_m2 = 50 ;  %50 = char '2' Joint
    end
end

if mode_m3~=0
    s.set_mode_m3 = 49 ;   %0x31 = 49 = char '1'
    if mode_m3 == 1 %Mode Wheel
        s.mode_m3 = 49 ;  %49 = char '1' Wheel
    elseif mode_m3==2  
        s.mode_m3 = 50 ;  %50 = char '2' Joint
    end
end


s.set_id_m1 = 0 ;
s.set_id_m2 = 0 ;
s.set_id_m3 = 0 ;

s.id_m1 = 0;
s.id_m2 = 0;
s.id_m3 = 0;

LEDM1 = 48;
if LedM1 ==1
    LEDM1 =49;
end

LEDM2 = 48;
if LedM2 ==1
    LEDM2 =49;
end

LEDM3 = 48;
if LedM3 ==1
    LEDM3 =49;
end

s.turnon_led_m1 = LEDM1;  %48:0  49:1
s.turnon_led_m2 = LEDM2;
s.turnon_led_m3 = LEDM3;

s.not_used17 = 0;
s.not_used18 = 0;
s.not_used19 = 0;

s.not_used20 = 0;
s.not_used21 = 0;
s.not_used22 = 0;
s.not_used23 = 0;
s.not_used24 = 0;
s.not_used25 = 0;
s.not_used26 = 0;
s.not_used27 = 0;
s.not_used28 = 0;
s.not_used29 = 0;
s.not_used30 = 1; %1:Simple 2: Extended   %Cambiar el paquete que llega a [32 1]
s.finish = 123;  %0X7B

ArrToSend = ([s.init ;s.mode ; s.set_mode_m1; s.set_mode_m2; s.set_mode_m3; s.mode_m1;s.mode_m2;s.mode_m3;s.set_id_m1;s.set_id_m2;s.set_id_m3;s.id_m1;s.id_m2;s.id_m3;s.turnon_led_m1;s.turnon_led_m2;s.turnon_led_m3;s.not_used17;s.not_used18;s.not_used19;s.not_used20;s.not_used21;s.not_used22;s.not_used23;s.not_used24;s.not_used25;s.not_used26;s.not_used27;s.not_used28;s.not_used29; s.not_used30;s.finish]);

fprintf(puerto_serial,ArrToSend); 

y = ArrToSend;