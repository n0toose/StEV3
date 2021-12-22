% The music in this file is not licensed under the terms of the
% GNU Affero General Public License.

% (I could make this a MIDI parser if I wanted to, dang.)

classdef songPlayer
properties
    notes = ["C", "c", "D", "d", "E", "F", "f", "G", "g", "A", "a", "B", " "];
    frequencies6 = [261.63, 277.18, 293.66, 311.13, 329.63, 369.99, 392.00, 415.30, 440.00, 466.16, 493.88, 523.25, 0.0];
    frequencies5 = [523.25, 554.37, 587.33, 622.25, 659.25, 698.46, 739.99, 783.99, 830.61, 880.00, 932.33, 987.77, 0.0];
    ms_per_note = 500;
end
methods
    function gotye_1 (obj, brickObj, joystick)
        % Insanely long vector containing notes and duration.
        load('song.mat')
        note_frequencies5 = containers.Map(obj.notes, obj.frequencies5);
        % BPM: 129
        obj.ms_per_note = 465;

        counter = 1;
        while counter < length(song)
            disp(song(counter));
            fprintf("\n")
            fprintf("\n%s - %d - %d", song(counter), song(counter+1), note_frequencies5((song(counter))))
            if song(counter) ~= " "
                brickObj.playTone(5, note_frequencies5((song(counter))), song(counter+1) * obj.ms_per_note)
            end
            pause(song(counter+1) * obj.ms_per_note * 0.001)
            counter = counter + 2;

            % Stop Button: X
            stop_pressed = button(joystick, 4);

            if stop_pressed == 1
                return;
            end
        end
    end
end
end