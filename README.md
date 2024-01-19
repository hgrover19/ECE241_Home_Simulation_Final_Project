# ECE241 Home Automation Simulation Final Project
This project was created for ECE241: Digital Systems at UofT on the DE1-SoC FPGA Board, programmed in Verilog using Intel Quartus. In addition, ModelSim was used for simulation, testing and debugging. 

Input is taken from the keys and switches on the board, and output is displayed on a VGA display with output audio. Displayed is a floor plan of a virtual house, and everytime an input is passed, the appropriate change is displayed with image tearing in real-time with audio played for conformation. Audio was sampled at 44.1 kHz at width of 16 bits to ensure clear sound, and converted to a .mif file stored in the on-chip memory for the onboard digital-to-analog converter to interpret.

The following features were implemented for this smart "home":
1. Thermostat
2. Lights On/Off
3. Doors Open/Close

References:
.mif file converter: https://github.com/Louis-He/mif_generator
