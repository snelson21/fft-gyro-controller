function ArrToSend = InitializeDataRate(puerto_serial,data_rate_in)
s.init = 122;   %0x7A
s.mode = 0;
s.config_data_rate = 49;  %0x31
s.data_rate = data_rate_in;   %
s.set_torque = 48 ;
s.torque_m1_lb = 0 ;
s.torque_m1_hb = 0;
s.torque_m2_lb = 0;
s.torque_m2_hb = 0;
s.torque_m3_lb = 0;
s.torque_m3_hb = 0;
s.set_vel=48;
s.vel_m1_lb =0 ;
s.vel_m1_hb=0;
s.vel_m2_lb = 0;
s.vel_m2_hb=0;
s.vel_m3_lb = 0;
s.vel_m3_hb=0;
s.not_used_1 = 0;
s.not_used_2 =0;
s.not_used_3 =0;
s.not_used_4 =0;
s.not_used_5 =0;
s.not_used_6 =0;
s.not_used_7 =0;
s.not_used_8=0;
s.not_used_9=0;
s.not_used_10=0;
s.not_used_11=0;
s.not_used_12=0;
s.checksum=0;
s.finish = 123;  %0X7B

ArrToSend = [s.init ;s.mode ; s.config_data_rate; s.data_rate; s.set_torque ; s.torque_m1_lb; s.torque_m1_hb; s.torque_m2_lb; s.torque_m2_hb; s.torque_m3_lb; s.torque_m3_hb; s.set_vel; s.vel_m1_lb; s.vel_m1_hb; s.vel_m2_lb; s.vel_m2_hb; s.vel_m3_lb; s.vel_m3_hb; s.not_used_1;s.not_used_2;s.not_used_3;s.not_used_4;s.not_used_5;s.not_used_6;s.not_used_7;s.not_used_8;s.not_used_9;s.not_used_10;s.not_used_11; s.not_used_12; s.checksum; s.finish];
SA=size(ArrToSend,1);
for sa=1:32
    fprintf(puerto_serial,'%c',ArrToSend(sa,:));
end
end