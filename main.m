function main

%% Initialize variables 

% Add ev3-toolbox-matlab library to search path
addpath('ev3-toolbox-matlab/source/')

% ----------------------------------------
% Xbox One Controller (Linux) Mapping Info
% ----------------------------------------
% Axes: 8
% Buttons: 11
% POVs: 0
% Forces: 0

%% Variables for plotting, disabled by default.
hold on
grid on
xlim([-1 1])
ylim([-1 1])

%% Joystick Initialization
% We initialize the joystick
% first, as we have found that the Bluetooth connection
% with the EV3 can be much more unreliable and harder to
% resolve. Dealing with the controller first is better.
joy = vrjoystick(1);

%% EV3 Initialization
% The kart is meant to be remotely
% controlled, which is why we opt for using Bluetooth
% by default.
b = EV3();
b.connect('bt', 'serPort', '/dev/rfcomm1', 'beep', 'on');
% b.connect('usb', 'beep', 'on');

%% Distance Sensor Initialization
% Can be toggled
% using the left stick button later. Off by default,
% because it is too annoying.
b.sensor2.mode = DeviceMode.UltraSonic.DistCM;
toggle_distance_beep = 0;

%% Internal Variable Initialization
% `waitTime` prevents MATLAB from getting overwhelmed over more commands
% than the ones that can be issued to the brick in a second anyways.
waitTime = 0.01;
debugMode = 'off';
previouslyStarted = false;

% Makes sure that the motors are not moving thanks to some
% previous instance of the program being exited in a non-graceful manner.
b.motorA.stop()
b.motorB.stop()
b.motorC.stop()
b.motorD.stop()

