# Create a new library
vlib bob

# Compile your Verilog files
vlog hexDisplay.v

# Run the simulation with the top-level module "nf_top_level_module"
vsim hexDisplay

# Add signals to the waveform window
add wave {/*}
log {/*}
# Run the simulation for a specified time

force {select} 0
force {display} 1

force {select} 1
force {display} 1

force {select} 1
force {display} 0

force {select} 0
force {display} 0
