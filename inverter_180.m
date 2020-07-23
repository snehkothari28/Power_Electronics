%created by Sneh Kothari

clc; clear all; close all;

d = 180;
f = 50;
vm = 230;
t = linspace(0,1/f,1000);
v = zeros(6, length(t));

at = d*t(end)/360;
for j = 1:length(t)
    if (at > t(j))
        v(1,j) = 1; 
    end
end

for  n = 2:6
    v(n,:) = circshift(v(1,:),round((n-1)*length(t)/(6)));
end
figure('Name','Firing Pulses');
for l = 1:6 
    subplot(6,1,l)
    plot(t,v(l,:))
    ylim([0 1.1*v(1,1)]);
    grid on;
    title(['thyristor', num2str(l)])
end


t = linspace(0,2/f,1000);
vao1 = zeros(1,(length(t))/4);
for k = 1:length(vao1) 
    if or(t(k) < (1/(f*6)),t(k) > (2/(f*6))) 
        vao1(k) = (vm/3);
    else 
        vao1(k) = (2*vm/3);
    end
end
vao = [vao1 -vao1 vao1 -vao1];
for n = 2:3
    vao(n,:) = circshift(vao(1,:),round((n-1)*length(vao)/(3)));
end
figure('Name','output phase voltage');
plot(t,vao) 
ph = ['a' 'b' 'c'];
for l = 1:3 
    subplot(3,1,l)
    plot(t,vao(l,:))
    ylim([-1.1*vm 1.1*vm]);
    title(['phase ', ph(l) ,' voltages'])
    grid on;
end

vab = vao(1,:) - vao(2,:);
vbc = vao(2,:) - vao(3,:);
vca = vao(3,:) - vao(1,:);
vl =[vab; vbc; vca];
line = ['ab'; 'bc'; 'ca'];
figure('Name','output line voltage');
for l = 1:3 
    subplot(3,1,l)
    plot(t,vl(l,:))
    ylim([-1.1*vm 1.1*vm]);
    title(['line ', line(l,:) ,' voltages'])
    grid on;
end