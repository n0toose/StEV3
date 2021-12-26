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



%% Internal Variable Initialization
% `waitTime` prevents MATLAB from getting overwhelmed over more commands
% than the ones that can be issued to the brick in a second anyways.
waitTime = 0.01;
debugMode = 'off';
previouslyStarted = false;

% Distance Sensor Initialization: Can be toggled
% using the left stick button later. Off by default,
% because it is too annoying.
b.sensor2.mode = DeviceMode.UltraSonic.DistCM;
distanceBeepToggle = 0;

%% Stop motors
% Makes sure that the motors are not moving thanks to some
% previous instance of the program being exited in a non-graceful manner.
b.motorA.stop()
b.motorB.stop()
b.motorC.stop()
b.motorD.stop()

while true
    %% Buttons
    buttonA = button(joy, 1);
    buttonB = button(joy, 2);
    buttonX = button(joy, 4);
    buttonY = button(joy, 5);

    buttonSelect = button(joy, 11);
    buttonStart = button(joy, 12);
    buttonHome = button(joy, 10);

    buttonStickLeft = button(joy, 14);
    buttonStickRight = button(joy, 15);

    buttonLeftShoulder = button(joy, 7);
    buttonRightShoulder = button(joy, 8);

    %% Axes
    % ------
    % Sticks
    % ------
    % We deliberately invert the value of left_vertical_stick,
    % as vrjoystick is generally used to control 3D models and
    % aims to emulate flight simulators.
    %
    % Minimum value: -1, Maximum value: 1, Value when idle: 0

    leftHorizontalStick = axis(joy, 1);
    leftVerticalStick = -axis(joy, 2);
    rightHorizontalStick = axis(joy, 3);
    rightVerticalStick = -axis(joy, 4);

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

    leftShoulder = axis(joy, 6);
    rightShoulder = axis(joy, 5);

    if leftShoulder > -1 || rightShoulder > -1 ...
        || buttonRightShoulder == 1 || buttonLeftShoulder == 1 ...
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
            if buttonRightShoulder == 1 && not(b.motorA.isRunning) && not(b.motorC.isRunning)
                previouslyStarted = true;
                power = -100;
                b.motorA.setProperties('debug', debugMode, 'power', power, 'brakeMode', 'Coast')
                b.motorA.start()
            elseif buttonLeftShoulder == 1 && not(b.motorB.isRunning) && not(b.motorC.isRunning)
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
            if leftShoulder > -1 && not(b.motorA.isRunning) && not(b.motorB.isRunning)
                previouslyStarted = true;
                % power = abs(left_shoulder + 1) * 100
                power = 100;
                b.motorA.setProperties('debug', debugMode, 'power', power, 'brakeMode', 'Coast')
                b.motorA.syncedStart(b.motorB)
            elseif rightShoulder > -1 && not(b.motorA.isRunning) && not(b.motorB.isRunning)
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
    
    %% Sounds
    % Honk!
    if buttonA
        b.beep();
    end

    % Surprising! honk
    if buttonB
        b.playTone(50, 800, 5)
    end

    % Annoying honk
    if buttonStickRight
        b.playTone(100, 3000, 250)
    end

    % Plays Gotye's "Somebody I Used To Know"
    if buttonX
        song = songPlayer();
        song.gotye_1(b, joy)
    end

    % Distance sensor
    if left_stick_pressed
        distanceBeepToggle = not(distanceBeepToggle)
        fprintf("Distance Beep: %d", distanceBeepToggle)
    end
        
    if (buttonX && buttonY) || distanceBeepToggle
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
    
    pause(waitTime);

    % Quit loop, close all windows.
    if buttonStart == 1
        close all;
        break;
    end
end
end
