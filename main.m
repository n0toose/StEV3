function main_loop
global joy

addpath('ev3-toolbox-matlab/source/')

joy = vrjoystick(1);

% ----------------------------------
% Xbox One Controller's Capabilities
% ----------------------------------
% Axes: 8
% Buttons: 11
% POVs: 0
% Forces: 0

% Keep in mind that the shoulders are
% not supported properly.

figure
hold on
grid on
xlim([-1 1])
ylim([-1 1])
tic

while true
    toc
    a_pressed = button(joy, 1);
    b_pressed = button(joy, 2);
    x_pressed = button(joy, 3);
    y_pressed = button(joy, 4);

    left_stick_pressed = button(joy, 14);
    right_stick_pressed = button(joy, 15);

    select_button_pressed = button(joy, 11);
    start_button_pressed = button(joy, 12);
    home_button_pressed = button(joy, 10);

    left_button_pressed = button(joy, 7);
    right_button_pressed = button(joy, 8);

    left_horizontal_stick = axis(joy, 1);
    left_vertical_stick = -axis(joy, 2);    
    left_shoulder = axis(joy, 6);

    right_horizontal_stick = axis(joy, 3);
    right_vertical_stick = -axis(joy, 4);
    right_shoulder = axis(joy, 5);

    dpad_horizontal = axis(joy, 8);
    dpad_vertical = axis(joy, 7);

    plot(left_horizontal_stick, left_vertical_stick, 'or')
    plot(right_horizontal_stick, right_vertical_stick, 'ob')
    pause(0.01);

    if start_button_pressed == 1
        close all;
        break;
    end
end
