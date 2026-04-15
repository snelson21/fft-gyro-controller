
res = deg2rad(0.0055); % Resolución en radianes
delta_theta = [res; res; res]; % vector de resoluciones

syms e1 e2 e3 real
     
     Rot_X = [1,       0,        0;
              0, cos(e1), -sin(e1);
              0, sin(e1),  cos(e1);];
              
     Rot_Y = [ cos(e2), 0, sin(e2);
                     0, 1,       0;
              -sin(e2), 0, cos(e2);];
              
     Rot_Z = [cos(e3), -sin(e3), 0;
              sin(e3),  cos(e3), 0;
                    0,        0, 1;];
                
     
     Rot_Global = Rot_Y*Rot_X*Rot_Z; %Cambie de orden Y por Z, y funciono
      
     i = Rot_Global*[1;0;0];
     j = Rot_Global*[0;1;0];
     k = Rot_Global*[0;0;1];
     
     i_X = i(1); i_Y = i(2); i_Z = i(3);
     j_X = j(1); j_Y = j(2); j_Z = j(3);
     k_X = k(1); k_Y = k(2); k_Z = k(3);
     
     Roll = acos(sqrt(j_X^2 + j_Y^2))*sign(j_Z);
     Pitch = -acos(sqrt(i_X^2 + i_Y^2))*sign(i_Z);
     Yaw = acos(i_X/sqrt(i_X^2 + i_Y^2));

     J = jacobian([Roll; Pitch; Yaw], [e1; e2; e3]);

     theta_vals = deg2rad([91; 91; 91]);

     J_num = double(subs(J, [e1; e2; e3], theta_vals));

     delta_phi = J_num * delta_theta;         % en radianes
     delta_phi_deg = rad2deg(abs(delta_phi)); % en grados
     disp('Resolución estimada en roll, pitch, yaw (grados):');
     disp(delta_phi_deg);