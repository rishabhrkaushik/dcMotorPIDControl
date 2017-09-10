# dcMotorPIDControl
Closed loop control for speed of DC motor. Arduino and Processing

Closed loop control system for controlling speed of DC motor. 
Motor is controlled by Arduino which sends PWM signal to Motor driver. Motor driver in turn drives motor. On the shaft of motor a wheel is attached over which a magnet is pasted. Over the assembly a hall effect sensor is mounted which produces an external interrupt whenever the magnet crosses below it. This interrupt signal is used by arduino to calculate current speed of motor and recalculate required PWM value. Arduino communicates via UART with PC ie reading desired speed, new constants values etc and printing all values on serial for debugging and graphing purposes.

The front end GUI is written in Processing which reads serial and plots the graph of speed and PWM value. It also has panel to send new values to arduino. It also stores the readings in a CSV file to plot later.
