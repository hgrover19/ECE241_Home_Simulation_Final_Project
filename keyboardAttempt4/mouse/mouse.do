# Create a new library
vlib work

# Compile your Verilog files
vlog mouse.v
vlog transmit.v

# Run the simulation with the top-level module "mouse"
vsim mouse

# Add signals to the waveform window
add wave {/*}

# Run the simulation for a specified time
run 100ns

# Alternatively, you can run the simulation indefinitely
# run -all

# Close the simulation
