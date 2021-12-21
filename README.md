# StEV3, the MATLAB-powered Lego kart!

This project was built in December, 2021, as part of an
experimental attempt to control the motors of a robot made
using the Lego Mindstorms EV3 kit using an Xbox One controller, as
part of the course "MATLAB meets LEGO Mindstorms".

The way that the controller is mapped is specific to the environment
you will be using. In order to remap the controller bindings quickly
and efficiently, I would suggest the following commands:

- `while true; disp(button(joy)); end;`
- `while true; disp(axis(joy)); end;`

Even though we chose not to include the building instructions yet
as a result of a time constraint, the code should be easily
modifiable and used as a point of reference for any project that
uses a controller for MATLAB-related projects. We would also
optimally use [Events](https://de.mathworks.com/help/matlab/events-sending-and-responding-to-messages.html)
instead of an infinite loop, but hey, it works.

## Dependencies

- [RWTH - Mindstorms NXT Toolbox](https://www.mathworks.com/matlabcentral/fileexchange/18646-rwth-mindstorms-nxt-toolbox)
- [Simulink 3D Animation](https://www.mathworks.com/products/3d-animation.html) (alternatively, [HebiRobotics](https://www.mathworks.com/matlabcentral/fileexchange/61276-hebirobotics-hebijoystick))

## Credits

- `Patrick Wendt`
- `fiftyseventh`
