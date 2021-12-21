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

addpath('ev3-toolbox-matlab/source/')

figure
joy = vrjoystick(1);
hold on
grid on
xlim([-1 1])
ylim([-1 1])

b = EV3();
b.connect('usb', 'beep', 'on');
debug = 'off'
startedPrevious = false;

b.motorA.stop()
b.motorB.stop()
b.motorC.stop()
b.motorD.stop()

a_running = false;
b_running = false;
c_running = false;
d_running = false;

while true
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
    left_shoulder_button = button(joy, 7);

    right_horizontal_stick = axis(joy, 3);
    right_vertical_stick = -axis(joy, 4);
    right_shoulder = axis(joy, 5);
    right_shoulder_button = button(joy, 8);

    dpad_horizontal = axis(joy, 7);
    dpad_vertical = axis(joy, 8);

    if left_shoulder > -1 || right_shoulder > -1 ...
        || right_shoulder_button == 1 || left_shoulder_button == 1 ...
        || dpad_horizontal ~= 0 || dpad_vertical ~= 0
        if startedPrevious == false;
            if dpad_horizontal ~= 0
                startedPrevious = true;
                power = dpad_horizontal * 50
                b.motorD.setProperties('debug', debug, 'power', power, 'brakeMode', 'Brake')
                b.motorD.start()
            end

            if dpad_vertical ~= 0
                startedPrevious = true;
                a_running = true;
                b_running = true;
                power = dpad_vertical * 50
                b.motorA.setProperties('debug', debug, 'power', power, 'brakeMode', 'Brake')
                b.motorA.syncedStart(b.motorB)
            end

            if left_shoulder > -1 && not(a_running) && not(b_running)
                startedPrevious = true;
                a_running = true;
                b_running = true;
                % power = abs(left_shoulder + 1) * 50
                power = 100;
                b.motorA.setProperties('debug', debug, 'power', power, 'brakeMode', 'Coast')
                b.motorA.syncedStart(b.motorB)
            elseif right_shoulder > -1 && not(a_running) && not(b_running)
                startedPrevious = true;
                a_running = true;
                b_running = true;
                % power = abs(right_shoulder + 1) * -50
                power = -100;
                b.motorA.setProperties('debug', debug, 'power', power, 'brakeMode', 'Coast')
                b.motorA.syncedStart(b.motorB)
            end

            if right_shoulder_button == 1 && not(a_running)
                startedPrevious = true;
                power = -100;
                b.motorA.setProperties('debug', debug, 'power', power, 'brakeMode', 'Brake')
                b.motorA.start()
            elseif left_shoulder_button == 1 && not(b_running)
                startedPrevious = true;
                power = -100;
                b.motorB.setProperties('debug', debug, 'power', power, 'brakeMode', 'Brake')
                b.motorB.start()
            end
        end
    else
        startedPrevious = false;
        a_running = false;
        b_running = false;
        c_running = false;
        d_running = false;

        b.motorA.stop()
        b.motorB.stop()
        b.motorC.stop()
        b.motorD.stop()
        end

        if b_pressed
            b.playTone(100, 5000, 5)
        end

        if a_pressed
            b.beep()
        end

        plot(left_horizontal_stick, left_vertical_stick, 'or')
        plot(right_horizontal_stick, right_vertical_stick, 'ob')
        pause(0.01);

        if start_button_pressed == 1
            close all;
            break;
        end
    end
end