while true
    %% Buttons
    a_pressed = button(joy, 1);
    b_pressed = button(joy, 2);
    x_pressed = button(joy, 4);
    y_pressed = button(joy, 5);

    select_button_pressed = button(joy, 11);
    start_button_pressed = button(joy, 12);
    home_button_pressed = button(joy, 10);

    left_button_pressed = button(joy, 7);
    right_button_pressed = button(joy, 8);

    left_stick_pressed = button(joy, 14);
    right_stick_pressed = button(joy, 15);

    %% Axes
    % ------
    % Sticks
    % ------
    % We deliberately invert the value of left_vertical_stick,
    % as vrjoystick is generally used to control 3D models and
    % aims to emulate flight simulators.
    %
    % Minimum value: -1, Maximum value: 1, Value when idle: 0

    left_horizontal_stick = axis(joy, 1);
    left_vertical_stick = -axis(joy, 2);
    right_horizontal_stick = axis(joy, 3);
    right_vertical_stick = -axis(joy, 4);

    % D-pad
    % -----
    % Vertical: Alternative way to accelerate and reverse for presentation
    % purposes.
    % Horizontal: Steering.
    %
    % Warning: Other systems, like Windows, detect the D-pad as a "POV",
    % like in joysticks. Please adjust the code accordingly.
    %
    % Minimum value: -1, Maximum value: 1, Value when idle: 0

    dpad_horizontal = axis(joy, 7);
    dpad_vertical = axis(joy, 8);    

    % Shoulders
    % ---------
    % The shoulders in game controllers generally act as
    % "Accelerate" and "Reverse" buttons, which we aim to
    % emulate.
    %
    % Minimum value: -1, Maximum value: 1, Value when idle: -1

    left_shoulder = axis(joy, 6);
    left_shoulder_button = button(joy, 7);
    right_shoulder = axis(joy, 5);
    right_shoulder_button = button(joy, 8);

    if left_shoulder > -1 || right_shoulder > -1 ...
        || right_shoulder_button == 1 || left_shoulder_button == 1 ...
        || dpad_horizontal ~= 0 || dpad_vertical ~= 0
        % previouslyStarted prevents conflicts between different controls
        % that utilize the same functions. For example, hitting the right
        % shoulder and the right button both result in starting b.motorA.
        % This results in a crash. The user has to stop pressing a button
        % in order to use another one. We still check if a motor is
        % running, just in case.
        if previouslyStarted == false
            if dpad_horizontal ~= 0
                previouslyStarted = true;
                power = dpad_horizontal * 50;
                b.motorD.setProperties('debug', debugMode, 'power', power, 'brakeMode', 'Brake')
                b.motorD.start()
            end

            if dpad_vertical ~= 0
                previouslyStarted = true;
                power = dpad_vertical * 50;
                b.motorA.setProperties('debug', debugMode, 'power', power, 'brakeMode', 'Brake')
                b.motorA.syncedStart(b.motorB)
            end

            % `power` is -100, as the motor in our car was "inverted". The
            % buttons in the back are responsible for "sharp turns", by
            % enabling only one of the back motors. The turns can be
            % improved if the front wheels are steered towards the correct
            % direction.
            if right_shoulder_button == 1 && not(b.motorA.isRunning) && not(b.motorC.isRunning)
                previouslyStarted = true;
                power = -100;
                b.motorA.setProperties('debug', debugMode, 'power', power, 'brakeMode', 'Coast')
                b.motorA.start()
            elseif left_shoulder_button == 1 && not(b.motorB.isRunning) && not(b.motorC.isRunning)
                previouslyStarted = true;
                power = -100;
                b.motorB.setProperties('debug', debugMode, 'power', power, 'brakeMode', 'Coast')
                b.motorB.start()
            end

            % Our car weighs a lot, so we used the max power instead of
            % calculating the power proportionally, depending on the power
            % the shoulder itself was pressed with. Although this works
            % great in videogames, it did not work so well here.
            %
            % If you'd like to insist on using it, use something like
            % `power = abs(right_shoulder + 1) * 100`
            if left_shoulder > -1 && not(b.motorA.isRunning) && not(b.motorB.isRunning)
                previouslyStarted = true;
                % power = abs(left_shoulder + 1) * 100
                power = 100;
                b.motorA.setProperties('debug', debugMode, 'power', power, 'brakeMode', 'Coast')
                b.motorA.syncedStart(b.motorB)
            elseif right_shoulder > -1 && not(b.motorA.isRunning) && not(b.motorB.isRunning)
                previouslyStarted = true;
                % power = abs(right_shoulder + 1) * -100
                power = -100;
                b.motorA.setProperties('debug', debugMode, 'power', power, 'brakeMode', 'Coast')
                b.motorA.syncedStart(b.motorB)
            end
        end
    else
        previouslyStarted = false; % Allows block after `if` to run.

        %% Stop motors
        b.motorA.stop()
        b.motorB.stop()
        b.motorC.stop()
        b.motorD.stop()
    end
    
    % Honk!
    if a_pressed
        b.beep();
    end

    % Surprising! honk
    if b_pressed
        b.playTone(50, 800, 5)
    end

    % Annoying honk
    if right_stick_pressed
        b.playTone(100, 3000, 250)
    end

    % Plays Gotye's "Somebody I Used To Know"
    if x_pressed
        song = songPlayer();
        song.gotye_1(b, joy)
    end

    % Distance sensor
    if left_stick_pressed
        toggle_distance_beep = not(toggle_distance_beep)
        fprintf("Distance Beep: %d", toggle_distance_beep)
    end
        
    if (x_pressed && y_pressed) || toggle_distance_beep
        % Max sensor value: 255. Let's not make it too annoying and cut
        % it down to 30.
        if b.sensor2.value < 30
            % The closer, the higher the pitch.
            b.playTone(100, (20 * 200 - b.sensor2.value * 200), 250)
        end
    end

    %% Plotting. Disabled by default.
    % plot(left_horizontal_stick, left_vertical_stick, 'or')
    % plot(right_horizontal_stick, right_vertical_stick, 'ob')
    
    pause(0.01);

    % Quit loop, close all windows.
    if start_button_pressed == 1
        close all;
        break;
    end
end
end
