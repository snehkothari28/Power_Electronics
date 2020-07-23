%created by Sneh Kothari


clc; clear all; close all;
x = menu('Select the project', ...
    'cycloconverter with RL load based application', ...
    'cycloconverter with RL load based simulation', ...
    'inverter 120 degree script', ...
    'inverter 180 degree script', ...
    'ac to ac controller application', ...
    'ac to ac controller simulink', ...
    'on off controller', ...
    'single phase bridge inverter simulation', ...
    'three phase bridge inverter simulation 120 degree', ...
    'three phase bridge inverter simulation 180 degree');
if x == 1
    cyclo_rl
elseif x == 2
    cyclo
elseif x == 3
    inverter_120
elseif x == 4
    inverter_180
elseif x == 5
    ac_ac_controller_rl
elseif x == 6
    ac_ac_controller
elseif x == 7
    on_off_control
elseif x == 8
    single_phase_bridge_inverter
elseif x == 9
    three_phase_bridge_inverter_120
elseif x == 10
    three_phase_bridge_inverter_180
end
