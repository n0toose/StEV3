function main

addpath('ev3-toolbox-matlab/source/')
addpath(pwd)
global joy

% ----------------------------------
% Xbox One Controller's Capabilities
% ----------------------------------
% Axes: 8
% Buttons: 11
% POVs: 0
% Forces: 0

figure
joy = vrjoystick(1);
hold on
grid on
xlim([-1 1])
ylim([-1 1])

b = EV3();
b.connect('bt', 'serPort', '/dev/rfcomm1', 'beep', 'on');
debug = 'off'
startedPrevious = false;

% Makes sure that the motors
% are not moving thanks to some
% previous instance of the program
% being exited in a non-graceful manner.
b.motorA.stop()
b.motorB.stop()
b.motorC.stop()
b.motorD.stop()

% Set up distance sensor
b.sensor2.mode = DeviceMode.UltraSonic.DistCM;
toggle_distance_beep = 0;

while true
    a_pressed = button(joy, 1);
    b_pressed = button(joy, 2);
    x_pressed = button(joy, 4);
    y_pressed = button(joy, 5);

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
            if dpad_horizontal ~= 0 % && not(b.motorD.isRunning)
                startedPrevious = true;
                power = dpad_horizontal * 50;
                b.motorD.setProperties('debug', debug, 'power', power, 'brakeMode', 'Brake')
                b.motorD.start()
            end

            if dpad_vertical ~= 0 % && not(a.motorA.isRunning) && not(a.motorB.isRunning)
                startedPrevious = true;
                power = dpad_vertical * 50;
                b.motorA.setProperties('debug', debug, 'power', power, 'brakeMode', 'Brake')
                b.motorA.syncedStart(b.motorB)
            end

            if right_shoulder_button == 1 && not(b.motorA.isRunning) && not(b.motorC.isRunning)
                startedPrevious = true;
                power = -100;
                b.motorA.setProperties('debug', debug, 'power', power, 'brakeMode', 'Coast')
                b.motorA.start()
                % b.motorA.syncedStart(b.motorD)
            elseif left_shoulder_button == 1 && not(b.motorB.isRunning) && not(b.motorC.isRunning)
                startedPrevious = true;
                power = -100;
                b.motorB.setProperties('debug', debug, 'power', power, 'brakeMode', 'Coast')
                b.motorB.start()
                % b.motorB.syncedStart(b.motorD)
            end

            if left_shoulder > -1 && not(b.motorA.isRunning) && not(b.motorB.isRunning)
                startedPrevious = true;
                % power = abs(left_shoulder + 1) * 50
                power = 100;
                b.motorA.setProperties('debug', debug, 'power', power, 'brakeMode', 'Coast')
                b.motorA.syncedStart(b.motorB)
            elseif right_shoulder > -1 && not(b.motorA.isRunning) && not(b.motorB.isRunning)
                startedPrevious = true;
                % power = abs(right_shoulder + 1) * -50
                power = -100;
                b.motorA.setProperties('debug', debug, 'power', power, 'brakeMode', 'Coast')
                b.motorA.syncedStart(b.motorB)
            end
        end
    else
        startedPrevious = false;

        b.motorA.stop()
        b.motorB.stop()
        b.motorC.stop()
        b.motorD.stop()
    end
        if b_pressed
            song = songPlayer();
            song.gotye_1(b, joy)
        end

        if a_pressed
            b.beep();
        end

        % Distance sensor
        if left_stick_pressed
            toggle_distance_beep = not(toggle_distance_beep)
            fprintf("Distance Beep: %d", toggle_distance_beep)
        end
        
        if (x_pressed && y_pressed) || toggle_distance_beep
            if b.sensor2.value < 20
                b.playTone(100, (20 * 200 - b.sensor2.value * 200), 250)
            end
        end

        % if b_pressed
        %     b.playTone(100, 5000, 5)
        % end

        if right_stick_pressed
            b.playTone(100, 3000, 250)
        end

        % plot(left_horizontal_stick, left_vertical_stick, 'or')
        % plot(right_horizontal_stick, right_vertical_stick, 'ob')
        pause(0.01);

        if start_button_pressed == 1
            close all;
            break;
        end
    end
end
